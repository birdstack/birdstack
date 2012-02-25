class Genus < ActiveRecord::Base
  include Birdstack::Taxon
	attr_accessible

	belongs_to	:family
	has_many	:species, :order => 'species.sort_order'
        belongs_to      :sort_after, :class_name => 'Genus'

        validates_presence_of :family_id
        validates_presence_of :latin_name

	def self.find_by_latin(name)
		# We can use search_version without a special column because we know that genus
		# will only ever be lower case a-z with no spaces
		self.find(:all, :conditions => ['latin_name LIKE ?', '%' + Birdstack::search_version(name) + '%'], :order => 'latin_name ASC')
	end

        def parent
          :family
        end
        def children
          :species
        end

        #
        # For the upgrade system
        #

        # Call after any updates to the taxonomy
	def update_cache
		self.species_count = self.species.count(:conditions => ['species.change_id IS NULL'])
		self.save!
	end

        def self.find_similar(old_f, g)
          # First try within our old family, then wherever
          old_g = old_f.andand.genera.andand.find_all_by_latin_name(g.latin_name)
          old_g = Genus.find_all_by_latin_name(g.latin_name) if (old_g.nil? or old_g.empty?)
          if(old_g.size == 1) then
            return old_g.first
          end

          # Try to be clever.  Find genera with roughly the same
          # number of species (within 10%), and a similarly low difference in
          # in genera names
          size_range = (g.species.size*0.9)..(g.species.size*1.1)
          potentials = Genus.all.find_all {|i| i.species.size > 5 && size_range === i.species.size }

          new_g_species_names = Set.new(g.species.collect {|s| s.latin_name })
          potentials = potentials.find_all do |p|
            matches = 0
            p.species.each do |s|
              matches += 1 if new_g_species_names.include?(s.latin_name)
            end
            size_range === matches
          end

          if potentials.size == 1 then
            puts "# Found via clever inference"
            return potentials.first 
          else
            return nil
          end
        end

        def generate_update(prev_g, g)
          update = {}
          update[:latin_name] = g.latin_name if self.latin_name != g.latin_name
          update[:note] = g.note if self.note.to_s != g.note.to_s
          update[:code] = g.code if self.code.to_s != g.code.to_s
          if self.family.latin_name != g.family.latin_name
            update[:family] = {
              :name => self.family.latin_name,
              :id => self.family.id,
              :included_genus => self.family.genera.first.latin_name
            }
          end

          new_sa = prev_g.andand.latin_name || :first
          old_sa = sort_after.andand.latin_name || :first

          # We definitely need to specify sort order if we're in a different family
          update[:sort_after] = new_sa if ((old_sa != new_sa) or update[:family])
          
          # We want the hash to be empty if we don't have any real updates
          if !update.empty? then
            update[:original] = self.latin_name
          end

          update
        end

        def self.generate_new(prev_g, g)
          {
            :latin_name => g.latin_name,
            :note => g.note,
            :code => g.code,
            :sort_after => (prev_g.andand.latin_name || :first),
            :family => g.family.latin_name
          }
        end
end
