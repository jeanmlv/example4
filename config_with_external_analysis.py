from __future__ import annotations

from pathlib import Path

APP_TITLE = "VSquad Data Inventory"
APP_SUBTITLE = "Study availability, processing, ARD coverage, splits, internal analysis and external data traceability"

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
DEFAULT_DATA_FILE = DATA_DIR / "ARGES_COMMONS.xlsx"

SHEETS = {
    "studies": "01_STUDIES",
    "availability": "02_DATA_AVAILABILITY",
    "assets": "03_ASSETS",
    "processing": "04_PROCESSING",
    "splits": "05_DATA_SPLITS",
    "ard": "06_ARD",
    "ard_variables": "07_ARD_VARIABLES",
    "analysis": "08_DATA_ANALYSIS",
    "external_analysis": "09_EXTERNAL_ANALYSIS",
}

# Professional J&J-adjacent neutral palette without relying on corporate branding.
COLORS = {
    "navy": "#17324D",
    "blue": "#2F6B9A",
    "teal": "#2A7F7F",
    "green": "#2E7D5B",
    "amber": "#B7791F",
    "red": "#B54747",
    "gray_900": "#25313C",
    "gray_700": "#4C5A67",
    "gray_500": "#7C8A96",
    "gray_300": "#D8E0E7",
    "gray_100": "#F4F7F9",
    "white": "#FFFFFF",
}

AVAILABILITY_ORDER = ["Available", "Pending", "Missing", "Unknown", "N/A"]
PROCESSING_ORDER = ["Complete", "In Progress", "Pending", "Not Started", "Failed", "Unknown", "N/A"]
