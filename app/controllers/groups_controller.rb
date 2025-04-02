# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[edit update destroy]
  skip_before_action :authenticate, only: %i[index show]

  def index
    @groups_grouped_by_hashtag = Group.order(:hashtag, :created_at).group_by(&:hashtag)
  end

  def show
    @group = Group.find(params[:id])
    @ticket = current_user&.tickets&.find_by(group: @group)
    @tickets = @group.tickets.includes(:user).order(:created_at)
    @posts = @group.posts.includes(:user).order(:created_at)
  end

  def new
    @group = current_user.groups.new(
      details: '誰でも参加OK！',
      capacity: 10,
      location: '未定',
      payment_method: '割り勘'
    )
  end

  def edit; end

  def create
    @group = current_user.groups.new(group_params)

    if @group.save
      redirect_to group_url(@group), notice: '2次会グループが作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      redirect_to group_url(@group), notice: '2次会グループが更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy!

    redirect_to groups_url, notice: '2次会グループが削除されました。'
  end

  private

  def set_group
    @group = current_user.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:hashtag, :name, :details, :capacity, :location, :payment_method)
  end
end
