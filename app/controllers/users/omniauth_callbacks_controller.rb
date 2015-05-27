class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def fitbit
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)
    user.set_omniauth_credentials(auth)
    if user.save
      sign_in_and_redirect user
    else
      redirect_to root_path
    end
  end
end

