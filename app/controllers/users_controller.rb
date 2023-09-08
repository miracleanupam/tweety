class UsersController < ApplicationController

  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  
  def show
    @user = User.find(params[:id])
    redirect_to root_path and return unless @user.activated?

    @microposts = @user.microposts
    @microposts_count = @microposts.count
    @microposts = Kaminari.paginate_array(@microposts).page(page=params[:page])
  end

  def new
    @user = User.new
  end
  
  def index
    @users = User.where(activated: true)
    @users = Kaminari.paginate_array(@users).page(page=params[:page])
  end

  def edit
    @user = User.find_by(id: params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:success] = "Please check your email to activate your account!"
      redirect_to root_path
    else
      render 'new', status: 422
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      render 'edit', status: 422
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User Deleted successfully"
    redirect_to users_path
  end

  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = Kaminari.paginate_array(@user.following).page(params[:page]).per(30)
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = Kaminari.paginate_array(@user.followers).page(params[:page]).per(30)
    render 'show_follow'
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # def signed_in_user
    #   unless is_signed_in?
    #     store_location
    #     flash[:danger] = "Please Log In First"
    #     redirect_to signin_path
    #   end
    # end

    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = "Not Authorized"
        redirect_to root_path
      end
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
