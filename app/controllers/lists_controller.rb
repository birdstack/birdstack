require 'csv'

class ListsController < ApplicationController
	skip_before_filter :login_required, :only => [:list, :index]

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
			@saved_searches = @user.saved_searches.find(:all, :conditions => {:temp => false }, :order => 'saved_searches.name')
		else
			@saved_searches = SavedSearch.find_public_by_user(@user, current_user, :order => 'saved_searches.name')
		end
	end

	def list
		@user = User.find_by_login(params[:user])

		if @user.nil? then
			unless params[:user].blank? then
				flash[:warning] = 'Unable to find user with login of "' + params[:user].to_s + '"'
			end
			redirect_to :controller => 'main', :action => 'index'
			return
		end

		if @user == current_user then
			# If they own the list, it doesn't have to be public
			@saved_search = @user.saved_searches.find_nontemp_by_id(params[:id])
		else
			@saved_search = @user.saved_searches.find_public_by_id(params[:id], current_user)
		end

		respond_to do |format|
			format.html
			# For the other formats, we redo the find as though it were public
			format.js do
				@saved_search = @user.saved_searches.find_public_by_id(params[:id], :false)
                                render
                                cache_page
			end
			format.atom do
				@saved_search = @user.saved_searches.find_public_by_id(params[:id], :false)

				unless @saved_search then
					redirect_to :format => 'html'
					return
				else
					render
                                        cache_page
				end
			end
		end
	end

	def export
		@saved_search = current_user.saved_searches.find_by_id(params[:id])
		
		unless @saved_search then
			redirect_to main_url
			return
		end

		return if request.format.to_sym == :html # Don't do anything else if we're just showing the page

		search = Birdstack::Search.new(@saved_search.user, @saved_search.search, true, current_user)
		@sightings = search.search_no_paginate

		respond_to do |format|
			format.html
			format.csv do
				headers.update('Content-Disposition' => "attachment; filename=#{@saved_search.id}_#{Time.now.strftime('%Y-%m-%d_%H-%M')}.csv")
				render
			end
			format.xml do
				headers.update('Content-Disposition' => "attachment; filename=#{@saved_search.id}_#{Time.now.strftime('%Y-%m-%d_%H-%M')}.xml")
				render
			end
		end
	end

	def construct
		# We only allow this for public searches
		@saved_search = current_user.saved_searches.find_public_by_id(params[:id])

		unless @saved_search then
			redirect_to :controller => 'search'
			return
		end

		return unless request.post?

		fields = [:limit, :width, :highlight_color]
		@list = Struct.new(*fields).new(*fields.collect {|i| params[:list][i]})

		# Apparently URL specs have to have symbols as keys. Weird.
		url_hash = Hash.new
		params[:list].each do |key, val|
			url_hash[key.to_sym] = val
		end
		@list_url = list_url({:user => current_user.login, :id => @saved_search.id, :format => 'js'}.merge(url_hash))
	end

end
