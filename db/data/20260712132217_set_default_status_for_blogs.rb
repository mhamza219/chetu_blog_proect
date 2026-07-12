# frozen_string_literal: true

class SetDefaultStatusForBlogs < ActiveRecord::Migration[7.2]
  def up
    Blog.where(status: nil).find_each do |blog|
      blog.update_columns(status: 0)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
