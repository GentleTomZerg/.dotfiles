import unittest
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
from splitter import parse_size, split_file


class TestSplitter(unittest.TestCase):
    def test_parse_size_mb(self):
        """Should parse size with MB suffix."""
        self.assertEqual(parse_size("10m"), 10 * 1024 * 1024)
        self.assertEqual(parse_size("10M"), 10 * 1024 * 1024)
        self.assertEqual(parse_size("10MB"), 10 * 1024 * 1024)

    def test_parse_size_gb(self):
        """Should parse size with GB suffix."""
        self.assertEqual(parse_size("1g"), 1 * 1024 * 1024 * 1024)
        self.assertEqual(parse_size("2GB"), 2 * 1024 * 1024 * 1024)

    def test_parse_size_kb(self):
        """Should parse size with KB suffix."""
        self.assertEqual(parse_size("500k"), 500 * 1024)
        self.assertEqual(parse_size("1KB"), 1 * 1024)

    def test_parse_size_bytes(self):
        """Should parse plain number as bytes."""
        self.assertEqual(parse_size("1024"), 1024)

    @patch("subprocess.run")
    def test_split_file_calls_7z(self, mock_run):
        """Should call 7z with correct arguments."""
        mock_run.return_value = MagicMock(returncode=0)

        chunks = split_file(Path("/tmp/big.zip"), "10m", Path("/tmp"))

        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn("7z", args[0])
        self.assertIn("a", args)
        self.assertIn("-v10m", args)
        self.assertIn("big.zip.7z", args[-2])

    @patch("subprocess.run")
    def test_split_file_returns_chunk_paths(self, mock_run):
        """Should return paths to created chunk files."""
        mock_run.return_value = MagicMock(returncode=0)

        with patch.object(Path, "exists", return_value=True):
            chunks = split_file(Path("/tmp/large.bin"), "5m", Path("/tmp"))

        self.assertTrue(len(chunks) > 0)
        for chunk in chunks:
            self.assertRegex(str(chunk), r"\.7z\.\d{3}$")


if __name__ == "__main__":
    unittest.main()
