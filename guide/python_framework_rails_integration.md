# Python Framework & Ruby on Rails Integration Guide

## Overview

This guide explains how the **Python Framework** is embedded within the **Ruby on Rails** application to handle document parsing, candidate information extraction, and future Python-based services.

The design allows developers to write Python code for processing tasks while running a **single server command (`rails s`)**. Rails delegates tasks on-demand to the Python framework via the `PythonFrameworkService` wrapper.

---

## System Architecture

```
                       ┌──────────────────────────────────────────────┐
                       │          Ruby on Rails Application           │
                       └──────────────────────┬───────────────────────┘
                                              │
                    ┌─────────────────────────┴────────────────────────┐
                    │ JobApplicationDetailsController                  │
                    └─────────────────────────┬────────────────────────┘
                                              │
                    ┌─────────────────────────┴────────────────────────┐
                    │ JobApplicationDetail Model                       │
                    │ (serialize :experience_details, coder: JSON)    │
                    └─────────────────────────┬────────────────────────┘
                                              │
                    ┌─────────────────────────┴────────────────────────┐
                    │ app/services/python_framework_service.rb        │
                    └─────────────────────────┬────────────────────────┘
                                              │ (CLI Subprocess Call)
                                              ▼
                    ┌──────────────────────────────────────────────────┐
                    │           python_framework/main.py               │
                    └─────────────────────────┬────────────────────────┘
                                              │
                 ┌────────────────────────────┼────────────────────────────┐
                 ▼                            ▼                            ▼
   ┌───────────────────────────┐┌───────────────────────────┐┌───────────────────────────┐
   │  ResumeParserService      ││   TextSummarizerService   ││   Future Python Services  │
   └─────────────┬─────────────┘└───────────────────────────┘└───────────────────────────┘
                 │
                 ▼
   ┌───────────────────────────┐
   │ utils/ (pdf, docx, xlsx)  │
   └───────────────────────────┘
```

---

## Directory Structure

```
chetu_blog_proect/
├── app/
│   ├── controllers/
│   │   └── job_application_details_controller.rb   # Rails Controller
│   ├── models/
│   │   └── job_application_detail.rb               # Model with JSON serialization
│   └── services/
│       └── python_framework_service.rb             # Rails-to-Python Bridge
├── python_framework/                               # Embedded Python Framework
│   ├── __init__.py
│   ├── main.py                                     # Main Entrypoint & Service Registry
│   ├── config.py                                   # Framework Config & Temp Dir
│   ├── base_service.py                             # Abstract Base Class for Python Services
│   ├── services/                                   # Registered Python Services
│   │   ├── __init__.py
│   │   ├── resume_parser_service.py                # Resume & Document Parser
│   │   └── text_summarizer_service.py              # Text Summarizer Example
│   └── utils/                                      # Extraction Utilities
│       ├── __init__.py
│       ├── docx_extractor.py                       # Word DOCX Extractor
│       ├── xlsx_extractor.py                       # Excel XLSX Extractor
│       ├── pdf_extractor.py                        # PDF Stream Extractor
│       └── pattern_matcher.py                      # Regex Pattern Matchers
└── guide/
    └── python_framework_rails_integration.md       # This Integration Guide
```

---

## Database Schema & Data Migrations

The `job_application_details` table stores applicant details extracted from documents.

### 1. Database Table Columns (`db/schema.rb`)
- `name`: string
- `email`: string
- `mobile_number`: string
- `experience_details`: string (default `"[]"`)
- `skills`: text
- `education`: string
- `summary`: text
- `resume_file_name`: string
- `status`: string (default `"draft"`)

### 2. Active Record Model (`app/models/job_application_detail.rb`)
```ruby
class JobApplicationDetail < ApplicationRecord
  has_one_attached :resume_file

  # Automatically serializes/deserializes Array/Hash into JSON string in DB
  serialize :experience_details, coder: JSON

  validates :name, presence: true
end
```

### 3. Data Migrations (`db/data/`)
Using `data_migrate` gem to safely update existing database records when field formats change:

- **Data Migration File**: `db/data/20260726143000_migrate_job_application_details_experience_json.rb`
- **Run Command**:
  ```bash
  rails data:migrate
  ```
- Normalizes existing `experience_details` text records into valid JSON string arrays (`"[]"`) and updates default statuses.


---

## How to Call Python Framework from Rails

You can invoke any registered Python service from anywhere in Rails (Controller, Model, Background Job, or Console):

```ruby
# 1. Parse a Document/Resume File
result = PythonFrameworkService.call("resume_parser", { file_path: "/path/to/resume.pdf" })

if result["success"]
  candidate_data = result["data"]
  puts candidate_data["name"]
  puts candidate_data["experience_details"] # Returns Array of Hashes
end

# 2. Summarize Text
summary_result = PythonFrameworkService.call("text_summarizer", { text: "Long text sample...", max_length: 50 })
```

---

## How to Add New Python Functionality

To create a new Python feature and expose it to Rails:

### Step 1: Create a Service Class in `python_framework/services/`
Create `python_framework/services/document_sentiment_service.py`:

```python
from python_framework.base_service import BaseService

class DocumentSentimentService(BaseService):
    """
    Analyzes sentiment of document text.
    """
    def run(self):
        text = self.payload.get('text', '')
        
        # Add your custom Python processing logic here
        sentiment = "positive" if "great" in text.lower() else "neutral"

        return {
            "success": True,
            "sentiment": sentiment,
            "character_count": len(text)
        }
```

### Step 2: Register Service in `python_framework/main.py`
Open `python_framework/main.py` and import & register your new service class:

```python
from python_framework.services.document_sentiment_service import DocumentSentimentService

SERVICE_REGISTRY = {
    "resume_parser": ResumeParserService,
    "text_summarizer": TextSummarizerService,
    "sentiment_analyzer": DocumentSentimentService, # Added!
}
```

### Step 3: Call from Rails
Invoke the new service from any Rails controller or service:

```ruby
result = PythonFrameworkService.call("sentiment_analyzer", { text: "This candidate has great experience!" })
# => {"success" => true, "sentiment" => "positive", "character_count" => 39}
```

---

## Running the Application

No separate Python web server process is required. Simply run:

```bash
rails s
```

When a document is uploaded, Rails triggers `PythonFrameworkService`, which runs `python3 python_framework/main.py <service_name> '<json_payload>'` on-demand, processes the file, and returns the response back to Rails.

---

## PaperTrail Audit & Version Control

The system uses `paper_trail` gem to track all changes made to candidate application records.

### Model Configuration (`app/models/job_application_detail.rb`)
```ruby
class JobApplicationDetail < ApplicationRecord
  has_paper_trail

  has_one_attached :resume_file
  serialize :experience_details, coder: JSON
end
```

### Accessing Version History
```ruby
candidate = JobApplicationDetail.find(1)

# List all versions
candidate.versions

# Restore previous state before update
previous_state = candidate.paper_trail.previous_version
```

