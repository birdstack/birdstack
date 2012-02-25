class Forum < ActiveRecord::Base
	has_and_belongs_to_many :comment_collections, :order => 'comment_collections.posted_at DESC'
	belongs_to :posted_by_user, :foreign_key => 'posted_by', :class_name => 'User'

	def update_cache
		self.thread_count = self.comment_collections.size
		self.post_count = Comment.count(:conditions => {:comment_collection_id => self.comment_collections, :deleted => false})

		last_post = Comment.find(:first, :conditions => {:comment_collection_id => self.comment_collections, :deleted => false}, :order => 'comments.created_at DESC')

		self.posted_at = last_post.created_at
		self.posted_by = last_post.user_id
		self.last_post_id = last_post.id

		self.save!
	end
end
