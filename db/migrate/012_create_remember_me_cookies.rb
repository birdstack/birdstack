class CreateRememberMeCookies < ActiveRecord::Migration
  def self.up
    create_table :remember_me_cookies do |t|
	    t.column :user_id,		:integer, :null => false
	    t.column :token,		:string, :null => false
	    t.column :expires_at,	:datetime, :null => false
	    t.column :created_at,	:datetime, :null => false
	    t.column :updated_at, 	:datetime, :null => false
    end

    add_index(:remember_me_cookies, :token)

    execute "ALTER TABLE remember_me_cookies ADD CONSTRAINT FOREIGN KEY (user_id) REFERENCES users(id)"

    remove_column(:users, :remember_token)
    remove_column(:users, :remember_token_expires_at)
  end

  def self.down
    drop_table :remember_me_cookies

    add_column(:users, :remember_token,            :string)
    add_column(:users, :remember_token_expires_at, :datetime)
  end
end
