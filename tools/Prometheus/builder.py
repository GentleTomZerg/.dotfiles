import base64
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, List

from config import Config
from emailer import Emailer, SendResult
from encoder import SplitStrategy, EncodeStrategy, NoOpStrategy

TEMP_DIR = Path(__file__).parent / "temp"


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
        subject_template: Optional[str] = None,
        body_template: Optional[str] = None,
        base64_encode: bool = True,
    ):
        self.files = files
        self.config = config
        self.split_size = split_size
        self._dry_run = is_dry_run
        self.subject_template = subject_template or config.subject_template
        self.body_template = body_template or config.body_template
        self.base64_encode = base64_encode
        self._strategy: Optional[NoOpStrategy] = None
        self._set_default_strategy()

    def _set_default_strategy(self):
        if self.split_size:
            self._strategy = SplitStrategy(self.split_size, TEMP_DIR)
        elif self.base64_encode:
            self._strategy = EncodeStrategy(TEMP_DIR)
        else:
            self._strategy = NoOpStrategy()

    def with_subject(self, template: str) -> "SendBuilder":
        self.subject_template = template
        return self

    def with_body(self, template: str) -> "SendBuilder":
        self.body_template = template
        return self

    def dry_run(self) -> "SendBuilder":
        self._dry_run = True
        return self

    def with_base64_encode(self, value: bool) -> "SendBuilder":
        self.base64_encode = value
        if value:
            self._strategy = EncodeStrategy(TEMP_DIR)
        else:
            self._strategy = NoOpStrategy()
        return self

    def with_split(self, size: str) -> "SendBuilder":
        self.split_size = size
        self._strategy = SplitStrategy(size, TEMP_DIR)
        return self

    def execute(self) -> BatchResult:
        TEMP_DIR.mkdir(parents=True, exist_ok=True)
        intermediates = self._strategy.transform(self.files)

        if self._dry_run:
            return self._dry_run_results(intermediates)

        return self._send_files(intermediates)

    def _dry_run_results(self, intermediates: List[Path]) -> BatchResult:
        result = BatchResult()
        print("[DRY RUN] Would send:")
        for f in intermediates:
            print(f"  - {f}")
            result.succeeded.append(f)
        return result

    def _send_files(self, files: List[Path]) -> BatchResult:
        emailer = Emailer(
            host=self.config.smtp_host,
            port=self.config.smtp_port,
            sender=self.config.sender,
            password=self.config.password,
        )

        results = emailer.send_batch(
            files=files,
            to=self.config.recipient,
            subject_template=self.subject_template,
            body_template=self.body_template,
        )

        batch_result = BatchResult()
        for r in results:
            if r.success:
                batch_result.succeeded.append(r.path)
                print(f"[SENT] {r.path}")
            else:
                batch_result.failed.append((r.path, r.error or "Unknown error"))
                print(f"[FAILED] {r.path} - {r.error}")

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
