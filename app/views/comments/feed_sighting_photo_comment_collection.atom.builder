@comment_collection.publicize!(current_user)
sighting_photo = @comment_collection.sighting_photo
sighting = sighting_photo.sighting
sighting_photo.publicize!(current_user)
sighting.publicize!(current_user)

atom_feed do |feed|
	feed.title("Birdstack: #{sighting_photo.title} - #{sighting.species.english_name} (#{@comment_collection.user.login})")
	feed.updated(@comment_collection.comments.last.created_at) if @comment_collection.comments.size > 0

	for comment in @comment_collection.comments.reverse
		feed.entry(comment, {:url => observation_photo_path(:user => @comment_collection.user.login, :sighting_id => sighting.id, :id => sighting_photo.id)}) do |entry|
			entry.title(comment.user.login + ' said')
			entry.content(birdstack_sanitize(comment.comment), :type => 'html')

			entry.author do |author|
				author.name(comment.user.login)
			end
		end
	end
end
