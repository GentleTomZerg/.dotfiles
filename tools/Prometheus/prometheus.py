#!/usr/bin/env python3
import argparse
import glob
import sys
from pathlib import Path

from builder import Prometheus


def resolve_files(patterns: list[str]) -> list[Path]:
    files = []
    for pattern in patterns:
        if "*" in pattern or "?" in pattern:
            files.extend(Path(p) for p in glob.glob(pattern))
        else:
            files.append(Path(pattern))
    return files


def main():
    parser = argparse.ArgumentParser(
        description="Prometheus - Send files via email with optional splitting"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    send_parser = subparsers.add_parser("send", help="Send files via email")
    send_parser.add_argument("files", nargs="+", help="Files to send (globs supported)")
    send_parser.add_argument("--subject", help="Subject template")
    send_parser.add_argument("--body", help="Body template")
    send_parser.add_argument("-v", "--verbose", action="count", default=0)
    send_parser.add_argument(
        "--dry-run", action="store_true", help="Preview without sending"
    )

    split_parser = subparsers.add_parser(
        "split-and-send", help="Split file and send chunks"
    )
    split_parser.add_argument("file", help="File to split and send")
    split_parser.add_argument("size", help="Chunk size (e.g., 10m, 1g)")
    split_parser.add_argument("--subject", help="Subject template")
    split_parser.add_argument("--body", help="Body template")
    split_parser.add_argument("-v", "--verbose", action="count", default=0)
    split_parser.add_argument(
        "--dry-run", action="store_true", help="Preview without sending"
    )

    args = parser.parse_args()

    prometheus = Prometheus()

    if args.command == "send":
        files = resolve_files(args.files)
        if not files:
            print("No files found matching the given patterns.")
            sys.exit(1)

        builder = prometheus.send(files)
        if args.verbose:
            builder = builder.with_verbosity(args.verbose)
        if args.subject:
            builder = builder.with_subject(args.subject)
        if args.body:
            builder = builder.with_body(args.body)
        if args.dry_run:
            builder = builder.dry_run()

        result = builder.execute()

    elif args.command == "split-and-send":
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"File not found: {file_path}")
            sys.exit(1)

        builder = prometheus.split_and_send(file_path, args.size)
        if args.verbose:
            builder = builder.with_verbosity(args.verbose)
        if args.subject:
            builder = builder.with_subject(args.subject)
        if args.body:
            builder = builder.with_body(args.body)
        if args.dry_run:
            builder = builder.dry_run()

        result = builder.execute()

    if result.failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
