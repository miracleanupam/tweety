class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && user.authenticated?(:activation, params[:id])
      if user.activated? && !is_signed_in?
        flash[:warning] = "Account already activated, please login"
        redirect_to signin_path
      elsif user.activated?
        flash[:warning] = "Account already activated, here is your Profile"
        redirect_back_or user
      else
        user.activate
        sign_in user
        flash[:success] = "Welcome Again!, Your account has been successfully activated!"
        redirect_to user
      end
    else
      flash[:danger] = "Something was not right!"
      redirect_to root_path
    end
  end
end
