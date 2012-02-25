atom_feed do |feed|
	feed.title('Birdstack: ' + @forum.name)
	feed.updated(@threads.first.created_at) if @threads.size > 0

	for comment_collection in @threads
		feed.entry(comment_collection, {:url => url_for(:controller => 'forums', :forum => @forum.url, :action => 'thread', :id => comment_collection.id)}) do |entry|
			entry.title(comment_collection.title)

			entry.content(birdstack_sanitize(comment_collection.comments.first.comment), :type => 'html')

			entry.author do |author|
				author.name(comment_collection.user.login)
			end
		end
	end
end
