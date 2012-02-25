class AddUniqueLowercaseUsernameIndex < ActiveRecord::Migration
  def self.up
    add_column :users, :login_lcase, :string
    execute "CREATE TRIGGER users_login_insert BEFORE INSERT ON users FOR EACH ROW SET NEW.login_lcase = LOWER(NEW.login);"
    execute "CREATE TRIGGER users_login_update BEFORE UPDATE ON users FOR EACH ROW SET NEW.login_lcase = LOWER(NEW.login);"
    execute "UPDATE users SET login_lcase = LOWER(login);"
    execute "CREATE UNIQUE INDEX login_lcase_unique ON users (login_lcase);"
  end

  def self.down
    execute "DROP INDEX login_lcase_unique ON users;"
    execute "DROP TRIGGER users_login_insert;"
    execute "DROP TRIGGER users_login_update;"
    remove_column :users, :login_lcase
  end
end
