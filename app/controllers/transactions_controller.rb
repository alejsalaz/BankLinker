class TransactionsController < ApplicationController
  require "csv"

  before_action :load_pockets, only: [:index, :categorize]

  def index
    @transaction = Transaction.next_pending
    @pending_transactions = Transaction.pending.order(:date, :id)
    @remaining = @pending_transactions.size
  end

  def categorize
    @categorized_transaction = Transaction.find(params[:id])
    pocket = Pocket.find_by(id: params[:pocket_id])

    if pocket.nil?
      redirect_to transactions_path, alert: "Pocket inválido."
      return
    end

    @categorized_transaction.update!(pocket: pocket, status: :processed)

    @next_transaction = Transaction.next_pending
    @remaining = Transaction.pending.count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to transactions_path }
    end
  end

  def clear_pending
    removed = Transaction.pending.delete_all
    redirect_to transactions_path, notice: "Cola limpiada: #{removed} transacciones eliminadas."
  end

  def export
    csv_data = build_csv
    filename = "banklinker_ivy_#{Date.current.strftime('%Y%m%d')}.csv"
    send_data csv_data, filename: filename, type: "text/csv"
  end

  private

  def load_pockets
    @pockets = Pocket.ordered
  end

  def build_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[date amount title account_name currency_code type]
      Transaction.processed.includes(:pocket).order(:date, :id).find_each do |t|
        csv << [
          t.date.iso8601,
          t.amount.to_s,
          t.description,
          t.pocket&.name,
          "COP",
          "EXPENSE"
        ]
      end
    end
  end
end
