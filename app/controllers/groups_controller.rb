# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]

  def index
    @groups = Group.all
  end

  def show; end

  def new
    @group = current_user.groups.new
  end

  def edit; end

  def create
    @group = current_user.groups.new(group_params)

    if @group.save
      redirect_to group_url(@group), notice: '2次会グループが作成されました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      redirect_to group_url(@group), notice: '2次会グループが更新されました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy!

    redirect_to groups_url, notice: '2次会グループが削除されました'
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:hashtag, :name, :details, :capacity, :location, :payment_method)
  end
end
