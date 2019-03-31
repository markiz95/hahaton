class ApplicationController < ActionController::Base

  def after_sign_in_path_for(resource_or_scope)
    edit_user_path(current_user.id)
  end
end
