class PendingImportItem < ActiveRecord::Base
	belongs_to :pending_import

	validates_presence_of :pending_import
	validates_presence_of :english_name

	def self.per_page
		100
	end

	attr_accessible :english_name, :line

	attr_accessor :sighting

	# Covers everything but location/trip finding/creating and saving
	def pre_realization(validate = true)
		# Can't do this without a user.  This could be the case if we aren't yet associated with a pending import
		return false unless self.pending_import and self.pending_import.user
		user = self.pending_import.user

		# Now create a sighting object
		# Note that this has to happen even if we don't find a species.  We will use the rest of the attributes on the object
		# to prefill the sighting in the sighting controller after the user selects a valid species
		@sighting = Sighting.new(self.attributes)
		@sighting.user = user

		# Try to find a matching english species name
		species = Species.find_valid_by_exact_english_name(self.english_name)

		return false if species.nil?

		@sighting.species = species

		# Make sure there are no notifications
		return false if species.notification and !user.ignored_notifications.find_by_notification_id(species.notification.id)

		# Optional validation.  We don't need to validate if we're going to do the realize step
		if validate then
			return @sighting.valid?
		else
			return true
		end
	end

	def realize_without_save(validate = true)
		# Can't do this without a user.  This could be the case if we aren't yet associated with a pending import
		return nil unless self.pending_import and self.pending_import.user
		user = self.pending_import.user

		pre_realized = self.pre_realization(validate)

		# Carry over eBird marking
		if self.pending_import.ebird_exclude then
			@sighting.ebird_exclude = true
		end

		# Find location
		if !self.location_name.blank? then
			@sighting.user_location = user.user_locations.find_or_create_by_name(self.location_name)
		end

		# Find Trip
		if !self.trip_name.blank? then
			@sighting.trip = user.trips.find_or_create_by_name(self.trip_name)
		end

		if !pre_realized then
			return false
		else
			# Optional validation.  We don't need to validate if we're going to do the realize step
			if validate then
				return @sighting.valid?
			else
				return true
			end
		end
	end

	def realize(batch = nil)
		realize_without_save(false)

		# Have the ability to mark this as part of a batch process, which skips updating cache stuff
		@sighting.batch = batch

		return @sighting.save
	end
end
