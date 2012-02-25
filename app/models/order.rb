class Order < ActiveRecord::Base
  include Birdstack::Taxon
	attr_accessible

	has_many	:families, :order => 'families.sort_order'
        belongs_to      :sort_after, :class_name => 'Order'

	def self.find_by_latin(name)
		# We can use search_version without a special column because we know that order
		# will only ever be lower case a-z with no spaces
		self.find(:all, :conditions => ['latin_name LIKE ?', '%' + Birdstack::search_version(name) + '%'], :order => 'latin_name ASC')
	end

        def parent
          nil
        end
        def children
          :families
        end

        #
        # For the upgrade system
        #

        # Call after any updates to the taxonomy
	def update_cache
		self.family_count = self.families.count
		self.save!
	end
        
        def self.find_similar(o)
          Order.find_by_latin_name(o.latin_name)
        end
        def generate_update(prev_o, o)
          update = {}
          update[:latin_name] = o.latin_name if self.latin_name != o.latin_name
          update[:note] = o.note if self.note.to_s != o.note.to_s
          update[:code] = o.code if self.code.to_s != o.code.to_s

          new_sa = prev_o.andand.latin_name || :first
          old_sa = sort_after.andand.latin_name || :first

          update[:sort_after] = new_sa if old_sa != new_sa
          
          # We want the hash to be empty if we don't have any real updates
          if !update.empty? then
            update[:original] = self.latin_name
          end

          update
        end
        def self.generate_new(prev_o, o)
          {
            :latin_name => o.latin_name,
            :note => o.note,
            :code => o.code,
            :sort_after => prev_o.andand.latin_name || :first
          }
        end


end
