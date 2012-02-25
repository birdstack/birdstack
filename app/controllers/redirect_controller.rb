class RedirectController < ApplicationController
	skip_before_filter :login_required

	def main
		redirect_to main_path(:action => params[:mainaction], :id => params[:mainid]), :status => 301
	end

	def sighting
		redirect_to :controller => 'sighting', :action => params[:sightingaction], :id => params[:sightingid], :status => 301
	end

	# This works only when someone is logged in
	def people
		if logged_in? then
			redirect_to "/people/#{current_user.login}/#{params[:peoplecontroller]}/#{params[:peopleaction]}", :status => 301
		else
			redirect_to '/', :status => 301
		end
	end
end
