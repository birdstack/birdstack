$stdout.sync = true

print "Blog post URL: "
url = $stdin.readline.chomp

users = User.find(:all, :conditions => {:pending_taxonomy_changes => true, :notify_taxonomy_changes => true})

puts "Sample mail:"
puts TaxonomyMailer.create_taxonomy_changes(users.first, url).body
puts

print "Ready to send? (y/n): "
exit unless $stdin.readline.chomp == "y"

users.each do |u|
	puts "Mailing #{u.login}"
	TaxonomyMailer.deliver_taxonomy_changes(u, url)
end
