require File.dirname(__FILE__) + '/../test_helper'

class ConversationTest < ActiveSupport::TestCase
  context "A Conversation" do
    setup do
      @c = Conversation.new(:subject => 'hi', :participants_text => 'quentin, joe1')
      assert @c.save
    end

    should "look up users correctly" do
      assert @c.users.include?(users(:quentin))
      assert @c.users.include?(users(:joe1))
      assert_equal 2, @c.users.size
    end

    should "be resavable" do
      c2 = Conversation.find(@c.id)
      assert c2.save
    end

    should "be able to add additional users" do
      @c.additional_users = [users(:anotherjoe)]
      assert @c.save
      assert @c.users.include?(users(:anotherjoe))
      assert_equal 3, @c.users.size
    end

    should "not include a message from an uninvolved user" do
      @m = Message.new(:body => 'test')
      @m.conversation = @c
      @m.user = users(:anotherjoe)
      assert !@m.save
      assert @m.errors.on(:users)
    end
  end

  context "A Conversation" do
    setup do
      @c = Conversation.new
    end
    
    should "require more than 1 particpant" do
      @c.subject = 'hi'
      @c.participants_text = 'quentin'
      assert !@c.save
      assert @c.errors.on(:users)
    end
  end

  context "A Conversation with a message" do
    setup do
      @c = Conversation.new(:subject => 'hi', :participants_text => 'quentin, joe1')
      assert @c.save
      @m = Message.new(:body => 'test')
      @m.conversation = @c
      @m.user = users(:quentin)
      assert @m.save
    end

    should "disappear when all references are gone" do
      @m.message_references.each do |mr|
        mr.destroy
      end

      assert !Conversation.find_by_id(@c.id)
    end

    should "stick around when not all references are gone" do
      @m.message_references.first.destroy

      assert Conversation.find_by_id(@c.id)
    end
  end
end
