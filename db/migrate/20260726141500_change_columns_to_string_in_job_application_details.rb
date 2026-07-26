class ChangeColumnsToStringInJobApplicationDetails < ActiveRecord::Migration[7.2]
  def change
    change_column :job_application_details, :experience_details, :string, using: 'experience_details::text', default: "[]"
    change_column :job_application_details, :education, :string
  end
end
