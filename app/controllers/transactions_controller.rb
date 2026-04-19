class TransactionsController < ApplicationController
  require "csv"

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
