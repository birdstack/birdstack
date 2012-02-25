require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :remember_me_cookies, :dependent => :destroy
  has_many :password_recovery_codes, :dependent => :destroy
  belongs_to :comment_collection
  has_many :user_locations, :order => 'user_locations.name'
  has_many :sightings
  has_many :comments, :dependent => :destroy
  has_many :trips
  has_many :saved_searches
  has_many :ignored_notifications
  has_many :pending_imports
  has_many :ebird_exports
  has_many :message_references
  has_and_belongs_to_many :conversations
  has_many :friend_relationships
  has_many :friends, :through => :friend_relationships
  has_many :friend_requests
  has_many :outgoing_friend_requests, :class_name => "FriendRequest", :foreign_key => "potential_friend_id", :dependent => :destroy

  has_many :sighting_activities
  has_many :sighting_photo_activities
  has_many :trip_photo_activities
  has_many :user_location_photo_activities
  has_many :activities

  has_many :sighting_photos
  has_many :trip_photos
  has_many :user_location_photos

  has_attached_file :profile_pic,
    :styles => {:normal => "150", :small => "32"},
    :processors => [:imagescience],
    :default_url => "/images/binoc_:style.png",
    :path => ":rails_root/user_data/public/:attachment/:id_partition/:style/:filename",
    :url => "/user_data/:attachment/:id_partition/:style/:filename"

  has_attached_file :export,
    :path => ":rails_root/user_data/private/:class/:attachment/:id_partition/:filename",
    :url  => "/export/download"

  validates_attachment_content_type :profile_pic, :content_type => /jpe?g|gif|png/i
  validates_attachment_size :profile_pic, :less_than => 10.megabytes


  # Description should be plural (e.g. "newsletters")
  # Changing the short codes will cause unsubscribe links to stop working!
  NOTIFICATION_TYPES = {
    :notify_newsletter => {
      :short => 'n',
      :desc => 'newsletters',
      :sort => 1
    },
    :notify_message => {
      :short => 'm',
      :desc => 'conversation updates',
      :sort => 2
    },
    :notify_friend_request => {
      :short => 'fr',
      :desc => 'friend requests',
      :sort => 3
    },
    :notify_taxonomy_changes => {
      :short => 'xc',
      :desc => 'pending taxonomy changes',
      :sort => 4
    },
    :notify_membership => {
      :short => 's',
      :desc => 'supporting membership updates',
      :sort => 5
    },

    :notify_forum_comment => {
      :short => 'fc',
      :desc => 'forum comments',
      :sort => 6,
    },
    :notify_user_location_comment => {
      :short => 'lc',
      :desc => 'location comments',
      :sort => 7,
    },
    :notify_sighting_comment => {
      :short => 'oc',
      :desc => 'observation comments',
      :sort => 8,
    },
    :notify_photo_comment => {
      :short => 'sc',
      :desc => 'photo comments',
      :sort => 9,
    },
    :notify_profile_comment => {
      :short => 'pc',
      :desc => "profile comments",
      :sort => 10,
    },
    :notify_trip_comment => {
      :short => 'tc',
      :desc => 'trip comments',
      :sort => 11,
    },
  }

  attr_accessible :login, :email, :email_confirmation, :password, :password_confirmation, :captcha, :captcha_code, :user_agreement, :age_verification, :gender, :website, :bio, :location, :signature, :default_trip_private, :default_user_location_private, :default_observation_private, :cc, :tag_list,  :time_zone, :time_24_hr, :time_day_first, :profile_pic, :default_photo_license, *NOTIFICATION_TYPES.keys

  apply_simple_captcha

  acts_as_taggable

  before_validation_on_create :add_activation_code

  # Virtual attribute for the unencrypted password
  attr_accessor :password, :password_confirmation, :user_agreement, :age_verification

  attr_accessor :batch

  validates_presence_of     :login, :email, :crypted_password, :salt, :activation_code
  validates_confirmation_of :email

  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_uniqueness_of   :activation_code

  validates_format_of       :email, :with => RFC822::EmailAddress

  validates_presence_of     :password, :password_confirmation,	:if => :password_required?
  validates_length_of       :password, :minimum => 6,		:if => :password_required?
  validates_confirmation_of :password,				:if => :password_required?

  validates_length_of       :login,    :within => 4..15

  validates_format_of       :login, :with => /\A[a-zA-Z][a-zA-Z0-9_-]*\z/

  validates_acceptance_of   :user_agreement
  validates_acceptance_of   :age_verification

  validates_inclusion_of    :gender, :in => %w( m f ), :allow_nil => true, :message => 'is not valid'

  validates_length_of       :signature, :maximum => 1000, :allow_nil => true

  validates_inclusion_of    :default_trip_private, :in => [true,false], :allow_nil => true
  validates_inclusion_of    :default_user_location_private, :in => [0,1,2], :allow_nil => true
  validates_inclusion_of    :default_observation_private, :in => [true,false], :allow_nil => true

  validates_http_url	    :website
	  

  def validate
	  if self.login =~ /\A(admin|superuser|root|sysop|birdstack|www|administrator|moderator|blog|you)\z/i then
		  errors.add(:login, 'is not allowed')
	  end
    if self.email =~ /@yeah.net|@163.com/ then
      errors.add(:email, 'is from an invalid provider')
    end
  end

  named_scope :valid, :conditions => ['activated_at IS NOT NULL']

  def photo_upload_limit
    if(self.supporting_member) then
      250
    else
      50
    end
  end

  def self.available_photo_licenses
    [
      ['All Rights Reserved', 'all-rights-reserved'],
      ['CC Attribution', 'cc-by'],
      ['CC Attribution Share Alike', 'cc-by-sa'],
      ['CC Attribution No Derivatives', 'cc-by-nd'],
      ['CC Attribution Non-Commercial', 'cc-by-nc'],
      ['CC Attribution Non-Commercial Share Alike','cc-by-nc-sa'],
      ['CC Attribution Non-Commercial No Derivatives', 'cc-by-nc-nd'],
    ]
  end

  def random_friends(count = 5)
    pool = self.friends.find(:all, :select => 'users.id') # We don't need to pull the entire record yet
    randoms = []
    1.upto(count) do
      break if pool.empty?
      randoms << self.friends.find_by_id(pool.slice!(rand(pool.length)).id)
    end
    randoms
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # Note that the login search is case insensitive.  We can do this because we validate
    # uniqueness without regard to case
    u = find(:first, :conditions => ['login like ? AND activated_at IS NOT NULL', login]) # need to get the salt
    u && encrypt(password, u.salt) == u.crypted_password ? u : nil
  end

  def self.find_recently_activated(limit = 10)
	  User.find(:all, :conditions => ['users.activated_at IS NOT NULL'], :order => 'activated_at DESC', :limit => limit)
  end

  def self.find_top_contributors(limit = 10)
	  User.find(:all, :conditions => ['users.activated_at IS NOT NULL AND public_observations IS NOT NULL'], :order => 'public_observations DESC', :limit => limit)
  end

  def self.find_random(limit = 5)
	  max = User.connection.select_one('SELECT MAX(id) as max FROM users WHERE activated_at IS NOT NULL AND profile_pic_file_name IS NOT NULL')['max'].to_i
	  users = []
          tries = 0
	  while (users.size < limit && tries < limit*2) do
		  users << User.find(:first, :conditions => ['users.activated_at IS NOT NULL AND profile_pic_file_name IS NOT NULL AND id >= ?', rand(max) + 1], :limit => 1)
                  users.compact!
                  users.uniq!
                  tries += 1
	  end

          if(users.size > 0 and users.size < limit) then
            while(users.size < limit) do
              users << users[-1]
            end
            users.shuffle!
          end

	  users
  end

  def update_cached_counts
          # TODO possible cache inefficiency here: 
          # Because this method will save a user, the SearchSweeper will wipe out all cached fragments for that
          # user.  However, because these cached counts shouldn't affect (most?) display stuff, we could probably
          # skip the cache invalidation.
          return if self.batch

	  self.public_observations = self.sightings.count(:conditions => ['private = 0 OR private IS NULL'])
	  self.pending_taxonomy_changes = self.pending_taxonomy_changes_count > 0 ? true : false

	  self.save
  end

  def password=(pwd)
	  @password = pwd
	  self.salt = create_salt
	  self.crypted_password = self.class.encrypt(password, salt)
  end

    # Activates the user in the database.
    def activate
	    return unless activated_at.nil?
	    if created_at + ACCOUNT_ACTIVIATION_TIMEOUT < Time.now then
		    self.destroy

		    false
	    else
		    @activated = activated_at.nil? and update_attribute(:activated_at, Time.now)
	    end
    end

    def before_destroy
	    # We have to disassociate ourselves from the comment collection first, or else foreign key constraints will fail
	    c = self.comment_collection
	    if c then
		    c.user = nil
		    c.save!
	    end
    end

    def after_destroy
	    # Now we can delete the comment collection
	    if self.comment_collection then
		    self.comment_collection.destroy
	    end
    end

    # Returns true if the user has just been activated.
    def recently_activated?
      @activated
    end

	def searchable_location_locations
		# Only returns the names of the unique records, nothing else!
		# This lets me do a DISTINCT query, but we can't know anything else about the object
		self.user_locations.find(:all, :select => 'DISTINCT user_locations.location, user_locations.adm2, user_locations.adm1, user_locations.cc', :conditions => ['user_locations.location IS NOT NULL AND user_locations.location != ""'], :order => 'user_locations.location')
	end

	def searchable_location_adm2s
		# Only returns the names of the unique records, nothing else!
		# This lets me do a DISTINCT query, but we can't know anything else about the object
		self.user_locations.find(:all, :select => 'DISTINCT user_locations.adm2, user_locations.adm1, user_locations.cc', :conditions => ['user_locations.adm2 IS NOT NULL AND user_locations.adm2 != ""'], :order => 'user_locations.adm2')
	end

	def searchable_location_adm1s
		# Only returns the names of the unique records, nothing else!
		# This lets me do a DISTINCT query, but we can't know anything else about the object
		self.user_locations.find(:all, :select => 'DISTINCT user_locations.adm1, user_locations.cc', :conditions => ['user_locations.adm1 IS NOT NULL AND user_locations.adm1 != ""'], :order => 'user_locations.adm1')
	end

	def searchable_location_ccs
		# Only returns the name, nothing else!
		# This lets me do a DISTINCT query, but we can't know anything else about the object
		self.user_locations.find(:all, :select => 'DISTINCT user_locations.cc', :conditions => ['user_locations.cc IS NOT NULL AND user_locations.cc != ""'], :joins => 'LEFT OUTER JOIN country_codes ON user_locations.cc = country_codes.cc', :order => 'country_codes.name, user_locations.cc')
	end

	def searchable_species
		species_ids = self.sightings.find(:all, :select => 'DISTINCT species_id').collect {|i| i.species_id}

		# It's better to do the search here and grab all the info in one query than hand the template a bunch of ids and have it generate lots of queries
		Species.find(:all, :conditions => {:id => species_ids}, :order => 'species.sort_order ASC')
	end

	def searchable_orders
		order_ids = Order.find(:all, :select => 'DISTINCT orders.id', :conditions => ['sightings.user_id = ?', self.id], :joins => 'INNER JOIN families ON families.order_id = orders.id INNER JOIN genera ON genera.family_id = families.id INNER JOIN species ON species.genus_id = genera.id INNER JOIN sightings ON sightings.species_id = species.id').collect {|i| i.id }

		# It's better to do the search here and grab all the info in one query than hand the template a bunch of ids and have it generate lots of queries
		Order.find(:all, :conditions => {:id => order_ids}, :order => 'orders.sort_order ASC')
	end

	def searchable_families
		family_ids = Family.find(:all, :select => 'DISTINCT families.id', :conditions => ['sightings.user_id = ?', self.id], :joins => 'INNER JOIN genera ON genera.family_id = families.id INNER JOIN species ON species.genus_id = genera.id INNER JOIN sightings ON sightings.species_id = species.id').collect {|i| i.id }

		# It's better to do the search here and grab all the info in one query than hand the template a bunch of ids and have it generate lots of queries
		Family.find(:all, :conditions => {:id => family_ids}, :order => 'families.sort_order ASC')
	end

	def searchable_genera
		genus_ids = Genus.find(:all, :select => 'DISTINCT genera.id', :conditions => ['sightings.user_id = ?', self.id], :joins => 'INNER JOIN species ON species.genus_id = genera.id INNER JOIN sightings ON sightings.species_id = species.id').collect {|i| i.id }

		# It's better to do the search here and grab all the info in one query than hand the template a bunch of ids and have it generate lots of queries
		Genus.find(:all, :conditions => {:id => genus_ids}, :order => 'genera.sort_order ASC')
	end

	def searchable_ecoregions
		self.user_locations.find(:all, :select => 'DISTINCT user_locations.ecoregion', :conditions => ['user_locations.ecoregion IS NOT NULL AND user_locations.ecoregion != ""'], :order => 'user_locations.ecoregion').collect {|i| i.ecoregion }
	end

	def find_pending_taxonomy_changes(change_type = nil, count = false)
		conditions = 'sightings.user_id = ?'
		params = [self.id]

		if (change_type) then
			conditions += ' AND changes.change_type = ?'
			params << change_type
		end

		joins = 'INNER JOIN species ON changes.id = species.change_id INNER JOIN sightings ON species.id = sightings.species_id'
		select = 'DISTINCT changes.id'

		if count then
			Change.count(:select => select, :conditions => [conditions, *params], :joins => joins)
		else
			change_ids = Change.find(:all, :select => select, :conditions => [conditions, *params], :joins => joins)
			Change.find(:all, :conditions => {:id => change_ids}, :order => 'changes.date ASC')
		end
	end

	# Syntactic sugar
	def pending_taxonomy_changes_count(change_type = nil)
		find_pending_taxonomy_changes(change_type, true)
	end

  protected
	  def before_create
		# Gotta have one of these
		c = UserCommentCollection.create(:title => self.login)
		self.comment_collection = c
	  end

	  def after_create
		  # And now that we have a user id, link our comment collection to us
		  c = self.comment_collection
		  c.user = self
		  c.save!

		  # Every new user gets some premade saved searches

		  # Life list
		  search = Birdstack::Search.new(self, {
			:observation_search_display => {:type => "table", :sort => "date_desc"},
			:observation_search_type => {:type => "earliest"}
		  }, false, self)
		  ss = SavedSearch.new()
		  ss.user = self
		  ss.private = false
		  ss.temp = false
		  ss.name = 'Life list'
		  ss.search = search.freeze
		  ss.save!
		  
		  # Everything
		  search = Birdstack::Search.new(self, {
			:observation_search_display => {:type => "table", :sort => "date_desc"},
			:observation_search_type => {:type => "all"}
		  }, false, self)
		  ss = SavedSearch.new()
		  ss.user = self
		  ss.private = false
		  ss.temp = false
		  ss.name = 'All observations'
		  ss.search = search.freeze
		  ss.save!
	  end

  private
	  # Encrypts some data with the salt.
	  def self.encrypt(password, salt)
	    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
	  end

	  # Generates a random value suitable for salt usage
	  def create_salt
		  Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{rand.to_s}--#{self.object_id.to_s}--#{id}")
	  end
	 
	  def add_activation_code
		  self.activation_code = create_salt
	  end

	  def password_required?
		  # A password is required if the record is new
		  # A password is also required if the "password" or "password_confirmation" field is present, which means the user is updating their password
		  new_record? || !password.nil? || !password_confirmation.nil?
	  end

end
