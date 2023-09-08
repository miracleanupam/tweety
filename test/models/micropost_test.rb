require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @temp_user = User.new(name: "Eric Cartman", email: "eric@southpark.com", password: "password", password_confirmation: "password")
    @micropost = @user.microposts.build(content: 'Lorem Ipsum')
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "should contain text content" do
    @micropost.content = nil
    assert_not @micropost.valid?
  end

  test "content should be less than or equal to 140 characters" do
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end

  test "should be associated with a user" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "should be ordered in reverse chronological method" do
    assert_equal microposts(:coffee), Micropost.first
  end

  test "deletion of user should delete their microposts too" do
    @temp_user.save
    @temp_user.microposts.create!(content: "Respect my autho-rata")
    assert_difference 'Micropost.count', -1 do
      @temp_user.destroy
    end
  end
end
