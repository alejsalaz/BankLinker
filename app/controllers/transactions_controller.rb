class TransactionsController < ApplicationController
  require "csv"

  before_action :load_envelopes, only: [:index, :categorize]

  def index
    @transaction = Transaction.next_pending
    @pending_transactions = Transaction.pending.order(:date, :id)
    @remaining = @pending_transactions.size
  end

  def categorize
    @categorized_transaction = Transaction.find(params[:id])
    envelope = Envelope.find_by(id: params[:envelope_id])

    if envelope.nil?
      redirect_to transactions_path, alert: "Sobre inválido."
      return
    end

    @categorized_transaction.assign_attributes(categorize_params)
    @categorized_transaction.envelope = envelope
    @categorized_transaction.status = :processed
    @categorized_transaction.save!

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

  def preview
    @staging_transactions = Transaction.staging.order(:date, :id)

    if @staging_transactions.empty?
      redirect_to root_path, alert: "No hay movimientos en preview. Sube un extracto primero."
      return
    end

    @date_from = @staging_transactions.minimum(:date)
    @date_to = @staging_transactions.maximum(:date)
  end

  def confirm_preview
    keep_ids = Array(params[:keep_ids]).map(&:to_i)
    staging = Transaction.staging

    discarded = staging.where.not(id: keep_ids).delete_all
    kept = staging.where(id: keep_ids).update_all(status: Transaction.statuses[:pending], updated_at: Time.current)

    if kept.zero?
      redirect_to root_path, alert: "Descartaste todos los movimientos. No se importó nada."
    else
      redirect_to transactions_path, notice: "Importadas #{kept} transacciones. #{discarded} descartadas."
    end
  end

  def discard_preview
    removed = Transaction.staging.delete_all
    redirect_to root_path, notice: "Preview descartado (#{removed} movimientos)."
  end

  def export
    csv_data = build_csv
    filename = "banklinker_ivy_#{Date.current.strftime('%Y%m%d')}.csv"
    send_data csv_data, filename: filename, type: "text/csv"
  end

  private

  def load_envelopes
    @envelopes = Envelope.ordered
  end

  def categorize_params
    permitted = params.permit(:title, :description, :category_id)
    permitted[:title] = permitted[:title].presence
    permitted[:category_id] = permitted[:category_id].presence
    permitted
  end

  # CSV orientado a apps de presupuesto: columnas en español y fecha en
  # dd/MM/yyyy. El mismo formato hay que elegirlo en el wizard de importación
  # de la app destino.
  CSV_TYPE_LABELS = {
    "expense" => "Expense",
    "income" => "Income",
    "transfer" => "Transfer"
  }.freeze

  def build_csv
    CSV.generate(headers: true) do |csv|
      csv << [
        "Fecha",
        "Tipo de transacción",
        "Cantidad",
        "Moneda",
        "Cuenta",
        "Categoría",
        "Título",
        "Descripción",
        "Receptor",
        "Moneda de cambio",
        "Cantidad de cambio"
      ]

      Transaction.processed.includes(:envelope, :category).order(:date, :id).find_each do |t|
        csv << [
          t.date.strftime("%d/%m/%Y"),
          CSV_TYPE_LABELS[t.transaction_type],
          t.csv_amount.to_s("F"),
          t.currency,
          t.envelope&.name,
          t.category&.name,
          t.csv_title,
          t.description,
          t.receiver,
          t.exchange_currency,
          t.exchange_amount&.to_s("F")
        ]
      end
    end
  end
end
