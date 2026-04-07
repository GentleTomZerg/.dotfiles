import unittest
from datetime import date
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from templates import render_template


class TestTemplates(unittest.TestCase):
    def test_renders_filename(self):
        """Template should render {filename} placeholder."""
        result = render_template(
            "File: {filename}",
            {"filename": "report.pdf", "size": "1MB", "date": date.today()},
        )
        self.assertEqual(result, "File: report.pdf")

    def test_renders_all_placeholders(self):
        """Template should render all common placeholders."""
        result = render_template(
            "{filename} sent on {date}, size {size}",
            {"filename": "archive.zip", "size": "50MB", "date": date(2025, 1, 15)},
        )
        self.assertEqual(result, "archive.zip sent on 2025-01-15, size 50MB")

    def test_missing_placeholder_not_replaced(self):
        """Unknown placeholders should be left as-is."""
        result = render_template(
            "Subject: {filename} {unknown}", {"filename": "test.txt"}
        )
        self.assertEqual(result, "Subject: test.txt {unknown}")


if __name__ == "__main__":
    unittest.main()
