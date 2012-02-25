require 'readline' # for the interactive editor

class Notification < ActiveRecord::Base
	attr_accessible :description

	belongs_to :species
	belongs_to :user

	validates_presence_of :user
	validates_presence_of :species
	validates_presence_of :description
	validates_uniqueness_of :species_id, :message => 'already has a notification'

	has_and_belongs_to_many	:potential_species, :class_name => "Species", :join_table => 'notifications_species'

	has_many :ignored_notifications, :dependent => :destroy

	# Removes duplicate potential species.  Not awesome, but it is effective
	def before_validation
		unique_species = self.potential_species.uniq
		self.potential_species.clear
		self.potential_species = unique_species
	end

	def validate
		unless self.potential_species.size > 0 then
			errors.add_to_base('You must select at least one species')
		end

		self.potential_species.each do |s|
			if s == self.species then
				errors.add_to_base('You cannot link a species to itself')
			end
			if !s.change.nil? then
				errors.add_to_base('You cannot link to a species that is no longer valid')
			end
		end
	end

        # Used for taxo upgrades
        def interactive_editor
          puts "Species: #{self.species.english_name}"
          puts "Description: #{self.description}"
          self.potential_species.each do |s|
            puts "\t#{s.english_name}" + (s.change.nil? ? '' : ' *SPECIES IS NO LONGER VALID*')
          end
          puts "User: #{self.user.login}"
          if self.species.change then
            puts "Change Type: #{self.species.change.change_type}"
            0.upto(self.species.change.potential_species.size-1) do |i|
              puts "\t#{i}) #{self.species.change.potential_species[i].english_name}"
            end
          end
          puts

          while(1) do
            puts "Choose: S) Skip, D) Delete, E) Edit, N[,N]) Reassign to one of the species above"
            response = Readline.readline('> ').downcase
            if response == 's' then
              break
            elsif response == 'd' then
              self.destroy
              break
            elsif response == 'e' then
              puts "New Description:"
              self.description = Readline.readline
              self.save!
            elsif response =~ /^\d/ then
              response.split(/\s*,\s*/).each do |r|
                # Create a new notification
                nfix = self.clone
                nfix.species = self.species.change.potential_species[r.to_i]
                nfix.save!
              end
              # Now delete this obsolete one
              self.destroy
              break
            else
              puts "I didn't understand your selection"
            end
          end
        end
end
