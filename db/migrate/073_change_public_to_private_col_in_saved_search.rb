class ChangePublicToPrivateColInSavedSearch < ActiveRecord::Migration
  def self.up
	  remove_column :saved_searches, :public
	  add_column :saved_searches, :private, :boolean, :default => false
  end

  def self.down
  end
end
