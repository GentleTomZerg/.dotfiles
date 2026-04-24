import base64
from abc import ABC, abstractmethod
from pathlib import Path
from typing import List

from splitter import split_file


class TransformStrategy(ABC):
    @abstractmethod
    def transform(self, files: List[Path]) -> List[Path]:
        pass


class NoOpStrategy(TransformStrategy):
    def transform(self, files: List[Path]) -> List[Path]:
        return files


class SplitStrategy(TransformStrategy):
    def __init__(self, size: str, temp_dir: Path):
        self.size = size
        self.temp_dir = temp_dir

    def transform(self, files: List[Path]) -> List[Path]:
        chunks = []
        for file_path in files:
            new_chunks = split_file(file_path, self.size, self.temp_dir)
            chunks.extend(new_chunks)
        return chunks


class EncodeStrategy(TransformStrategy):
    def __init__(self, temp_dir: Path):
        self.temp_dir = temp_dir

    def transform(self, files: List[Path]) -> List[Path]:
        encoded = []
        for f in files:
            b64_path = self.temp_dir / f"{f.stem}.b64"
            b64_path.write_text(base64.b64encode(f.read_bytes()).decode())
            encoded.append(b64_path)
        return encoded