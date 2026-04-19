class TransactionsController < ApplicationController
  before_action :load_pockets, only: [:index, :categorize]

  def index
    @transaction = Transaction.next_pending
    @remaining = Transaction.pending.count
  end

  def categorize
    transaction = Transaction.find(params[:id])
    pocket = Pocket.find_by(id: params[:pocket_id])

    if pocket.nil?
      redirect_to transactions_path, alert: "Pocket inválido."
      return
    end

    transaction.update!(pocket: pocket, status: :processed)

    @next_transaction = Transaction.next_pending
    @remaining = Transaction.pending.count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to transactions_path }
    end
  end

  private

  def load_pockets
    @pockets = Pocket.ordered
  end
end
