class DisallowNullValuesInUsersTable < ActiveRecord::Migration
  def self.up
	  change_column(:users, :login, :string, :null => false)
	  change_column(:users, :email, :string, :null => false)
	  change_column(:users, :crypted_password, :string, :null => false)
	  change_column(:users, :salt, :string, :null => false)
	  change_column(:users, :created_at, :datetime, :null => false)
	  change_column(:users, :updated_at, :datetime, :null => false)
  end

  def self.down
	  change_column(:users, :login, :string)
	  change_column(:users, :email, :string)
	  change_column(:users, :crypted_password, :string, :limit => 40)
	  change_column(:users, :salt, :string, :limit => 40)
	  change_column(:users, :created_at, :datetime, :default => nil)
	  change_column(:users, :updated_at, :datetime, :default => nil)
  end
end
