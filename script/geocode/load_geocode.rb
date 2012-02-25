conn = ActiveRecord::Base.connection

Species.transaction do
begin

adm1file = ARGV[0] + "/ADM-1-Reference.csv"

puts "Clearing DB"
conn.delete("DELETE FROM primary_adm1s")
conn.delete("DELETE FROM adm1s")
conn.delete("DELETE FROM country_codes")
conn.delete("DELETE FROM adm2s")


# Load main place DB

puts "Opening main location database: " + ARGV[1]
File.open(ARGV[1]).each do |line|
	row = line.split("\t").collect { |i| i.strip }
	if row[10] == 'ADM1' then
		puts "Adding ADM1 [" + row[23] + "]"
		conn.insert("INSERT INTO adm1s (cc, adm1, name) VALUES (#{ conn.quote(row[12]) }, #{ conn.quote(row[13]) }, #{ conn.quote(row[23]) })")
		id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()'].to_i
		if row[18] == 'eng' then
			next if !conn.select_one("SELECT * FROM primary_adm1s WHERE cc = #{ conn.quote(row[12]) } AND adm1 = #{ conn.quote(row[13]) }").nil?
			puts "Also adding as primary"
			conn.insert("INSERT INTO primary_adm1s (cc, adm1, adm1_id) VALUES (#{ conn.quote(row[12]) }, #{ conn.quote(row[13]) }, #{ conn.quote(id) })")
		end
	elsif row[9] == 'P' then
		puts "Adding place [" + row[23] + "]"
		conn.insert("INSERT INTO locations (latitude, longitude, cc, adm1, adm2, name) VALUES (#{ conn.quote(row[3]) }, #{ conn.quote(row[4]) }, #{ conn.quote(row[12]) }, #{ conn.quote(row[13]) }, #{ conn.quote(row[14]) }, #{ conn.quote(row[23]) })")
	end
end

# Read ADM1 reference file, find ADM1s already in the database that do not have a primary, add the primary from the reference file

puts "Reading in local ADM1 primary reference: " + adm1file
adm1_reference = Hash.new
File.open(adm1file).each do |line|
	row = line.split("\t").collect {|i| i.strip }
	if row[1] =~ /\A\d+\z/ then
		row[1] = sprintf("%02d", row[1])
	end
	adm1_reference[row[0] + row[1]] = row[2]
	puts row.join(', ')
end

conn.select_all("SELECT DISTINCT cc, adm1 FROM adm1s").each do |adm|
	if !conn.select_one("SELECT * FROM primary_adm1s WHERE cc = #{ conn.quote(adm['cc']) } AND adm1 = #{ conn.quote(adm['adm1']) }").nil? then
		puts "Skipping " + adm['cc'] + adm['adm1']
		next
	end
	if adm1_reference[adm['cc'] + adm['adm1']] then
		puts "Adding " + adm['cc'] + adm['adm1'] + " = " + adm1_reference[adm['cc'] + adm['adm1']]
		id = conn.select_one("SELECT id FROM adm1s WHERE cc = #{ conn.quote(adm['cc']) } AND adm1 = #{ conn.quote(adm['adm1']) }")['id']
		conn.insert("INSERT INTO primary_adm1s (cc, adm1, adm1_id) VALUES (#{ conn.quote(adm['cc']) }, #{ conn.quote(adm['adm1']) }, #{ conn.quote(id) })")
	else
		puts "Failed to add " + adm['cc'] + adm['adm1']
	end
end

# Load US Places

puts "Opening US place DB " + ARGV[2]

File.open(ARGV[2]).each do |line|
	row = line.split("\t").collect {|i| i.strip }
	next unless row[0] =~ /\A\d+\z/ # Make sure we skip the header

	puts ("INSERT INTO locations (latitude, longitude, cc, adm1, adm2, name) VALUES (#{ conn.quote(row[9]) }, #{ conn.quote(row[10]) }, #{ conn.quote('US') }, #{ conn.quote(row[4]) }, #{ conn.quote(row[5]) }, #{ conn.quote(row[1]) })")
	conn.insert("INSERT INTO locations (latitude, longitude, cc, adm1, adm2, name) VALUES (#{ conn.quote(row[9]) }, #{ conn.quote(row[10]) }, #{ conn.quote('US') }, #{ conn.quote(row[4]) }, #{ conn.quote(row[5]) }, #{ conn.quote(row[1]) })")
end

# Load CCs

puts "Reading in local ADM1 primary reference " + adm1file
File.open(adm1file).each do |line|
	row = line.split("\t").collect {|i| i.strip }
	if row[1] =~ /\A\d+\z/ then
		row[1] = sprintf("%02d", row[1])
	end

	next unless row[1] == '00'

	puts "Adding CC " + row.join(', ')
	country_name = row[2].sub('(general)', '').strip
	puts "For country " + country_name

	conn.insert("INSERT INTO adm1s (cc, adm1, name) VALUES (#{ conn.quote(row[0]) }, #{ conn.quote(row[1]) }, #{ conn.quote(row[2]) })")
	id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()'].to_i
	conn.delete("DELETE FROM primary_adm1s WHERE cc = #{ conn.quote(row[0]) } AND adm1 = #{ conn.quote(row[1]) }")
	conn.insert("INSERT INTO primary_adm1s (cc, adm1, adm1_id) VALUES (#{ conn.quote(row[0]) }, #{ conn.quote(row[1]) }, #{ conn.quote(id) })")

	conn.insert("INSERT INTO country_codes (cc, name) VALUES (#{ conn.quote(row[0]) }, #{ conn.quote(country_name) })")
end

# Load missing ADM1s
# Read the ADM1 file, make sure all of these have been entered.  This is a sort of last resort

puts "Reading in local ADM1 primary reference " + adm1file
File.open(adm1file).each do |line|
	row = line.split("\t").collect {|i| i.strip }
	if row[1] =~ /\A\d+\z/ then
		row[1] = sprintf("%02d", row[1])
	end

	if !conn.select_one("SELECT * FROM primary_adm1s WHERE cc = #{ conn.quote(row[0]) } AND adm1 = #{ conn.quote(row[1]) }").nil? then
		puts "Skipping " + row[0] + row[1]
		next
	end

	if row[2] =~ /\(\w\w\w\w\)/ then
		puts "Not adding " + row.join(', ')
		next
	end

	puts "Adding " + row.join(', ')
	conn.insert("INSERT INTO adm1s (cc, adm1, name) VALUES (#{ conn.quote(row[0]) }, #{ conn.quote(row[1]) }, #{ conn.quote(row[2]) })")
	id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()'].to_i
	conn.insert("INSERT INTO primary_adm1s (cc, adm1, adm1_id) VALUES (#{ conn.quote(row[0]) }, #{ conn.quote(row[1]) }, #{ conn.quote(id) })")
end

# Load ADM2 from main DB

puts "Opening main location db: " + ARGV[1]
File.open(ARGV[1]).each do |line|
	row = line.split("\t").collect { |i| i.strip }
	if row[10] == 'ADM2' and !row[23].blank? then
		puts "Adding ADM2 [" + row[23] + "]"
		puts("INSERT INTO adm2s (latitude, longitude, cc, adm1, name) VALUES (#{ conn.quote(row[3]) }, #{ conn.quote(row[4]) }, #{ conn.quote(row[12]) }, #{ conn.quote(row[13]) }, #{ conn.quote(row[23]) })")
		conn.insert("INSERT INTO adm2s (latitude, longitude, cc, adm1, name) VALUES (#{ conn.quote(row[3]) }, #{ conn.quote(row[4]) }, #{ conn.quote(row[12]) }, #{ conn.quote(row[13]) }, #{ conn.quote(row[23]) })")
	end
end

# Load ADM1 for US

usadm1file = ARGV[0] + '/State-ADM1.csv'
puts "Opening US State DB: " + usadm1file
File.open(usadm1file).each do |line|
	row = line.split("\t").collect {|i| i.strip }
	if row[1] =~ /\A\d+\z/ then
		row[1] = sprintf("%02d", row[1])
	end
	puts "Adding primary ADM1 " + row.join(', ')
	conn.insert("INSERT INTO adm1s (cc, adm1, name) VALUES (#{ conn.quote('US') }, #{ conn.quote(row[1]) }, #{ conn.quote(row[0]) })")
	id = conn.select_one("SELECT LAST_INSERT_ID()")['LAST_INSERT_ID()'].to_i
	conn.insert("INSERT INTO primary_adm1s (cc, adm1, adm1_id) VALUES (#{ conn.quote('US') }, #{ conn.quote(row[1]) }, #{ conn.quote(id) })")
end

# Load ADM2 from US

puts "Opening US allstates db: " + ARGV[3]
File.open(ARGV[3]).each do |line|
	row = line.split("|").collect { |i| i.strip }
	if row[2] == 'Civil' then
		puts "Adding ADM2 [" + row[1] + "]"

		puts("INSERT INTO adm2s (latitude, longitude, cc, adm1, name) VALUES (#{ conn.quote(row[9]) }, #{ conn.quote(row[10]) }, #{ conn.quote('US') }, #{ conn.quote(row[4]) }, #{ conn.quote(row[1]) })")
		conn.insert("INSERT INTO adm2s (latitude, longitude, cc, adm1, name) VALUES (#{ conn.quote(row[9]) }, #{ conn.quote(row[10]) }, #{ conn.quote('US') }, #{ conn.quote(row[4]) }, #{ conn.quote(row[1]) })")
	end
end

# End transaction

begin
	puts "Verify that things are good.  If so, continue; if not, throw an exception and the transaction will abort"
	require 'ruby-debug'
	debugger
rescue LoadError
	puts "Unable to load debugger.  Continuing."
end

rescue e
	puts "Something bad happened"
	puts $!
	begin
		require 'ruby-debug'
		debugger
	rescue LoadError
		puts "Unable to load debugger.  Bailing."
	end
end


end
