import os
import re
from python_framework.base_service import BaseService
from python_framework.utils.pdf_extractor import extract_pdf_text
from python_framework.utils.docx_extractor import extract_docx_text
from python_framework.utils.xlsx_extractor import extract_xlsx_text
from python_framework.utils.pattern_matcher import (
    extract_email,
    extract_mobile,
    extract_candidate_name,
    extract_experience_list,
    extract_skills
)

class ResumeParserService(BaseService):
    """
    Resume & Document Parsing Service inside Python Framework.
    Extracts Candidate Name, Mobile, Email, Experience Details (JSON), Skills, Education & Summary.
    """

    def run(self):
        file_path = self.payload.get('file_path')
        if not file_path or not os.path.exists(file_path):
            return {"success": False, "error": f"File path not found: {file_path}"}

        ext = os.path.splitext(file_path)[1].lower()
        if ext == '.docx':
            raw_text = extract_docx_text(file_path)
        elif ext in ['.xlsx', '.xls']:
            raw_text = extract_xlsx_text(file_path)
        elif ext == '.pdf':
            raw_text = extract_pdf_text(file_path)
        else:
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    raw_text = f.read()
            except Exception:
                raw_text = ""

        lines = [line.strip() for line in raw_text.splitlines() if line.strip()]
        full_text = "\n".join(lines)

        name = extract_candidate_name(lines)
        email = extract_email(full_text)
        mobile_number = extract_mobile(full_text)
        experience_details = extract_experience_list(full_text)
        skills = extract_skills(full_text)

        education_match = re.search(r'(?:EDUCATION|ACADEMIC|QUALIFICATION)(.*?)(?:EXPERIENCE|SKILLS|PROJECTS|DECLARATION|$)', full_text, re.DOTALL | re.IGNORECASE)
        education = education_match.group(1).strip() if education_match else "B.Tech Computer Science"

        summary = lines[0] if lines else ""
        if len(lines) > 1 and len(summary) < 50:
            summary += " - " + lines[1]

        return {
            "success": True,
            "data": {
                "name": name,
                "email": email,
                "mobile_number": mobile_number,
                "experience_details": experience_details,
                "skills": skills,
                "education": education[:250],
                "summary": summary[:250]
            }
        }
