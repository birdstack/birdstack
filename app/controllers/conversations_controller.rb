class ConversationsController < ApplicationController
  def index
    # Show only messages we didn't send
    @message_references = current_user.message_references.paginate(:conditions => ['messages.user_id != ?', current_user.id], :include => :message, :order => 'message_references.created_at DESC', :page => params[:page]);

    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html 'inbox', :partial => 'inbox', :locals => { :message_references => @message_references }
        end
      end
    end
  end

  def sent
    # Show only messages we sent
    @message_references = current_user.message_references.paginate(:conditions => ['messages.user_id = ?', current_user.id], :include => :message, :order => 'message_references.created_at DESC', :page => params[:page]);

    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html 'sent', :partial => 'sent', :locals => { :message_references => @message_references }
        end
      end
    end
  end

  def modify
    MessageReference.transaction do
      if(params[:message_references]) then
        params[:message_references].each do |mr,notused|
          current_user.message_references.find(mr).destroy
        end
      end
    end

    if(params[:go] == 'inbox') then
      redirect_to :action => 'index'
    elsif(params[:go] == 'sent') then
      redirect_to :action => 'sent'
    else
      redirect_to :action => 'index'
    end
  end

  def start
    @conversation = Conversation.new(params[:conversation])
    @message = Message.new(params[:message])
    
    return if params[:commit] == 'Preview' or !request.post?

    Conversation.transaction do
      # Have to add our user here so that they don't show up in the text list
      @conversation.additional_users = [current_user]
      return unless @conversation.save

      @message.conversation = @conversation
      @message.user = current_user
      return unless @message.save
    end

    flash[:notice] = "Message sent"

    redirect_to :action => :index
  end

  def reply
    @conversation = current_user.conversations.find_by_id(params[:id])
    unless @conversation then
      flash[:warning] = "Could not find conversation id #{params[:id]}"
      redirect_to :action => 'index'
      return
    end

    @message = Message.new(params[:message])
    
    return if params[:commit] == 'Preview' or !request.post?

    @message.conversation = @conversation
    @message.user = current_user

    return unless @message.save

    flash[:notice] = "Message sent"

    redirect_to :action => :view, :id => @conversation.id, :anchor => @message.id
  end

  def view
    @conversation = current_user.conversations.find_by_id(params[:id])
    unless @conversation then
      flash[:warning] = "Could not find conversation id #{params[:id]}"
      redirect_to :action => 'index'
      return
    end

    # Viewing the conversation means you've read all the messages
    @conversation.messages.each do |m|
      changed_read = false

      current_user.message_references.find(:all, :conditions => {:message_id => m.id}).each do |mr|
        unless mr.read then
          changed_read = true
          mr.skip_update = true
          mr.read = true
          mr.save!
        end
      end

      if(changed_read) then
        MessageReference.update_cache(current_user)
      end
    end
  end
end
