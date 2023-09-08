require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:dwight)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not signed in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to signin_path
  end

  test "should redirect update when not signed in" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to signin_path
  end

  test "should not redirect on actions other than user edit and update" do
    get signup_path
    assert flash.empty?
    assert_template "new"
  end

  test "should redirect when signed in as wrong user" do
    sign_in_as(@user)
    get edit_user_path(@other_user)
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "should redirect update when signed in as wrong user" do
    sign_in_as(@user)
    patch user_path(@other_user), params: { user: { name: @other_user.name, email: @other_user.email } }
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "friendly forwarding user edit" do
    get edit_user_path(@user)
    sign_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name, email: email, password: '', password_confirmation: '' } }
    assert_not flash.empty?
    assert_redirected_to @uer
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "should redirect index when not signed in" do
    get users_path
    assert_redirected_to signin_path
  end

  test "should redirect destroy user when not signed in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end

    assert_redirected_to signin_path
  end

  test "should redirect destroy when signed in as non admin" do
    sign_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end

    assert_redirected_to root_path
  end

  test "User count should decrease by 1 when destroyed by admin" do
    sign_in_as(@user)
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
    end
  end

  test "should redirect following when not signed in" do
    get following_user_path(@user)
    assert_redirected_to signin_path
  end

  test "should redirect followers when not signed in" do
    get followers_user_path(@user)
    assert_redirected_to signin_path
  end
end
