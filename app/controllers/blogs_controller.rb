class BlogsController < ApplicationController

  before_action :blog_params, except: [:index, :new]

  def index
    @blogs = Blog.all
  end

  def new
    @blog = Blog.new
  end

  def show
  end

  def create

    @blog = Blog.create(title: params["blog"]["title"] , description: params["blog"]["description"])
  end

  def edit
  end

  def update

    @blog.update!(title: params["blog"]["title"] , description: params["blog"]["description"])
  end

  def delete
  end

  private

  def blog_params
    @blog = Blog.find(params[:id])
  end

end
