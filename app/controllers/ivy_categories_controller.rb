class IvyCategoriesController < ApplicationController
  before_action :set_ivy_category, only: [:edit, :update, :destroy]

  def index
    @ivy_categories = IvyCategory.ordered
    @ivy_category = IvyCategory.new
  end

  def create
    @ivy_category = IvyCategory.new(ivy_category_params)

    if @ivy_category.save
      redirect_to ivy_categories_path, notice: "Categoría '#{@ivy_category.name}' creada."
    else
      @ivy_categories = IvyCategory.ordered
      render :index, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @ivy_category.update(ivy_category_params)
      redirect_to ivy_categories_path, notice: "Categoría actualizada."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @ivy_category.destroy
    redirect_to ivy_categories_path, notice: "Categoría eliminada."
  end

  private

  def set_ivy_category
    @ivy_category = IvyCategory.find(params[:id])
  end

  def ivy_category_params
    params.expect(ivy_category: [:name, :position])
  end
end
