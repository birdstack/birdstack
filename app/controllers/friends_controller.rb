class FriendsController < ApplicationController
  skip_before_filter :login_required, :only => [:index]

  def index
    @user = User.valid.find_by_login(params[:user]) || (logged_in? ? current_user : nil)

    if @user.nil? then
      unless params[:user].blank? then
        flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
      end
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @friends = @user.friends.find(:all, :order => 'users.login ASC')
  end

  def activity
    @activities = Activity.find(:all, :conditions => {:user_id => current_user.friends}, :order => 'occurred_at DESC', :limit => 25)
  end

  def add
    @friend = User.valid.find_by_id(params[:id])

    if @friend.nil? then
      flash[:warning] = 'Unable to find user with id of "' + params[:id].to_s + '"'
      redirect_to :controller => 'people', :action => 'view', :login => nil
      return
    end

    @friend_request = FriendRequest.new(params[:friend_request])

    return unless request.post?

    @friend_request.user = @friend
    @friend_request.potential_friend = current_user

    return unless @friend_request.save

    flash[:notice] = "Sent friend request to #{@friend.login}"

    redirect_to :controller => 'people', :action => 'view', :login => @friend.login
  end

  def pending
    @friend_requests = current_user.friend_requests
  end

  def destroy
    unless request.post? then
      redirect_to :controller => 'friends', :action => 'index'
      return
    end

    unless(friend = current_user.friends.find_by_id(params[:id])) then
      flash[:warning] = "Unable to find friend with id #{params[:id]}"
      redirect_to :controller => 'friends', :action => 'index'
      return
    end

    # By now, it's valid
    begin
      FriendRelationship.transaction do
        FriendRelationship.destroy_reciprocal_relationship(current_user, friend) or raise "Could not destroy relationship"
      end
    rescue
      flash[:warning] = "Error destroying relationship."
      # TODO should send some sort of error email here
      redirect_to :controller => 'friends', :action => 'index'
      return
    end

    redirect_to :controller => 'friends', :action => 'index'
    return
  end

  def confirm
    unless request.post? then
      redirect_to :controller => 'friends', :action => 'pending'
      return
    end

    unless(fr = current_user.friend_requests.find_by_id(params[:id])) then
      flash[:warning] = "Unable to find friend request with id #{params[:id]}"
      redirect_to :controller => 'friends', :action => 'pending'
      return
    end

    # By now, it's valid
    begin
      FriendRelationship.transaction do
        FriendRelationship.create_reciprocal_relationship(current_user, fr.potential_friend) or raise "Could not create relationship"
        fr.destroy
      end
    rescue
      flash[:warning] = "Error creating relationship."
      # TODO should send some sort of error email here
      redirect_to :controller => 'friends', :action => 'pending'
      return
    end

    redirect_to :controller => 'friends', :action => 'pending'
    return
  end
  
  def ignore
    unless request.post? then
      redirect_to :controller => 'friends', :action => 'pending'
      return
    end

    unless(fr = current_user.friend_requests.find_by_id(params[:id])) then
      flash[:warning] = "Unable to find friend request with id #{params[:id]}"
      redirect_to :controller => 'friends', :action => 'pending'
      return
    end

    # If we got here, it's a valid request
    fr.destroy
    redirect_to :controller => 'friends', :action => 'pending'
    return
  end
end
