import unittest
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
from splitter import parse_size, split_file, get_7z_command


class TestGet7zCommand(unittest.TestCase):
    @patch("shutil.which")
    def test_finds_7z(self, mock_which):
        """Should return first available 7z command."""
        mock_which.side_effect = lambda x: x in ["7z", "7za"]
        self.assertEqual(get_7z_command(), "7z")

    @patch("shutil.which")
    def test_falls_back_to_7za(self, mock_which):
        """Should return 7za if 7z not found."""
        mock_which.side_effect = lambda x: x == "7za"
        self.assertEqual(get_7z_command(), "7za")

    @patch("shutil.which")
    def test_raises_when_none_found(self, mock_which):
        """Should raise RuntimeError if no 7z available."""
        mock_which.return_value = None
        with self.assertRaises(RuntimeError):
            get_7z_command()


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

    @patch("splitter.get_7z_command")
    @patch("subprocess.run")
    def test_split_file_calls_7z(self, mock_run, mock_get_cmd):
        """Should call 7z with correct arguments."""
        mock_get_cmd.return_value = "7z"
        mock_run.return_value = MagicMock(returncode=0)

        chunks = split_file(Path("/tmp/big.zip"), "10m", Path("/tmp"))

        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn("7z", args[0])
        self.assertIn("a", args)
        self.assertIn("-v10m", args)
        self.assertIn("big.zip.7z", args[-2])

    @patch("splitter.get_7z_command")
    @patch("subprocess.run")
    def test_split_file_returns_chunk_paths(self, mock_run, mock_get_cmd):
        """Should return paths to created chunk files."""
        mock_get_cmd.return_value = "7z"
        mock_run.return_value = MagicMock(returncode=0)

        with patch.object(Path, "exists", return_value=True):
            chunks = split_file(Path("/tmp/large.bin"), "5m", Path("/tmp"))

        self.assertTrue(len(chunks) > 0)
        for chunk in chunks:
            self.assertRegex(str(chunk), r"\.7z\.\d{3}$")

    @patch("splitter.get_7z_command")
    @patch("subprocess.run")
    def test_split_file_raises_on_error(self, mock_run, mock_get_cmd):
        """Should raise RuntimeError on 7z failure."""
        mock_get_cmd.return_value = "7z"
        mock_run.return_value = MagicMock(returncode=1, stderr="Permission denied")

        with self.assertRaises(RuntimeError) as ctx:
            split_file(Path("/tmp/big.zip"), "10m", Path("/tmp"))

        self.assertIn("7z failed", str(ctx.exception))

    @patch("splitter.get_7z_command")
    @patch("subprocess.run")
    def test_split_file_uses_temp_dir_when_provided(self, mock_run, mock_get_cmd):
        """Should write chunks to temp_dir instead of source directory."""
        mock_get_cmd.return_value = "7z"
        mock_run.return_value = MagicMock(returncode=0)

        temp_dir = Path("/tmp/my_temp")
        with patch.object(Path, "exists", return_value=True):
            chunks = split_file(Path("/src/file.zip"), "10m", temp_dir)

        mock_run.assert_called_once()
        args = mock_run.call_args[0][0]
        self.assertIn(str(temp_dir / "file.zip.7z"), args[-2])


if __name__ == "__main__":
    unittest.main()
