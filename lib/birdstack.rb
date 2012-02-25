module Birdstack
  # TODO most of these really belong in models as class methods

  def self.sanitize(s)
    Birdstack::Sanitize::birdstack_sanitize(s)
  end

  def self.strip_tags(s)
    Birdstack::Sanitize::strip_tags(s)
  end

  def self.trips_options(user)
    user.trips.find(:all, :order => 'trips.lft').collect do |trip|
      [
        (1..trip.level).collect{'-'}.join() +
                                        ' ' +
                                        trip.name +
                                        (trip.science_trip? ? ' *' : ''),
                                        trip.id,
      ]
    end
  end

  def self.search_version(name)
    # Arg, I wish Ruby had good unicode support
    name.to_s.gsub('Ä','A').gsub('Ü', 'U').gsub('Ö', 'O').gsub('ä', 'a').gsub('ü','u').gsub('ö', 'o').gsub(/[^[:alpha:]]/, '').downcase
  end
end

