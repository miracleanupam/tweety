require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', return_full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'nav.pagination'
    user_microposts = @user.microposts
    user_microposts = Kaminari.paginate_array(user_microposts).page(1)
    user_microposts.each do |mp|
      assert_match mp.content, CGI::unescapeHTML(response.body)
    end
  end
end
