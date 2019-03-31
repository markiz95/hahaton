class User < ApplicationRecord
  has_many :creator, foreign_key: :creator_id, class_name: "Event", dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :events, through: :members
  acts_as_follower

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :omniauthable

  def refresh!
    data = JSON.parse(request_token_from_google.body)
    update_attributes(
      token: data['access_token'],
      expires_at: Time.now + data['expires_in'].to_i.seconds
    )
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    @data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    @token = access_token["credentials"]["token"]
    t = @token 
    url = URI("https://accounts.google.com/o/oauth2/token")
    data = JSON.parse(Net::HTTP.post_form(url, { 'refresh_token' =>@token,
      'client_id'     => Rails.application.secrets.google_client_id,
      'client_secret' => Rails.application.secrets.google_client_secret,
      'grant_type'    => 'refresh_token'}).body)
    t = data['access_token']
    @expires_at = Time.now + data['expires_in'].to_i.seconds
    @refresh_token = t
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
  
  def to_params
    { 'refresh_token' => refresh_token,
      'client_id'     => Rails.application.secrets.google_client_id,
      'client_secret' => Rails.application.secrets.google_client_secret,
      'grant_type'    => 'refresh_token'}
  end

  def request_token_from_google
    url = URI("https://accounts.google.com/o/oauth2/token")
    Net::HTTP.post_form(url, self.to_params)
  end
  
  def self.access_token
    #convenience method to retrieve the latest token and refresh if necessary
  end


end
