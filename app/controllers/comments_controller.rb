class CommentsController < ApplicationController
	skip_before_filter :login_required, :only => [:feed, :paginate]

	def post
		@comment = Comment.new(params[:comment])

		@comment.comment_collection = CommentCollection.find_by_id(params[:id])

		if @comment.comment_collection.nil? then
			flash[:warning] = 'Unable to find comment collection "' + params[:id].to_s + '"'
			redirect_to_goto
			return
		end

		# Make sure the comment collection is either owned by the user or is public
		unless @comment.comment_collection.user == current_user or CommentCollection.find_public_by_id(@comment.comment_collection.id, current_user) then
			flash[:warning] = 'Unable to find comment collection "' + params[:id].to_s + '"'
			redirect_to_goto
			return
		end

		# We don't do a publicize! call here because we intend to modify the collection

		return unless request.post?

		@comment.user = current_user

		return if params[:commit] == 'Preview'

		return unless @comment.save

		redirect_to_goto
	end

	def feed
		@comment_collection = CommentCollection.find_by_id(params[:id])

		unless @comment_collection then
			flash[:warning] = 'Unable to find comment collection "' + params[:id].to_s + '"'
			redirect_to_goto
			return
		end

		# Make sure the comment collection is either owned by the user or is public
		unless @comment_collection.user == current_user or CommentCollection.find_public_by_id(@comment_collection.id, current_user) then
			flash[:warning] = 'Unable to find comment collection "' + params[:id].to_s + '"'
			redirect_to_goto
			return
		end

		@comment_collection.publicize!(current_user)

		# Don't care what they asked for, they're getting atom.  So there.
		params['format'] = 'atom'

		render :template => 'comments/feed_' + @comment_collection.class.to_s.underscore
	end

	def paginate
		respond_to do |format|
			format.html do
				render :partial => 'shared/comments_comment_comments', :layout => true
			end
			format.js do
				render :update do |page|
					page.replace_html 'comments', :partial => 'shared/comments_comment_comments'
				end
			end
		end
	end
end
