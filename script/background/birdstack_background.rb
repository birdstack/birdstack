# Ensure that only one copy runs
f = File.new("/tmp/birdstack_background.pid", "a+")
f.flock(File::LOCK_EX|File::LOCK_NB) or raise "Could not obtain lock!"
f.truncate(0)
f.puts Process.pid
f.flush

# Run inside script/runner

ACTIVITY_GEN_DELAY = 1.minute

while(true) do
  puts "Running..."
  num_generated = Birdstack::Background::ActivityGenerator.generate_activities
  puts "Generated #{num_generated}"
  sleep ACTIVITY_GEN_DELAY.to_i
end
