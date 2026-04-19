class EnvelopesController < ApplicationController
  before_action :set_envelope, only: [:edit, :update, :destroy]

  def index
    @envelopes = Envelope.ordered
    @envelope = Envelope.new(color: "slate")
  end

  def create
    @envelope = Envelope.new(envelope_params)

    if @envelope.save
      redirect_to envelopes_path, notice: "Sobre '#{@envelope.name}' creado."
    else
      @envelopes = Envelope.ordered
      render :index, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @envelope.update(envelope_params)
      redirect_to envelopes_path, notice: "Sobre actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @envelope.transactions.processed.exists?
      redirect_to envelopes_path, alert: "No se puede eliminar '#{@envelope.name}' porque tiene transacciones procesadas asociadas."
    else
      @envelope.destroy
      redirect_to envelopes_path, notice: "Sobre eliminado."
    end
  end

  private

  def set_envelope
    @envelope = Envelope.find(params[:id])
  end

  def envelope_params
    params.expect(envelope: [:name, :color, :position])
  end
end
