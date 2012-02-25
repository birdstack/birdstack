class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :comment_collection

	attr_accessible :comment, :updated_reason

	validates_presence_of	:comment

	def self.per_page
		25
	end

	def deleted=(del)
		@recently_deleted = true
		write_attribute("deleted", del)
	end

	def validate
		# Cannot delete the first post to a thread in a forum
		if self.in_forum then
			if self.comment_collection.comments.first == self then
				errors.add(:deleted, 'cannot delete the first post in a forum thread')
			end
		end
	end

	def in_forum
		return self.comment_collection.forums[0]
	end

        def notify_list
          # All users who have commented on this collection plus the owner (but not the current user)
          # and want to receive notifications for this type of comment
          (self.comment_collection.comments.collect do |c|
            c.user
          end << self.comment_collection.user).uniq.reject do |u|
            u == self.user
          end.find_all do |u|
            u.send(self.comment_collection.class.notify_property)
          end
        end

	def before_save
		if self.deleted and !@recently_deleted then
			self.errors.add_to_base("You cannot modify a comment that has been deleted")
			return false
		end
	end

	def before_destroy
		cc = self.comment_collection
		# We have to set this to null for now to avoid a foreign key constraint problem
		if cc.last_post_id == self.id then
			cc.last_post_id = nil
			cc.save
		end
	end

	attr_accessor :skip_parent_update
	def parent_update
		self.comment_collection.update_cache unless self.skip_parent_update
	end

	def after_save
		self.parent_update
	end

	def after_destroy
		self.parent_update
	end
end
