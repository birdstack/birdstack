class AddPublicObservationsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :public_observations, :integer
  end

  def self.down
    remove_column :users, :public_observations
  end
end
