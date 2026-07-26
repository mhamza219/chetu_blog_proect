class JobApplicationDetailsController < ApplicationController
  before_action :set_job_application_detail, only: [:show, :edit, :update, :destroy]

  # GET /job_application_details
  def index
    @job_application_details = JobApplicationDetail.order(created_at: :desc)
    if params[:search].present?
      term = "%#{params[:search].downcase}%"
      @job_application_details = @job_application_details.where(
        "LOWER(name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(mobile_number) LIKE ? OR LOWER(skills) LIKE ?",
        term, term, term, term
      )
    end
  end

  # GET /job_application_details/1
  def show
  end

  # GET /job_application_details/new
  def new
    @job_application_detail = JobApplicationDetail.new
  end

  # POST /job_application_details/parse_document
  def parse_document
    uploaded_file = params[:document]
    
    if uploaded_file.blank?
      render json: { success: false, error: "Please select a document file to upload." }, status: :unprocessable_entity
      return
    end

    # Save file temporarily in tmp directory
    temp_dir = Rails.root.join("tmp", "uploads")
    FileUtils.mkdir_p(temp_dir)
    temp_path = temp_dir.join("#{Time.now.to_i}_#{uploaded_file.original_filename}")
    
    File.open(temp_path, "wb") do |file|
      file.write(uploaded_file.read)
    end

    # Call Python script parser
    parsed_data = JobApplicationDetail.parse_document_file(temp_path)

    # Clean up temp file
    File.delete(temp_path) if File.exist?(temp_path)

    if parsed_data.is_a?(Hash) && parsed_data["error"].blank?
      render json: {
        success: true,
        filename: uploaded_file.original_filename,
        data: parsed_data
      }
    else
      render json: {
        success: false,
        error: parsed_data["error"] || "Failed to extract content from document."
      }, status: :unprocessable_entity
    end
  end

  # POST /job_application_details
  def create
    @job_application_detail = JobApplicationDetail.new(job_application_detail_params)
    
    # Process experience_details json param if provided as string or formatted array
    if params[:job_application_detail][:experience_details_json].present?
      begin
        @job_application_detail.experience_details = JSON.parse(params[:job_application_detail][:experience_details_json])
      rescue JSON::ParserError
        # ignore or keep existing
      end
    end

    if params[:job_application_detail][:resume_file].present?
      @job_application_detail.resume_file_name = params[:job_application_detail][:resume_file].original_filename
    end

    if @job_application_detail.save
      redirect_to @job_application_detail, notice: "Job Application Details were successfully saved!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /job_application_details/1/edit
  def edit
  end

  # PATCH/PUT /job_application_details/1
  def update
    if params[:job_application_detail][:experience_details_json].present?
      begin
        params[:job_application_detail][:experience_details] = JSON.parse(params[:job_application_detail][:experience_details_json])
      rescue JSON::ParserError
      end
    end

    if @job_application_detail.update(job_application_detail_params)
      redirect_to @job_application_detail, notice: "Job Application Details were successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /job_application_details/1
  def destroy
    @job_application_detail.destroy
    redirect_to job_application_details_path, notice: "Job Application record was successfully deleted."
  end

  private

  def set_job_application_detail
    @job_application_detail = JobApplicationDetail.find(params[:id])
  end

  def job_application_detail_params
    params.require(:job_application_detail).permit(
      :name, :email, :mobile_number, :skills, :education, :summary,
      :resume_file_name, :status, :resume_file, experience_details: []
    )
  end
end
