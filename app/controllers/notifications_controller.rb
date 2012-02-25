class NotificationsController < ApplicationController
	skip_before_filter :login_required, :only => [:index, :flag]

	def index
		redirect_to main_url(:action => 'index')
	end

	def flag
		@notification = Notification.find_by_id(params[:id])

		unless @notification then
			flash[:warning] = 'Unable to locate notification ID ' + params[:id].to_s
			redirect_to main_url(:action => 'index')
			return
		end

		@notification_flag = NotificationFlag.new(params[:notification_flag])
		@notification_flag.user = logged_in? ? current_user : nil
		@notification_flag.notification = @notification

		return unless request.post?

		if logged_in? ? @notification_flag.valid? : @notification_flag.valid_with_captcha?
			NotificationFlagMailer.deliver_notification_flag(@notification_flag)
			flash[:notice] = "Your message has been sent. Thank you for your feedback."

			species = @notification.species
			redirect_to :controller => 'ioc', :action => 'species', :species => species.latin_name.downcase, :genus => species.genus.latin_name.downcase, :family => species.genus.family.latin_name.downcase, :order => species.genus.family.order.latin_name.downcase
		end
	end

	def add
		@species = Species.find_valid_by_id(params[:id])

		unless @species then
			flash[:warning] = 'Unable to locate species ID ' + params[:id].to_s
			redirect_to main_url(:action => 'index')
			return
		end

		@notification = Notification.new(params[:notification])
		
		return unless request.post?

		@notification.user = current_user
		@notification.species = @species

		if params[:potential_species] then
			params[:potential_species].each do |id, val|
				potential_species = Species.find_by_id(params[:potential_species][id][:id])
				@notification.potential_species << potential_species if potential_species
			end
		end
		
		unless params[:species_english_name].blank? then
			unless species = Species.find_valid_by_exact_english_name(params[:species_english_name])
				@notification.errors.add(:species_english_name, 'was not valid')
			else
				@notification.potential_species << species
			end
		end

		return unless params[:commit] == 'Save'

		return unless @notification.save

		redirect_to :controller => 'ioc', :action => 'species', :species => @species.latin_name.downcase, :genus => @species.genus.latin_name.downcase, :family => @species.genus.family.latin_name.downcase, :order => @species.genus.family.order.latin_name.downcase
	end
end
