import subprocess
from pathlib import Path
import re
import shutil


def get_7z_command() -> str:
    for cmd in ["7z", "7za", "7zr"]:
        if shutil.which(cmd):
            return cmd
    raise RuntimeError("No 7z command found (tried: 7z, 7za, 7zr)")


def parse_size(size_str: str) -> int:
    size_str = size_str.strip().upper()
    match = re.match(r"^(\d+(?:\.\d+)?)\s*(KB|MB|GB|K|M|G)?$", size_str)
    if not match:
        raise ValueError(f"Invalid size format: {size_str}")

    value = float(match.group(1))
    unit = match.group(2) or ""

    multipliers = {
        "": 1,
        "K": 1024,
        "M": 1024**2,
        "G": 1024**3,
        "KB": 1024,
        "MB": 1024**2,
        "GB": 1024**3,
    }

    return int(value * multipliers[unit])


def split_file(file_path: Path, size: str, output_dir: Path) -> list[Path]:
    size_bytes = parse_size(size)
    size_mb = size_bytes // (1024 * 1024)

    cmd = get_7z_command()

    result = subprocess.run(
        [
            cmd,
            "a",
            f"-v{size_mb}m",
            str(output_dir / file_path.name) + ".7z",
            str(file_path),
        ],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(f"{cmd} failed: {result.stderr}")

    chunks = []
    base = output_dir / (file_path.name + ".7z")
    for i in range(1, 999):
        chunk = Path(str(base) + f".{i:03d}")
        if chunk.exists():
            chunks.append(chunk)
        else:
            break

    return chunks
