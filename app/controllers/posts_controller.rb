# frozen_string_literal: true

class PostsController < ApplicationController
  def create
    @group = Group.find(params[:group_id])
    @post = current_user.posts.build do |t|
      t.group = @group
      t.content = params[:post][:content]
    end

    respond_to do |format|
      if @post.save
        format.html { redirect_to @group, notice: '投稿が作成されました' }
        format.turbo_stream { flash.now[:notice] = '投稿が作成されました' }
      else
        format.html { redirect_to @group, alert: @post.errors.full_messages.to_sentence }
        format.turbo_stream { flash.now[:alert] = @post.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy!
    respond_to do |format|
      format.html { redirect_to group_path(params[:group_id]), notice: '投稿が削除されました' }
      format.turbo_stream { flash.now[:notice] = '投稿が削除されました' }
    end
  end
end
