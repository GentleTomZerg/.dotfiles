import unittest
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys
import tempfile
import shutil

sys.path.insert(0, str(Path(__file__).parent.parent))
from encoder import SplitStrategy, EncodeStrategy, NoOpStrategy


class TestSplitStrategy(unittest.TestCase):
    def test_transform_returns_chunk_paths(self):
        """SplitStrategy.transform() should return paths to 7z chunks."""
        temp_dir = Path(tempfile.mkdtemp())
        try:
            source = temp_dir / "test.zip"
            source.write_bytes(b"test content")

            strategy = SplitStrategy("1m", temp_dir)

            with patch("encoder.split_file") as mock_split:
                mock_split.return_value = [
                    temp_dir / "test.7z.001",
                    temp_dir / "test.7z.002",
                ]
                result = strategy.transform([source])

                self.assertEqual(len(result), 2)
                self.assertTrue(all(".7z." in p.name for p in result))
        finally:
            shutil.rmtree(temp_dir)


class TestEncodeStrategy(unittest.TestCase):
    def test_transform_creates_b64_file(self):
        """EncodeStrategy.transform() should create .b64 file."""
        temp_dir = Path(tempfile.mkdtemp())
        try:
            source = temp_dir / "file.pdf"
            source.write_bytes(b"hello")

            strategy = EncodeStrategy(temp_dir)
            result = strategy.transform([source])

            self.assertEqual(len(result), 1)
            self.assertEqual(result[0].name, "file.b64")
            self.assertTrue(result[0].exists())
            self.assertEqual(result[0].read_text().strip(), "aGVsbG8=")
        finally:
            shutil.rmtree(temp_dir)


class TestNoOpStrategy(unittest.TestCase):
    def test_transform_passes_through_files(self):
        """NoOpStrategy.transform() should return input files unchanged."""
        temp_dir = Path(tempfile.mkdtemp())
        try:
            files = [temp_dir / "a.txt", temp_dir / "b.txt"]
            for f in files:
                f.write_text("content")

            strategy = NoOpStrategy()
            result = strategy.transform(files)

            self.assertEqual(result, files)
        finally:
            shutil.rmtree(temp_dir)


if __name__ == "__main__":
    unittest.main()