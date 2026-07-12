# frozen_string_literal: true

class PopulateNameFromEmailForUsers < ActiveRecord::Migration[7.2]
  def up
    User.reset_column_information

    User.where(name: nil).find_each do |user|
      if user.email.present?
        email_prefix = user.email.split('@').first
        user.update_columns(name: email_prefix)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
