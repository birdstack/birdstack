@comment_collection.publicize!(current_user)

atom_feed do |feed|
	feed.title("Birdstack: #{@comment_collection.trip.name} (#{@comment_collection.user.login})")
	feed.updated(@comment_collection.comments.last.created_at) if @comment_collection.comments.size > 0

	for comment in @comment_collection.comments.reverse
		feed.entry(comment, {:url => trip_path(:user => @comment_collection.user.login, :id => @comment_collection.trip.id)}) do |entry|
			entry.title(comment.user.login + ' said')
			entry.content(birdstack_sanitize(comment.comment), :type => 'html')

			entry.author do |author|
				author.name(comment.user.login)
			end
		end
	end
end
