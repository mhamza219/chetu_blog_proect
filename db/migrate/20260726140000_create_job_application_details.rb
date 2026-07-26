class CreateJobApplicationDetails < ActiveRecord::Migration[7.2]
  def change
    create_table :job_application_details do |t|
      t.string :name
      t.string :email
      t.string :mobile_number
      t.jsonb :experience_details, default: []
      t.text :skills
      t.text :education
      t.text :summary
      t.string :resume_file_name
      t.string :status, default: "draft"

      t.timestamps
    end
  end
end
