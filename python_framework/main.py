#!/usr/bin/env python3
"""
Central Entrypoint & Dispatcher for Python Framework.
Invocation from Rails or CLI:
  python3 python_framework/main.py <service_name> '<json_payload>'
"""

import sys
import os
import json

# Ensure python_framework directory is in python path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from python_framework.services.resume_parser_service import ResumeParserService
from python_framework.services.text_summarizer_service import TextSummarizerService

# Central Service Registry: Register any new Python services here
SERVICE_REGISTRY = {
    "resume_parser": ResumeParserService,
    "text_summarizer": TextSummarizerService,
}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "Usage: python3 main.py <service_name> [json_payload_string]",
            "available_services": list(SERVICE_REGISTRY.keys())
        }))
        sys.exit(1)

    service_name = sys.argv[1]
    
    if service_name == "--list":
        print(json.dumps({"services": list(SERVICE_REGISTRY.keys())}))
        sys.exit(0)

    if service_name not in SERVICE_REGISTRY:
        print(json.dumps({
            "error": f"Service '{service_name}' not found.",
            "available_services": list(SERVICE_REGISTRY.keys())
        }))
        sys.exit(1)

    # Parse JSON payload passed from Rails
    payload = {}
    if len(sys.argv) >= 3:
        raw_payload = sys.argv[2]
        try:
            payload = json.loads(raw_payload)
        except Exception as e:
            print(json.dumps({"error": f"Invalid JSON payload: {str(e)}"}))
            sys.exit(1)

    try:
        service_class = SERVICE_REGISTRY[service_name]
        service_instance = service_class(payload)
        result = service_instance.run()
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({"error": f"Service execution failed: {str(e)}"}))
        sys.exit(1)

if __name__ == '__main__':
    main()
