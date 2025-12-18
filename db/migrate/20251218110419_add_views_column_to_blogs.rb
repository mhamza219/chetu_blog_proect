class AddViewsColumnToBlogs < ActiveRecord::Migration[7.2]
  def change
    add_column :blogs, :views, :integer, default: 0
  end
end
