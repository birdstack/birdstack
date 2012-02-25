#!/usr/bin/ruby -w

require "csv"
require "dbi"

region_abbreviations = [
	["NA", "North America", "includes the Caribbean"],
	["MA", "Middle America", "Mexico through Panama"],
	["SA", "South America"],
	["LA", "Latin America", "Middle and South America"],
	["AF", "Africa", "entire continent rather than south of Sahara"],
	["EU", "Eurasia", "Europe, Asia from the Middle East through central Asias north of the Himalayas, Siberia and northern China to Japan"],
	["OR", "Oriental Region", "South Asia from Pakistan to Taiwan, plus Southeast Asia, the Philippines, and Greater Sundas"],
	["AU", "Australasia", "Wallacea (Indonesian islands east of Wallace's line), New Guinea and its islands, Australia, New Zealand and its subantarctic islands, the Solomons, New Caledonia, and Vanuatu"],
	["AO", "Atlantic Ocean"],
	["PO", "Pacific Ocean"],
	["IO", "Indian Ocean"],
	["TrO", "Tropical oceans"],
	["TO", "Temperate oceans"],
	["SO", "Southern oceans"],
	["NO", "Northern oceans"],
	["AN", "Antarctica"],
	["Worldwide", "Worldwide"],
]

dbh = DBI.connect("DBI:Mysql:birdstack:localhost", "birdstack", "humm1ngduc")

new_section = false
order = nil
family_english = nil
family_latin = nil

species_count = 0
order_count = 0
order_id = nil
family_count = 0
family_id = nil
genus_count = 0
genus_ids = Hash.new

region_count = Hash.new
region_ids = Hash.new

region_abbreviations.each do |region|
	dbh.do("INSERT INTO regions (code, name, description) VALUES (?, ?, ?)", region[0], region[1], region[2])
	region_ids[region[0]] = dbh.select_one("SELECT LAST_INSERT_ID()")[0]
end

begin

CSV.open('IOC Names File.csv', 'r') do |row|
	begin

	row_orig = row

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
			puts "Order: " + order = row[1].sub(/^ORDER/, '').strip.capitalize
			dbh.do("INSERT INTO orders (sort_order, latin_name) VALUES (?, ?)", order_count, order);
			order_id = dbh.select_one("SELECT LAST_INSERT_ID()")[0]
			order_count += 1
		else
			puts
			puts "English family: " + family_english = row[0].strip.capitalize
			puts "Latin family: " + family_latin = row[1].sub(/^Family/, '').strip.capitalize

			dbh.do("INSERT INTO families (sort_order, order_id, english_name, latin_name) VALUES (?, ?, ?, ?)", family_count, order_id, family_english, family_latin);
			family_id = dbh.select_one("SELECT LAST_INSERT_ID()")[0]

			# Reset Genus id maps
			genus_ids = Hash.new

			family_count += 1

			puts "---"

			# We should now be ready for species
			new_section = false
		end
	else
		species_english = row[0].strip.gsub(/\s+/, ' ') # Remove double spaces from inside the name
		genus, species_latin = row[1].split(/\s+/).collect {|i| i.strip }
		breeding_ranges = row[2].split(/,\s*/).collect {|i| i.strip }
		breeding_ranges.each {|i| region_count[i].nil? ? region_count[i] = 1 : region_count[i] += 1 }
		# to_s prevents nil errors. It's OK if these are nil
		breeding_range_subregions = row[3].to_s.strip
		nonbreeding_range = row[4].to_s.strip

		puts "[#{ species_english }]"
		puts "\tGenus: [#{ genus }], Species: [#{species_latin}]"
		puts "\tGeneral Ranges: #{ breeding_ranges.collect {|i| "[#{ i }]" }.join(', ') }"
		puts "\tSubregions [#{ breeding_range_subregions }]"
		puts "\tNonbreeding Range: [#{ nonbreeding_range }]"

		if genus_ids[genus].nil? then
			dbh.do("INSERT INTO genera (sort_order, family_id, latin_name) VALUES (?, ?, ?)", genus_count, family_id, genus);
			genus_ids[genus] = dbh.select_one("SELECT LAST_INSERT_ID()")[0]

			genus_count += 1
		end

		dbh.do("INSERT INTO species (sort_order, genus_id, english_name, latin_name, breeding_subregions, nonbreeding_regions)
		       VALUES (?, ?, ?, ?, ?, ?)",
		       species_count, genus_ids[genus], species_english, species_latin, breeding_range_subregions, nonbreeding_range
		);

		species_id = dbh.select_one("SELECT LAST_INSERT_ID()")[0]

		breeding_ranges.each do |i|
			if region_ids[i].nil? then
				raise "Unknown region: #{ i }"
			end

			dbh.do("INSERT INTO species_breeding_regions (species_id, region_id) VALUES (?, ?)", species_id, region_ids[i]);
		end

		species_count += 1
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
	puts "Genera: #{ genus_count }"
	puts "Species: #{ species_count }"
	puts
	puts "Regions:"
	region_count.sort {|a, b| b[1] <=> a[1] }.each {|key, value| puts "\t#{ key }: #{ value }" }

	dbh.disconnect
end
