require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @micropost = microposts(:orange)
    @micropost_of_other_user = microposts(:laptop)
  end

  test "should redirect when trying to create when not signed in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { microopst: { content: 'Lorem Ipsum' } }
    end
    assert_redirected_to signin_path
  end

  test "should redirect destroy when not signed in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to signin_path
  end

  test "should redirect destroy for wrong micropost" do
    sign_in_as(@user)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost_of_other_user)
    end
    assert_redirected_to root_path
  end
end
