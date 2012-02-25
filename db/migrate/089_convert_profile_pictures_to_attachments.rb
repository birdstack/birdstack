class ConvertProfilePicturesToAttachments < ActiveRecord::Migration
	def self.up
		User.find(:all).each do |user|
			if user.profile_pic and user.profile_pic.picture then
				# read_attribute must be used so that file_column doesn't overwrite part of the file when we go to read it
				file = Tempfile.new('picture')
				file.write(user.profile_pic.read_attribute(:picture))
				file.close

				file_small = Tempfile.new('picture_small')
				file_small.write(user.profile_pic.read_attribute(:picture_small))
				file_small.close

				dirname = File.join(RAILS_ROOT, 'public/profile_pic/picture', user.profile_pic.id.to_s)

				FileUtils.mkdir(dirname)
				FileUtils.mkdir(File.join(dirname, 'normal'))
				FileUtils.mkdir(File.join(dirname, 'small'))
				FileUtils::cp(file.path, File.join(dirname, 'pic.jpg'))
				FileUtils::cp(file.path, File.join(dirname, 'normal', 'pic.jpg'))
				FileUtils::cp(file_small.path, File.join(dirname, 'small', 'pic.jpg'))

				user.profile_pic.write_attribute(:picture, 'pic.jpg')
				execute "UPDATE profile_pics set picture = 'pic.jpg' WHERE id = #{user.profile_pic.id}"
			end
		end

		remove_column 'profile_pics', 'picture_small'
		change_column 'profile_pics', 'picture', :string
	end

	def self.down
		raise ActiveRecord::IrreversibleMigration
	end
end
