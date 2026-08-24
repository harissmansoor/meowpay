class CatsController < ApplicationController
  def index
    @cats = Cat.order(:name)
  end

  def show
    @cat = Cat.find(params[:id])
    @cats = Cat.where.not(id: @cat.id).order(:name)
    @recent_transfers = Transfer
      .where(sender_id: @cat.id)
      .or(Transfer.where(recipient_id: @cat.id))
      .includes(:sender, :recipient)
      .order(created_at: :desc)
  end
end
