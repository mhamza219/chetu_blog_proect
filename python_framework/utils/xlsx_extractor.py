import zipfile
import xml.etree.ElementTree as ET
import sys

def extract_xlsx_text(file_path):
    lines = []
    try:
        with zipfile.ZipFile(file_path, 'r') as z:
            shared_strings = []
            if 'xl/sharedStrings.xml' in z.namelist():
                ss_tree = ET.fromstring(z.read('xl/sharedStrings.xml'))
                for si in ss_tree.iter():
                    if si.tag.endswith('t') and si.text:
                        shared_strings.append(si.text)
            
            sheets = [f for f in z.namelist() if f.startswith('xl/worksheets/sheet')]
            for sheet_file in sheets:
                sheet_tree = ET.fromstring(z.read(sheet_file))
                for row in sheet_tree.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'):
                    row_vals = []
                    for c in row.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
                        val_type = c.attrib.get('t')
                        val_elem = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                        if val_elem is not None and val_elem.text:
                            v = val_elem.text
                            if val_type == 's' and int(v) < len(shared_strings):
                                row_vals.append(shared_strings[int(v)])
                            else:
                                row_vals.append(v)
                    if row_vals:
                        lines.append(" | ".join(row_vals))
    except Exception as e:
        print(f"Error reading xlsx: {e}", file=sys.stderr)
    return "\n".join(lines)
