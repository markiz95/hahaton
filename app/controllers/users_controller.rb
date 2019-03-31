class UsersController < ApplicationController
  before_action :unfollow_all, only: [:update]

  def edit
  end

  def update
    (Tag.where(id: user_params[:following_tags]) +
    User.where(id: user_params[:following_users])).each do |tag|
      current_user.follow(tag)
    end
    render 'edit'
  end
  
  private

  def unfollow_all
    current_user.all_following.each do |following|
      current_user.stop_following(following)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.permit(:following_tags => [], :following_users => [])
  end

end
