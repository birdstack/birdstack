class SightingPhotoController < ApplicationController
  skip_before_filter :login_required, :only => [:view, :paginate]

  def new
    @sighting_photo = SightingPhoto.new
    @sighting = current_user.sightings.find_by_id(params[:sighting_id])
    if @sighting.nil? then
      flash[:warning] = 'Unable to find sighting id ' + params[:sighting_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end
  end

  def create
    unless request.put? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @sighting = current_user.sightings.find_by_id(params[:sighting_id])
    if @sighting.nil? then
      flash[:warning] = 'Unable to find sighting id ' + params[:sighting_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end
    
    # Filter out blank entries
    params[:sighting][:sighting_photo_attributes].delete_if do |k, v|
      v["photo"].blank? && v["title"].blank? && v["description"].blank?
    end

    @sighting.attributes = params[:sighting]

    # Remember which ones have been newly created
    @new_photos = @sighting.sighting_photo.find_all {|p| p.new_record?}

    unless @new_photos.size > 0 && @sighting.save then
      render :new
    else
      @processing_status = SightingPhoto.processing_status_for_user(@new_photos.collect {|np| np.id}, current_user)
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
      @sighting = @user.sightings.find_by_id(params[:sighting_id])
    else
      @sighting = @user.sightings.find_public_by_id(params[:sighting_id], current_user)
    end

    @sighting_photo = @sighting.andand.sighting_photo.andand.find_by_id(params[:id])
    if @sighting_photo.nil? then
      flash[:warning] = 'Unable to find sighting photo id ' + params[:id].to_s
      redirect_to observation_url(:user => params[:user], :id => params[:sighting_id])
      return
    end

    @sighting.publicize!(current_user)
    @sighting_photo.publicize!(current_user)
  end

  def paginate
    user = User.find_by_login(params[:user])
    
    respond_to do |format|
      format.html do
        render :partial => 'paginate', :layout => true, :locals => {:user => user}
      end
      format.js do
        render :update do |page|
          page.replace_html 'sighting-photos', :partial => 'paginate', :locals => {:user => user}
        end
      end
    end
  end

  def edit
    @sighting_photo = current_user.sightings.find_by_id(params[:sighting_id]).andand.sighting_photo.andand.find_by_id(params[:id])
    if @sighting_photo.nil? then
      flash[:warning] = 'Unable to find sighting photo id ' + params[:id].to_s
      redirect_to observation_url(:user => current_user.login, :id => params[:sighting_id])
      return
    end
  end

  def update
    unless request.put? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @sighting = current_user.sightings.find_by_id(params[:sighting_id])
    if @sighting.nil? then
      flash[:warning] = 'Unable to find sighting id ' + params[:sighting_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @sighting_photo = @sighting.sighting_photo.find_by_id(params[:sighting_photo][:id])
    if @sighting_photo.nil? then
      flash[:warning] = 'Unable to find sighting photo id ' + params[:id].to_s
      redirect_to observation_url(:user => current_user.login, :id => params[:sighting_id])
      return
    end

    @sighting_photo.attributes = params[:sighting_photo]
    if(@sighting_photo.save) then
      flash[:notice] = 'Photo updated'
      redirect_to observation_photo_url(:user => @sighting.user.login, :sighting_id => @sighting.id, :id => @sighting_photo.id)
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

    @sighting_photo = current_user.sightings.find_by_id(params[:sighting_id]).andand.sighting_photo.andand.find_by_id(params[:id])
    if @sighting_photo.nil? then
      flash[:warning] = 'Unable to find sighting photo id ' + params[:id].to_s
      redirect_to observation_url(:user => current_user.login, :id => params[:sighting_id])
      return
    end

    @sighting_photo.destroy
    redirect_to observation_url(:user => current_user.login, :id => params[:sighting_id])
  end

  def processing_update
    @type = SightingPhoto
    @processing_status = SightingPhoto.processing_status_for_user(params[:ids], current_user)
    render :partial => 'shared_photo/processing_update'
  end

  def private_photo
    @sighting_photo = SightingPhoto.find_by_id(params[:id])
    if(@sighting_photo.nil? || @sighting_photo.user != current_user) then
      render_404
    else
      send_file @sighting_photo.photo.path(params[:style]),
        :type => @sighting_photo.photo.content_type,
        :dispostion => 'inline',
        :x_sendfile => (defined? ENABLE_XSENDFILE) && ENABLE_XSENDFILE
    end
  end
end
