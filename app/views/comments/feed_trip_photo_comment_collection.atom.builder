@comment_collection.publicize!(current_user)
trip_photo = @comment_collection.trip_photo
trip = trip_photo.trip
trip_photo.publicize!(current_user)
trip.publicize!(current_user)

atom_feed do |feed|
	feed.title("Birdstack: #{trip_photo.title} - #{trip.name} (#{@comment_collection.user.login})")
	feed.updated(@comment_collection.comments.last.created_at) if @comment_collection.comments.size > 0

	for comment in @comment_collection.comments.reverse
		feed.entry(comment, {:url => trip_photo_path(:user => @comment_collection.user.login, :trip_id => trip.id, :id => trip_photo.id)}) do |entry|
			entry.title(comment.user.login + ' said')
			entry.content(birdstack_sanitize(comment.comment), :type => 'html')

			entry.author do |author|
				author.name(comment.user.login)
			end
		end
	end
end
