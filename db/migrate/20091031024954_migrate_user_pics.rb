class MigrateUserPics < ActiveRecord::Migration
  def self.up
    ProfilePic.all.each do |pic|
      begin
        u = pic.user
        puts u.login
        u.profile_pic = File.open(pic.picture)
        puts u.save!
      rescue Exception => e
        puts "Conversion trouble!"
        puts e
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
