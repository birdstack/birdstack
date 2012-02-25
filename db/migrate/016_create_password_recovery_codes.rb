class CreatePasswordRecoveryCodes < ActiveRecord::Migration
  def self.up
    create_table :password_recovery_codes do |t|
	    t.column :user_id,	:integer, :null => false
	    t.column :code,	:string, :null => false
	    t.column :created_at, :datetime, :null => false
    end

    add_index(:password_recovery_codes, :code, :unique => true)

    execute "ALTER TABLE password_recovery_codes ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    drop_table :password_recovery_codes
  end
end
