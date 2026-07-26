class JobApplicationDetail < ApplicationRecord
  has_one_attached :resume_file

  # Serialize experience_details string column to/from JSON array/hash in Rails
  serialize :experience_details, coder: JSON

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Delegate document processing to the Python Framework
  def self.parse_document_file(file_path)
    res = PythonFrameworkService.call("resume_parser", { file_path: file_path })
    if res["success"]
      res["data"]
    else
      { "error" => res["error"] || "Failed to parse document" }
    end
  end
end
