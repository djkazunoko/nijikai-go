# frozen_string_literal: true

class UserSessions::FailureController < ApplicationController
  skip_before_action :authenticate, only: %i[create]

  def create
    redirect_to root_path, alert: 'ログインをキャンセルしました。'
  end
end
