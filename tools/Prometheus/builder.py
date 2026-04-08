from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, List

from config import Config
from emailer import Emailer, SendResult
from splitter import split_file


@dataclass
class BatchResult:
    succeeded: List[Path] = field(default_factory=list)
    failed: List[tuple[Path, str]] = field(default_factory=list)

    @property
    def all_success(self) -> bool:
        return len(self.failed) == 0


class SendBuilder:
    def __init__(
        self,
        files: List[Path],
        config: Config,
        split_size: Optional[str] = None,
        is_dry_run: bool = False,
        verbosity: int = 0,
        subject_template: Optional[str] = None,
        body_template: Optional[str] = None,
        base64_encode: bool = True,
        rename_to_txt: bool = False,
    ):
        self.files = files
        self.config = config
        self.split_size = split_size
        self._dry_run = is_dry_run
        self.verbosity = verbosity
        self.subject_template = subject_template or config.subject_template
        self.body_template = body_template or config.body_template
        self.base64_encode = base64_encode
        self.rename_to_txt = rename_to_txt
        self._chunks: List[Path] = []

    def with_subject(self, template: str) -> "SendBuilder":
        self.subject_template = template
        return self

    def with_body(self, template: str) -> "SendBuilder":
        self.body_template = template
        return self

    def with_verbosity(self, level: int) -> "SendBuilder":
        self.verbosity = level
        return self

    def dry_run(self) -> "SendBuilder":
        self._dry_run = True
        return self

    def with_base64_encode(self, value: bool) -> "SendBuilder":
        self.base64_encode = value
        return self

    def with_rename_to_txt(self, value: bool) -> "SendBuilder":
        self.rename_to_txt = value
        return self

    def execute(self) -> BatchResult:
        if self.split_size:
            self._split_files()

        if self._dry_run:
            return self._dry_run_results()

        return self._send_files()

    def _split_files(self):
        for file_path in self.files:
            if self.verbosity > 0:
                print(f"Splitting {file_path.name} into {self.split_size} chunks...")
            chunks = split_file(file_path, self.split_size, file_path.parent)
            self._chunks.extend(chunks)

    def _dry_run_results(self) -> BatchResult:
        result = BatchResult()
        for f in self._chunks or self.files:
            if self.verbosity > 0:
                print(f"[DRY RUN] Would send: {f}")
            result.succeeded.append(f)
        return result

    def _send_files(self) -> BatchResult:
        emailer = Emailer(
            host=self.config.smtp_host,
            port=self.config.smtp_port,
            sender=self.config.sender,
            password=self.config.password,
        )

        files_to_send = self._chunks if self._chunks else self.files
        results = emailer.send_batch(
            files=files_to_send,
            to=self.config.recipient,
            subject_template=self.subject_template,
            body_template=self.body_template,
            base64_encode=self.base64_encode,
            rename_to_txt=self.rename_to_txt,
        )

        batch_result = BatchResult()
        for r in results:
            if r.success:
                batch_result.succeeded.append(r.path)
            else:
                batch_result.failed.append((r.path, r.error or "Unknown error"))

        if self.verbosity > 0:
            print(f"Sent {len(batch_result.succeeded)}/{len(files_to_send)} files")
            for path, error in batch_result.failed:
                print(f"Failed: {path} - {error}")

        return batch_result


class Prometheus:
    def __init__(
        self, config_path: Optional[Path] = None, env_path: Optional[Path] = None
    ):
        if config_path is None:
            config_path = Path(__file__).parent / "config.ini"
        if env_path is None:
            env_path = Path(__file__).parent / ".env"

        self.config = Config.load(config_path, env_path)

    def send(self, files: List[Path]) -> SendBuilder:
        return SendBuilder(files=files, config=self.config)

    def split_and_send(self, file: Path, size: str) -> SendBuilder:
        return SendBuilder(files=[file], config=self.config, split_size=size)
