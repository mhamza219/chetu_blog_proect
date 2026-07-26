# frozen_string_literal: true

class MigrateJobApplicationDetailsExperienceJson < ActiveRecord::Migration[7.2]
  def up
    JobApplicationDetail.find_each do |record|
      # Format experience_details to valid JSON array string if blank or invalid
      if record.experience_details.blank?
        record.update_columns(experience_details: "[]")
      elsif record.experience_details.is_a?(String)
        begin
          JSON.parse(record.experience_details)
        rescue JSON::ParserError
          # Convert legacy plain text into structured JSON array
          formatted_json = [{ company_name: "Previous Company", designation: record.experience_details }].to_json
          record.update_columns(experience_details: formatted_json)
        end
      end

      # Set default status if missing
      if record.status.blank?
        record.update_columns(status: "parsed")
      end
    end
  end

  def down
    # Irreversible or noop fallback
  end
end
