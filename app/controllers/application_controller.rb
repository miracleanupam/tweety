class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    def signed_in_user
      unless is_signed_in?
        store_location
        flash[:danger] = "Please sign in first!"
        redirect_to signin_path
      end
    end
end
