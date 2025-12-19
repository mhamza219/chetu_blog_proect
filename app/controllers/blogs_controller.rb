class BlogsController < ApplicationController

  before_action :set_blog, except: [:index, :new, :create]

  def index
    @blogs = Blog.all
  end

  def new
    @blog = Blog.new
  end

  def show
    # byebug
    @blog.views += 1
    @blog.save
  end

  def create
    @blog = Blog.new(blog_params)
    if @blog.save
      redirect_to blogs_path
    else
      render new
    end
  end

  def edit
  end

  def update
    if @blog.update(blog_params)
      redirect_to "/blogs"
    else
      render new
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :description)
  end

end
