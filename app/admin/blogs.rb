ActiveAdmin.register Blog do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :description, :views, :user_id, :status
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :description, :views, :user_id, :status]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :title, :description, :status, :user_id, :video, images: []

  filter :title
  filter :status
  filter :user
  filter :created_at
  filter :views

  index do
    selectable_column
    id_column
    column :title
    column :status
    column :user
    column :views

    column "Images" do |blog|
      if blog.images.attached?
        image_tag blog.images.first.variant(resize_to_limit: [80, 80])
      end
    end

    column "Video" do |blog|
      blog.video.attached? ? "Attached" : "—"
    end

    actions
  end
end
