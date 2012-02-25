class RecoverPasswordController < ApplicationController
	skip_before_filter :login_required

	def index
		return unless request.post?
		user = User.find_by_login(params[:login_or_email]) || User.find_by_email(params[:login_or_email])

		if user.nil? then
			flash.now[:warning] = "Unable to locate a user with the username or email address you supplied."
		else
			PasswordRecoveryCode.create(:user => user)
			flash.now[:notice] = "Instructions for resetting your password were sent to the email address associated with your account."
		end
	end

	def code
		logout_and_delete_remember_me

		code = PasswordRecoveryCode.find_by_code(params[:id])

		if !code.nil? and (code.created_at + PASSWORD_RECOVERY_CODE_DURATION) < Time.now then
			code.destroy
			code = nil
		end
		
		if code.nil? then
			flash[:warning] = "Invalid password recovery code."
			redirect_to :action => :index
			return
		end

		@user = code.user

		return unless request.post?

		if @user.update_attributes(params[:user]) then
			code.destroy
			flash[:notice] = "Your password was successfully updated. You may now sign in."
			redirect_to :controller => :account, :action => :login
		end
	end
end
