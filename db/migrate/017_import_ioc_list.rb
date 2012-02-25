class ImportIocList < ActiveRecord::Migration
  def self.up
	# Reset to a known state
	down

	dirname = File.join(File.dirname(__FILE__), "017_import_ioc_list_data")

	require "#{ dirname }/regions.rb"
	require "csv"

	prev_order = ''
	prev_family = ''
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

	Regions::REGION_ABBREVIATIONS.each do |region, info|
		execute("INSERT INTO regions (code, name, description) VALUES (#{quote(region)}, #{quote(info[0])}, #{quote(info[1].to_s)})")
		region_ids[region] = select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']
	end

	begin

	CSV.open("#{ dirname }/fixed.csv", 'r') do |row|
		begin
			order = row[0]
			family_english = row[1]
			family_latin = row[2]
			species_english = row[3]
			genus = row[4]
			species_latin = row[5]
			breeding_ranges = row[6]
			# Do to_s here because they might be nil, which is fine
			breeding_range_subregions = row[7].to_s
			nonbreeding_range = row[8].to_s

			if(order != prev_order) then
				puts "Order: " + order
				execute("INSERT INTO orders (sort_order, latin_name) VALUES (#{quote(order_count)}, #{quote(order)})")
				puts order_id = select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']
				order_count += 1
				prev_order = order
				prev_family = ''
			end

			if(family_latin != prev_family) then
				puts "English family: " + family_english
				puts "Latin family: " + family_latin

				execute("INSERT INTO families (sort_order, order_id, english_name, latin_name) VALUES (#{quote(family_count)}, #{quote(order_id)}, #{quote(family_english)}, #{quote(family_latin)})")
				family_id = select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']

				prev_family = family_latin

				# Reset Genus id maps
				genus_ids = Hash.new

				family_count += 1

				puts "---"
			end

			breeding_ranges = breeding_ranges.split(/,\s*/).collect {|i| i.strip }
			breeding_ranges.each {|i| region_count[i].nil? ? region_count[i] = 1 : region_count[i] += 1 }

			puts "[#{ species_english }]"
			puts "\tGenus: [#{ genus }], Species: [#{species_latin}]"
			puts "\tGeneral Ranges: #{ breeding_ranges.collect {|i| "[#{ i }]" }.join(', ') }"
			puts "\tSubregions [#{ breeding_range_subregions }]"
			puts "\tNonbreeding Range: [#{ nonbreeding_range }]"

			if genus_ids[genus].nil? then
				execute("INSERT INTO genera (sort_order, family_id, latin_name) VALUES (#{quote(genus_count)}, #{quote(family_id)}, #{quote(genus)})")
				genus_ids[genus] = select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']

				genus_count += 1
			end

			execute("INSERT INTO species (sort_order, genus_id, english_name, latin_name, breeding_subregions, nonbreeding_regions) VALUES (#{quote(species_count)}, #{quote(genus_ids[genus])}, #{quote(species_english)}, #{quote(species_latin)}, #{quote(breeding_range_subregions)}, #{quote(nonbreeding_range)})")

			species_id = select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']

			breeding_ranges.each do |i|
				if region_ids[i].nil? then
					raise "Unknown region: #{ i }"
				end

				execute("INSERT INTO regions_species (species_id, region_id) VALUES (#{quote(species_id)}, #{quote(region_ids[i])})")
			end

			species_count += 1
		rescue
			puts "Problematic row:"
			p row
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
	end
  end

  def self.down
	  execute('DELETE FROM changes_species')
	  execute('DELETE FROM regions_species')
	  execute('DELETE FROM regions')
	  execute('DELETE FROM species')
	  execute('DELETE FROM changes')
	  execute('DELETE FROM genera')
	  execute('DELETE FROM families')
	  execute('DELETE FROM orders')
  end
end
