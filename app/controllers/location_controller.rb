class LocationController < ApplicationController
	skip_before_filter :login_required, :only => [:index, :view]

	def index
		@user = User.find_by_login(params[:user]) || (logged_in? ? current_user : nil)

		if @user.nil? then
			unless params[:user].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
			end
			redirect_to :controller => 'main', :action => 'index'
			return
		end

		joins = 'LEFT OUTER JOIN country_codes ON user_locations.cc = country_codes.cc'
		order = "ISNULL(country_codes.name) ASC, country_codes.name ASC, user_locations.cc ASC, IFNULL(user_locations.adm1, '') = '' ASC, user_locations.adm1 ASC, IFNULL(user_locations.adm2, '') = '' ASC, user_locations.adm2, user_locations.name ASC"
		
		if @user == current_user then
			@locations = @user.user_locations.find(:all, :order => order, :joins => joins)
		else
			@locations = UserLocation.find_public_by_user(@user, current_user, :order => order, :joins => joins)
		end
	end

	def view
		@user = User.find_by_login(params[:user]) || (logged_in? ? current_user : nil)

		if @user.nil? then
			unless params[:user].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
			end
			redirect_to :controller => 'main', :action => 'index'
			return
		end
		
		if @user == current_user then
			@location = @user.user_locations.find_by_id(params[:id])
		else
			@location = @user.user_locations.find_public_by_id(params[:id], current_user)
		end
	end

        caches_page :auto_complete_for_adm1
	def auto_complete_for_adm1
		@adm1s_count = 0
		@adm1s = []

		if(!params[:adm1].blank? and !params[:cc].blank?) then
			@adm1s_count = Adm1.count(:all, :conditions => [ 'name LIKE ? AND cc = ?', '%' + params[:adm1] + '%', params[:cc] ])
			@adm1s = Adm1.find(:all, :conditions => [ 'name LIKE ? AND cc = ?', '%' + params[:adm1] + '%', params[:cc] ], :order => 'length(name), name ASC', :limit => 10)
		end

		render :partial => 'auto_complete_for_adm1'
	end

        caches_page :auto_complete_for_adm2
	def auto_complete_for_adm2
		@adm2s = []
		@adm2s_count = 0

		if(!params[:cc].blank? and !params[:adm2].blank?) then
			adm1 = nil
			adm1 = Adm1.find(:first, :conditions => [ 'name LIKE ? AND cc = ?', params[:adm1], params[:cc] ]) if !params[:adm1].blank?

			if !adm1.nil? then
				@adm2s_count = Adm2.count(:all, :conditions => [ "name LIKE ? AND cc = ? AND (adm1 = '00' OR adm1 = ?)", '%' + params[:adm2] + '%', params[:cc], adm1.adm1 ])
				@adm2s = Adm2.find(:all, :conditions => [ "name LIKE ? AND cc = ? AND (adm1 = '00' OR adm1 = ?)", '%' + params[:adm2] + '%', params[:cc], adm1.adm1 ], :order => 'length(name), name ASC', :limit => 10)
			else
				@adm2s_count = Adm2.count(:all, :conditions => [ 'name LIKE ? AND cc = ?', '%' + params[:adm2] + '%', params[:cc] ])
				@adm2s = Adm2.find(:all, :conditions => [ 'name LIKE ? AND cc = ?', '%' + params[:adm2] + '%', params[:cc] ], :order => 'length(name), name ASC', :limit => 10)
			end
		end

		render :partial => 'auto_complete_for_adm2'
	end

        caches_page :auto_complete_for_location
	def auto_complete_for_location
		@locations = []
		@locations_count = 0

		if(!params[:cc].blank? and !params[:location].blank?) then
			adm1 = nil
			adm1 = Adm1.find(:first, :conditions => [ 'name LIKE ? AND cc = ?', params[:adm1], params[:cc] ]) if !params[:adm1].blank?

			if !adm1.nil? then
				@locations_count = Location.count(:all, :conditions => [ "name LIKE ? AND cc = ? AND (adm1 = '00' OR adm1 = ?)", '%' + params[:location] + '%', params[:cc], adm1.adm1 ])
				@locations = Location.find(:all, :conditions => [ "name LIKE ? AND cc = ? AND (adm1 = '00' OR adm1 = ?)", '%' + params[:location] + '%', params[:cc], adm1.adm1 ], :order => 'length(name), name ASC', :limit => 10)
			else
				@locations_count = Location.count(:all, :conditions => [ 'name LIKE ? AND cc = ?', '%' + params[:location] + '%', params[:cc] ])
				@locations = Location.find(:all, :conditions => [ 'name LIKE ? AND cc = ?', '%' + params[:location] + '%', params[:cc] ], :order => 'length(name), name ASC', :limit => 10)
			end
		end

		render :partial => 'auto_complete_for_location'
	end


	def delete
		@location = current_user.user_locations.find_by_id(params[:id])

		unless request.post? and @location then
			redirect_to locations_url(:user => current_user.login)
			return
		end

		if @location.sightings.size > 0 then
			flash[:warning] = "The location \"#{@location.name}\" cannot be deleted until there are no observations associated with it."
			redirect_to location_url(:id => params[:id], :user => current_user.login)
			return
		end

                begin
                  @location.destroy
                  flash[:notice] = 'Successfully deleted location ' + @location.name

                  redirect_to locations_url(:user => current_user.login)
                rescue ActiveRecord::StaleObjectError
                  if @rescued_stale_object then
                    raise
                  else
                    logger.warn("Rescuing StaleObjectError for #{params[:action]}")
                    @rescued_stale_object = true
                    return delete
                  end
                end
	end

	def merge
		@location = current_user.user_locations.find_by_id(params[:id])
		@new_location = current_user.user_locations.find_by_id(params[:new_location])

		unless request.post? and @location and @new_location then
			flash[:notice] = 'Error merging location'
			redirect_to locations_url(:user => current_user.login)
			return
		end

		if @location.merge_into(@new_location) then
			flash[:notice] = 'Successfully merged location ' + @location.name + ' into ' + @new_location.name
		else
			flash[:warning] = 'Error merging location ' + @location.name + ' into ' + @new_location.name
		end

		redirect_to locations_url(:user => current_user.login)
	end

	def add
		location_params = {}
		# Merge in any parameters from an existing location that the user wants to base their new location on
		if params[:from] then
			from_location = UserLocation.find_public_by_id(params[:from], current_user)
			if from_location and from_location.user != current_user then
				location_params.merge!(UserLocation.find_public_by_id(params[:from], current_user).publicize!(current_user).attributes)
			else
				flash.now[:warning] = 'Invalid source location'
			end
		end
		# Merge in form parameters last because they get priority
		location_params.merge!(params[:user_location] || {})

		@user_location = UserLocation.new(location_params)
		@user_location.user = current_user

		# On this, we have to check the param passed in.  The form will always return a value.
		# If the param is blank, that means the form hasn't been submitted yet.
		if params[:user_location].blank? or params[:user_location][:private].blank? then
			if current_user.default_user_location_private then
				@user_location.private = current_user.default_user_location_private
			end
		end

		add_or_edit
	end

	def edit
		@user_location = current_user.user_locations.find_by_id(params[:id])

		unless @user_location then
			redirect_to :action => 'index'
			return
		end

		@user_location.attributes = params[:user_location]

		# TODO This is a hack so that some value will show.  We need user preferences
		@user_location.elevation ||= @user_location.elevation_m

		add_or_edit
	end
	
	protected

	def add_or_edit
		@countries = CountryCode.find(:all, :order => 'name ASC')

		params[:prefill] ||= {}
		# Have to carry this info across in case we're in the middle of the big scary workflow
		@sighting = current_user.sightings.find_by_id(params[:prefill][:sighting])

		return unless request.post?

                begin
                  return unless @user_location.save
                rescue ActiveRecord::StaleObjectError
                  if @rescued_stale_object then
                    raise
                  else
                    logger.warn("Rescuing StaleObjectError for #{params[:action]}")
                    @rescued_stale_object = true
                    if params[:action] == 'add' then
                      return add
                    elsif params[:action] == 'edit' then
                      return edit
                    else
                      raise "Unknown action!"
                    end
                  end
                end

		if(@sighting) then
			@sighting.user_location = @user_location
			success = @sighting.save
			unless success then
				flash[:warning] = 'Unable to associate new location with sighting ID ' + @sighting.id.to_s
			end
		end

		# Now we decide where to redirect for
		
		params[:prefill][:location] = @user_location.id

		if !params[:prefill][:trip].blank? and params[:prefill][:trip].to_i == 0 then
			redirect_to :controller => 'trip', :action => 'add', :prefill => params[:prefill]
			return
		elsif !params[:prefill][:pending_import].blank? then
			redirect_to :controller => 'import', :action => 'pending', :id => params[:prefill][:pending_import]
			return
		elsif params[:action] == 'add' then
			redirect_to :controller => 'sighting', :action => 'select_species', :prefill => params[:prefill]
			return
		else
			redirect_to location_url(:user => @user_location.user.login, :id => @user_location.id)
			return
		end
	end
end
