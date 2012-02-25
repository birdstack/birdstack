# Pipe the output of this through:
# aspell --lang=en create master ./birdstack.rws
# Place it in /data
# config/environment.rb sets up ASPELL_CONF to point to it

puts Species.find(:all, :conditions => ['change_id IS NULL']).collect {|s| s.english_name_search_version }.join("\n")
