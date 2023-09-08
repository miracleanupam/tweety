class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Tweetie Created Successfully!"
      redirect_to root_path
    else
      @feed_items = current_user.feed
      @feed_items = Kaminari.paginate_array(@feed_items).page(params[:page])
      render 'static_pages/home', status: 422
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Tweetie Deleted Successfully!"
    redirect_to request.referrer || root_path
  end

  private
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_path if @micropost.nil?
    end
end
