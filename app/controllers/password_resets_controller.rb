class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def edit; end

  def create
    @user = User.find_by(email: params[:password_reset][:email])
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
    end
    flash[:info] = 'Check your email for password reset instructions'
    redirect_to root_path
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "Can't be empty")
      render 'edit', status: 422
    elsif @user.update(user_params)
      sign_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = 'Password has been reset successfully'
      redirect_to @user
    else
      render 'edit', status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_has_expired?

    flash[:danger] = 'Password Reset has expired'
    redirect_to new_password_reset_path
  end
end
