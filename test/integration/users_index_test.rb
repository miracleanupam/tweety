require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:michael)
    @assistant_to_the_admin_user = users(:dwight)
  end

  test "index with pagination" do
    sign_in_as(@admin_user)
    get users_path
    assert_template 'users/index'
    assert_select 'nav.pagination'

    first_page_of_users = User.where(activated: true)
    first_page_of_users = Kaminari.paginate_array(first_page_of_users).page(1)

    first_page_of_users.each { |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?]', user_path(user), text: 'delete' unless user.admin? 
    }
    
    assert_difference 'User.count', -1 do
      delete user_path(@assistant_to_the_admin_user)
    end
  end

  test "index as non-admin" do
    sign_in_as(@assistant_to_the_admin_user)
    assert_select 'a[href=?]', users_path(@admin_user), text: 'delete', count: 0

    assert_no_difference 'User.count' do
      delete user_path(@admin_user)
    end
  end
end
