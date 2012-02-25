#!/usr/bin/ruby

require "csv"
require 'ruby-debug'

ebird_map = {}

read_header = false
CSV.open(ARGV[0], 'r') do |row|
	unless read_header then
		read_header = true
		next
	end

	# Prepare for 2nd level hash action by adding a blank ADM1 mapping
	ebird_map[row[0]] ||= {'' => [row[1], '']}

	# Optional ADM1 processing
	if !row[2].blank? then
		# Find all alternate names for this ADM1
		# First, try an exact match on the ADM1 name
		adm1s = Adm1.find(:all, :conditions => ['cc = ? AND name LIKE ?', row[0], row[2]])
		# Then, if needed, do a substring search
		adm1s = Adm1.find(:all, :conditions => ['cc = ? AND name LIKE ?', row[0], '%' + row[2] + '%']) unless adm1s.size > 0

		# If we have ones that aren't 00, throw 00 out
		if adm1s.find {|adm1| adm1.adm1 != '00'} then
			adm1s = adm1s.reject {|adm1| adm1.adm1 == '00'}
		end
		
		# Check to make sure we found a unique match
		unless adm1s.collect {|adm1| adm1.adm1 }.uniq.size == 1 then
			$stderr.puts "ADM1 name is not unique or was not found: #{row.join(', ')}.  Possible matches: #{adm1s.collect {|adm1| adm1.name + ':' + adm1.adm1}.join(', ')}"
			next
		end

		Adm1.find(:all, :conditions => ['cc = ? AND adm1 = ?', row[0], adm1s[0].adm1]).collect do |alternate_name|
			ebird_map[row[0]][alternate_name.name] = [row[1], row[3]]
		end
	else
		ebird_map[row[0]][''] = [row[1]]
	end
end

puts "EBIRD_MAP = #{ebird_map.pretty_inspect}"
