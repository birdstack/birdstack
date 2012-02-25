conn = ActiveRecord::Base.connection
conn.transaction do

# Clear everything!
comment_collections = conn.select_all('SELECT comment_collection_id FROM sightings').collect {|i| i['comment_collection_id'] }
conn.execute('DELETE FROM sightings')
conn.execute('DELETE FROM alternate_names')
conn.execute('DELETE FROM notifications_species')
conn.execute('DELETE FROM ignored_notifications')
conn.execute('DELETE FROM notifications')
conn.execute("UPDATE comment_collections SET last_post_id = NULL WHERE id IN (#{comment_collections.join(',')})") if comment_collections.size > 0
conn.execute("DELETE FROM comments WHERE comment_collection_id IN (#{comment_collections.join(',')})") if comment_collections.size > 0
conn.execute("DELETE FROM comment_collections WHERE id in (#{comment_collections.join(',')})") if comment_collections.size > 0
conn.execute('DELETE FROM changes_species')
conn.execute('DELETE FROM regions_species')
conn.execute('DELETE FROM species')
conn.execute('DELETE FROM changes')
conn.execute('DELETE FROM genera')
conn.execute('DELETE FROM families')
conn.execute('DELETE FROM orders')

require "csv"

prev_order = ''
prev_family = ''
prev_genus = ''
order = nil
family_english = nil
family_latin = nil
genus = nil

species_count = 0
order_count = 0
order_id = nil
family_count = 0
family_id = nil
genus_count = 0
genus_id = nil

region_count = {}

header = false

CSV.open(ARGV[0], 'r') do |row|
	unless header then
		header = true
		next
	end

	order = row[0]
	family_latin = row[1]
	family_english = row[2]
	genus = row[3]
	species_latin = row[4]
	species_english = row[5]
	breeding_ranges = row[6]
	# Do to_s here because they might be nil, which is fine
	breeding_range_subregions = row[7].to_s
	nonbreeding_range = row[8].to_s

	if(!order.blank? and order != prev_order) then
		puts "Order: " + order
		conn.execute("INSERT INTO orders (sort_order, latin_name) VALUES (#{conn.quote(order_count)}, #{conn.quote(order)})")
		puts order_id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']
		order_count += 1
		prev_order = order
		prev_family = ''
		prev_genus = ''
		next
	end

	if(!family_latin.blank? and family_latin != prev_family) then
		puts "English family: " + family_english
		puts "Latin family: " + family_latin

		conn.execute("INSERT INTO families (sort_order, order_id, english_name, latin_name) VALUES (#{conn.quote(family_count)}, #{conn.quote(order_id)}, #{conn.quote(family_english)}, #{conn.quote(family_latin)})")
		family_id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']

		prev_family = family_latin

		family_count += 1

		prev_genus = ''

		puts "---"
		next
	end

	if(!genus.blank? and genus != prev_genus) then
		puts "Genus: " + genus

		conn.execute("INSERT INTO genera (sort_order, family_id, latin_name) VALUES (#{conn.quote(genus_count)}, #{conn.quote(family_id)}, #{conn.quote(genus)})")
		genus_id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']

		prev_genus = genus

		genus_count += 1

		puts "---"
		next
	end

	breeding_ranges = breeding_ranges.split(/,\s*/).collect {|i| i.strip }
	breeding_ranges.each {|i| region_count[i].nil? ? region_count[i] = 1 : region_count[i] += 1 }

	puts "[#{ species_english }]"
	puts "\tGenus: [#{ prev_genus }], Species: [#{species_latin}]"
	puts "\tGeneral Ranges: #{ breeding_ranges.collect {|i| "[#{ i }]" }.join(', ') }"
	puts "\tSubregions [#{ breeding_range_subregions }]"
	puts "\tNonbreeding Range: [#{ nonbreeding_range }]"

	conn.execute("INSERT INTO species (sort_order, genus_id, english_name, latin_name, breeding_subregions, nonbreeding_regions) VALUES (#{conn.quote(species_count)}, #{conn.quote(genus_id)}, #{conn.quote(species_english)}, #{conn.quote(species_latin)}, #{conn.quote(breeding_range_subregions)}, #{conn.quote(nonbreeding_range)})")

	species_id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()']

	breeding_ranges.each do |i|
		if Region.find_by_code(i).nil? then
			raise "Unknown region: #{ i }"
		end

		conn.execute("INSERT INTO regions_species (species_id, region_id) VALUES (#{conn.quote(species_id)}, #{conn.quote(Region.find_by_code(i))})")
	end

	species_count += 1
end

# End transaction
end

Species.find(:all).each do |species|
	species.save!
end
