class RenameTripTimes < ActiveRecord::Migration
  def self.up
	  rename_column	:trips,	:start_time_hour,	:time_hour_start
	  rename_column	:trips,	:start_time_minute,	:time_minute_start
  end

  def self.down
	  rename_column	:trips,	:time_hour_start,	:start_time_hour
	  rename_column	:trips,	:time_minute_start,	:start_time_minute
  end
end
