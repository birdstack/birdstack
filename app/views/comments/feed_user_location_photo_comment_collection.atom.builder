@comment_collection.publicize!(current_user)
user_location_photo = @comment_collection.user_location_photo
user_location = user_location_photo.user_location
user_location_photo.publicize!(current_user)
user_location.publicize!(current_user)

atom_feed do |feed|
	feed.title("Birdstack: #{user_location_photo.title} - #{user_location.name} (#{@comment_collection.user.login})")
	feed.updated(@comment_collection.comments.last.created_at) if @comment_collection.comments.size > 0

	for comment in @comment_collection.comments.reverse
		feed.entry(comment, {:url => location_photo_path(:user => @comment_collection.user.login, :location_id => user_location.id, :id => user_location_photo.id)}) do |entry|
			entry.title(comment.user.login + ' said')
			entry.content(birdstack_sanitize(comment.comment), :type => 'html')

			entry.author do |author|
				author.name(comment.user.login)
			end
		end
	end
end
