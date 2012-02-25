require 'birdstack/search'

class SearchController < ApplicationController
	def index
		redirect_to :controller => 'sighting', :action => 'index'
	end

	def delete
		@saved_search = current_user.saved_searches.find_by_id(params[:id])
		
		unless @saved_search and request.post? then
			redirect_to :controller => 'sighting', :action => 'index'
			return
		end

		@saved_search.destroy

		flash[:notice] = 'Deleted list "' + @saved_search.name.to_s + '"'
		redirect_to :controller => 'sighting', :action => 'index'
	end

	def observation
		if params[:id] then
			begin
				@saved_search = current_user.saved_searches.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				# If it's not valid, just take them to the construct search page
				redirect_to :action => 'observation', :id => nil
				return
			end
		end

		# We want to default to this
		if @observation_search_type.blank? or @observation_search_type.type.blank? then
			@observation_search_type = Struct.new(:type).new('all')
		end

		if request.post? then
			@search = Birdstack::Search.new(current_user, params, false, current_user)
		elsif @saved_search then
			@search = Birdstack::Search.new(current_user, @saved_search.search, true, current_user)
		else
			return
		end

		@search.generate_instance_vars(self)

		return unless @search.generate_search_params

		# We don't ever modify things on GET.  Only on POST
		# Didn't put this earlier because we still want to validate the search before attempting to save
		# Also, this means we can use an existing saved_search object if we have one
		if request.post? then
			unless @saved_search then
				@saved_search = SavedSearch.new()
				@saved_search.temp = true # Always start out temp
				@saved_search.user = current_user
				@saved_search.name ||= '' # Cannot be null
			end

			@saved_search.attributes = params[:saved_search]
			# Don't put this in the above line because then a user could modify the value stored in 'search'
			@saved_search.search = @search.freeze

			if params[:commit] == 'Save list' and @saved_search.temp == true then
				@saved_search.temp = false
			end

			return unless @saved_search.save

			# Now that we have a saved search, we need to redirect to a URL that contains the search ID
			# This makes saving future changes easier, and allows pagination to just work
			# However, we don't need to do this if the URL already has the search ID
			unless params[:id] then
				redirect_to :id => @saved_search.id
				return
			end
		end

		# We don't want the user to be able to dynamically change the display type
		params[:no_display_change] = true

		# TODO This is ugly and unreliable
		if params[:commit] == 'Save list' and !@saved_search.temp then
			redirect_to list_url(:user => current_user.login, :id => @saved_search.id, :format => 'html')
			return
		end

		if @saved_search and !@saved_search.temp then
			render :action => 'observation_edit'
		else
			render :action => 'observation'
		end
	end
end
