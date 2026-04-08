import unittest
from unittest.mock import patch, MagicMock
from pathlib import Path
from datetime import date
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
from emailer import Emailer, SendResult


class TestEmailer(unittest.TestCase):
    @patch("smtplib.SMTP_SSL")
    def test_send_email_success(self, mock_smtp):
        """Should send email via SMTP_SSL and return success."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")
        result = emailer.send(
            to="recipient@example.com",
            subject="Test",
            body="Hello",
            attachment=Path("/tmp/test.pdf"),
        )

        self.assertTrue(result.success)
        self.assertEqual(result.error, None)
        mock_conn.login.assert_called_once_with("sender@example.com", "pass123")
        mock_conn.send_message.assert_called_once()

    @patch("smtplib.SMTP_SSL")
    def test_send_email_without_attachment(self, mock_smtp):
        """Should send email without attachment."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")
        result = emailer.send(to="recipient@example.com", subject="Test", body="Hello")

        self.assertTrue(result.success)
        mock_conn.send_message.assert_called_once()

    @patch("smtplib.SMTP_SSL")
    def test_send_email_failure(self, mock_smtp):
        """Should return error result on SMTP failure."""
        mock_smtp.return_value.__enter__.side_effect = Exception("Connection refused")

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")
        result = emailer.send(to="recipient@example.com", subject="Test", body="Hello")

        self.assertFalse(result.success)
        self.assertIn("Connection refused", result.error)

    @patch("smtplib.SMTP_SSL")
    def test_send_batch_collects_results(self, mock_smtp):
        """Should return results for each file in batch."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")
        files = [Path("/tmp/a.pdf"), Path("/tmp/b.pdf")]

        mock_file = MagicMock()
        mock_file.__enter__.return_value.read.return_value = b"fake pdf content"

        with patch.object(
            Path, "stat", create=True, return_value=MagicMock(st_size=1024)
        ):
            with patch.object(Path, "exists", return_value=True):
                with patch("builtins.open", return_value=mock_file):
                    results = emailer.send_batch(
                        files,
                        "recipient@example.com",
                        "Build {filename}",
                        "Sent {filename}",
                    )

        self.assertEqual(len(results), 2)
        for r in results:
            self.assertTrue(r.success)

    @patch("smtplib.SMTP_SSL")
    def test_send_without_base64(self, mock_smtp):
        """Should send file as binary when base64_encode=False."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")

        mock_file = MagicMock()
        mock_file.__enter__.return_value.read.return_value = b"fake content"

        with patch.object(Path, "exists", return_value=True):
            with patch.object(Path, "stat", return_value=MagicMock(st_size=100)):
                with patch("builtins.open", return_value=mock_file):
                    result = emailer.send(
                        to="recipient@example.com",
                        subject="Test",
                        body="Hello",
                        attachment=Path("/tmp/test.js"),
                        base64_encode=False,
                    )

        self.assertTrue(result.success)
        call_args = mock_conn.send_message.call_args[0][0]
        payload_str = call_args.as_string()
        self.assertIn("Content-Transfer-Encoding: binary", payload_str)
        self.assertIn("test.js", payload_str)

    @patch("smtplib.SMTP_SSL")
    def test_send_rename_to_txt(self, mock_smtp):
        """Should rename attachment to .txt when rename_to_txt=True."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")

        mock_file = MagicMock()
        mock_file.__enter__.return_value.read.return_value = b"fake content"

        with patch.object(Path, "exists", return_value=True):
            with patch.object(Path, "stat", return_value=MagicMock(st_size=100)):
                with patch("builtins.open", return_value=mock_file):
                    result = emailer.send(
                        to="recipient@example.com",
                        subject="Test",
                        body="Hello",
                        attachment=Path("/tmp/script.sh"),
                        rename_to_txt=True,
                    )

        self.assertTrue(result.success)
        call_args = mock_conn.send_message.call_args[0][0]
        payload_str = call_args.as_string()
        self.assertIn("script.sh.txt", payload_str)

    @patch("smtplib.SMTP_SSL")
    def test_send_no_base64_and_rename_to_txt(self, mock_smtp):
        """Should send as binary with .txt extension."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")

        mock_file = MagicMock()
        mock_file.__enter__.return_value.read.return_value = b"fake content"

        with patch.object(Path, "exists", return_value=True):
            with patch.object(Path, "stat", return_value=MagicMock(st_size=100)):
                with patch("builtins.open", return_value=mock_file):
                    result = emailer.send(
                        to="recipient@example.com",
                        subject="Test",
                        body="Hello",
                        attachment=Path("/tmp/malware.js"),
                        base64_encode=False,
                        rename_to_txt=True,
                    )

        self.assertTrue(result.success)
        call_args = mock_conn.send_message.call_args[0][0]
        payload_str = call_args.as_string()
        self.assertIn("Content-Transfer-Encoding: binary", payload_str)
        self.assertIn("malware.js.txt", payload_str)

    @patch("smtplib.SMTP_SSL")
    def test_send_batch_with_options(self, mock_smtp):
        """Should pass base64 and rename options to send_batch."""
        mock_conn = MagicMock()
        mock_smtp.return_value.__enter__.return_value = mock_conn

        emailer = Emailer("smtp.example.com", 465, "sender@example.com", "pass123")
        files = [Path("/tmp/test.sh")]

        mock_file = MagicMock()
        mock_file.__enter__.return_value.read.return_value = b"#!/bin/bash"

        with patch.object(
            Path, "stat", create=True, return_value=MagicMock(st_size=100)
        ):
            with patch.object(Path, "exists", return_value=True):
                with patch("builtins.open", return_value=mock_file):
                    results = emailer.send_batch(
                        files,
                        "recipient@example.com",
                        "Subject",
                        "Body",
                        base64_encode=False,
                        rename_to_txt=True,
                    )

        self.assertEqual(len(results), 1)
        self.assertTrue(results[0].success)
        payload_str = mock_conn.send_message.call_args[0][0].as_string()
        self.assertIn("Content-Transfer-Encoding: binary", payload_str)
        self.assertIn("test.sh.txt", payload_str)


if __name__ == "__main__":
    unittest.main()
