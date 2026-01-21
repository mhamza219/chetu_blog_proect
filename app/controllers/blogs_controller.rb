class BlogsController < ApplicationController

  # include Common
  # helper_method :demo_method

  before_action :set_blog, except: [:index, :new, :create]
  before_action :authenticate_user!

  def index
    # byebug
    if user_signed_in?
      @blogs = Blog.where(user_id: current_user.id).or(Blog.where.not(user_id: current_user.id).published)
    else
      @blogs = Blog.all
    # render json: {data: @blogs} 
    end
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
    @blog = current_user.blogs.new(blog_params)
    if @blog.save
      redirect_to blogs_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @blog.update(blog_params)
      redirect_to "/blogs"
    else
      render 'new'
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path
  end

  def update_blog_status
    # byebug
    @blog = Blog.find(params[:id])
    if @blog.draft?
      @blog.published! if current_user.id == @blog.user_id
    else
      @blog.draft! if current_user.id == @blog.user_id
    end
    redirect_to '/blogs'
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :description, :status, :video, images: [])
  end

end
