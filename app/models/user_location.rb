class UserLocation < ActiveRecord::Base
	belongs_to :country_code
	belongs_to :user
	belongs_to :comment_collection

        has_many   :user_location_photo, :dependent => :destroy
        accepts_nested_attributes_for :user_location_photo

	acts_as_taggable

	has_many :sightings

	validates_presence_of	:name
	validates_uniqueness_of	:name, :scope => :user_id
	
	validates_presence_of :user_id

	validates_numericality_of :latitude, :allow_nil => true
	validates_numericality_of :longitude, :allow_nil => true

	validates_presence_of :latitude, :if => :longitude, :message => 'is required with longitude'
	validates_presence_of :longitude, :if => :latitude, :message => 'is required with latitude'

	validates_format_of :ecoregion, :with => /\A(AA|AN|AT|IM|NA|NT|OC|PA)[0-9]{4}\z/, :if => Proc.new { |user_location| !user_location.ecoregion.blank? }

	validates_numericality_of :elevation, :allow_nil => true
	validates_numericality_of :elevation_m, :allow_nil => true
	validates_numericality_of :elevation_ft, :allow_nil => true

	validates_inclusion_of :private, :in => [0,1,2], :allow_nil => true

	validates_http_url :link

	attr_accessible :cc, :adm1, :adm2, :location, :name, :notes, :latitude, :longitude, :zoom, :source, :ecoregion, :elevation_m, :elevation_ft, :elevation, :elevation_units, :private, :tag_list, :link, :user_location_photo_attributes

	# Virtual fields for unit data
	attr_accessor :elevation, :elevation_units
	# This alias is required because I want to do Rails validation on the elevation "facade" column and the validation routine calls the _before_type_cast version of the field (which for our purposes is the same)
	alias :elevation_before_type_cast :elevation

	# User locations have finer grained privacy.  1 means only the coordinates are private.  2 means everything is private.
	def publicize!(user = nil)
		raise 'Attempted to republicize user location ' + self.id.to_s + ' for ' + (user ? user.login : 'nil') + ' already done for ' + (@publicized_for ? @publicized_for.login : 'nil') if @publicized and @publicized_for != user

		return self if @publicized

		if self.user == user then
			# Do nothing
		elsif self.private == 2 then
			raise 'Attempted to publicize user location ' + self.id.to_s
		elsif self.private == 1 then
			[:latitude, :longitude, :zoom, :source].each {|a| self.write_attribute(a, nil)}
			# Scrub our private status
			self.private = nil
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

	# This will find privacy of levels 0 (everything) and 1 (only coordinates are restricted)
        named_scope :public, :conditions => ['user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1']

	def self.find_public_by_id(id, user = nil)
          user_location = self.public.first(:conditions => {:id => id})
          user_location.publicize!(user) if user_location
          return user_location
	end
	
	def self.find_public_by_user(user, publicize_for = nil, options = {})
          options[:order] ||= 'user_locations.name'
          self.public.all(options.merge(:conditions => {:user_id => user.id})).collect do |user_location|
            user_location.publicize!(publicize_for)
          end
	end

        def sighting_photos(public_only = false)
          if public_only then
            SightingPhoto.user_location_id(self.id).public
          else
            SightingPhoto.user_location_id(self.id)
          end
        end

	def merge_into(new_location)
		return false unless self.user == new_location.user
		begin
			UserLocation.transaction do
				self.sightings.update_all({:user_location_id => new_location.id})
				self.reload
				unless self.sightings.size == 0 then
					raise 'Something went wrong with the merge'
				end
				self.destroy
			end
		rescue
			return false
		end

		return true
	end

	def before_validation
		if(self.name.blank?) then
			if !self.location.blank? then
				self.name = self.location
			elsif !self.adm2.blank? then
				self.name = self.adm2
			elsif !self.adm1.blank? then
				self.name = self.adm1
			elsif !self.cc.blank? then
				self.name = CountryCode.country_name(self.cc)
			end
		end

		if !self.elevation.blank? then
			if self.elevation_units == 'ft' then
				self.elevation_ft = self.elevation
				self.elevation_m = nil
			else
				self.elevation_m = self.elevation
				self.elevation_ft = nil
			end
		else
			# For some reason I have to set this.  Otherwise, if a user enters a number, submits the sighting, gets an unrelated error, removes the number, and resubmits, they'll get an error about it not being a number
			self.elevation = nil
		end

		begin
			if !self.elevation_m.blank? then
				self.elevation_ft = self.elevation_m.to_f * FEET_PER_METER
			elsif !self.elevation_ft.blank? then
				self.elevation_m = self.elevation_ft.to_f * METERS_PER_FOOT
			end
		rescue
			# If it fails, it fails
		end
		
		# Make the ecoregion all upper case
		unless self.ecoregion.nil? then
			self.ecoregion = self.ecoregion.to_s.upcase
		end
	end

	def after_destroy
		self.comment_collection.destroy
	end

	def before_save
		unless self.comment_collection then
			c = UserLocationCommentCollection.new(:title => self.user.login + "'s location")
			c.user = self.user
			c.save!
			self.comment_collection = c
		end
	end

        def after_save
          if self.private_changed? then
            c = self.comment_collection
            # Only count it as private if the privacy level is 2
            c.private = self.private == 2 ? true : false
            c.save!

            self.user_location_photo.each do |sp|
              sp.save!
            end
          end
        end
end
