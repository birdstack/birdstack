module Birdstack::Redirect
	private

	def redirect_to_goto
		@goto = params[:goto]
		# Prevent XSS badness
		
		@goto = nil unless (!@goto.blank? and @goto.first == '/')

		redirect_to (@goto.blank? ? main_url(:action => 'index') : @goto)
	end
end
