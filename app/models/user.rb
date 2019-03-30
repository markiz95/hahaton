class User < ApplicationRecord
  has_many :events, foreign_key: :creator_id, class_name: "Event", dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :events, through: :members

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :omniauthable

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
     @data = access_token.info
     user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
     @token = access_token["credentials"]["token"]
     @refresh_token = access_token["credentials"]["refresh_token"]
     @expires_at = access_token["credentials"]["expires_at"]
     if user
       user.image = @data["image"] unless user.image
       return user
     else
       registered_user = User.where(:email => access_token.info.email).first
       if registered_user
        registered_user.image = @data["image"] unless registered_user.image
        return registered_user
       else
        user = User.create(name: @data["name"],
                    provider:access_token.provider,
                    email: @data["email"],
                    image: @data["image"],
                    uid: access_token.uid,
                    password: Devise.friendly_token[0,20],
                    token: @token         )
       end
     end
   end

   def self.find_for_show
   end 

end
