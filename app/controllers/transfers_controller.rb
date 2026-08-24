class TransfersController < ApplicationController
  def create
    result = TransferService.call(
      sender_id: transfer_params[:sender_id],
      recipient_id: transfer_params[:recipient_id],
      amount: transfer_params[:amount]
    )

    sender_id = transfer_params[:sender_id]

    if result.success?
      flash[:notice] = "Sent #{result.transfer.amount} treats."
      redirect_to cat_path(sender_id)
    else
      flash[:alert] = result.message
      redirect_to cat_path(sender_id)
    end
  end

  private

  def transfer_params
    params.require(:transfer).permit(:sender_id, :recipient_id, :amount)
  end
end
