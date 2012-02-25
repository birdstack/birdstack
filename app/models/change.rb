class Change < ActiveRecord::Base
	attr_accessible

	has_one	:species
	has_and_belongs_to_many	:potential_species, :class_name => "Species", :join_table => 'changes_species'

	validates_inclusion_of :change_type, :in => ['split', 'lump', 'removal'], :message => 'is not valid'

	validates_presence_of :description
	validates_presence_of :date
	validates_presence_of :change_type

	def validate
		case self.change_type
			when 'split' then
				errors.add(:potential_species, 'should have >1 if split') unless self.potential_species.size > 1
			when 'lump' then
				errors.add(:potential_species, 'should have 1 if lump') unless self.potential_species.size == 1
			when 'removal' then
				errors.add(:potential_species, 'should have 0 if removal') unless self.potential_species.size == 0
			else
				errors.add(:change_type, 'unknown!')
		end
	end
end
