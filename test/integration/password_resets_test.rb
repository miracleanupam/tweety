require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    assert_select 'input[name=?]', 'password_reset[email]'

    # Invalid email
    post password_resets_path, params: { password_reset: { email: ""} }
    assert_not flash.empty?
    assert_redirected_to root_path

    # Valid email
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_path

    # Password Reset Form
    user = assigns(:user)

    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_path

    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_path

    # Right email, wrong token
    user.toggle!(:activated)
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_path

    # right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # Invalid password and confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: '', password_confirmation: '' } }
    assert_select 'div#error_explanation'

    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: 'worldhello', password_confirmation: 'helloworld' } }
    assert_select 'div#error_explanation'

    # correct email, correct token
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: 'helloworld', password_confirmation: 'helloworld' } }
    assert_nil user.reload.reset_digest
    assert is_signed_in_test?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }
    
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@user.reset_token), params: { email: @user.email, user: { password: 'newpassword', password_confirmation: 'newpassword' } }
    assert_response :redirect
    follow_redirect!
    assert_match 'expired', response.body
  end
end
