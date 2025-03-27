# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[create]

  def create
    user = User.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
    session[:user_id] = user.id
    params = request.env['omniauth.params']

    if params['group_id']
      create_ticket_and_redirect(user, params['group_id'])
    else
      redirect_to request.env['omniauth.origin'] || root_path, notice: 'ログインしました'
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
