# frozen_string_literal: true

class RetirementsController < ApplicationController
  def create
    if current_user.destroy
      reset_session
      redirect_to root_path, notice: 'アカウントが削除されました'
    else
      redirect_to root_path, alert: current_user.errors.full_messages.to_sentence
    end
  end
end
