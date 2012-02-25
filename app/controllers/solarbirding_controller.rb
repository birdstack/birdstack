class SolarbirdingController < ApplicationController
	skip_before_filter :login_required
	skip_before_filter :verify_authenticity_token

        def view
          sanitize = /[^a-zA-Z0-9_-]+/
          event = params[:event].gsub(sanitize, '').downcase
          page = params[:page].gsub(sanitize, '').downcase

          if(event == "index" and page == "index") then
            redirect_to solar_url(:event => 'december-solstice-2008')
            return
          end

          begin
            render :action => "#{event}/#{page}"
          rescue
            raise ActionController::RoutingError, "Could not find page #{page} for event #{event}"
          end
        end
end
