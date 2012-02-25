class AddEndDateToTrip < ActiveRecord::Migration
  def self.up
	rename_column	:trips,	:date_day,	:date_day_start
	rename_column	:trips,	:date_month,	:date_month_start
	rename_column	:trips,	:date_year,	:date_year_start

	add_column	:trips,	:date_day_end,		:integer
	add_column	:trips,	:date_month_end,	:integer
	add_column	:trips,	:date_year_end,		:integer
  end

  def self.down
	  # Just didn't feel like actually making it.  It could be done.
	  throw ActiveRecord::IrreversibleMigration
  end
end
