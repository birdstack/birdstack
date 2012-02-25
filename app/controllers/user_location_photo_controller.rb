class UserLocationPhotoController < ApplicationController
  skip_before_filter :login_required, :only => [:view, :paginate]

  def new
    @user_location_photo = UserLocationPhoto.new
    @user_location = current_user.user_locations.find_by_id(params[:location_id])
    if @user_location.nil? then
      flash[:warning] = 'Unable to find location id ' + params[:location_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end
  end

  def create
    unless request.put? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @user_location = current_user.user_locations.find_by_id(params[:location_id])
    if @user_location.nil? then
      flash[:warning] = 'Unable to find location id ' + params[:location_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end
    
    # Filter out blank entries
    params[:user_location][:user_location_photo_attributes].delete_if do |k, v|
      v["photo"].blank? && v["title"].blank? && v["description"].blank?
    end

    @user_location.attributes = params[:user_location]

    # Remember which ones have been newly created
    @new_photos = @user_location.user_location_photo.find_all {|p| p.new_record?}

    unless @new_photos.size > 0 && @user_location.save then
      render :new
    else
      @processing_status = UserLocationPhoto.processing_status_for_user(@new_photos.collect {|np| np.id}, current_user)
      render :processing
    end
  end

  def view
    @user = User.find_by_login(params[:user])

    if @user.nil? then
      unless params[:user].blank? then
        flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
      end
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    if @user == current_user then
      @user_location = @user.user_locations.find_by_id(params[:location_id])
    else
      @user_location = @user.user_locations.find_public_by_id(params[:location_id], current_user)
    end

    @user_location_photo = @user_location.andand.user_location_photo.andand.find_by_id(params[:id])
    if @user_location_photo.nil? then
      flash[:warning] = 'Unable to find location photo id ' + params[:id].to_s
      redirect_to location_url(:user => params[:user], :id => params[:location_id])
      return
    end

    @user_location.publicize!(current_user)
    @user_location_photo.publicize!(current_user)
  end

  def paginate
    user = User.find_by_login(params[:user])
    
    respond_to do |format|
      format.html do
        render :partial => 'paginate', :layout => true, :locals => {:user => user}
      end
      format.js do
        render :update do |page|
          page.replace_html 'user-location-photos', :partial => 'paginate', :locals => {:user => user}
        end
      end
    end
  end

  def edit
    @user_location_photo = current_user.user_locations.find_by_id(params[:location_id]).andand.user_location_photo.andand.find_by_id(params[:id])
    if @user_location_photo.nil? then
      flash[:warning] = 'Unable to find location photo id ' + params[:id].to_s
      redirect_to location_url(:user => current_user.login, :id => params[:location_id])
      return
    end
  end

  def update
    unless request.put? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @user_location = current_user.user_locations.find_by_id(params[:location_id])
    if @user_location.nil? then
      flash[:warning] = 'Unable to find location id ' + params[:location_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @user_location_photo = @user_location.user_location_photo.find_by_id(params[:user_location_photo][:id])
    if @user_location_photo.nil? then
      flash[:warning] = 'Unable to find location photo id ' + params[:id].to_s
      redirect_to location_url(:user => current_user.login, :id => params[:location_id])
      return
    end

    @user_location_photo.attributes = params[:user_location_photo]
    if(@user_location_photo.save) then
      flash[:notice] = 'Photo updated'
      redirect_to location_photo_url(:user => @user_location.user.login, :location_id => @user_location.id, :id => @user_location_photo.id)
      return
    else
      render :edit
    end
  end

  def destroy
    unless request.delete? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @user_location_photo = current_user.user_locations.find_by_id(params[:location_id]).andand.user_location_photo.andand.find_by_id(params[:id])
    if @user_location_photo.nil? then
      flash[:warning] = 'Unable to find location photo id ' + params[:id].to_s
      redirect_to location_url(:user => current_user.login, :id => params[:location_id])
      return
    end

    @user_location_photo.destroy
    redirect_to location_url(:user => current_user.login, :id => params[:location_id])
  end

  def processing_update
    @type = UserLocationPhoto
    @processing_status = UserLocationPhoto.processing_status_for_user(params[:ids], current_user)
    render :partial => 'shared_photo/processing_update'
  end

  def private_photo
    @user_location_photo = UserLocationPhoto.find_by_id(params[:id])
    if(@user_location_photo.nil? || @user_location_photo.user != current_user) then
      render_404
    else
      send_file @user_location_photo.photo.path(params[:style]),
        :type => @user_location_photo.photo.content_type,
        :dispostion => 'inline',
        :x_sendfile => (defined? ENABLE_XSENDFILE) && ENABLE_XSENDFILE
    end
  end
end
