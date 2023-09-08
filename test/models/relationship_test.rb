require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @michael = users(:michael)
    @dwight = users(:dwight)
    @relationship = Relationship.new(follower_id: @michael.id, followed_id: @dwight.id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require follower and followed id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?

    @relationship.follower_id = @michael.id
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
