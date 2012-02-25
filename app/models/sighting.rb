class Sighting < ActiveRecord::Base
	belongs_to	:user
	belongs_to	:species
	belongs_to	:user_location
	belongs_to	:trip
	belongs_to	:comment_collection
	belongs_to      :sighting_activity
        has_many        :sighting_photo, :dependent => :destroy
        accepts_nested_attributes_for :sighting_photo

	acts_as_taggable

	AGE_SEX_COUNT = [:juvenile_male, :juvenile_female, :juvenile_unknown, :immature_male, :immature_female, :immature_unknown, :adult_male, :adult_female, :adult_unknown, :unknown_male, :unknown_female, :unknown_unknown]

	attr_accessible :species_id, :user_location_id, :date_day, :date_month, :date_year, :trip_id, :species_count, :notes, :time_hour, :time_minute, :private, :tag_list, :link, :sighting_photo_attributes, *AGE_SEX_COUNT

	attr_accessor :batch

	validates_numericality_of :species_count, :allow_nil => true, :greater_than => 0
	validates_presence_of :date_month, :if => :date_day, :message => 'is required with day'
	validates_presence_of :date_year, :if => :date_month, :message => 'is required with month'
	# Using Date.tomorrow.year is a cheap trick to avoid timezone issues, but it should work
	validates_inclusion_of :date_year, :in => 1900 .. Date.tomorrow.year, :allow_nil => true, :message => 'is not valid'
	validates_inclusion_of :date_month, :in => 1 .. 12, :allow_nil => true, :message => 'is not valid'
	validates_inclusion_of :date_day, :in => 1 .. 31, :allow_nil => true, :message => 'is not valid'
	validates_inclusion_of :time_hour, :in => 0 .. 23, :allow_nil => true, :message => 'is not valid'
	validates_inclusion_of :time_minute, :in => 0 .. 59, :allow_nil => true, :message => 'is not valid'
	validates_presence_of :time_hour, :if => :time_minute, :message => 'is required with minute'
	validates_presence_of :time_minute, :if => :time_hour, :message => 'is required with hour'
	validates_inclusion_of :private, :in => [true,false], :allow_nil => true
	validates_presence_of :species

	validates_http_url :link

	def publicize!(user = nil)
		if @publicized and @publicized_for != user then
			raise 'Attempted to republicize sighting ' + self.id.to_s + ' for ' + (user ? user.login : 'nil') + ' when already publicized for ' + (@publicized_for ? @publicized_for.login : @publicized_for)
		end

		return self if @publicized

		if self.user == user then
			# Do nothing
		elsif self.private then
			raise 'Attempted to publicize sighting ' + self.id.to_s
		else
			# Scrub our potentially private associations
			if self.user_location then
				if self.user_location.private == 2 then
					self.user_location = nil
				else
					self.user_location.publicize!(user)
				end
			end
			if self.trip then
				if self.trip.private then
					self.trip = nil
				else
					self.trip.publicize!(user)
				end
			end

			# Scrub our private status
			self.private = nil
		end

		@publicized = true
		@publicized_for = user

		self.readonly!
		self.freeze
		
		return self
	end

        named_scope :public, :conditions => ['sightings.private IS NULL OR sightings.private = 0']

	def self.find_public_by_id(id, user = nil)
          sighting = self.public.first(:conditions => {:id => id})
          sighting.publicize!(user) if sighting
          return sighting
	end

	def self.find_public_recent(limit = 10)
          self.public.all(:order => 'created_at DESC', :limit => limit).collect do |sighting|
            sighting.publicize!
          end
	end

	def self.paginate_for_map(species_id, options)
		options ||= {}
		# This query has to check the privacy settings on the location because even though the location might
		# have lat/lon, it might be private
		sightings = send(:paginate, options.merge({:conditions => ['(sightings.private IS NULL OR sightings.private = 0) AND sightings.species_id = ? AND sightings.user_location_id IS NOT NULL AND user_locations.latitude IS NOT NULL AND user_locations.longitude IS NOT NULL AND (user_locations.private IS NULL OR user_locations.private = 0)', species_id], :joins => 'LEFT JOIN user_locations ON sightings.user_location_id = user_locations.id', :order => 'ISNULL(sightings.date_year), sightings.date_year DESC, ISNULL(sightings.date_month), sightings.date_month DESC, ISNULL(sightings.date_day), sightings.date_day DESC, ISNULL(sightings.time_hour), sightings.time_hour DESC, ISNULL(sightings.time_minute), sightings.time_minute DESC, sightings.created_at DESC'}))
		sightings.each {|sighting| sighting.publicize!(nil) }
		return sightings
	end

	def self.paginate_for_map_for_user(species_id, user_id, options)
		options ||= {}
		# This query will find private observations
		sightings = send(:paginate, options.merge({:conditions => ['sightings.species_id = ? AND sightings.user_id = ? AND sightings.user_location_id IS NOT NULL AND user_locations.latitude IS NOT NULL AND user_locations.longitude IS NOT NULL', species_id, user_id], :joins => 'LEFT JOIN user_locations ON sightings.user_location_id = user_locations.id', :order => 'ISNULL(sightings.date_year), sightings.date_year DESC, ISNULL(sightings.date_month), sightings.date_month DESC, ISNULL(sightings.date_day), sightings.date_day DESC, ISNULL(sightings.time_hour), sightings.time_hour DESC, ISNULL(sightings.time_minute), sightings.time_minute DESC, sightings.created_at DESC'}))
		return sightings
	end

	def before_validation
		# Fill in the minute as 0 if they've put an hour in
		if !self.time_hour.blank? and self.time_minute.blank? then
			self.time_minute = 0
		end
	end

	def validate
		unless Date.valid_civil?(date_year || Time.now.year, date_month || 1, date_day || 1) then
			errors.add(:date, 'is invalid')
		else
			date = Date.civil(date_year || Time.now.year, date_month || 1, date_day || 1)
			# Use tomorrow to get around timezone issues
			errors.add(:date, 'is in the future') if date > Date.tomorrow
		end

		# TODO This should be tested
		if self.trip_id then
			if Trip.find_by_id(self.trip_id).blank? then
				errors.add(:trip_id, 'does not exist')
			elsif self.trip.user != self.user then
				errors.add(:trip_id, 'does not belong to you')
			end
		end

		# TODO This should be tested
		if self.user_location_id then
			if UserLocation.find_by_id(self.user_location_id).blank? then
				errors.add(:user_location_id, 'does not exist')
			elsif self.user_location.user != self.user then
				errors.add(:user_location_id, 'does not belong to you')
			end
		end

		# Ensure that we match up with the science trip, if needed
		if self.trip and self.trip.science_trip? then
			science_trip = self.trip

			start_time = science_trip.date_time_start
			end_time = science_trip.date_time_end

			observation_time = nil
			begin
				# Note that we default to the start time of the science trip if we don't have sighting time info
				# this is because we allow sighting times to be blank, but for validation purposes, we need
				# to set them to something that will always work.
				# This is further complicated by start and end times that span days.  Bleh
				time_minute = self.time_minute.to_i
				time_hour = self.time_hour.to_i
				if(self.time_minute.nil? and self.time_hour.nil?) then
					# Is the sighting on the starting day?
					if(self.date_year.to_i == start_time.year and
					   self.date_month.to_i == start_time.month and
					   self.date_day.to_i == start_time.day) then
						time_minute = start_time.min
						time_hour = start_time.hour
					# or maybe the ending day?
					elsif(self.date_year.to_i == start_time.year and
					      self.date_month.to_i == start_time.month and
					      self.date_day.to_i == start_time.day) then
						time_minute = start_time.min
						time_hour = start_time.hour
					end
				end

				observation_time = Time.gm(self.date_year.to_i, self.date_month.to_i, self.date_day.to_i, time_hour, time_minute)
			rescue ArgumentError
				# we'll set an error later
			end

			if observation_time.nil? then
				errors.add(:datetime, 'must fall within the time period specified for the trip')
			else
				if observation_time < start_time then
					errors.add(:datetime, 'cannot occur before the beginning of the trip')
				end

				if observation_time > end_time then
					errors.add(:datetime, 'cannot occur after the end of the trip')
				end
			end
		elsif self.trip and !self.trip.science_trip? and !self.trip.date_start.nil? then
			# We're not a science trip, but if there are dates set, then we must abide by them
			# Note that it's okay to have no date, it's just that if we have one, it must be within the range
			# We only need to check for the existence of the start date because if there's a start date, there must be an end date

			observation_date = nil

			begin
				observation_date = Date.civil(self.date_year.to_i, self.date_month.to_i, self.date_day.to_i)
			rescue ArgumentError
				# No big deal if the date didn't work out, we check for nil later
			end

			unless observation_date.nil? then
				if observation_date < self.trip.date_start then
					errors.add(:date, 'cannot occur before the beginning of the trip')
				end

				if observation_date > self.trip.date_end then
					errors.add(:date, 'cannot occur after the end of the trip')
				end
			end
		end

		# We don't start modifying and validating unless they filled in something because we want to allow nulls
		# but the moment they do specify something, we convert everything to integers (filling in zeros where it
		# was blank before) and validate
		if AGE_SEX_COUNT.detect {|i| !read_attribute(i).blank? } then
			# Prepare for species count validation
			# Make sure we're dealing with all integers, and make sure they're all positive
			AGE_SEX_COUNT.each do |i|
				# We have to specifically get these before they're typecast to look at them as strings
				unless self.send((i.to_s+'_before_type_cast')).to_s =~ /\A[0-9]*\z/ then
					errors.add(:age_sex, 'must contain whole, non-negative numbers')
					# We can't do any more checks at this point
					return
				else
					write_attribute(i, read_attribute(i).to_i) unless read_attribute(i).blank?
				end
			end
			
			# Okay, they put at least some valid numbers in, time to start adding
			self.species_count = self.species_count.to_i

			# If they left the overall count blank, figure it out for them
			if self.species_count == 0 then
				AGE_SEX_COUNT.each {|i| self.species_count += read_attribute(i).to_i }
			end

			# If the total individual counts doesn't add up to the overall total, and they haven't filled in the unknown-unknown field, use it to make the numbers add up
			if self.unknown_unknown.blank? then
				individual_totals = 0
				(AGE_SEX_COUNT - [:unknown_unknown]).each{|i| individual_totals += read_attribute(i).to_i}
				discrepancy = self.species_count - individual_totals
				self.unknown_unknown = discrepancy if discrepancy >= 0
			end

			# Now we validate
			individual_totals = 0
			AGE_SEX_COUNT.each{|i| individual_totals += read_attribute(i).to_i}

			unless individual_totals == self.species_count then
				errors.add(:species_count, 'does not equal total of individual counts')
			end

			# One final sanity check
			if(self.species_count < 0) then
				errors.add(:species_count, 'cannot be negative')
			end
		end
	end

	def before_save
		unless self.comment_collection then
			c = SightingCommentCollection.new(:title => self.user.login + "'s observation")
			c.user = self.user
			c.save!
			self.comment_collection = c
		end
	end

	def after_save
		# Don't bother to update the cached counts if this is a part of a batch addition
                self.user.batch = self.batch
                self.user.update_cached_counts

                if self.private_changed? then
                  c = self.comment_collection
                  c.private = self.private
                  c.save!
                end

                # Because of our default_scope in the photos, this will not update photos that
                # haven't finished processing.  But, once they have finished processing, they'll
                # get updated anyway.  So it's alright
                if self.private_changed? or self.species_id_changed? or 
                    self.trip_id_changed? or self.user_location_id_changed? then
                  self.sighting_photo.reload
                  self.sighting_photo.each do |sp|
                    sp.fill_in_cached_values
                    sp.save!
                  end
                end
	end

	def after_destroy
		self.comment_collection.destroy

                self.user.batch = self.batch
                self.user.update_cached_counts
	end
end
