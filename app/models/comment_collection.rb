class CommentCollection < ActiveRecord::Base
	has_many :comments, :order => 'comments.created_at ASC'
	belongs_to :user
	belongs_to :posted_by_user, :foreign_key => 'posted_by', :class_name => 'User'
	has_and_belongs_to_many :forums

	attr_accessible :title

	validates_presence_of	:title
	validates_presence_of	:type

	# Don't get all smart and try to do this! (either in AR or the db)
	# validates_presence_of	:user_id
	# The problem is during user creation.  The new user needs a comment collection,
	# but the user object doesn't exist yet, so the comment collection cannot be
	# associated with a user id.  This problem also happens when deleting a user.

	def self.per_page
		25
	end

	def publicize!(user = nil)
		if @publicized and @publicized_for != user then
			raise 'Attempted to republicize comment collection ' + self.id.to_s + ' for ' + user.to_s + ' when already publicized for ' + @publicized_for.to_s
		end

		return self if @publicized

		if self.user == user then
			# Do nothing
		elsif self.private then
			raise 'Attempted to publicize comment collection ' + self.id.to_s
		else
			self.private = nil
		end

		@publicized = true
		@publicized_for = user

		self.readonly!
		self.freeze
		
		return self
	end

	def self.find_public_by_id(id, user = nil)
		comment_collection = send(:find, :first, :conditions => ['comment_collections.id = ? AND (comment_collections.private IS NULL OR comment_collections.private = 0)', id])
		comment_collection.publicize!(user) if comment_collection
		return comment_collection
	end

	def update_cache
		last_comment = self.comments.find(:first, :conditions => {:deleted => false}, :order => 'comments.created_at DESC')
		count = self.comments.count(:conditions => {:deleted => false})

		self.post_count = count
		if last_comment then
			self.posted_at = last_comment.created_at
			self.posted_by = last_comment.user_id
			self.last_post_id = last_comment.id
		else
			self.posted_at = nil
			self.posted_by = nil
			self.last_post_id = nil
		end

		self.save!
	end

	def before_destroy
		self.comments.each do |c|
			c.skip_parent_update = true
			c.destroy
		end
	end

	attr_accessor :skip_parent_update
	def parent_update
		self.forums[0].update_cache if self.forums[0]
	end

	def after_save
		self.parent_update
	end

	def after_destroy
		self.parent_update
	end
end
