unless ARGV.size == 1 then
  $stderr.puts "Usage: #{$0} <taxo.csv>"
  exit 1
end
results = Birdstack::VerifyDB.verify(ARGV[0])
puts results[:errors].join("\n");
if(results[:errors].size > 0) then
  puts results[:db_csv].join("\n");
end
puts "#{results[:errors].size} taxonomy errors"
