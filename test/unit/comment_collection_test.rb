require File.dirname(__FILE__) + '/../test_helper'

class CommentCollectionTest < ActiveSupport::TestCase
	test "test_delete_comments" do
		cc = UserCommentCollection.create(:title => 'test')
		cc.user = users(:quentin)
		cc.save!
		c = Comment.new
		c.user = users(:quentin)
		c.comment = "balrgh"
		cc.comments << c

		cc.destroy
		assert !CommentCollection.find_by_id(cc.id)
		assert !Comment.find_by_id(c.id)
	end
end
