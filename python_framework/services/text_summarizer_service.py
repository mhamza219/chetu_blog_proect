from python_framework.base_service import BaseService

class TextSummarizerService(BaseService):
    """
    Example additional service in Python Framework.
    Summarizes text input or document content.
    """

    def run(self):
        text = self.payload.get('text', '')
        max_length = self.payload.get('max_length', 150)
        
        words = text.split()
        summary = " ".join(words[:max_length]) + ("..." if len(words) > max_length else "")

        return {
            "success": True,
            "summary": summary,
            "word_count": len(words)
        }
