class CatsController < ApplicationController
  def index
    @cats = Cat.order(:name)
  end

  def show
    @cat = Cat.find(params[:id])
    @cats = Cat.where.not(id: @cat.id).order(:name)
    @sent_transfers = @cat.sent_transfers.includes(:recipient).order(created_at: :desc)
    @received_transfers = @cat.received_transfers.includes(:sender).order(created_at: :desc)
  end
end
