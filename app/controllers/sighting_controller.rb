class SightingController < ApplicationController
	skip_before_filter :login_required, :only => [:view]

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
			@sighting = @user.sightings.find_by_id(params[:id])
		else
			@sighting = @user.sightings.find_public_by_id(params[:id], current_user)
		end
	end

	def select_species
		@trip = current_user.trips.find_by_id(params[:prefill][:trip]) if params[:prefill]
		@location = current_user.user_locations.find_by_id(params[:prefill][:location]) if params[:prefill]

		# If we're starting here, we don't want to prefill a sighting.  That would be silly.  Ditto for species
		params[:prefill] ||= {}
		params[:prefill][:sighting] = nil
		params[:prefill][:species] = nil
	end

	def notification
		@notification = Notification.find_by_id(params[:id])

		if current_user.ignored_notifications.find_by_notification_id(@notification.id) then
			redirect_to :action => 'add', :id => @notification.species.id, :prefill => params[:prefill]
			return
		end

		params[:prefill] ||= {}
		unless @notification
			redirect_to :controller => 'sighting', :action => 'add', :id => params[:prefill][:species]
			return
		end

		return unless request.post?

		if params[:ignore] then
			ignored_notification = IgnoredNotification.new
			ignored_notification.user = current_user
			ignored_notification.notification = @notification
			ignored_notification.save!
		end

		species = Species.find_by_id(params[:species])

		redirs_for_select_species_or_notification(species)
	end

	def alternate_name
		@alternate_names = AlternateName.find_all_valid_by_exact_name(params[:id])

		params[:prefill] ||= {}
		unless @alternate_names.size > 0
			redirect_to :controller => 'sighting', :action => 'add', :id => params[:prefill][:species]
			return
		end
	end

	def add
		if(params[:id]) then
			species = Species.find_valid_by_id(params[:id])
		end

		unless species then
			redirect_to :action => 'index'
			return
		end

		params[:prefill] ||= {}

		@sighting = Sighting.new(params[:sighting])

		# Prefill if the user didn't submit anything
		unless params[:sighting] then
			if params[:prefill][:pending_import] then
				pending_import = current_user.pending_imports.find_by_id(params[:prefill][:pending_import])
				pending_import_item = pending_import.pending_import_items.find_by_id(params[:prefill][:pending_import_item]) if pending_import
				if pending_import_item then
					pending_import_item.realize_without_save
					@sighting = pending_import_item.sighting if pending_import_item.sighting
				end
			end

			if(params[:prefill][:trip]) then
				trip = current_user.trips.find_by_id(params[:prefill][:trip])
				@sighting.trip ||= trip if trip
			end

			if(params[:prefill][:location]) then
				user_location = current_user.user_locations.find_by_id(params[:prefill][:location])
				@sighting.user_location ||= user_location if user_location
			end

			# If they're in a single-day trip, go ahead and prefill the date for them
			if(@sighting.trip and !@sighting.trip.date_start.nil? and !@sighting.trip.date_end.nil? and @sighting.trip.date_end == @sighting.trip.date_start) then
				@sighting.date_year ||= @sighting.trip.date_year_start
				@sighting.date_month ||= @sighting.trip.date_month_start
				@sighting.date_day ||= @sighting.trip.date_day_start
			end

			# Prefill date
			@sighting.date_year ||= params[:prefill][:date_year]
			@sighting.date_month ||= params[:prefill][:date_month]
			@sighting.date_day ||= params[:prefill][:date_day]

			# Prefill privacy
			if current_user.default_observation_private then
				@sighting.private = true
			else
				@sighting.private = params[:prefill][:private]
			end
		end

		# These settings /always/ trump any prefill
		# Import in particular may override them if they are placed earlier
		@sighting.user = current_user
		@sighting.species = species

		add_or_edit
	end

	def edit
		@sighting = current_user.sightings.find_by_id(params[:id])

		unless @sighting then
			redirect_to :action => 'index'
			return
		end

		@sighting.attributes = params[:sighting]

		add_or_edit
	end

	def delete
		@sighting = current_user.sightings.find_by_id(params[:id])

		unless request.post? and @sighting then
                  redirect_to :controller => 'sighting', :action => 'index'
                  return
                end

                begin
                  @sighting.destroy
                  redirect_to :controller => 'sighting', :action => 'index'
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


	def species_english_search
		params[:prefill] ||= {}

		# First check for exact matches
		exact_match = false
		species = nil
		if params[:id] and species = Species.find_valid_by_id(params[:id]) then
			exact_match = true
		elsif params[:species_english_name] and species = Species.find_valid_by_exact_english_name(params[:species_english_name])
			exact_match = true
		end

		if exact_match then
			if species.notification and !current_user.ignored_notifications.find_by_notification_id(species.notification.id) then
				redirect_to :controller => :sighting, :action => 'notification', :id => species.notification.id, :prefill => params[:prefill]
				return
			end

			redirs_for_select_species_or_notification(species)
			return
		end

		# Then for exact alternate name
		if params[:species_english_name] and (AlternateName.find_all_valid_by_exact_name(params[:species_english_name]).size > 0) then
			redirect_to :controller => :sighting, :action => 'alternate_name', :id => Birdstack::search_version(params[:species_english_name]), :prefill => params[:prefill]
		end

		# Then do a real search
		@ioc_search = IocSearch.new(:term => params[:species_english_name])

		return unless @ioc_search.valid?

		@results = @ioc_search.search_species_english

		@sighting = current_user.sightings.find_by_id(params[:prefill][:sighting])
		@trip = current_user.trips.find_by_id(params[:prefill][:trip])
		@location = current_user.user_locations.find_by_id(params[:prefill][:location])
	end

        caches_page :auto_complete_for_species_english_name
	def auto_complete_for_species_english_name
		@species_count, @species = Species.find_and_count_valid_by_english(params[:species_english_name], 10, {:order => 'length(english_name), english_name ASC'})

		if @species.size < 10 then
			@alternate_names = AlternateName.find_unique_valid_by_name(params[:species_english_name], 10-@species.size, {:order => 'length(name), name ASC'})
		end

		if @species.size == 0 and @alternate_names.size == 0 then
			@spell_check_search = Species.find_by_spell_check(params[:species_english_name])
		end

		render :partial => 'auto_complete_for_species_english_name'
	end

	private
	
	def add_or_edit
		return unless request.post?

		params[:prefill] ||= {}
		params[:prefill][:trip] = params[:sighting][:trip_id]
		params[:prefill][:location] = params[:sighting][:user_location_id]

		@trip = current_user.trips.find_by_id(params[:prefill][:trip])
		@location = current_user.user_locations.find_by_id(params[:prefill][:location])

		search_species = false

		@species_english_name = params[:species_english_name]
		if !@species_english_name.blank? then
			species_count, species = Species.find_and_count_valid_by_english(@species_english_name, nil)

			if(species_count == 1)
				@sighting.species = species.first
			else
				search_species = true
			end
		end

		if @sighting.user_location_id == 0 then
			# We don't actually want to save with 0
			# it'd cause a foreign key error anyway
			@sighting.user_location_id = nil
		end

		if @sighting.trip_id == 0 then
			# We don't actually want to save with 0
			# it'd cause a foreign key error anyway
			@sighting.trip_id = nil
		end

                pending_import_item = nil
		if params[:prefill][:pending_import] then
                  pending_import = current_user.pending_imports.find_by_id(params[:prefill][:pending_import])
                  if pending_import then
                    pending_import_item = pending_import.pending_import_items.find_by_id(params[:prefill][:pending_import_item]) if pending_import

                    # Retain ebird exclusion flag from import
                    @sighting.ebird_exclude = pending_import.ebird_exclude
                  end
                end

                begin
                  unless @sighting.save then
                          # If we failed, reset it back to the fake 0 value
                          # so the form retains state
                          @sighting.user_location_id = params[:prefill][:location]
                          @sighting.trip_id = params[:prefill][:trip]
                          return
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
                end

		if params[:action] == 'edit' then
			flash[:notice] = "Observation for #{@sighting.species.english_name} successfully edited."
		elsif params[:action] == 'add' then
			flash[:notice] = "Observation for #{@sighting.species.english_name} successfully added."
		end

		params[:prefill][:sighting] = @sighting.id
		params[:prefill][:date_year] = @sighting.date_year
		params[:prefill][:date_month] = @sighting.date_month
		params[:prefill][:date_day] = @sighting.date_day
		params[:prefill][:private] = @sighting.private

		# If we did this from an import item, we can now delete it
                pending_import_item.andand.destroy

		if search_species then
			redirect_to :controller => 'sighting', :action => 'species_english_search', :species_english_name => @species_english_name, :prefill => params[:prefill]
			return
		elsif !params[:prefill][:location].blank? and params[:prefill][:location].to_i == 0 then
			redirect_to :controller => :location, :action => :add, :prefill => params[:prefill]
			return
		elsif !params[:prefill][:trip].blank? and params[:prefill][:trip].to_i == 0 then
			redirect_to :controller => :trip, :action => :add, :prefill => params[:prefill]
			return
		elsif !params[:prefill][:pending_import].blank? then
			redirect_to :controller => 'import', :action => 'pending', :id => params[:prefill][:pending_import]
			return
		elsif params[:action] != 'edit' and (!params[:prefill][:trip].blank? or !params[:prefill][:location].blank?) then
			redirect_to :controller => :sighting, :action => 'select_species', :prefill => params[:prefill]
			return
		else
			redirect_to observation_url(:user => current_user.login, :id => @sighting.id)
			return
		end
	end

	private

	def redirs_for_select_species_or_notification(species)
		params[:prefill] ||= {}

		unless(species) then
			redirect_to :action => 'select_species', :prefill => params[:prefill]
			return
		end

		params[:prefill][:species] = species.id

                # We might have gotten here after a user wanted to select a new species for their sighting
                # but because they didn't type in an exact match, they were sent to the search page
                # with the params[:prefill][:sighting] filled out.  See #add_or_edit.
		sighting = current_user.sightings.find_by_id(params[:prefill][:sighting])

		if sighting then
			sighting.species = species
			sighting.save or flash[:warning] = 'Unable to associate new species with sighting ID ' + sighting.id.to_s

			if params[:prefill][:location] == 0 then
				redirect_to :controller => :location, :action => :add, :prefill => params[:prefill]
				return
			elsif params[:prefill][:trip] == 0 then
				redirect_to :controller => :trip, :action => :add, :prefill => params[:prefill]
				return
			else
				# This means they just wanted to edit
				redirect_to observation_url(:user => sighting.user.login, :id => sighting.id)
				return
			end
		else
			redirect_to :controller => :sighting, :action => :add, :id => species.id, :prefill => params[:prefill]
			return
		end
	end
end
