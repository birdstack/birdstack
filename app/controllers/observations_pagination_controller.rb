class ObservationsPaginationController < ApplicationController
	skip_before_filter :login_required

	# This controller is a bit weird because all the work is done in the views.  This is so we can render the first
	# time as a partial being called from another controller and the second time as its own request being called
	# from this controller.  Putting all the logic in the view prevents duplicated code at the cost of breaking
	# MVC abstraction.

	# Note that for this one, we always publicize for :false, to present a public view at all times
	def user
		respond_to do |format|
			format.html do
				render :partial => 'user_observations', :layout => true, :locals => {:publicize_for => :false}
			end
			format.js do
				render :update do |page|
					page.replace_html 'sightings', :partial => 'user_observations', :locals => {:publicize_for => :false}
				end
			end
		end
	end

	# This one is just all kinds of different
	def species_map
		respond_to do |format|
			format.html do
				# In case of a non-ajax load, we just need to redir because this is primarily
				# for showing AJAX stuff.  There's no HTML table or anything that would load.
				if params[:id] and Species.find_by_id(params[:id]) then
					species = Species.find_by_id(params[:id])
					redirect_to :controller => :ioc,
						:order => species.genus.family.order.latin_name.downcase,
						:family => species.genus.family.latin_name.downcase,
						:genus => species.genus.latin_name.downcase,
						:species => species.latin_name.downcase, 
						:action => :species
				else
					redirect_to :controller => 'ioc'
				end
			end
			format.js do
				render :update do |page|
					page.replace_html 'species_map', :partial => 'species_map'
				end
			end
		end
	end

	def tag
		respond_to do |format|
			format.html do
				render :partial => 'tag_observations', :layout => true
			end
			format.js do
				render :update do |page|
					page.replace_html 'sightings', :partial => 'tag_observations'
				end
			end
		end
	end

	def trip
		respond_to do |format|
			format.html do
				render :partial => 'trip_observations', :layout => true
			end
			format.js do
				render :update do |page|
					page.replace_html 'sightings', :partial => 'trip_observations'
				end
			end
		end
	end

	def location
		respond_to do |format|
			format.html do
				render :partial => 'location_observations', :layout => true
			end
			format.js do
				render :update do |page|
					page.replace_html 'sightings', :partial => 'location_observations'
				end
			end
		end
	end

	def species
		respond_to do |format|
			format.html do
				render :partial => 'species_observations', :layout => true
			end
			format.js do
				render :update do |page|
					page.replace_html 'sightings', :partial => 'species_observations'
				end
			end
		end
	end

	def list
		respond_to do |format|
			format.html do
				render :partial => 'list_observations', :layout => true
			end
			format.js do
				render :update do |page|
					page.replace_html 'sightings', :partial => 'list_observations'
				end
			end
		end
	end
end
