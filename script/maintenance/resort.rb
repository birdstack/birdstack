include Birdstack::Resort

require 'csv'

csv = CSV.open(ARGV[0], 'r')

csv.shift # skip header

lines = []
while(!(line = csv.shift).empty?) do
  lines << line
end

Species.transaction do
  old_order = nil
  old_family = nil
  old_genus = nil
  old_species = nil

  while(line = lines.shift) do
    if(!line[0].blank?) then
      new_order = Order.find_by_latin_name(line[0])
      puts "Order: #{new_order.latin_name}"
      if(old_order.nil?) then
        puts "Insert first order #{new_order.latin_name}"
        insert_first(new_order)
      else
        insert_after(old_order, new_order)
      end
      old_order = new_order
    elsif(!line[1].blank?) then
      # There can be more than one incertae sedis family per order, so the only safe way to get the family we want
      # is to peak ahead and grab a species out of that family
      new_family = Species.find_valid_by_exact_english_name(lines[1][5]).genus.family
      new_family = Family.find(new_family.id)
      puts "Family: #{new_family.latin_name}"
      if(old_family.nil?) then
        insert_first(new_family)
      else
        insert_after(old_family, new_family)
      end
      old_family = new_family
    elsif(!line[3].blank?) then
      new_genus = Genus.find_by_latin_name(line[3])
      puts "Genus: #{new_genus.latin_name}"
      if(old_genus.nil?) then
        insert_first(new_genus)
      else
        insert_after(old_genus, new_genus)
      end
      old_genus = new_genus
    elsif(!line[5].blank?) then
      new_species = Species.find_valid_by_exact_english_name(line[5])
      puts "Species: #{new_species.latin_name}"
      if(old_species.nil?) then
        insert_first(new_species)
      else
        insert_after(old_species, new_species)
      end
      old_species = new_species
    end
  end

  puts "Verifying against CSV"

  errors = Birdstack::VerifyDB.verify(ARGV[0])

  if errors.size > 0 then
          puts errors.join("\n")
          puts "#{errors.size} errors found"
          raise 'The database does not fully match the csv'
  end

  puts "Sorted and verified!"
end
