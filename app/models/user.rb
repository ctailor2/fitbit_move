class User < ActiveRecord::Base
  devise  :rememberable, :trackable, :omniauthable, omniauth_providers: [:fitbit]
end
