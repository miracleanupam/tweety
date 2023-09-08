class StaticPagesController < ApplicationController
  def home
    if is_signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed
      @feed_items = Kaminari.paginate_array(@feed_items).page(params[:page])
    end
  end

  def about
  end

  def contact
  end

  def help
  end
end
