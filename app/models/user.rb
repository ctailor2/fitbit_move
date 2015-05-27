class User < ActiveRecord::Base
  devise  :trackable, :omniauthable, omniauth_providers: [:fitbit]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.provider    = auth.provider
      user.uid         = auth.uid
    end
  end

  def set_omniauth_credentials(auth)
    oauth_token  = auth['credentials']['token']
    oauth_secret = auth['credentials']['secret']
  end
end
