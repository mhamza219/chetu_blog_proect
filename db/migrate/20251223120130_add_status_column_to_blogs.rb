class AddStatusColumnToBlogs < ActiveRecord::Migration[7.2]
  def change
    add_column :blogs, :status, :integer, default: 0
  end
end
