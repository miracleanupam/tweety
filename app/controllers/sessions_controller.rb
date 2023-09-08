class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        sign_in(user)
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or root_path
      else
        flash[:warning] = "Please activate your account first. Check your email for account activation instructions."
        redirect_back_or root_path
      end
    else
      flash.now[:danger] = 'Invalid Credentials'
      render 'new', status: 422
    end
  end

  def destroy
    sign_out if is_signed_in?
    redirect_to root_url
  end
end
