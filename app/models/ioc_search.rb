class IocSearch < Tableless
	column :term,		:string

	validates_presence_of	:term

	attr_accessible :term

	def validate
		unless(!self.term.blank? and Birdstack::search_version(self.term).length >= 2) then
			errors.add(:term, "is not long enough (minimum 2 characters)")
		end
	end

	def search_species_english
		result = {}

		result[:species_count], result[:species] = Species.find_and_count_valid_by_english(self.term, nil)

		result[:alternate_names] = AlternateName.find_unique_valid_by_name(self.term, nil)

		result[:spell_check_search] = [] # Always at least have an empty array

		if result[:species_count] == 0 and result[:alternate_names].size == 0 then
			result[:spell_check_search] = Species.find_by_spell_check(self.term)
		end

		return result
	end

	def search_species_binomial
		Species.find_valid_by_binomial(self.term)
	end

	def search_genus_latin
		Genus.find_by_latin(self.term)
	end

	def search_family_latin
		Family.find_by_latin(self.term)
	end

	def search_family_english
		Family.find_by_english(self.term)
	end

	def search_order_latin
		Order.find_by_latin(self.term)
	end

	def search_all
		result = {
			:species_english => search_species_english,
			:species_binomial => search_species_binomial,
			:genus_latin => search_genus_latin,
			:family_latin => search_family_latin,
			:family_english => search_family_english,
			:order_latin => search_order_latin,
		}

		return result
	end
end
