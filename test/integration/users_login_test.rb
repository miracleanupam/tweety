require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "flash message should dissapear on page reload/redirect/navigation" do
    get signin_path
    assert_template 'sessions/new'

    post signin_path params: { session: {
      email: 'mail@testemail.com',
      password: 'invalidpassword',
    }}

    assert_not is_signed_in_test?

    assert_template 'sessions/new'
    assert_not flash.empty?
    
    get root_path
    assert flash.empty?
  end

  test "login with valid info followed by logout" do 
    get signin_path
    post signin_path params: {
      session: {
        email: @user.email,
        password: 'password'
      }
    }

    assert_redirected_to root_path
    follow_redirect!

    assert_template 'static_pages/home'
    # assert_select "a[href=?]", signin_path, count: 0
    # assert_select "a[href=?]", signout_path
    # assert_select "a[href=?]", user_path(@user)

    delete signout_path
    assert_not is_signed_in_test?
    assert_redirected_to root_url

    delete signout_path
    follow_redirect!

    assert_select "a[href=?]", signin_path
    assert_select "a[href=?]", signout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    sign_in_as(@user, remember_me: '1')
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    sign_in_as(@user, remember_me: '1')
    sign_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
end
