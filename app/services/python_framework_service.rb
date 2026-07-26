require "shellwords"

class PythonFrameworkService
  # Generic runner to execute any service inside python_framework
  def self.call(service_name, payload = {})
    main_script = Rails.root.join("python_framework", "main.py").to_s
    json_payload = payload.to_json
    
    cmd = "python3 #{Shellwords.escape(main_script)} #{Shellwords.escape(service_name.to_s)} #{Shellwords.escape(json_payload)}"
    
    output = `#{cmd}`
    begin
      JSON.parse(output)
    rescue StandardError => e
      { "success" => false, "error" => "Failed to parse Python response: #{e.message}" }
    end
  end
end
