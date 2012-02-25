class DashboardController < ApplicationController
	def index
		@saved_searches = current_user.saved_searches.find(:all, :conditions => {:temp => false }, :order => 'saved_searches.created_at DESC', :limit => 10)
		@tags = current_user.sightings.tag_counts(:limit => 10, :order => 'count DESC').sort {|a,b| a.name.downcase <=> b.name.downcase }

                @activity = Activity.find(:first, :conditions => {:user_id => current_user.friends}, :order => 'occurred_at DESC')
	end

	def invite
		@invite = Invite.new({
			:name => current_user.login,
			:subject => current_user.login + ' has invited you to Birdstack',
			:body => render_to_string(:partial => 'invite_body')
		}.merge(params[:invite] || {}))
		@invite.user = current_user

		return unless request.post?

		if @invite.save
			InviteMailer.deliver_invite(@invite)
			flash[:notice] = "Your message has been sent. Thanks for spreading the word!"
			redirect_to :controller => 'dashboard', :action => 'index'
		end
	end
end
