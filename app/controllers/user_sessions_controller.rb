# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[create failure]

  def create
    user = User.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to new_group_path, notice: 'ログインしました'
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_path, alert: 'ログインをキャンセルしました'
  end
end
