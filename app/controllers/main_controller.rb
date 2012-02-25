class MainController < ApplicationController
	skip_before_filter :login_required
	skip_before_filter :verify_authenticity_token

	def abbreviations
		@regions = Region.find(:all)
	end

	def contact
		@contact = Contact.new(params[:contact])

		return unless request.post?

		if (logged_in? or local_request?) ? @contact.valid? : @contact.valid_with_captcha?
			ContactNotifier.deliver_contact_form(@contact, logged_in? ? current_user : nil, request.remote_ip)
			@contact = Contact.new
			flash.now[:notice] = "Your message has been sent. Thank you for your feedback."
		end
	end

        def test_exception
          raise "This is a test exception"
        end
end
