class EmailActivation < ActiveRecord::Migration
  def self.up
	  add_column :users,	:activation_code, :string, :null => false, :default => 'invalid'
	  add_column :users,	:activated_at, :datetime

	  User.find_all_by_activated_at(nil).each do |u|
		u.update_attribute(:activated_at, Time.now)
	  end

	  # Give them all unique ids so we can add a unique index
	  User.find_all_by_activation_code('invalid').each do |u|
		u.update_attribute(:activation_code, 'migration_code' + u.id.to_s)
	  end

	  add_index(:users, :activation_code, :unique => true)
  end

  def self.down
	  remove_column :users,	:activation_code
	  remove_column :users, :activated_at
  end
end
