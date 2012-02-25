#!/usr/bin/ruby

require 'csv'
require "regions"

writer = CSV.open(ARGV[1], 'w')
CSV.open(ARGV[0], 'r') do |row|
	order = row[0].strip.gsub(/\s+/, ' ')
	unless order =~ /\A[[:alpha:]]+\z/ then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "order: [#{order}]"
	end

	family_english = row[1].strip.gsub(/\s+/, ' ')
	unless family_english =~ /\A[[:alpha:] ,&-]+\z/ then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "family_english: [#{family_english}]"
	end

	family_latin = row[2].strip.gsub(/\s+/, ' ')
	unless family_latin =~ /\A([[:alpha:]]+)|(Incertae sedis)\z/ then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "family_latin: [#{family_latin}]"
	end

	species_english = row[3].strip.gsub(/\s+/, ' ').gsub('’', "'").gsub('–','-')
	unless species_english =~ /\A[[:alpha:]'. Öäüö-]+\z/u then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "species_english: [#{species_english}]"
	end

	genus = row[4].strip.gsub(/\s+/, ' ')
	unless genus =~ /\A[[:alpha:]]+\z/ then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "genus: [#{genus}]"
	end

	species_latin = row[5].strip.gsub(/\s+/, ' ')
	unless species_latin =~ /\A[[:alpha:]]+\z/ then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "species_latin: [#{species_latin}]"
	end

	breeding_ranges = row[6].strip.gsub(/\s+/, ' ')
	breeding_ranges.split(/,\s*/).each do |i|
		unless Regions::REGION_ABBREVIATIONS[i] then
			$stderr.puts "row: " + row.join(',')
			$stderr.puts "Invalid region: " + i
		end
	end

	breeding_range_subregions = row[7]
	if !breeding_range_subregions.nil? then
		breeding_range_subregions.strip.gsub(/\s+/, ' ')
	end
	nonbreeding_range = row[8]
	if !nonbreeding_range.nil? then
		nonbreeding_range.strip.gsub(/\s+/, ' ')
	end

	unless row[9].nil? then
		$stderr.puts "row: " + row.join(',')
		$stderr.puts "Extra row!"
	end

	writer << [order, family_english, family_latin, species_english, genus, species_latin, breeding_ranges, breeding_range_subregions, nonbreeding_range]
end

