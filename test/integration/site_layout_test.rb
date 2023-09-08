require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout_links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count:2
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", help_path
  end

  test "return_full_title_test" do
    get root_path
    assert_select "title", return_full_title
    get contact_path
    assert_select "title", return_full_title("Contact")
  end
  
  test "full title helper test" do
    assert_equal return_full_title, "Tweety"
    assert_equal return_full_title("About"), "About | Tweety"
  end
end
