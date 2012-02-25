class TripPhotoController < ApplicationController
  skip_before_filter :login_required, :only => [:view, :paginate]

  def new
    @trip_photo = TripPhoto.new
    @trip = current_user.trips.find_by_id(params[:trip_id])
    if @trip.nil? then
      flash[:warning] = 'Unable to find trip id ' + params[:trip_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end
  end

  def create
    unless request.put? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @trip = current_user.trips.find_by_id(params[:trip_id])
    if @trip.nil? then
      flash[:warning] = 'Unable to find trip id ' + params[:trip_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end
    
    # Filter out blank entries
    params[:trip][:trip_photo_attributes].delete_if do |k, v|
      v["photo"].blank? && v["title"].blank? && v["description"].blank?
    end

    @trip.attributes = params[:trip]

    # Remember which ones have been newly created
    @new_photos = @trip.trip_photo.find_all {|p| p.new_record?}

    unless @new_photos.size > 0 && @trip.save then
      render :new
    else
      @processing_status = TripPhoto.processing_status_for_user(@new_photos.collect {|np| np.id}, current_user)
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
      @trip = @user.trips.find_by_id(params[:trip_id])
    else
      @trip = @user.trips.find_public_by_id(params[:trip_id], current_user)
    end

    @trip_photo = @trip.andand.trip_photo.andand.find_by_id(params[:id])
    if @trip_photo.nil? then
      flash[:warning] = 'Unable to find trip photo id ' + params[:id].to_s
      redirect_to trip_url(:user => params[:user], :id => params[:trip_id])
      return
    end

    @trip.publicize!(current_user)
    @trip_photo.publicize!(current_user)
  end

  def paginate
    user = User.find_by_login(params[:user])
    
    respond_to do |format|
      format.html do
        render :partial => 'paginate', :layout => true, :locals => {:user => user}
      end
      format.js do
        render :update do |page|
          page.replace_html 'trip-photos', :partial => 'paginate', :locals => {:user => user}
        end
      end
    end
  end

  def edit
    @trip_photo = current_user.trips.find_by_id(params[:trip_id]).andand.trip_photo.andand.find_by_id(params[:id])
    if @trip_photo.nil? then
      flash[:warning] = 'Unable to find trip photo id ' + params[:id].to_s
      redirect_to trip_url(:user => current_user.login, :id => params[:trip_id])
      return
    end
  end

  def update
    unless request.put? then
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @trip = current_user.trips.find_by_id(params[:trip_id])
    if @trip.nil? then
      flash[:warning] = 'Unable to find trip id ' + params[:trip_id].to_s
      redirect_to :controller => 'main', :action => 'index'
      return
    end

    @trip_photo = @trip.trip_photo.find_by_id(params[:trip_photo][:id])
    if @trip_photo.nil? then
      flash[:warning] = 'Unable to find trip photo id ' + params[:id].to_s
      redirect_to trip_url(:user => current_user.login, :id => params[:trip_id])
      return
    end

    @trip_photo.attributes = params[:trip_photo]
    if(@trip_photo.save) then
      flash[:notice] = 'Photo updated'
      redirect_to trip_photo_url(:user => @trip.user.login, :trip_id => @trip.id, :id => @trip_photo.id)
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

    @trip_photo = current_user.trips.find_by_id(params[:trip_id]).andand.trip_photo.andand.find_by_id(params[:id])
    if @trip_photo.nil? then
      flash[:warning] = 'Unable to find trip photo id ' + params[:id].to_s
      redirect_to trip_url(:user => current_user.login, :id => params[:trip_id])
      return
    end

    @trip_photo.destroy
    redirect_to trip_url(:user => current_user.login, :id => params[:trip_id])
  end

  def processing_update
    @type = TripPhoto
    @processing_status = TripPhoto.processing_status_for_user(params[:ids], current_user)
    render :partial => 'shared_photo/processing_update'
  end

  def private_photo
    @trip_photo = TripPhoto.find_by_id(params[:id])
    if(@trip_photo.nil? || @trip_photo.user != current_user) then
      render_404
    else
      send_file @trip_photo.photo.path(params[:style]),
        :type => @trip_photo.photo.content_type,
        :dispostion => 'inline',
        :x_sendfile => (defined? ENABLE_XSENDFILE) && ENABLE_XSENDFILE
    end
  end
end
