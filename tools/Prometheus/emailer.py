import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders
from pathlib import Path
from dataclasses import dataclass
from datetime import date
from typing import Optional


@dataclass
class SendResult:
    path: Path
    success: bool
    error: Optional[str] = None


class Emailer:
    def __init__(self, host: str, port: int, sender: str, password: str):
        self.host = host
        self.port = port
        self.sender = sender
        self.password = password

    def send(
        self,
        to: str,
        subject: str,
        body: str,
        attachment: Optional[Path] = None,
        base64_encode: bool = True,
        rename_to_txt: bool = False,
    ) -> SendResult:
        try:
            msg = MIMEMultipart()
            msg["From"] = self.sender
            msg["To"] = to
            msg["Subject"] = subject
            msg.attach(MIMEText(body, "plain"))

            if attachment and attachment.exists():
                with open(attachment, "rb") as f:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(f.read())

                filename = (
                    f"{attachment.name}.txt" if rename_to_txt else attachment.name
                )

                if base64_encode:
                    encoders.encode_base64(part)
                else:
                    part.add_header("Content-Transfer-Encoding", "binary")

                part.add_header(
                    "Content-Disposition",
                    f"attachment; filename= {filename}",
                )
                msg.attach(part)

            context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
            with smtplib.SMTP_SSL(self.host, self.port, context=context) as server:
                server.login(self.sender, self.password)
                server.send_message(msg)

            return SendResult(path=attachment or Path(""), success=True)

        except Exception as e:
            return SendResult(path=attachment or Path(""), success=False, error=str(e))

    def send_batch(
        self,
        files: list[Path],
        to: str,
        subject_template: str,
        body_template: str,
        base64_encode: bool = True,
        rename_to_txt: bool = False,
    ) -> list[SendResult]:
        results = []
        for file_path in files:
            context = {
                "filename": file_path.name,
                "size": self._format_size(file_path.stat().st_size),
                "date": date.today(),
            }
            subject = self._render(subject_template, context)
            body = self._render(body_template, context)

            result = self.send(
                to=to,
                subject=subject,
                body=body,
                attachment=file_path,
                base64_encode=base64_encode,
                rename_to_txt=rename_to_txt,
            )
            results.append(result)
        return results

    def _render(self, template: str, context: dict) -> str:
        result = template
        for key, value in context.items():
            if isinstance(value, date):
                value = value.strftime("%Y-%m-%d")
            result = result.replace(f"{{{key}}}", str(value))
        return result

    def _format_size(self, bytes: int) -> str:
        for unit in ["B", "KB", "MB", "GB"]:
            if bytes < 1024:
                return f"{bytes:.1f}{unit}"
            bytes /= 1024
        return f"{bytes:.1f}TB"
