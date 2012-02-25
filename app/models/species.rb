class Species < ActiveRecord::Base
  include Birdstack::Taxon

	attr_accessible

	belongs_to	:change
	belongs_to	:genus
	has_and_belongs_to_many	:changes
	has_and_belongs_to_many	:regions
	has_many	:sightings
	has_one		:notification
	has_many	:alternate_names
        belongs_to      :sort_after, :class_name => 'Species'

        named_scope :valid, :conditions => 'change_id IS NULL'

	def self.find_and_count_valid_by_english(species_english_name, limit = 10, options = {})
		search_string = Birdstack::search_version(species_english_name.to_s)

		count = self.count(:all, :conditions => [ 'english_name_search_version LIKE ? and change_id IS NULL', '%' + search_string + '%' ])
		species = self.find(:all, {:conditions => [ 'english_name_search_version LIKE ? and change_id IS NULL', '%' + search_string + '%' ], :order => 'english_name ASC', :limit => limit}.merge(options))

		return [count, species]
	end

	def self.find_by_spell_check(species_english_name, limit = 5)
		results = []
		# In case of raspell badness, do everything in a block

		search_string = Birdstack::search_version(species_english_name.to_s)
		
		begin
			require 'raspell'

			sp = Aspell.new()
			sp.suggest(search_string).first(limit).each do |suggestion|
				results << Species.find_by_english_name_search_version(suggestion)
			end
		rescue Exception
			# Oh well, at least we tried
			logger.info "Error attempting spellcheck search #{$!}"
		end

		return results.compact
	end

	def self.find_valid_by_id(id)
		self.find(:first, :conditions => [ 'id = ? AND change_id IS NULL', id ])
	end

	def self.find_valid_by_exact_english_name(species_english_name)
		self.find(:first, :conditions => [ 'english_name_search_version = ? AND change_id IS NULL', Birdstack::search_version(species_english_name.to_s)])
	end

	def self.find_valid_by_binomial(name)
		self.find(:all, :conditions => [ 'binomial_name_search_version LIKE ? AND change_id IS NULL', '%' + Birdstack::search_version(name) + '%' ], :order => 'binomial_name_search_version ASC')
	end

        def parent
          :genus
        end
        def children
          nil
        end

        def before_save
          if(english_name_changed? or genus_id_changed?) then
            self.english_name_search_version = Birdstack::search_version(self.english_name)
            self.binomial_name_search_version = Birdstack::search_version(self.genus.latin_name + self.latin_name)
          end
        end

        #
        # For the upgrade system
        #
        def self.find_similar(old_g, s)
          potential_similars = []
          # First try to find the latin name within our old genus
          potential_similars << old_g.
            andand.species.
            andand.valid.
            andand.find_by_latin_name(s.latin_name)
          # Now find any valid species with the exact same english name
          potential_similars << Species.
            find_valid_by_exact_english_name(s.english_name)

          potential_similars.compact!
          #puts "# potentials: " + potential_similars.size.to_s
          potential_similars.each do |old_s|
            # If nothing changed about the english or scientific names, it's good
            if old_s.english_name == s.english_name &&
                old_s.latin_name == s.latin_name &&
                old_s.genus.latin_name == s.genus.latin_name
                then
              return old_s
            end
            # If either english or scientific name matches and the breeding
            # range info stayed the same, it's good
            if old_s.regions == s.regions && 
                old_s.breeding_subregions.to_s == s.breeding_subregions.to_s &&
                old_s.nonbreeding_regions.to_s == s.nonbreeding_regions.to_s 
                then
              #puts "# found a winner"
              return old_s
            end
            puts "# potential #{s.english_name}/#{s.genus.latin_name} " +
              "#{s.latin_name} has different breeding info."
          end

          #puts "# no potentials matched :-("
          return nil
        end

        def generate_update(prev_s, s, prev_genus_name)
          update = {}
          update[:english_name] = s.english_name if self.english_name != s.english_name
          update[:latin_name] = s.latin_name if self.latin_name != s.latin_name
          update[:breeding_ranges] = s.regions.collect {|r| r.code}.join(', ') if self.regions != s.regions
          update[:breeding_subregions] = s.breeding_subregions if self.breeding_subregions.to_s != s.breeding_subregions.to_s
          update[:nonbreeding_regions] = s.nonbreeding_regions if self.nonbreeding_regions.to_s != s.nonbreeding_regions.to_s
          update[:note] = s.note if self.note.to_s != s.note.to_s
          update[:code] = s.code if self.code.to_s != s.code.to_s
          # prev_genus_name is the previous name of the parent genus (if it was updated with a name change)
          if self.genus.latin_name != prev_genus_name then
            update[:genus] = s.genus.latin_name
            if prev_genus_name.nil? then
              puts "# WARNING - Unexpected genus change: current=#{s.genus.latin_name},old=#{self.genus.latin_name}"
            end
          end

          new_sa = prev_s.andand.english_name || :first
          old_sa = sort_after.andand.english_name || :first

          # We definitely need to specify sort order if we're in a different genus
          update[:sort_after] = new_sa if ((old_sa != new_sa) or update[:genus])
          
          # We want the hash to be empty if we don't have any real updates
          if !update.empty? then
            update[:original] = self.english_name
          end

          update
        end

        def self.generate_new(prev_s, s)
          {
            :latin_name => s.latin_name,
            :english_name => s.english_name,
            :breeding_ranges => s.regions.collect {|r| r.code}.join(', '),
            :breeding_subregions => s.breeding_subregions,
            :nonbreeding_regions => s.nonbreeding_regions,
            :note => s.note,
            :code => s.code,
            :sort_after => (prev_s.andand.english_name || :first),
            :genus => s.genus.latin_name
          }
        end
end
