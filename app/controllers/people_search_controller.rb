class PeopleSearchController < ApplicationController
	skip_before_filter :login_required

	def index
		@countries = CountryCode.find(:all, :order => 'name ASC')
		@user_search = UserSearch.new(params[:user_search])
		@results = @user_search.search(:page => params[:page])

		respond_to do |format|
			format.html
			format.js do
				render :update do |page|
					page.replace_html 'search_results', :partial => 'search_results'
				end
			end
		end
	end
end
