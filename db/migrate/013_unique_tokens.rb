class UniqueTokens < ActiveRecord::Migration
  def self.up
	  remove_index(:sessions, :session_id)
	  add_index(:sessions, :session_id, :unique => true)

	  remove_index(:remember_me_cookies, :token)
	  add_index(:remember_me_cookies, :token, :unique => true)
  end

  def self.down
	  remove_index(:sessions, :session_id)
	  add_index(:sessions, :session_id)

	  remove_index(:remember_me_cookies, :token)
	  add_index(:remember_me_cookies, :token)
  end
end
