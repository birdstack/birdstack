require 'readline'

!(@@version = ARGV[1]).nil? or raise "no version!"
!(@@pub_date = ARGV[2]).nil? or raise "no pub date!"

puts "IOC Version #{@@version}, published #{@@pub_date}"

def danger_notification(original, new)
          puts "Danger! Tried to add an alternate name, but the original name is now also a valid species!"
          if(original.notification) then
            puts "* There's already a notification:"
            original.notification.interactive_editor
            return
          end

          n = Notification.new
          n.user = User.find_by_login('djringer')
          n.species = original
          n.potential_species = [new]

          puts "Notification:"
          puts "Species: #{n.species.english_name}"
          puts "User: #{n.user.login}"
          puts "Potentials:"
          n.potential_species.each do |p|
                  puts "\t#{p.english_name}"

          puts "You get to make up the description: "
          n.description = Readline.readline
          puts "Description: #{n.description}"
          end
          puts "---"

          n.save!
end

def species_splits(updates)
  updates = [updates].flatten

  updates.each do |s|
    if(s[:potentials].find {|p| p[:english_name] == s[:original] }) then
      # If one of the potentials retained the english name of the original, generate a notification
      
      species = Species.find_valid_by_exact_english_name(s[:original]) or raise "Could not find original: #{s[:original]}.  Was the species changed in both a split and an update?  If possible, consolidate the update and re-run."
      n = Notification.new(:description => "In version #{@@version} of the IOC list (#{@@pub_date}), #{s[:original]} (<i>#{species.genus.latin_name} #{species.latin_name}</i>) was split into #{s[:potentials].size} species.  If you are using an older field guide or checklist, the name #{s[:original]} might refer to one of the newly split species.")
      n.user = User.find_by_login('djringer')
      n.species = species
      n.potential_species = s[:potentials].find_all {|p| p[:english_name] != s[:original] }.
        collect {|p| Species.find_valid_by_exact_english_name(p[:english_name]) }

      puts "Notification:"
      puts "Species: #{n.species.english_name}"
      puts "Description: #{n.description}"
      puts "User: #{n.user.login}"
      puts "Potentials:"
      n.potential_species.each do |p|
        puts "\t#{p.english_name}"
      end
      puts "---"

      n.save!
    else
      # Otherwise, none of the new species have the same name as the original,
      # so we should generate alternate names for each of the new species
      # (original english name)->(new species name)

      s[:potentials].each do |p|
        an = AlternateName.new(:name => s[:original], :description => "#{p[:english_name]} was split from #{s[:original]} in version #{@@version} of the IOC list (#{@@pub_date}).")
        an.user = User.find_by_login('djringer')
        an.species = Species.find_valid_by_exact_english_name(p[:english_name])

        puts "Alternate Name: #{an.name}"
        puts "Species: #{an.species.english_name}"
        puts "Description: #{an.description}"
        puts "User: #{an.user.login}"

        if an.species.english_name.downcase.include?(an.name.downcase) then
          puts "Skipping because alternate name is a part of the species name"
        else
          an.save!
        end
        puts "---"
      end
    end
  end
end
alias :species_split :species_splits

def species_updates(updates)
  updates = [updates].flatten

  updates.each do |s|
        next unless s[:original] # If they didn't specify an original name, that means they didn't change it
        next unless s[:english_name] # They apparently didn't change the name
        # Didn't change the name enough to matter
        next if Birdstack::search_version(s[:english_name]) == Birdstack::search_version(s[:original])

        species = Species.find_valid_by_exact_english_name(s[:english_name])

        if(original = Species.find_valid_by_exact_english_name(s[:original])) then
          danger_notification(original, species)
        else
          an = AlternateName.new(:name => s[:original], :description => "The English name for this species was changed from #{s[:original]} to #{species.english_name} in version #{@@version} of the IOC list (#{@@pub_date}).")
          an.user = User.find_by_login('djringer')
          an.species = species

          puts "Alternate Name: #{an.name}"
          puts "Species: #{an.species.english_name}"
          puts "Description: #{an.description}"
          puts "User: #{an.user.login}"

          if an.species.english_name.downcase.include?(an.name.downcase) then
            puts "Skipping because alternate name is a part of the species name"
          else
            an.save!
          end
          puts "---"
        end
  end
end
alias :species_update :species_updates

def species_lumps(updates)
  updates = [updates].flatten

  updates.each do |u|
    u.each_pair do |s,c|
      next if Birdstack::search_version(c[:species]) == Birdstack::search_version(s)

      species = Species.find_valid_by_exact_english_name(c[:species])
      next unless species

      if(original = Species.find_valid_by_exact_english_name(s)) then
        danger_notification(original, species)
      else
        an = AlternateName.new(:name => s, :description => "In version #{@@version} of the IOC list (#{@@pub_date}), #{s} was lumped with #{c[:species]}.")
        an.user = User.find_by_login('djringer')
        an.species = species

        puts "Alternate Name: #{an.name}"
        puts "Species: #{an.species.english_name}"
        puts "Description: #{an.description}"
        puts "User: #{an.user.login}"
        puts "---"

        an.save!
      end
    end
  end
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
  require ARGV[0]
end
