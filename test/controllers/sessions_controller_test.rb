require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new session" do
    get signin_path
    assert_response :success
  end
end
