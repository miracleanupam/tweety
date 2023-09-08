module ApplicationHelper
  def return_full_title(page_title='')
    base_title = 'Tweety'
    puts page_title
    if page_title.empty?
      return base_title
    else
      return "#{page_title} | #{base_title}"
    end
  end
end
