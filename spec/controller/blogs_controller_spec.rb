require 'rails_helper'

RSpec.describe BlogsController, type: :controller do
  # let(:user) { FactoryBot.create(:user) }
  # let(:blog) { FactoryBot.create(:blog, user: user) }

  before(:each) do
     @user = FactoryBot.create(:user)
     @blog = FactoryBot.create(:blog, user: @user)
    sign_in @user
  end

  # let(:params) { { user: @current_user, blog: @blogs } }




  describe "GET #index" do
    it "shows all blogs" do
      # This is the magic line enabled by the helper above
      # sign_in user 

      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #CREATE" do
    # let(:blog_params) { { title: "my first trst blog" } }

    it "redirect_to blogs_path after blog create" do
      post :create, params: {"blog" => {title: "my first blog_test"} }
      # post :create, params: { data: { attributes: { title: "my first blog_test", user_id: @user.id } } }
      # expect(response).to have_http_status(:created)
      expect(response).to redirect_to(blogs_path)
    end

    it "render blogs_path if blog not created" do
      post :create, params: {"blog" => {title: ""} }
      # post :create, params: { data: { attributes: { title: "my first blog_test", user_id: @user.id } } }
      # expect(response).to have_http_status(:created)
      # expect(response).to render_template(:new)
      # expect(response.body).to include("error")
      expect(response).to have_http_status(:ok)
    end

  end

  describe "DELETE #DESTROY" do
    # let(:blog_params) { { title: "my first trst blog" } }

    it "delete blog" do
      delete :destroy, params: {"id" => @blog.id }
      # post :create, params: { data: { attributes: { title: "my first blog_test", user_id: @user.id } } }
      # expect(response).to have_http_status(:created)
      expect(response).to redirect_to(blogs_path)
    end

  end

end
