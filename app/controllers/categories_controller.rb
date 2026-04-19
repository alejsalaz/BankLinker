class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.ordered
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: "Categoría '#{@category.name}' creada."
    else
      @categories = Category.ordered
      render :index, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Categoría actualizada."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "Categoría eliminada."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.expect(category: [:name, :position])
  end
end
