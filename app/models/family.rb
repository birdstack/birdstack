class Family < ActiveRecord::Base
  include Birdstack::Taxon
	attr_accessible

	belongs_to	:order
	has_many	:genera, :order => 'genera.sort_order'
        belongs_to      :sort_after, :class_name => 'Family'

	validates_presence_of :latin_name
	validates_presence_of :english_name
	validates_presence_of :order_id

	def self.find_by_latin(name)
		# We can use search_version without a special column because we know that family latin
		# will only ever be lower case a-z with no spaces (with the exception of incertae sedis,
		# which we handle as a special case here)
		search = Birdstack::search_version(name)
		if(search == "incertaesedis") then
			search = "incertae sedis"
		end
		self.find(:all, :conditions => [ 'latin_name LIKE ?', '%' + search + '%' ], :order => 'latin_name ASC')
	end

	def self.find_by_english(name)
		search = Birdstack::search_version(name)
		self.find(:all, :conditions => [ 'english_name_search_version LIKE ?', '%' + search + '%' ], :order => 'english_name_search_version ASC')
	end

        def parent
          :order
        end
        def children
          :genera
        end

	def before_save
		self.english_name_search_version = Birdstack::search_version(self.english_name)
	end

        #
        # For the upgrade system
        #
        
        # Call after any updates to the taxonomy
	def update_cache
		self.genus_count = self.genera.count
		self.save!
	end

        def self.find_similar(old_o, f)
          # First try within our old order, then wherever
          # Have to be careful within family because latin names may not be unique (Incertae Sedis)
          old_f = old_o.andand.families.andand.find_all_by_latin_name(f.latin_name)
          old_f = Family.find_all_by_latin_name(f.latin_name) if (old_f.nil? or old_f.empty?)
          if(old_f.size == 1) then
            return old_f.first
          end

          # Try to be clever.  Find families with roughly the same
          # number of genera (within 10%), and a similarly low difference in
          # in genera names
          size_range = (f.genera.size*0.9)..(f.genera.size*1.1)
          potentials = Family.all.find_all {|i| size_range === i.genera.size }

          new_f_genera_names = Set.new(f.genera.collect {|g| g.latin_name })
          potentials = potentials.find_all do |p|
            matches = 0
            p.genera.each do |g|
              matches += 1 if new_f_genera_names.include?(g.latin_name)
            end
            # If everything matched, or if it fell within the reasonable range and there were at least 5
            matches == f.genera.size ||
              (size_range === matches && matches >= 5)
          end

          if potentials.size == 1 then
            puts "# Found #{potentials.first.latin_name} family via clever inference"
            return potentials.first 
          else
            return nil
          end
        end

        def generate_update(prev_f, f)
          update = {}
          update[:latin_name] = f.latin_name if self.latin_name != f.latin_name
          update[:english_name] = f.english_name if self.english_name != f.english_name
          update[:note] = f.note if self.note.to_s != f.note.to_s
          update[:code] = f.code if self.code.to_s != f.code.to_s
          update[:order] = f.order.latin_name if self.order.latin_name != f.order.latin_name

          new_sa = prev_f.andand.latin_name || :first
          old_sa = sort_after.andand.latin_name || :first

          # We definitely need to specify sort order if we're in a different order
          update[:sort_after] = new_sa if ((old_sa != new_sa) or update[:order])
          
          # We want the hash to be empty if we don't have any real updates
          if !update.empty? then
            update[:original] = self.latin_name
            update[:id] = self.id # Family latin names may not be unique (Incertae Sedis)
            update[:included_genus] = self.genera.first.latin_name
          end

          update
        end

        def self.generate_new(prev_f, f)
          {
            :latin_name => f.latin_name,
            :english_name => f.english_name,
            :note => f.note,
            :code => f.code,
            :sort_after => (prev_f.andand.latin_name || :first),
            :order => f.order.latin_name
          }
        end
end
