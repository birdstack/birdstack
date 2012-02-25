$stdout.sync = true

print "User: "
user = $stdin.readline
user = User.find_by_login(user.chomp)

if !user.notify_membership then
  print "User has elected not to receive membership updates.\n"
  exit
end

mail = MembershipMailer.create_membership(user)

puts "----"

puts "Subject: " + mail.subject
puts
puts mail.body

puts "----"
print "Good to send? [yes/no]: "
exit unless $stdin.readline == "yes\n"

MembershipMailer.deliver_membership(user)
