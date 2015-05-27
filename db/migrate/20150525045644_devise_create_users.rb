class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Omniauthable
      t.string :oauth_token
      t.string :oauth_secret
      t.string :provider
      t.string :uid

      t.timestamps null: false
    end
  end
end
