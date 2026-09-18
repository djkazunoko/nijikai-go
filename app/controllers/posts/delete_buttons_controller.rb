# frozen_string_literal: true

module Posts
  class DeleteButtonsController < ApplicationController
    skip_before_action :authenticate

    def show
      @group = Group.find(params[:group_id])
      @post = @group.posts.find(params[:post_id])
    end
  end
end
