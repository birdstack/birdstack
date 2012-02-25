$stdout.sync = true

print "Subject: "
subject = $stdin.readline
subject.chomp!
puts "Body:"
newsletter = $stdin.read
newsletter.chomp!

puts "----"
puts "Subject: #{subject}"
puts "Body:"

puts NewsletterMailer.create_newsletter(subject, newsletter, User.find_by_login('cghawthorne')).body

puts "----"
print "Good to send? [yes/no]: "
exit unless $stdin.readline == "yes\n"

User.find(:all, :conditions => {:notify_newsletter => true}).each do |u|
	puts "Mailing #{u.login}"
	NewsletterMailer.deliver_newsletter(subject, newsletter, u)
end
