class AddUserNewsletterPreferences < ActiveRecord::Migration
  def self.up
	  add_column :users, :notify_newsletter, :boolean, :default => true, :null => false
  end

  def self.down
	  remove_column :users, :notify_newsletter
  end
end
