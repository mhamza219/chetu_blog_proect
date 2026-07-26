import re
import zlib
import sys

def extract_pdf_text(file_path):
    text_content = []
    try:
        with open(file_path, 'rb') as f:
            content = f.read()
        
        stream_pattern = re.compile(rb'stream[\r\n]+(.*?)[\r\n]+endstream', re.DOTALL)
        for match in stream_pattern.finditer(content):
            stream_data = match.group(1)
            decompressed = None
            try:
                decompressed = zlib.decompress(stream_data)
            except Exception:
                try:
                    decompressed = zlib.decompress(stream_data, -zlib.MAX_WBITS)
                except Exception:
                    decompressed = stream_data
            
            if decompressed:
                text_brackets = re.findall(rb'\((.*?)\)', decompressed)
                for tb in text_brackets:
                    try:
                        decoded = tb.decode('utf-8', errors='ignore')
                        if len(decoded.strip()) > 0:
                            text_content.append(decoded)
                    except Exception:
                        pass
        
        if len("".join(text_content).strip()) < 50:
            raw_text = content.decode('utf-8', errors='ignore')
            ascii_words = re.findall(r'[A-Za-z0-9@+.,\s-]{3,}', raw_text)
            text_content = ascii_words
    except Exception as e:
        print(f"Error reading pdf: {e}", file=sys.stderr)
    
    return "\n".join(text_content)
