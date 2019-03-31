require 'google/api_client/client_secrets.rb'
require 'google/apis/calendar_v3'

class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    if request.env["omniauth.auth"].info["email"] !~ /@profitero\.com$/
      flash[:alert] = "You must enter under profitero user account."
      redirect_to new_user_session_path
      return
    end

    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authorization
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
    end
  end

end
