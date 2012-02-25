#!/usr/bin/ruby -w

require "csv"

new_section = false
order = nil
family_english = nil
family_latin = nil

species_count = 0
order_count = 0
family_count = 0

begin

writer = CSV.open(ARGV[1], 'w')
CSV.open(ARGV[0], 'r') do |row|
	begin

	raise "The first column wasn't nil.  It's supposed to be nil." unless row.shift.nil?

	if row.detect {|i| i.to_s.strip != '' }.nil? then
		new_section = true
		next
	end

	if new_section then
		if row.first.nil? then
			# Process a new order
			if (row.slice(0).to_a + row.slice(2..row.size - 1)).detect {|i| i != nil} then
			    raise "Thought this was an Order row, but it doesn't look like one"
			end
			puts
			puts "Order: " + order = row[1].strip.sub(/^ORDER\s+/, '')
			order_count += 1
		else
			puts
			puts "English family: " + family_english = row[0].strip
			puts "Latin family: " + family_latin = row[1].strip.sub(/^Family\s+/, '')

			# Reset Genus id maps
			genus_ids = Hash.new

			family_count += 1

			puts "---"

			# We should now be ready for species
			new_section = false
		end
	else
		species_english = row[0]
		genus, species_latin = row[1].strip.split(/\s+/).collect {|i| i }
		breeding_ranges = row[2]
		breeding_range_subregions = row[3]
		nonbreeding_range = row[4]

		#puts "[#{ species_english }]"
		#puts "\tGenus: [#{ genus }]"
		#puts "\tSpecies: [#{species_latin}]"
		#puts "\tGeneral Ranges: #{ breeding_ranges}"
		#puts "\tSubregions [#{ breeding_range_subregions }]"
		#puts "\tNonbreeding Range: [#{ nonbreeding_range }]"

		species_count += 1

		writer << [order, family_english, family_latin, species_english, genus, species_latin, breeding_ranges, breeding_range_subregions, nonbreeding_range]
	end

	rescue
		puts "Problematic row:"
		p row_orig
		raise
	end
end

ensure
	puts
	puts "---"
	puts "Orders: #{ order_count }"
	puts "Families: #{ family_count }"
	puts "Species: #{ species_count }"
end
