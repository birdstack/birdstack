class TagsController < ApplicationController
	skip_before_filter :login_required

	def observations_tags
		@user = User.find_by_login(params[:user])

		if @user.nil? then
			unless params[:user].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
			end
			redirect_to :controller => 'main', :action => 'index'
			return
		end

		if @user == current_user then
			@tags = @user.sightings.tag_counts(:order => 'tags.name')
		else
			@tags = @user.sightings.tag_counts(:order => 'tags.name', :conditions => 'sightings.private = 0')
		end
	end

	def observations_tag
		@user = User.find_by_login(params[:user])

		if @user.nil? then
			unless params[:user].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
			end
			redirect_to :controller => 'main', :action => 'index'
			return
		end

		@tag = params[:id]
	end
end
