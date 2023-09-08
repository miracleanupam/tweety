require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "test micropost interface" do
    # Sign In
    sign_in_as(@user)
    assert_redirected_to root_path
    follow_redirect!

    # puts CGI::unescapeHTML(response.body)
    # Make sure there is a form to create a new micropost
    assert_select "form", count: 1

    assert_select "input[type=file]", count: 1
    # Make invalid micropost submission and make sure micropost count remains same
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"

    # Valid Submission
    content = "Test Micropost"
    image = fixture_file_upload('test/fixtures/test.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do 
      post microposts_path, params: { micropost: { content: content, image: image } }
    end
    latest_micropost = Micropost.first
    assert latest_micropost.image.attached?
    assert_redirected_to root_path

    follow_redirect!

    assert_match content, CGI::unescapeHTML(response.body)

    assert_select 'a', text: 'delete'

    first_micropost = Kaminari.paginate_array(@user.microposts).page(1).first
    puts first_micropost.content
    puts first_micropost.id

    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end

    get user_path(users(:dwight))
    assert_select 'a', text: 'delete', count: 0
  end
end
