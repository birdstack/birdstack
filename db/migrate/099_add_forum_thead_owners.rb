class AddForumTheadOwners < ActiveRecord::Migration
  def self.up
	  ForumCommentCollection.find(:all).each do |f|
		next unless f.comments.size > 0

		f.user = f.comments.find(:first).user
		f.save!
	  end
  end

  def self.down
	  throw ActiveRecord::IrreversibleMigration
  end
end
