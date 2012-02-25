Activity.all.each do |a|
  begin
    a.description[:sightings].each do |s|
      Sighting.find(s).publicize!
    end
    a.description[:locations].each do |l|
      UserLocation.find(l).publicize!
    end
    a.description[:trips].each do |t|
      Trip.find(t).publicize!
    end
  rescue
    puts "Something is messed up with #{a.id}.  Should be deleted"
  end
end
