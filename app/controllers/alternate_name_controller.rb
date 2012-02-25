class AlternateNameController < ApplicationController
	skip_before_filter :login_required, :only => [:index, :flag]

	def index
		redirect_to main_url(:action => 'index')
	end

	def flag
		@alternate_name = AlternateName.find_by_id(params[:id])

		unless @alternate_name then
			flash[:warning] = 'Unable to locate alternate name ID ' + params[:id].to_s
			redirect_to main_url(:action => 'index')
			return
		end

		@alternate_name_flag = AlternateNameFlag.new(params[:alternate_name_flag])
		@alternate_name_flag.user = logged_in? ? current_user : nil
		@alternate_name_flag.alternate_name = @alternate_name

		return unless request.post?

		if logged_in? ? @alternate_name_flag.valid? : @alternate_name_flag.valid_with_captcha?
			AlternateNameFlagMailer.deliver_alternate_name_flag(@alternate_name_flag)
			flash[:notice] = "Your message has been sent. Thank you for your feedback."

			species = @alternate_name.species
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

		@alternate_name = AlternateName.new(params[:alternate_name])
		@alternate_name.species = @species
		
		return unless request.post?

		@alternate_name.user = current_user

		return unless @alternate_name.save

		flash[:notice] = "Your alternate name has been added. Thank you for your contribution."

		redirect_to :controller => 'ioc', :action => 'species', :species => @species.latin_name.downcase, :genus => @species.genus.latin_name.downcase, :family => @species.genus.family.latin_name.downcase, :order => @species.genus.family.order.latin_name.downcase
	end
end
