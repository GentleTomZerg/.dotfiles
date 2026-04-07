import unittest
import tempfile
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from config import Config


class TestConfig(unittest.TestCase):
    def test_loads_from_ini_and_env(self):
        """Config should load from config.ini with .env secrets."""
        ini_content = """[EMAIL]
SMTP_SSL_DOMAIN = smtp.example.com
SMTP_SSL_PORT = 465
SEND_EMAIL = sender@example.com
RECV_EMAIL = recipient@example.com

[TEMPLATES]
SUBJECT = {filename}
BODY = File: {filename}
"""
        env_content = """SMTP_PASSWORD=secret123
"""
        with tempfile.TemporaryDirectory() as tmp:
            ini_path = Path(tmp) / "config.ini"
            ini_path.write_text(ini_content)
            env_path = Path(tmp) / ".env"
            env_path.write_text(env_content)

            config = Config.load(ini_path, env_path)

            self.assertEqual(config.smtp_host, "smtp.example.com")
            self.assertEqual(config.smtp_port, 465)
            self.assertEqual(config.sender, "sender@example.com")
            self.assertEqual(config.recipient, "recipient@example.com")
            self.assertEqual(config.password, "secret123")
            self.assertEqual(config.subject_template, "{filename}")
            self.assertEqual(config.body_template, "File: {filename}")

    def test_env_takes_precedence_over_ini(self):
        """Environment variables should override config.ini values."""
        ini_content = """[EMAIL]
SMTP_SSL_DOMAIN = ini.example.com
SMTP_SSL_PORT = 465
SEND_EMAIL = ini@example.com
RECV_EMAIL = ini@recipient.com
"""
        env_content = """SMTP_PASSWORD=env_secret
SMTP_HOST=env.example.com
"""
        with tempfile.TemporaryDirectory() as tmp:
            ini_path = Path(tmp) / "config.ini"
            ini_path.write_text(ini_content)
            env_path = Path(tmp) / ".env"
            env_path.write_text(env_content)

            config = Config.load(ini_path, env_path)

            self.assertEqual(config.smtp_host, "env.example.com")
            self.assertEqual(config.password, "env_secret")

    def test_defaults_for_optional_fields(self):
        """Missing optional fields should use defaults."""
        ini_content = """[EMAIL]
SMTP_SSL_DOMAIN = smtp.example.com
SEND_EMAIL = sender@example.com
RECV_EMAIL = recipient@example.com
"""
        env_content = """SMTP_PASSWORD=secret
"""
        with tempfile.TemporaryDirectory() as tmp:
            ini_path = Path(tmp) / "config.ini"
            ini_path.write_text(ini_content)
            env_path = Path(tmp) / ".env"
            env_path.write_text(env_content)

            config = Config.load(ini_path, env_path)

            self.assertEqual(config.smtp_port, 465)
            self.assertEqual(config.subject_template, "{filename}")
            self.assertEqual(config.body_template, "{filename}")


if __name__ == "__main__":
    unittest.main()
