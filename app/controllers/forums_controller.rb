class ForumsController < ApplicationController
	skip_before_filter :login_required, :except => [:newthread]

	def index
		@forums = Forum.find(:all, :order => 'forums.sort_order ASC')
	end

	def forum
		@forum = Forum.find_by_url(params[:forum])

		unless @forum then
			flash[:warning] = 'Could not find forum "' + params[:forum] + '"'
			redirect_to :action => 'index'
			return
		end

		@threads = @forum.comment_collections.paginate(:page => params[:page])

		respond_to do |format|
			format.html
			format.js do
				render :update do |page|
					page.replace_html 'threadlist', :partial => 'threadlist'
				end
			end
		end
	end

	def feed
		@forum = Forum.find_by_url(params[:forum])

		unless @forum then
			flash[:warning] = 'Could not find forum "' + params[:forum] + '"'
			redirect_to :action => 'index'
			return
		end

		@threads = @forum.comment_collections.find(:all, :limit => 20)

		# Don't care what they asked for, they're getting atom.  So there.
		params['format'] = 'atom'
	end

	def newthread
		@forum = Forum.find_by_url(params[:forum])

		unless @forum then
			flash[:warning] = 'Could not find forum "' + params[:forum] + '"'
			redirect_to :action => 'index'
			return
		end

		@comment = Comment.new(params[:comment])
		@comment_collection = ForumCommentCollection.new(params[:comment_collection])

		return unless request.post?

		@comment.user = current_user
		@comment_collection.user = current_user

		return if params[:commit] == 'Preview'

		# All of these must succeed, and in this order
		begin
			CommentCollection.transaction do
				Comment.transaction do
					@comment_collection.save!
					@comment.comment_collection = @comment_collection
					@comment.save!
					@forum.comment_collections.push @comment_collection
					
					# Save again to update the forum cache, now that we're associated
					@comment_collection.reload
					@comment_collection.save! 
				end
			end
		rescue
			if @comment_collection.errors.empty? and @comment.errors.empty? then
				# Something happened that we didn't expect
				raise
			end
			# Display errors
			return
		end

		redirect_to :action => 'thread', :forum => @forum.url, :id => @comment_collection.id
	end

	def thread
		@forum = Forum.find_by_url(params[:forum])

		unless @forum then
			flash[:warning] = 'Could not find forum "' + params[:forum] + '"'
			redirect_to main_url(:action => 'index')
			return
		end

		@comment_collection = @forum.comment_collections.find_by_id(params[:id])

		unless @comment_collection then
			flash[:warning] = 'Could not find thread "' + params[:id].to_s + '"'
			redirect_to :controller => 'forums', :forum => @forum.url, :action => 'forum'
			return
		end

		@comment_collection.publicize!(current_user)

		respond_to do |format|
			format.html
			format.js do
				render :update do |page|
					page.replace_html 'comments', :partial => 'shared/comments_forum', :locals => { :comment_collection => @comment_collection, :goto => url_for(:controller => 'forums', :forum => @forum.url, :action => 'thread', :id => @comment_collection.id) }
				end
			end
		end
	end
end
