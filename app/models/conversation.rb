class Conversation < ActiveRecord::Base
	has_and_belongs_to_many :users
	has_many :messages, :order => 'created_at ASC'

	validates_presence_of :subject

        attr_accessible :subject, :participants_text

        attr_accessor :additional_users
        attr_accessor :participants_text
        attr_accessor :participants_users

        def validate
          if self.participants_text then
            usernames = self.participants_text.split(/,\s*/)
            self.participants_users = usernames.collect do |u|
              User.valid.find_by_login(u) or self.errors.add(:users, "Could not find user #{u}")
            end
          else
            self.participants_users = self.users
          end

          self.participants_users += self.additional_users.to_a

          self.participants_users = self.participants_users.compact.uniq

          self.errors.add(:users, "Must have at least 1 recipient, and you cannot send a message to yourself") if self.participants_users.size < 2
        end

        def after_save
          self.users = self.participants_users
        end

        def before_destroy
          self.messages.each do |m|
            m.destroy
          end
        end
end
