class User < ActiveRecord::Base
  devise  :trackable, :omniauthable, omniauth_providers: [:fitbit]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.provider    = auth.provider
      user.uid         = auth.uid
    end
  end

  def set_omniauth_credentials(auth)
    self.oauth_token  = auth['credentials']['token']
    self.oauth_secret = auth['credentials']['secret']
  end

  def linked?
    oauth_token.present? && oauth_secret.present?
  end

  def fitbit_client
    raise 'Account is not linked with a Fitbit account' unless linked?
    @fitbit_client ||= Fitgem::Client.new(
      consumer_key: ENV['FITBIT_CONSUMER_KEY'],
      consumer_secret: ENV['FITBIT_CONSUMER_SECRET'],
      token: oauth_token,
      secret: oauth_secret,
      user_id: uid,
      ssl: true
    )
  end

  def info
    @info ||= fitbit_client.user_info['user']
  end

  def full_name
    info['fullName']
  end

  def timezone
    info['timezone']
  end

  def step_count
    fitbit_client.activities_on_date('today')['summary']['steps']
  end
end
