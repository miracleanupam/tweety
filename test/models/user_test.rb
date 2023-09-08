require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "John Doe", email: "johndoe@email.com", password: "foobar", password_confirmation: "foobar")
  end

  test "user should be valid" do
    assert @user.valid?
  end

  test "user should have a name" do
    @user.name = "     "
    assert_not @user.valid?
    @user.name = nil
    assert_not @user.valid?
    @user.name = ''
    assert_not @user.valid?
  end

  test "user email should not be empty" do
    @user.email = "     "
    assert_not @user.valid?
    @user.email = nil
    assert_not @user.valid?
    @user.email = ''
    assert_not @user.valid?
  end

  test "user emails shold not be too long" do
    @user.email = 'a' * 250 + '@email.com'
    assert_not @user.valid?
  end
  
  test "user should have a valid email" do
    valid_address = %w[user@example.com USRE@example.com a_BC@example.com foo.bar@example.com alice+bob@example.com]
    valid_address.each { |ve|
      @user.email = ve
      assert @user.valid?, "#{ve.inspect} should be valid"
    }

    invalid_address = %w[user.com johndoe@user]
    invalid_address.each { |ive|
      @user.email = ive
      assert_not @user.valid?
    }
  end

  test "each user must have a unique email" do
    duplicate_user = @user.dup
    @user.save
    duplicate_user.email = @user.email.upcase
    assert_not duplicate_user.valid?
  end

  test "email address should be saved as lowercase" do
    mixed_case_email = "ABC@gMaIL.com"
    @user.email = mixed_case_email.upcase
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "every user should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = "   "
    assert_not @user.valid?
  end

  test "password should have a mimium length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    toby = users(:toby)
    assert_not michael.following?(toby)
    michael.follow(toby)
    assert michael.following?(toby)
    assert toby.followers.include?(michael)
    michael.unfollow(toby)
    assert_not michael.following?(toby)
  end

  test "feed should have right posts" do
    michael = users(:michael)
    andy = users(:andy)
    gabe = users(:gabe)

    michael.follow(andy)

    andy.microposts.each do |post_following|
      assert michael.feed.include?(post_following)    
    end

    gabe.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end

    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
  end
end
