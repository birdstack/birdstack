class EbirdExport < ActiveRecord::Base
	belongs_to :user

	has_attachment :storage => :file_system, :file_system_path => File.join('user_data', 'ebird_exports')
        
        # We don't need a fancy partitioning scheme.  Plus, I want backwards compatibility with acts_as_attachment
        def partitioned_path(*args)
          [attachment_path_id.to_s] + args
        end

	validates_as_attachment
end
