import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(BASE_DIR)
TEMP_DIR = os.path.join(PROJECT_ROOT, "tmp", "python_framework")

os.makedirs(TEMP_DIR, exist_ok=True)
