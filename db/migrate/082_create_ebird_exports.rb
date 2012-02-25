class CreateEbirdExports < ActiveRecord::Migration
  def self.up
    create_table :ebird_exports do |t|
      t.column "user_id", :string
      t.column "description", :string
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
    end

    execute "ALTER TABLE sightings ADD CONSTRAINT FOREIGN KEY (ebird) REFERENCES ebird_exports(id)"

    # only for db-based files
    # create_table :db_files, :force => true do |t|
    #      t.column :data, :binary
    # end
  end

  def self.down
    drop_table :ebird_exports
    
    # only for db-based files
    # drop_table :db_files
  end
end
