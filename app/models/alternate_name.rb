class AlternateName < ActiveRecord::Base
	validates_presence_of :name
	validates_uniqueness_of :name, :scope => :species_id
	validates_presence_of :description
	validates_presence_of :user_id
	validates_presence_of :species_id

	belongs_to :user
	belongs_to :species

	attr_accessible :name, :description

	def validate
		if Species.find_valid_by_exact_english_name(self.name) then
			errors.add(:name, 'is already used by another species in the database')
		end
                # For auto-complete purposes, having an alternate name that fully includes the species
                # name is pointless
		if self.species and self.species.english_name.downcase.include?(self.name.downcase) then
			errors.add(:name, 'cannot be a shorter version of the full name (e.g., "Emerald Dove" for "Common Emerald Dove")')
		end
	end

	# This will return only unique combinations of search_name and name.  Used for searching and autocomplete
	def self.find_unique_valid_by_name(search_string, limit = 10, options = {})
		self.find(:all, {:select => 'DISTINCT alternate_names.search_name, alternate_names.name', :conditions => [ 'alternate_names.search_name LIKE ? and species.change_id IS NULL', '%' + Birdstack::search_version(search_string) + '%' ], :joins => 'LEFT OUTER JOIN species ON alternate_names.species_id = species.id', :order => 'name ASC', :limit => limit}.merge(options))
	end

	# This will actually find all matching records, even if several have the same search_name.  Used on the alternate name page
	def self.find_all_valid_by_exact_name(search_string)
		self.find(:all, :conditions => [ 'alternate_names.search_name LIKE ? and species.change_id IS NULL', Birdstack::search_version(search_string)], :joins => 'LEFT OUTER JOIN species ON alternate_names.species_id = species.id', :order => 'name ASC')
	end

	def before_save
		self.search_name = Birdstack::search_version(self.name)
	end
end
