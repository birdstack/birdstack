class PeopleController < ApplicationController
	skip_before_filter :login_required, :except => [:edit, :account]

	# We don't have a dedicated page for observations, so redir them to the profile
	def redir_to_profile
		redirect_to :controller => 'people', :action => 'view', :user => params[:user]
	end

	alias :observations :redir_to_profile

        def photos
          @user = User.valid.find_by_login(params[:login])

          if @user.nil? then
            unless params[:login].blank? then
              flash[:warning] = 'Unable to find user with login of "' + params[:login].to_s + '"'
            end
            redirect_to :controller => 'people', :action => 'view', :login => nil
            return
          end
        end

	def view
		if params[:login].blank?
			@recent = User.find_recently_activated(10)
			@top = User.find_top_contributors(10)
			@random = User.find_random(3)
			@tags = User.tag_counts(:limit => 20, :order => 'count DESC').sort {|a,b| a.name.downcase <=> b.name.downcase }
                        @activities = Activity.find(:all, :limit => 10, :order => 'occurred_at DESC')

			render :action => 'people'
			return
		end

		@user = User.valid.find_by_login(params[:login])

		if @user.nil? then
			unless params[:login].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:login].to_s + '"'
			end
			redirect_to :controller => 'people', :action => 'view', :login => nil
			return
		end

		@saved_searches = SavedSearch.find_public_by_user(@user, current_user, :order => 'saved_searches.created_at DESC', :limit => 10)

		@tags = @user.sightings.tag_counts(:limit => 10, :order => 'count DESC', :conditions => 'sightings.private = 0').sort {|a,b| a.name.downcase <=> b.name.downcase }

                @activities = @user.activities.non_photo.find(:all, :order => 'occurred_at DESC', :limit => 7)
                @photo_activities = @user.activities.photo.find(:all, :order => 'occurred_at DESC', :limit => 3)
	end

	def edit
		@user = User.find_by_login(params[:login])
		unless @user == current_user then
			flash[:warning] = 'Cannot edit users other than yourself!'
			redirect_to :controller => 'main', :action => 'index'
		end

		@countries = CountryCode.find(:all, :order => 'name ASC')

		return unless request.post?

		if params[:user] then
			# In this case, if the field is blank, we want to store it as NULL, not blank
			params[:user] = params[:user].each_pair {|k, v| params[:user][k] = v.blank? ? nil : v }

                        if params[:profile_pic_delete] then
                          params[:user].delete(:profile_pic)
                          @user.profile_pic.clear
                        end

			@user.attributes = params[:user]
		end

                @user.save
	end

	def account
		@user = User.find_by_login(params[:login])
		unless @user == current_user then
			flash[:warning] = 'Cannot edit users other than yourself!'
			redirect_to :controller => 'main', :action => 'index'
		end

		return unless request.post?

		# We don't want to update unless the user actually changed something
		updates = {}
		if !params[:user][:password].blank? or !params[:user][:password_confirmation].blank? then
			updates[:password] = params[:user][:password]
			updates[:password_confirmation] = params[:user][:password_confirmation]
		end
		if (!params[:user][:email].blank? and (params[:user][:email] != @user.email)) or !params[:user][:email_confirmation].blank? then
			updates[:email] = params[:user][:email]
			updates[:email_confirmation] = params[:user][:email_confirmation]
		end

		[:default_trip_private, :default_user_location_private, :default_observation_private, :time_zone, :time_24_hr, :time_day_first, :default_photo_license, *User::NOTIFICATION_TYPES.keys].each do |k|
			updates[k] = params[:user][k]
		end

		return unless @user.update_attributes(updates)

		flash[:notice] = 'Account changes saved'
		redirect_to :controller => 'people', :action => 'view', :login => @user.login
	end
end
