class DashboardsController < ApplicationController
  def show
    @pending_count = Transaction.pending.count
    @processed_count = Transaction.processed.count
    @pockets = Pocket.ordered
    @pockets_count = @pockets.size
    @extractor_types = Extractors::Dispatcher.available_types
  end

  def upload
    uploaded = params[:file]
    extractor_type = params[:extractor_type].presence || Extractors::Dispatcher::DEFAULT
    password = params[:password]

    if uploaded.blank?
      redirect_to root_path, alert: "Debes adjuntar un archivo."
      return
    end

    tempfile_path = persist_temporarily(uploaded)

    begin
      rows = Extractors::Dispatcher.for(tempfile_path, type: extractor_type, password: password).call

      if rows.empty?
        redirect_to root_path, alert: "No se detectaron transacciones en el archivo."
        return
      end

      persist_rows(rows)
      redirect_to transactions_path, notice: "Se importaron #{rows.size} transacciones."
    rescue => e
      Rails.logger.error("[BankLinker] Error procesando extracto: #{e.class} - #{e.message}")
      redirect_to root_path, alert: "No se pudo procesar el archivo: #{e.message}"
    ensure
      File.delete(tempfile_path) if tempfile_path && File.exist?(tempfile_path)
    end
  end

  private

  def persist_temporarily(uploaded)
    extension = File.extname(uploaded.original_filename.to_s)
    tempfile = Tempfile.new(["banklinker_upload", extension])
    tempfile.binmode
    IO.copy_stream(uploaded.tempfile, tempfile)
    tempfile.close
    tempfile.path
  end

  def persist_rows(rows)
    now = Time.current
    records = rows.map do |row|
      {
        date: row[:date],
        description: row[:description],
        amount: row[:amount],
        status: Transaction.statuses[:pending],
        created_at: now,
        updated_at: now
      }
    end

    Transaction.insert_all(records)
  end
end
