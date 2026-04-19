class PocketsController < ApplicationController
  before_action :set_pocket, only: [:edit, :update, :destroy]

  def index
    @pockets = Pocket.ordered
    @pocket = Pocket.new(color: "slate")
  end

  def create
    @pocket = Pocket.new(pocket_params)

    if @pocket.save
      redirect_to pockets_path, notice: "Pocket '#{@pocket.name}' creado."
    else
      @pockets = Pocket.ordered
      render :index, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @pocket.update(pocket_params)
      redirect_to pockets_path, notice: "Pocket actualizado."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @pocket.transactions.processed.exists?
      redirect_to pockets_path, alert: "No se puede eliminar '#{@pocket.name}' porque tiene transacciones procesadas asociadas."
    else
      @pocket.destroy
      redirect_to pockets_path, notice: "Pocket eliminado."
    end
  end

  private

  def set_pocket
    @pocket = Pocket.find(params[:id])
  end

  def pocket_params
    params.expect(pocket: [:name, :color, :position])
  end
end
