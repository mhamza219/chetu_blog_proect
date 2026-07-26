import zipfile
import xml.etree.ElementTree as ET
import sys

def extract_docx_text(file_path):
    text_content = []
    try:
        with zipfile.ZipFile(file_path, 'r') as z:
            if 'word/document.xml' in z.namelist():
                xml_content = z.read('word/document.xml')
                tree = ET.fromstring(xml_content)
                for p in tree.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
                    texts = [node.text for node in p.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t') if node.text]
                    if texts:
                        text_content.append("".join(texts))
    except Exception as e:
        print(f"Error reading docx: {e}", file=sys.stderr)
    return "\n".join(text_content)
