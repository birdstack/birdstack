class TripController < ApplicationController
	skip_before_filter :login_required, :only => [:view, :index]
	
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
			@trip = @user.trips.find_by_id(params[:id])
			@branch = Trip.branch(@trip.root) if @trip
		else
			@trip = @user.trips.find_public_by_id(params[:id], current_user)
			@branch = Trip.public_branch(@trip.root, current_user) if @trip
		end
	end

	def index
		@user = User.find_by_login(params[:user]) || (logged_in? ? current_user : nil)

		if @user.nil? then
			unless params[:user].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
			end
			redirect_to :controller => 'main', :action => 'index'
			return
		end
		
		if @user == current_user then
			@trips = @user.trips.find(:all, :order => 'trips.lft')
		else
			@trips = Trip.find_public_by_user(@user, current_user, :order => 'trips.lft')
		end
	end

	def delete
		@trip = current_user.trips.find_by_id(params[:id])

		unless request.post? and @trip then
			redirect_to trips_url(:user => current_user.login)
			return
		end

		if @trip.sightings.size > 0 or @trip.descendants.size > 0 then
			flash[:warning] = "The trip \"#{@trip.name}\" cannot be deleted until there are no observations associated with it and no subtrips."
			redirect_to trip_url(:id => params[:id], :user => current_user.login)
			return
		end

                begin
                  @trip.destroy

                  flash[:notice] = 'Successfully deleted trip ' + @trip.name

                  redirect_to trips_url(:user => current_user.login)
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

	def add
		@trip = Trip.new(params[:trip])
		@trip.user = current_user

		# On this, we have to check the param passed in.  The form will always return a value.
		# If the param is blank, that means the form hasn't been submitted yet.
		if params[:trip].blank? or params[:trip][:private].blank? then
			if current_user.default_trip_private then
				@trip.private = true
			end
		end

		add_or_edit
	end

	def edit
		@trip = current_user.trips.find_by_id(params[:id])

		unless @trip then
			redirect_to trips_url(:user => current_user.login)
			return
		end

                merge_edit_attributes

		add_or_edit
	end

	protected
	
	def add_or_edit
          @trips = current_user.trips.find(:all, :order => 'lft')

          params[:prefill] ||= {}

          # In case we've been redirected here from the create sighting page
          @sighting = current_user.sightings.find_by_id(params[:prefill][:sighting])

          return unless request.post?

          # These need to succeed in this order or not at all
          begin
            Trip.transaction do
              @trip.save! if @trip.new_record? # If it's new, we can't move it until it's saved
              begin
                if params[:trip] and params[:trip][:parent_id] != (@trip.parent ? @trip.parent.id.to_s : '') then
                  if params[:trip][:parent_id] == '' then
                    @trip.move_to_right_of(@trip.root.id) 
                  else
                    @trip.move_to_child_of(params[:trip][:parent_id]) 
                  end
                end
              rescue
                @trip.errors.add(:parent_id, 'could not be changed')
                raise
              end
              # We need to do this again in case the move_to_child_of went to an invalid parent
              # this is the only way to check against that possibility

              # We also need to remerge the attributes the user passed in because moving the trip
              # removed our changes
              @trip.reload
              merge_edit_attributes
              @trip.save!
            end
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
          rescue
            if @trip.errors.empty? then
              # An error occurred that we didn't expect
              raise
            end
            # Display errors
            return
          end

          if @sighting then
            debugger
            saved = false
            begin
              @sighting.trip = @trip
              saved = @sighting.save
            rescue ActiveRecord::StaleObjectError
              # Apparently our sighting has become stale.  Just give it a reload and it we'll try once more.
              # If we fail this time, we fail for reals.
              @sighting.reload
              @sighting.trip = @trip
              saved = @sighting.save
            end
            unless saved then
              flash[:warning] = 'This observation could not be added to the trip "' + @trip.name + '".  Please ensure that the date of the observation falls within the date range of the trip and try again.'
              redirect_to :controller => 'sighting', :action => 'edit', :id => @sighting.id
              return
            end
          end

          params[:prefill][:trip] = @trip.id

          if !params[:prefill][:pending_import].blank? then
            redirect_to :controller => 'import', :action => 'pending', :id => params[:prefill][:pending_import]
            return
          elsif params[:action] == 'add' then
            redirect_to :controller => 'sighting', :action => 'select_species', :prefill => params[:prefill]
            return
          else
            redirect_to trip_url(:user => @trip.user.login, :id => @trip.id)
            return
          end
	end

        private

        def merge_edit_attributes
		@trip.attributes = params[:trip]

		# TODO This is a hack so that some value will show.  We need user preferences
		@trip.distance_traveled ||= @trip.distance_traveled_km
		@trip.area_covered ||= @trip.area_covered_sqkm
        end
end
