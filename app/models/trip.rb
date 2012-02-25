class Trip < ActiveRecord::Base
	acts_as_nested_set :scope => :user

	acts_as_taggable

        has_many        :trip_photo, :dependent => :destroy
        accepts_nested_attributes_for :trip_photo

	self.write_inheritable_attribute(:attr_protected, nil) # awesome_nested_set puts stuff in here.  It's useless because I use the more restrictive attr_accessible, and it causes ActiveRecord to raise an error
	
	# Be sure that parent_id is not accessible!  Reparenting operations must be done by betternestedset
	attr_accessible :name, :description, :time_hour_start, :time_minute_start, :protocol, :number_observers, :duration_hours, :duration_minutes, :distance_traveled, :distance_traveled_units, :area_covered, :area_covered_units, :date_day_start, :date_month_start, :date_year_start, :date_day_end, :date_month_end, :date_year_end, :all_observations_reported, :private, :tag_list, :link, :trip_photo_attributes

	validates_http_url :link

	has_many :sightings
	belongs_to :user

	belongs_to :comment_collection

	attr_accessor :distance_traveled, :distance_traveled_units, :area_covered, :area_covered_units

	# This alias is required because I want to do Rails validation on the elevation "facade" column and the validation routine calls the _before_type_cast version of the field (which for our purposes is the same)
	alias :distance_traveled_before_type_cast :distance_traveled
	alias :area_covered_before_type_cast :area_covered

	def publicize!(user = nil)
                if @publicized and @publicized_for != user then
                  raise 'Attempted to republicize trip ' + self.id.to_s + ' for ' + (user ? user.login : 'nil') + ' when already publicized for ' + (@publicized_for ? @publicized_for.login : 'nil')
                end

		return self if @publicized

		if self.user == user then
			# Do nothing
		elsif self.private then
			raise 'Attempted to publicize user location ' + self.id.to_s
		else
			# Scrub our private status
			self.private = nil
		end

		@publicized = true
		@publicized_for = user

		self.readonly!
		self.freeze
		
		return self
	end

	# This ensures that the trip isn't private
        named_scope :public, :conditions => ['trips.private IS NULL OR trips.private = 0']

	def self.find_public_by_id(id, user = nil)
          trip = self.public.first(:conditions => {:id => id})
          trip.publicize!(user) if trip
          return trip
	end

	# This accepts an options hash, but will not carry across any conditions specified
	def self.find_public_by_user(user, publicize_for = nil, options = {})
          options[:order] ||= 'trips.lft'
          self.public.all(options.merge(:conditions => {:user_id => user.id})).collect do |trip|
            trip.publicize!(publicize_for)
          end
	end

	def self.public_branch(root, publicize_for = nil)
		branch = [root] + root.descendants
		branch = branch.find_all {|node| !node.private}
		branch.each {|node| node.publicize!(publicize_for) }
		return branch
	end

	def self.branch(root)
		branch = [root] + root.descendants
		return branch
	end

        def sighting_photos
          SightingPhoto.trip_id(self.id)
        end

	def public_ancestors(user = nil)
		send(:ancestors).collect {|a| a.publicize!(user) }
	end

	def science_trip?
		['traveling', 'stationary', 'area'].include? self.protocol
	end

	def before_validation
		# These next two blocks move the data from the facade column into the appropriate real one

		if !self.distance_traveled.blank? then
			if self.distance_traveled_units == 'km' then
				self.distance_traveled_km = self.distance_traveled
				self.distance_traveled_mi = nil
			else
				self.distance_traveled_mi = self.distance_traveled
				self.distance_traveled_km = nil
			end
		else
			# For some reason I have to set this.  Otherwise, if a user enters a number, submits the sighting, gets an unrelated error, removes the number, and resubmits, they'll get an error about it not being a number
			# TODO Still the case in Rails 2.0?
			self.distance_traveled = nil
		end

		if !self.area_covered.blank? then
			if self.area_covered_units == 'sqkm' then
				self.area_covered_sqkm = self.area_covered
				self.area_covered_sqmi = nil
				self.area_covered_acres = nil
			elsif self.area_covered_units == 'sqmi' then
				self.area_covered_sqmi = self.area_covered
				self.area_covered_sqkm = nil
				self.area_covered_acres = nil
			elsif self.area_covered_units == 'ha' then
				self.area_covered_sqkm = self.area_covered.to_f / 100 # Convert to square kilometers
				self.area_covered_sqmi = nil
				self.area_covered_acres = nil
			else
				self.area_covered_acres = self.area_covered
				self.area_covered_sqmi = nil
				self.area_covered_sqkm = nil
			end
		else
			# For some reason I have to set this.  Otherwise, if a user enters a number, submits the sighting, gets an unrelated error, removes the number, and resubmits, they'll get an error about it not being a number
			# TODO Still the case in Rails 2.0?
			self.area_covered = nil
		end

		# Here, the unit conversion takes place
		begin
			if !self.distance_traveled_km.blank? then
				self.distance_traveled_mi = self.distance_traveled_km.to_f * MILES_PER_KILOMETER
			elsif !self.distance_traveled_mi.blank? then
				self.distance_traveled_km = self.distance_traveled_mi.to_f * KILOMETERS_PER_MILE
			end

			if !self.area_covered_sqkm.blank? then
				self.area_covered_sqmi = self.area_covered_sqkm.to_f * SQ_MILES_PER_SQ_KILOMETER
				self.area_covered_acres = self.area_covered_sqkm.to_f * ACRES_PER_SQ_KILOMETER
			elsif !self.area_covered_sqmi.blank? then
				self.area_covered_sqkm = self.area_covered_sqmi.to_f * SQ_KILOMETERS_PER_SQ_MILE
				self.area_covered_acres = self.area_covered_sqmi.to_f * ACRES_PER_SQ_MILE
			elsif !self.area_covered_acres.blank? then
				self.area_covered_sqkm = self.area_covered_acres.to_f * SQ_KILOMETERS_PER_ACRE
				self.area_covered_sqmi = self.area_covered_acres.to_f * SQ_MILES_PER_ACRE
			end
		rescue
			# If it fails, it fails
		end
	end

	# REALLY IMPORTANT VALIDATION!  Ensures that sightings are properly constrained based on trip dates and such
	validates_associated :sightings, :message => 'are invalid.  Ensure that all associated observations fall within the date range specified for your trip'

	validates_presence_of :name
	validates_uniqueness_of :name, :scope => :user_id

	validates_presence_of :date_year_start, :if => :science_trip?
	validates_numericality_of :date_year_start, :greater_than_or_equal_to => 1900, :message => 'is not valid', :if => :date_data_present?
	validates_presence_of :date_month_start, :if => :science_trip?
	validates_inclusion_of :date_month_start, :in => 1 .. 12, :message => 'is not valid', :if => :date_data_present?
	validates_presence_of :date_day_start, :if => :science_trip?
	validates_inclusion_of :date_day_start, :in => 1 .. 31, :message => 'is not valid', :if => :date_data_present?
	
	# We don't need to validate the end date on a science trip because it's autogenerated once we have a valid start date and duration
	validates_numericality_of :date_year_end, :greater_than_or_equal_to => 1900, :message => 'is not valid', :if => Proc.new {|trip| !trip.science_trip? and trip.date_data_present? }
	validates_inclusion_of :date_month_end, :in => 1 .. 12, :message => 'is not valid', :if => Proc.new {|trip| !trip.science_trip? and trip.date_data_present? }
	validates_inclusion_of :date_day_end, :in => 1 .. 31, :message => 'is not valid', :if => Proc.new {|trip| !trip.science_trip? and trip.date_data_present? }
	
	validates_presence_of :time_hour_start, :if => :science_trip?
	validates_presence_of :time_minute_start, :if => :science_trip?
	validates_inclusion_of :time_hour_start, :in => 0 .. 23, :message => 'is not valid', :if => :science_trip?
	validates_inclusion_of :time_minute_start, :in => 0 .. 59, :message => 'is not valid', :if => :science_trip?

	validates_presence_of :duration_hours, :if => :science_trip?
	validates_presence_of :duration_minutes, :if => :science_trip?
	validates_inclusion_of :duration_hours, :in => 0 .. 23, :message => 'is not valid', :if => :science_trip?
	validates_inclusion_of :duration_minutes, :in => 0 .. 59, :message => 'is not valid', :if => :science_trip?

	validates_inclusion_of :protocol, :in => ['casual', 'traveling', 'stationary', 'area'], :message => 'is not valid'

	validates_inclusion_of :all_observations_reported, :in => [true, false], :message => 'is not valid'

	validates_numericality_of :number_observers, :allow_nil => true, :only_integer => true

	validates_numericality_of :distance_traveled, :allow_nil => true
	validates_numericality_of :distance_traveled_km, :allow_nil => true
	validates_numericality_of :distance_traveled_mi, :allow_nil => true

	validates_numericality_of :area_covered, :allow_nil => true
	validates_numericality_of :area_covered_sqkm, :allow_nil => true
	validates_numericality_of :area_covered_sqmi, :allow_nil => true
	validates_numericality_of :area_covered_acres, :allow_nil => true

	validates_inclusion_of :private, :in => [true,false], :allow_nil => true


	def validate
		# FIXME This should really be taken care of in betternested set
		# Potentially confusing!
		# A move_to_child_of operation to a parent that's a science trip WILL SUCCEED.
		# Every time you do something like this, you should do it inside a transaction and check
		# valid? or maybe do a second save! after the move operation
		
		# Cannot have a parent that is a science trip
		if self.parent and self.parent.science_trip? then
			errors.add(:parent_id, 'cannot be a trip that uses the ' + self.parent.protocol + ' protocol')
		end

		# We don't have to check this if it's a new record.  Records that don't exist can't have children.
		if !self.new_record? and self.science_trip? and self.descendants.size > 0 then
			errors.add_to_base('Trips containing subtrips can be marked only as casual observation')
		end

		# Private trips can't have public children (don't check on new record)
		if !self.new_record? and self.private then
			self.descendants.each do |child|
				if !child.private then
					errors.add(:private, 'cannot be selected for trips with public subtrips')
					break
				end
			end
		end

		# Public trips cannot have private ancestors
		if self.parent and !self.private then
			self.ancestors.each do |ancestor|
				if ancestor.private then
					errors.add(:parent_id, '(or other ancestor) is private and therefore this trip must be private as well')
					break
				end
			end
		end

		if science_trip? then
			# Science trips should not have an end date filled out to start with.  We'll add one for them.
			# This is because science trips should never last more than 24 hours, but if they start late
			# in the day, there is a possibility that they will span 2 days, hence the need for calculation.

			self.date_year_end = self.date_month_end = self.date_day_end = nil # Start them out at nil to avoid extra errors about a user-filled in end date

			science_date_end = self.date_time_end
			# If it's nil, then it's invalid, and we've already set an error
			unless science_date_end.nil? then
				self.date_year_end = science_date_end.year
				self.date_month_end = science_date_end.month
				self.date_day_end = science_date_end.day
			end

			if self.protocol == 'traveling' then
				error_msg = 'required for traveling protocol'

				if self.distance_traveled_km.blank? or self.distance_traveled_mi.blank? then
					errors.add(:distance_traveled, error_msg)
				end

				errors.add(:distance_traveled_km, error_msg) if self.distance_traveled_km.blank?
				errors.add(:distance_traveled_mi, error_msg) if self.distance_traveled_mi.blank?

				[:area_covered_sqkm, :area_covered_sqmi, :area_covered_acres].each do |field|
					unless read_attribute(field).nil? then
						# Rather than set an error, just do the right thing
						write_attribute(field, nil)
					end
				end
			elsif self.protocol == 'area' then
				error_msg = 'required for area protocol'

				if self.area_covered_sqkm.blank? or self.area_covered_sqmi.blank? or self.area_covered_acres.blank? then
					errors.add(:area_covered, error_msg)
				end

				errors.add(:area_covered_sqkm, error_msg) if self.area_covered_sqkm.blank?
				errors.add(:area_covered_sqmi, error_msg) if self.area_covered_sqmi.blank?
				errors.add(:area_covered_acres, error_msg) if self.area_covered_acres.blank?

				[:distance_traveled_km, :distance_traveled_mi].each do |field|
					unless read_attribute(field).nil? then
						# Rather than set an error, just do the right thing
						write_attribute(field, nil)
					end
				end
			elsif self.protocol == 'stationary'
				[:area_covered_sqkm, :area_covered_sqmi, :area_covered_acres, :distance_traveled_km, :distance_traveled_mi].each do |field|
					unless read_attribute(field).nil? then
						# Rather than set an error, just do the right thing
						write_attribute(field, nil)
					end
				end

			else
				raise "Unknown science trip protocol: #{self.protocol}"
			end
		else
			# Not a science trip! And therefore can't have any of these sciencey fields
			[:time_hour_start, :time_minute_start, :duration_hours, :duration_minutes, :distance_traveled_mi, :distance_traveled_km, :area_covered_acres, :area_covered_sqmi, :area_covered_sqkm].each do |field|
				unless read_attribute(field).nil? then
					# Rather than set an error, just do the right thing
					write_attribute(field, nil)
				end
			end
		end

		if !date_year_start.blank? && !date_month_start.blank? && !date_day_start.blank? then
			begin
				if !Date.valid_civil?(date_year_start, date_month_start, date_day_start) then
					errors.add(:date_start, 'is invalid')
				end
			rescue
				errors.add(:date_start, 'is invalid')
			end
		end

		if !science_trip? && !date_year_end.blank? && !date_month_end.blank? && !date_day_end.blank? then
			begin
				if !Date.valid_civil?(date_year_end, date_month_end, date_day_end) then
					errors.add(:date_end, 'is invalid')
				end
			rescue
				errors.add(:date_end, 'is invalid')
			end
		end

		if !date_start.nil? and !date_end.nil? then
			if date_start > date_end then
				errors.add(:date_end, "occurs before starting date")
			end
		end
	end

	def date_time_start
		raise "Cannot do this calculation on non-science trips" unless science_trip?
		time = nil
		begin
			time = Time.gm(self.date_year_start, self.date_month_start, self.date_day_start, self.time_hour_start, self.time_minute_start)
		rescue
                        errors.add(:date_start, 'is invalid')
		end
		return time
	end

	def date_time_end
		raise "Cannot do this calculation on non-science trips" unless science_trip?
		time = nil
		begin
			time = self.date_time_start + self.duration_hours.hours + self.duration_minutes.minutes
		rescue
                        errors.add(:date_start, 'is invalid')
		end
		return time
	end

	def date_start
		begin
			return Date.civil(date_year_start, date_month_start, date_day_start)
		rescue
			return nil
		end
	end

	def date_end
		begin
			return Date.civil(date_year_end, date_month_end, date_day_end)
		rescue
			return nil
		end
	end

	def before_save
		unless self.comment_collection then
			c = TripCommentCollection.new(:title => self.user.login + "'s trip")
			c.user = self.user
			c.save!
			self.comment_collection = c
		end
	end


	# We want to validate all the sightings before we allow this to get saved, but we can't validate the sightings until
	# the changes the science trip have been saved.  So, I override the save method here and wrap everything in a transaction
	# so I can save the science trip, then validate all the sightings based on the new info.
	#
	# Note that there are ways to get around this and the valid? method doesn't work.  We'll just have to be careful
	alias :save_orig! :save!

	def save!
		save or raise(RecordNotSaved)
	end

	def save
		begin
			transaction do
				save_orig!
				# Now we need to forget everything we've cached
				self.reload
				unless self.valid? then
					self.errors.add_to_base('Error saving trip')
					raise(ActiveRecord::RecordInvalid.new(self))
				end
			end
		rescue ActiveRecord::RecordInvalid
			return false
		end

		return true
	end

	def date_data_present?
		!date_year_start.blank? || !date_month_start.blank? || !date_day_start.blank? || !date_year_end.blank? || !date_month_end.blank? || !date_day_end.blank?
	end

	TRIPS_ORDER_BY = 'ISNULL(trips.date_year_start), trips.date_year_start DESC, ISNULL(trips.date_month_start), trips.date_month_start DESC, ISNULL(trips.date_day_start), trips.date_day_start DESC, ISNULL(trips.time_hour_start), trips.time_hour_start DESC, ISNULL(trips.time_minute_start), trips.time_minute_start DESC, trips.created_at DESC'

	def after_save
		# Reordering fu!
		parent_ids = [nil]
		while(parent_ids.size > 0) do
			trips = user.trips.find(:all, :conditions => {:parent_id => parent_ids.pop}, :order => TRIPS_ORDER_BY)
			parent_ids += trips
			1.upto(trips.size - 1) do |i|
				trips[i].move_to_right_of(trips[i-1])
			end
		end
                
                if self.private_changed? then
                  c = self.comment_collection
                  c.private = self.private
                  c.save!

                  self.trip_photo.each do |sp|
                    sp.save!
                  end
                end
	end

	def after_destroy
		self.comment_collection.destroy
	end
end
