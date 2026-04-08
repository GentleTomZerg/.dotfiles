from dataclasses import dataclass
from pathlib import Path
from configparser import ConfigParser


@dataclass
class Config:
    smtp_host: str
    smtp_port: int
    sender: str
    recipient: str
    password: str
    subject_template: str
    body_template: str

    @classmethod
    def load(cls, ini_path: Path, env_path: Path) -> "Config":
        parser = ConfigParser()
        parser.read(ini_path)

        env_vars = {}
        if env_path.exists():
            for line in env_path.read_text().strip().split("\n"):
                if "=" in line:
                    key, value = line.split("=", 1)
                    env_vars[key.strip()] = value.strip()

        email = parser["EMAIL"]
        templates = parser["TEMPLATES"] if parser.has_section("TEMPLATES") else {}

        return cls(
            smtp_host=env_vars.get("SMTP_HOST", email.get("SMTP_SSL_DOMAIN", "")),
            smtp_port=int(env_vars.get("SMTP_PORT", email.get("SMTP_SSL_PORT", 465))),
            sender=email.get("SEND_EMAIL", ""),
            recipient=email.get("RECV_EMAIL", ""),
            password=env_vars.get("SMTP_PASSWORD", ""),
            subject_template=templates.get("SUBJECT", "{filename}"),
            body_template=templates.get("BODY", "{filename}"),
        )
