class User < ApplicationRecord
  has_many :creator, foreign_key: :creator_id, class_name: "Event", dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :events, through: :members
  acts_as_followable
  acts_as_follower
  scope :all_except, ->(user) { where.not(id: user) }

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :omniauthable

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    @data = access_token.info
    @expires_at = Time.now + access_token["credentials"]['expires_at']
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    uri = URI('https://accounts.google.com/o/oauth2/revoke') 
    params = {:token => access_token["credentials"]["token"] }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get(uri)
    @expires_at = Time.now + access_token["credentials"]['expires_at']
    @token = access_token["credentials"]["token"]
    @refresh_token = access_token["credentials"]["refresh_token"]
    if user
      user.token  = @token
      user.google_refresh_token = @refresh_token
      user.oauth_expires_at    = @expires_at
      user.save
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        registered_user.image = @data["image"] unless registered_user.image
        registered_user.token  = @token
        registered_user.google_refresh_token = @refresh_token
        registered_user.oauth_expires_at    = @expires_at
        registered_user.save
        return registered_user
      else
       user = User.create(name: @data["name"],
                   provider:access_token.provider,
                   email: @data["email"],
                   image: @data["image"],
                   uid: access_token.uid,
                   password: Devise.friendly_token[0,20],
                   token: @token,
                   google_refresh_token: @refresh_token,
                   oauth_expires_at: @expires_at)
      end
    end
  end

end
