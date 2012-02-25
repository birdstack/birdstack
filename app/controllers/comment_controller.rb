class CommentController < ApplicationController
	def edit
		@goto = params[:goto]
		@comment = Comment.find_by_id(params[:id])

		unless @comment then
			redirect_to_goto
			return
		end

		unless @comment.user == current_user then
			flash[:warning] = "You can't edit comments that aren't yours."
			redirect_to_goto
			return
		end

		# Make sure the comment collection is either owned by the user or is public
		unless @comment.comment_collection.user == current_user or CommentCollection.find_public_by_id(@comment.comment_collection.id, current_user) then
			redirect_to_goto
			return
		end


		return unless request.post?

		@comment.update_attributes(params[:comment])

		return if params[:commit] == 'Preview'

		return unless @comment.save

		redirect_to_goto
	end

	def delete
		redirect_to_goto and return unless request.post?
		
		@comment = Comment.find_by_id(params[:id])
		
		unless @comment then
			redirect_to_goto
			return
		end

		# Make sure the comment collection is either owned by the user or is public
		unless @comment.comment_collection.user == current_user or CommentCollection.find_public_by_id(@comment.comment_collection.id, current_user) then
			redirect_to_goto
			return
		end

		unless @comment.user == current_user then
			flash[:warning] = "You can't delete comments that aren't yours."
			redirect_to_goto
			return
		else
			@comment.deleted = true
			@comment.comment = 'This comment was removed by its author.'
			@comment.updated_reason = 'Deleted'
			@comment.save
		end

		redirect_to_goto
	end

	def permanently_delete
		redirect_to_goto and return unless request.post?

		@comment = Comment.find_by_id(params[:id])

		unless @comment.comment_collection.user == current_user then
			flash[:warning] = "You can't permanently delete comments from a comment collection you don't own."
			redirect_to_goto
			return
		else
			@comment.destroy
		end

		redirect_to_goto
	end
end
