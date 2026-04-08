import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
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
        with patch("builder.Config.load"):
            with patch("emailer.Emailer") as mock_emailer:
                mock_emailer.return_value = MagicMock()
                p = Prometheus()
                builder = p.send([Path("file.pdf")])

                result = (
                    builder.with_subject("Build: {filename}")
                    .with_body("Sent: {filename}")
                    .with_verbosity(2)
                    .dry_run()
                    .execute()
                )

                self.assertIsInstance(result, BatchResult)

    def test_dry_run_skips_send(self):
        """Dry run should not call emailer.send()."""
        with patch("builder.Config.load"):
            with patch("emailer.Emailer") as mock_emailer:
                mock_emailer.return_value.send_batch.return_value = []
                p = Prometheus()

                p.send([Path("file.pdf")]).dry_run().execute()

                mock_emailer.return_value.send_batch.assert_not_called()

    def test_collects_results_on_failure(self):
        """Should return BatchResult with succeeded and failed lists."""
        with patch("builder.Config.load"):
            with patch("builder.Emailer") as mock_emailer:
                failed_result = SendResult(Path("bad.pdf"), False, "Connection refused")
                mock_emailer.return_value.send_batch.return_value = [failed_result]
                p = Prometheus()

                result = p.send([Path("bad.pdf")]).execute()

                self.assertEqual(len(result.succeeded), 0)
                self.assertEqual(len(result.failed), 1)
                self.assertEqual(result.failed[0][1], "Connection refused")

    def test_with_base64_encode(self):
        """Should pass base64_encode option to send_batch."""
        with patch("builder.Config.load"):
            with patch("builder.Emailer") as mock_emailer:
                mock_emailer.return_value.send_batch.return_value = []
                p = Prometheus()

                p.send([Path("file.pdf")]).with_base64_encode(False).execute()

                call_kwargs = mock_emailer.return_value.send_batch.call_args[1]
                self.assertEqual(call_kwargs["base64_encode"], False)

    def test_with_rename_to_txt(self):
        """Should pass rename_to_txt option to send_batch."""
        with patch("builder.Config.load"):
            with patch("builder.Emailer") as mock_emailer:
                mock_emailer.return_value.send_batch.return_value = []
                p = Prometheus()

                p.send([Path("script.sh")]).with_rename_to_txt(True).execute()

                call_kwargs = mock_emailer.return_value.send_batch.call_args[1]
                self.assertEqual(call_kwargs["rename_to_txt"], True)


if __name__ == "__main__":
    unittest.main()
