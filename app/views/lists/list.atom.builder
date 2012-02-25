# As far as publicize! and friends are concerned, the user is always someone other than the owner 
@saved_search.publicize!(:false)
search = Birdstack::Search.new(@saved_search.user, @saved_search.search, true, :false)
sightings = search.search_no_paginate('created_at_desc', params[:limit] || 10)

atom_feed do |feed|
	feed.title("Birdstack: #{@saved_search.name} (#{@saved_search.user.login})")
	feed.updated(sightings.first.created_at) if sightings.size > 0

	for sighting in sightings
		sighting.publicize!(:false)
		feed.entry(sighting, {:url => observation_url(:user => sighting.user.login, :id => sighting.id)}) do |entry|
			entry.title(sighting.species.english_name)
			entry.content(render(:partial => 'shared/observation_report.html.erb', :locals => {:sighting => sighting, :publicize_for => :false}), :type => 'html')

			entry.author do |author|
				author.name(sighting.user.login)
			end
		end
	end
end
