# frozen_string_literal: true

class PostsController < ApplicationController
  def create
    group = Group.find(params[:group_id])
    post = current_user.posts.build do |t|
      t.group = group
      t.content = params[:post][:content]
    end

    if post.save
      redirect_to group, notice: '投稿が作成されました'
    else
      redirect_to group, alert: post.errors.full_messages.to_sentence
    end
  end
end
