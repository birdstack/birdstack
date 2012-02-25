#!/usr/bin/ruby

require 'csv'
require 'pp'
#require 'ruby-debug'


puts "Loading the new taxonomy..."

# Load the taxo tree into memory
orders = Birdstack::ParseCSV.parse_ioc_csv(ARGV[0])

orders_updated = []
families_updated = []
genera_updated = []
species_updated = []

prev_o = nil
orders.each do |o|
  old_o = Order.find_similar(o)
  update = old_o.andand.generate_update(prev_o, o)
  if update then
    orders_updated << old_o.id
    unless update.empty? then
      puts "order_update("
      pp update
      puts ")"
    end
  else
    puts
    puts "TODO: Unable to generate order update.  Possibly an add:"
    puts "order_new("
    pp Order.generate_new(prev_o, o)
    puts ")"
    puts
  end

  prev_f = nil
  prev_g = nil
  prev_s = nil
  
  o.families.each do |f|
    old_f = Family.find_similar(old_o, f)
    update = old_f.andand.generate_update(prev_f, f)

    if update then
      families_updated << old_f.id
      unless update.empty? then
        puts "family_update("
        pp update
        puts ")"
      end
    else
      puts
      puts "TODO: Unable to generate family update.  Possibly an add:"
      puts "family_new("
      pp Family.generate_new(prev_f, f)
      puts ")"
      puts
    end

    prev_g = nil
    prev_s = nil

    f.genera.each do |g|
      old_g = Genus.find_similar(old_f, g)
      update = old_g.andand.generate_update(prev_g, g)
      prev_genus_name = nil

      if update then
        genera_updated << old_g.id
        prev_genus_name = old_g.latin_name
        unless update.empty? then
          puts "genus_update("
          pp update
          puts ")"
        end
      else
        puts
        puts "TODO: Unable to generate genus update.  Possibly an add:"
        puts "genus_new("
        pp Genus.generate_new(prev_g, g)
        puts ")"
        puts
      end

      prev_s = nil

      g.species.each do |s|
        old_s = Species.find_similar(old_g, s)
        update = old_s.andand.generate_update(prev_s, s, prev_genus_name)

        if update then
          species_updated << old_s.id
          unless update.empty? then
            puts "species_update("
            pp update
            puts ")"
          end
        else
          puts
          puts "TODO: Unable to generate species update.  Possibly an add/split:"
          if(s.code =~ /AS/i) then
            puts "species_split("
            pp [{
              :original => "TODO",
              :description => s.note,
              :potentials => [
                {
                  :english_name => "TODO",
                },
                {
                  :sort_after => "TODO",
                  :latin_name => s.latin_name,
                  :breeding_ranges => s.regions.collect {|r| r.code}.join(', '),
                  :breeding_subregions => s.breeding_subregions,
                  :code => s.code,
                  :genus => s.genus.latin_name,
                  :note => s.note,
                  :nonbreeding_regions => s.nonbreeding_regions,
                  :english_name => s.english_name
                }
              ]
            }]
            puts ")"
          else
            puts "species_new("
            pp Species.generate_new(prev_s, s)
            puts ")"
          end
          puts
        end

        prev_s = s
      end

      prev_g = g
    end

    prev_f = f
  end

  prev_o = o
end

# Detect taxon that weren't updated
# Be sure to restrict to current (valid) species
(Species.valid.collect {|s| s.id } - species_updated).each do |s|
  puts
  puts "TODO: Old species not handled in update.  Possibly a delete/lump:"
  puts "species_lump("
  s = Species.find(s)
  pp ({s.english_name => {:description => s.note, :species => 'TODO', :id => s.id}})
  puts ")"
  puts
end
(Genus.all.collect {|g| g.id } - genera_updated).each do |g|
  puts
  puts "TODO: Old genus not handled in update.  Possibly a delete:"
  puts "genus_delete("
  pp ({:latin_name => Genus.find(g).latin_name, :id => g})
  puts ")"
  puts
end
(Family.all.collect {|f| f.id } - families_updated).each do |f|
  puts
  puts "TODO: Old family not handled in update.  Possibly a delete:"
  puts "family_delete("
  # Note that we have to include the id because family latin names may not be unique
  # because of Incertae Sedis
  pp ({:latin_name => Family.find(f).latin_name, :id => f})
  puts ")"
  puts
end
(Order.all.collect {|o| o.id } - orders_updated).each do |o|
  puts
  puts "TODO: Old order not handled in update.  Possibly a delete:"
  puts "order_delete("
  pp ({:latin_name => Order.find(o).latin_name, :id => o})
  puts ")"
  puts
end
