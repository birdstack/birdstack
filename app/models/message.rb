class Message < ActiveRecord::Base
	belongs_to :user
	belongs_to :conversation
        has_many :message_references

        validates_presence_of :body

        attr_accessible :body

        def validate
          unless self.conversation.users.include? self.user then
            self.errors.add(:users, 'is not a part of this conversation')
          end
        end
end
