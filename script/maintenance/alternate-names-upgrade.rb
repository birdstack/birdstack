require 'readline'

@@alternate_names = []

def species_updates(updates)
  updates = [updates].flatten

  updates.each do |s|
        next unless s[:original] and s[:english_name]
        @@alternate_names += Species.find_valid_by_exact_english_name(s[:english_name]).andand.alternate_names
  end
end
alias :species_update :species_updates

def species_splits(updates)
end
alias :species_split :species_splits
def species_lumps(updates)
end
alias :species_lump :species_lumps
def genus_deletes(updates)
end
alias :genus_delete :genus_deletes
def species_deletes(updates)
end
alias :species_delete :species_deletes
def family_deletes(updates)
end
alias :family_delete :family_deletes
def family_updates(updates)
end
alias :family_update :family_updates
def genus_new(updates)
end
def species_new(updates)
end
def family_new(updates)
end
def genus_updates(updates)
end
alias :genus_update :genus_updates
def order_updates(updates)
end
alias :order_update :order_updates
def order_new(update)
end

Species.transaction do
        # Find all alternate names that are associated with species that have had their english name changed
        require ARGV[0] if ARGV[0]

        # Find all alternate names for species that are now out of date
	@@alternate_names += AlternateName.find(:all, :conditions => ['species.change_id IS NOT NULL'], :joins => 'LEFT JOIN species ON alternate_names.species_id = species.id')

        # Find invalid alternate names
        @@alternate_names += AlternateName.find(:all).find_all {|an| !an.valid? }

        @@alternate_names.uniq!

        puts "Reviewing #{@@alternate_names.size} alternate names"
        puts

        @@alternate_names.each do |an|
                # Object might be in a weird state because of the joins
                an = AlternateName.find(an.id)

		puts "Alternate Name: #{an.name}"
                puts "Currently valid: #{an.valid? ? 'yes' : 'no'}"
		puts "Description: #{an.description}"
		puts "User: #{an.user.login}"
		puts "Species: #{an.species.english_name}"
                puts "Associated with old species? #{an.species.change ? 'yes' : 'no'}"
                if an.species.change then
                  puts "Change Type: #{an.species.change.change_type}"
                  0.upto(an.species.change.potential_species.size-1) do |i|
                          puts "\t#{i}) #{an.species.change.potential_species[i].english_name}"
                  end
                end
		puts
		while(1) do
			puts "Choose: S) Skip, D) Delete, E) Edit, N[,N]) Reassign to one of the species above"
			response = Readline.readline('> ').downcase
			if response == 's' then
				break
			elsif response == 'd' then
				an.destroy
				break
			elsif response == 'e' then
				puts "New Description:"
				an.description = Readline.readline
				an.save!
			elsif response =~ /^\d/ then
				response.split(/\s*,\s*/).each do |r|
                                        # Make a copy for reassignment
					anfix = an.clone
					anfix.species = an.species.change.potential_species[r.to_i]
					anfix.save!
				end
                                # Delete the original (obsolete) copy
				an.destroy
				break
			else
				puts "I didn't understand your selection"
			end
		end
		puts "---"
	end
end
