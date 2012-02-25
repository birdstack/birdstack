require "csv"

Species.transaction do

header = false
CSV.open(ARGV[0], 'r') do |row|
	unless header then
		header = true
		next
	end

	next if row[5].blank?

	s = Species.find_valid_by_exact_english_name(row[5])
	s.code = row[9]
	s.note = row[10]
	s.save!
end

errors = Birdstack::VerifyDB.verify(ARGV[0])

if errors.size > 0 then
	puts errors.join("\n")
	puts "#{errors.size} errors found"
	raise 'The database does not fully match the csv'
end

puts "Loaded and verified!  You rock!"

end # end transaction
