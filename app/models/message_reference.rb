class MessageReference < ActiveRecord::Base
	belongs_to :user
	belongs_to :message

        attr_accessible

        def self.per_page
          50
        end

        def self.update_cache(user)
          user.unread_messages = user.message_references.count(:conditions => ['message_references.read = 0 AND messages.user_id != ?', user.id], :joins => 'LEFT JOIN messages ON message_references.message_id = messages.id')
          user.save!
        end

        attr_accessor :skip_update
        def after_save
          MessageReference.update_cache(self.user) unless self.skip_update
        end

        def after_destroy
          MessageReference.update_cache(self.user) unless self.skip_update
        end
end
