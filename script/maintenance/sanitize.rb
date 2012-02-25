require 'ruby-debug'

conn = ActiveRecord::Base.connection

Species.transaction do
  conn.delete("DELETE FROM sightings WHERE private = 1")

  conn.delete("UPDATE sightings SET user_location_id = NULL WHERE sightings.user_location_id IN (SELECT user_locations.id FROM user_locations WHERE private = 2)")
  conn.delete("DELETE FROM user_locations WHERE private = 2")
  conn.update("UPDATE user_locations SET latitude = NULL, longitude = NULL, zoom = NULL, source = NULL WHERE private = 1")

  conn.delete("UPDATE sightings SET trip_id = NULL WHERE sightings.trip_id IN (SELECT trips.id FROM trips WHERE private = 1)")
  conn.delete("DELETE FROM trips WHERE private = 1")

  conn.delete("UPDATE comment_collections SET last_post_id = NULL WHERE private = 1")
  conn.delete("DELETE FROM comments WHERE comment_collection_id IN (SELECT id FROM comment_collections WHERE private = 1)")
  conn.delete("DELETE FROM comment_collections WHERE private = 1")

  conn.delete("DELETE FROM message_references")
  conn.delete("DELETE FROM messages")
  conn.delete("DELETE FROM conversations_users")
  conn.delete("DELETE FROM conversations")

  conn.delete("DELETE FROM friend_requests")

  conn.update("UPDATE users SET crypted_password = \"\", salt = \"\", activation_code = users.id")

  User.find(:all).each do |u|
    u.update_attribute('email', u.login + '@localhost')
  end
  debugger
end
