require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  def test_cannot_update_deleted
	  c = comments(:deleted)
	  c.comment = "boo for cheese"
	  assert !c.save
	  assert c.errors
  end

  def test_can_delete_comment
	  cc = comment_collections(:aaroncollection)
	  c = Comment.new
	  c.user = users(:quentin)
	  c.comment = "awesomes"
	  c.comment_collection = cc
	  assert c.save
	  assert_equal cc.last_post_id, c.id
	  # Now we've saved, which means that the cached stuff is updated
	  # Now, we try to delete, which will fail a foreign key constraint unless the destroy method clears the cached last post id first
	  assert c.destroy
	  assert_not_equal c.comment_collection.last_post_id, c.id
  end

  def test_nil_last_post_cache_when_all_are_deleted
	  cc = comment_collections(:aaroncollection)
	  c = Comment.new
	  c.user = users(:quentin)
	  c.comment = "awesomes"
	  c.comment_collection = cc
	  assert c.save
	  assert_equal cc.last_post_id, c.id

	  # Ok, we've got at least one comment, and it was cached in the comment collection
	  # Now, delete all comments and make sure the caches get cleared

	  cc.comments.each do |comment|
		  assert comment.destroy
		  assert_not_equal comment.comment_collection.last_post_id, comment.id
	  end

	  cc.reload

	  assert_nil cc.last_post_id
	  assert_nil cc.posted_at
	  assert_nil cc.posted_by
  end
end
