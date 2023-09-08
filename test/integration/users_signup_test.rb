require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path

    assert_no_difference 'User.count' do
      post users_path params: { user: {
        name: "",
        email: "abc@gmail",
        password: "hello",
        password_confirmation: "helloworld",
      }}

      assert_template 'users/new'

      # assert_select 'css selector'
      # To find the ul element inside div with id: error_explanation
      # css selector is div#error_explanation ul
      # and inside that we expert 4 li elements
      assert_select "div#error_explanation ul" do
        assert_select 'li', 4
      end
    end
  end

  test "valid signup information with account activation" do
    get signup_path

    # Sign up as new user and make user user count increses by 1
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User', email: 'user@example.com', password: 'password', password_confirmation: 'password' } }
    end
    
    # Make sure activaion email for the newly registered user has been sent
    assert_equal  1, ActionMailer::Base.deliveries.size

    # assign lets us access instance variable in corresponding action
    user = assigns(:user)

    # make user the account has not been activated yet
    assert_not user.activated?

    # Try signing in without activating the account and make user the user is not signed in
    sign_in_as(user)
    assert_not is_signed_in_test?

    # Try activating the account with invalid token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_signed_in_test?

    # Try activating the account with incorrect email address
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_signed_in_test?

    # Try activating the account with right params
    puts user.activation_token
    puts user.email
    get edit_account_activation_path(user.activation_token, email: user.email)
    puts user.reload.activated?

    follow_redirect!

    # User should be signed in and redirected to their profile
    assert_template 'users/show'
    assert is_signed_in_test?
  end

  test "valid signup information" do
    get signup_path

    assert_difference 'User.count', 1 do
      post users_path params: { user: {
        name: 'Homer Simpson',
        email: 'homer@python.com',
        password: 'springfield',
        password_confirmation: 'springfield',
      }}
    end

    follow_redirect!
    assert_template 'static_pages/home'

    assert_not is_signed_in_test?
    assert_select ".alert-success"
  end
end
