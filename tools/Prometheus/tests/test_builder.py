import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
import builder
from builder import Prometheus, SendBuilder, SendResult, BatchResult


class TestPrometheus(unittest.TestCase):
    def test_send_returns_builder(self):
        """Prometheus.send() should return a SendBuilder."""
        with patch("builder.Config.load"):
            p = Prometheus()
        builder = p.send([Path("file.pdf")])
        self.assertIsInstance(builder, SendBuilder)

    def test_split_and_send_returns_builder(self):
        """Prometheus.split_and_send() should return a SendBuilder."""
        with patch("builder.Config.load"):
            p = Prometheus()
        builder = p.split_and_send(Path("large.bin"), "10m")
        self.assertIsInstance(builder, SendBuilder)


class TestSendBuilder(unittest.TestCase):
    def test_fluent_api(self):
        """Methods should return self for chaining."""
        import tempfile
        import shutil

        temp_dir = Path(tempfile.mkdtemp())
        test_file = temp_dir / "file.pdf"
        test_file.write_bytes(b"test")

        try:
            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    mock_emailer.return_value = MagicMock()
                    p = Prometheus()
                    builder = p.send([test_file])

                    result = (
                        builder.with_subject("Build: {filename}")
                        .with_body("Sent: {filename}")
                        .dry_run()
                        .execute()
                    )

                    self.assertIsInstance(result, BatchResult)
            shutil.rmtree(temp_dir)
        finally:
            if temp_dir.exists():
                shutil.rmtree(temp_dir)

    def test_dry_run_skips_send(self):
        """Dry run should not call emailer.send()."""
        import tempfile
        import shutil

        temp_dir = Path(tempfile.mkdtemp())
        test_file = temp_dir / "file.pdf"
        test_file.write_bytes(b"test")

        try:
            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    mock_emailer.return_value.send_batch.return_value = []
                    p = Prometheus()

                    p.send([test_file]).with_base64_encode(False).dry_run().execute()

                    mock_emailer.return_value.send_batch.assert_not_called()
        finally:
            shutil.rmtree(temp_dir)

    def test_collects_results_on_failure(self):
        """Should return BatchResult with succeeded and failed lists."""
        import tempfile
        import shutil

        temp_dir = Path(tempfile.mkdtemp())
        test_file = temp_dir / "bad.pdf"
        test_file.write_bytes(b"test")

        try:
            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    failed_result = SendResult(test_file, False, "Connection refused")
                    mock_emailer.return_value.send_batch.return_value = [failed_result]
                    p = Prometheus()

                    result = p.send([test_file]).with_base64_encode(False).execute()

                    self.assertEqual(len(result.succeeded), 0)
                    self.assertEqual(len(result.failed), 1)
                    self.assertEqual(result.failed[0][1], "Connection refused")
        finally:
            shutil.rmtree(temp_dir)

    def test_creates_temp_directory_if_missing(self):
        """Should create ./temp directory before sending files."""
        import tempfile
        import shutil

        temp_project = Path(tempfile.mkdtemp())
        try:
            temp_dir = temp_project / "temp"
            self.assertFalse(temp_dir.exists())

            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    with patch.object(builder, "TEMP_DIR", temp_dir):
                        mock_emailer.return_value.send_batch.return_value = []
                        p = Prometheus()

                        test_file = temp_project / "file.pdf"
                        test_file.write_bytes(b"test")
                        p.send([test_file]).with_base64_encode(False).execute()

                        self.assertTrue(temp_dir.exists())
                        self.assertTrue(temp_dir.is_dir())
        finally:
            shutil.rmtree(temp_project)

    def test_encodes_to_base64_file_when_enabled(self):
        """Should create .b64 file in temp dir when base64_encode=True."""
        import tempfile
        import shutil

        temp_project = Path(tempfile.mkdtemp())
        source_file = temp_project / "test.pdf"
        source_file.write_bytes(b"fake pdf content")

        try:
            temp_dir = temp_project / "temp"
            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    with patch.object(builder, "TEMP_DIR", temp_dir):
                        mock_emailer.return_value.send_batch.return_value = []
                        p = Prometheus()

                        p.send([source_file]).with_base64_encode(True).execute()

                        b64_file = temp_dir / "test.b64"
                        self.assertTrue(b64_file.exists())
                        self.assertEqual(b64_file.read_text().strip(), "ZmFrZSBwZGYgY29udGVudA==")
        finally:
            shutil.rmtree(temp_project)

    def test_attaches_base64_file_to_email(self):
        """Should attach base64 file to email when base64_encode=True."""
        import tempfile
        import shutil

        temp_project = Path(tempfile.mkdtemp())
        source_file = temp_project / "data.zip"
        source_file.write_bytes(b"hello world")

        try:
            temp_dir = temp_project / "temp"
            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    with patch.object(builder, "TEMP_DIR", temp_dir):
                        mock_emailer.return_value.send_batch.return_value = []
                        p = Prometheus()

                        p.send([source_file]).with_base64_encode(True).execute()

                        call_kwargs = mock_emailer.return_value.send_batch.call_args[1]
                        files_sent = call_kwargs["files"]
                        self.assertEqual(len(files_sent), 1)
                        self.assertEqual(files_sent[0].name, "data.b64")
        finally:
            shutil.rmtree(temp_project)

    def test_with_split_sets_strategy(self):
        """SendBuilder.with_split() should use SplitStrategy."""
        with patch("builder.Config.load"):
            p = Prometheus()
            b = p.send([Path("large.bin")]).with_split("10m")

            self.assertIsNotNone(b._strategy)
            self.assertEqual(b._strategy.__class__.__name__, "SplitStrategy")

    def test_split_strategy_sends_split_chunks(self):
        """SplitStrategy should pass split chunk files to emailer.send_batch()."""
        with patch("builder.Config.load"):
            with patch("builder.Emailer") as mock_emailer:
                with patch("builder.SplitStrategy.transform") as mock_transform:
                    mock_emailer.return_value.send_batch.return_value = []
                    split_chunk = Path("temp/large.bin.7z.001")
                    mock_transform.return_value = [split_chunk]
                    p = Prometheus()

                    p.send([Path("large.bin")]).with_split("10m").execute()

                    call_kwargs = mock_emailer.return_value.send_batch.call_args[1]
                    self.assertEqual(call_kwargs["files"], [split_chunk])

    def test_with_base64_encode_true_sets_strategy(self):
        """SendBuilder.with_base64_encode(True) should use EncodeStrategy."""
        with patch("builder.Config.load"):
            p = Prometheus()
            b = p.send([Path("file.pdf")]).with_base64_encode(True)

            self.assertIsNotNone(b._strategy)
            self.assertEqual(b._strategy.__class__.__name__, "EncodeStrategy")

    def test_with_base64_encode_false_sets_noop_strategy(self):
        """SendBuilder.with_base64_encode(False) should use NoOpStrategy."""
        with patch("builder.Config.load"):
            p = Prometheus()
            b = p.send([Path("file.pdf")]).with_base64_encode(False)

            self.assertIsNotNone(b._strategy)
            self.assertEqual(b._strategy.__class__.__name__, "NoOpStrategy")

    def test_dry_run_runs_transform(self):
        """Dry run should run transform strategy to create intermediates."""
        import tempfile
        import shutil

        temp_project = Path(tempfile.mkdtemp())
        source_file = temp_project / "data.zip"
        source_file.write_bytes(b"hello")

        try:
            temp_dir = temp_project / "temp"
            with patch("builder.Config.load"):
                with patch("builder.Emailer") as mock_emailer:
                    with patch.object(builder, "TEMP_DIR", temp_dir):
                        mock_emailer.return_value.send_batch.return_value = []
                        p = Prometheus()

                        p.send([source_file]).with_base64_encode(True).dry_run().execute()

                        b64_file = temp_dir / "data.b64"
                        self.assertTrue(b64_file.exists())
                        mock_emailer.return_value.send_batch.assert_not_called()
        finally:
            shutil.rmtree(temp_project)


if __name__ == "__main__":
    unittest.main()
