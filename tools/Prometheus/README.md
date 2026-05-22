# Prometheus

Send files via email with optional 7z splitting and optional `.b64` content generation.

## Features

- Send files via email with SMTP/SSL
- SMTP-safe MIME base64 transport encoding for attachments
- Optional `.b64` content generation
- 7z splitting for large files (bypass email size limits)
- Dry run mode to preview before sending
- Template variables in subject/body

## Setup

```bash
# 1. Copy and configure config files
cp config.ini.example config.ini
cp .env.example .env

# 2. Edit config.ini with your email settings
# 3. Edit .env with your SMTP password
```

### Configuration

**config.ini**
| Section | Option | Description | Default |
|---------|--------|-------------|---------|
| EMAIL | SMTP_SSL_DOMAIN | SMTP server hostname | - |
| EMAIL | SMTP_SSL_PORT | SMTP port | 465 |
| EMAIL | SEND_EMAIL | Sender email address | - |
| EMAIL | RECV_EMAIL | Recipient email address | - |
| TEMPLATES | SUBJECT | Email subject template | `{filename}` |
| TEMPLATES | BODY | Email body template | `{filename}` |

**.env**
| Variable | Description |
|----------|-------------|
| SMTP_HOST | SMTP server (overrides config.ini) |
| SMTP_PORT | SMTP port (overrides config.ini) |
| SMTP_PASSWORD | SMTP password |

---

## Usage

### `send` Command

Send files via email. By default, input files are first converted to `.b64` files in `./temp/`.

```
python prometheus.py send <files> [options]
```

| Option | Description | Default |
|--------|-------------|---------|
| `--subject` | Subject template | From config |
| `--body` | Body template | From config |
| `--no-base64` | Skip `.b64` content generation and send original files | `false` |
| `--dry-run` | Preview without sending | `false` |

**Examples**

```bash
# Single file
python prometheus.py send report.pdf

# Multiple files
python prometheus.py send file1.pdf file2.zip

# Glob patterns
python prometheus.py send *.zip

# Custom templates
python prometheus.py send file.pdf --subject "Build: {filename}" --body "File: {filename}"

# Dry run (preview)
python prometheus.py send file.pdf --dry-run

# Skip `.b64` content generation
python prometheus.py send script.sh --no-base64
```

**Sample output**
```
[DRY RUN] Would send:
  - temp/file.b64
```
```
[SENT] temp/file.b64
```

---

### `split-and-send` Command

Split large file into 7z chunks, then send each chunk.

```
python prometheus.py split-and-send <file> <size> [options]
```

| Option | Description | Default |
|--------|-------------|---------|
| `size` | Chunk size (e.g., 10m, 1g, 500k) | Required |
| `--subject` | Subject template | From config |
| `--body` | Body template | From config |
| `--dry-run` | Preview without sending | `false` |

**Size format**: `N[kKmMgG]` where:
- `k` / `K` = kilobytes (1024)
- `m` / `M` = megabytes (1024²)
- `g` / `G` = gigabytes (1024³)
- No suffix = bytes

**Examples**

```bash
# Split into 10MB chunks
python prometheus.py split-and-send bigfile.zip 10m

# Split into 1GB chunks
python prometheus.py split-and-send large.bin 1g

# Dry run
python prometheus.py split-and-send bigfile.zip 10m --dry-run
```

**Sample output**
```
[DRY RUN] Would send:
  - temp/bigfile.7z.001
  - temp/bigfile.7z.002
  - temp/bigfile.7z.003
```
```
[SENT] temp/bigfile.7z.001
[SENT] temp/bigfile.7z.002
[SENT] temp/bigfile.7z.003
```

---

## Encoding Model

Prometheus has two separate encoding layers:

1. Content encoding (`--no-base64` controls this for `send`)
- Default `send`: create `*.b64` files in `./temp/` and attach those files.
- With `--no-base64`: attach original files directly (no `.b64` intermediate files).
- `split-and-send`: create and attach `*.7z.001`, `*.7z.002`, ... chunks.

2. Transport encoding (always on)
- All attachments are MIME base64 encoded before SMTP transfer.
- This preserves attachment bytes across typical SMTP relays.

---

## Template Variables

Use these placeholders in `--subject` and `--body`:

| Variable | Description | Example Output |
|----------|-------------|----------------|
| `{filename}` | Basename of file | `report.pdf` |
| `{size}` | Human-readable size | `1.5MB` |
| `{date}` | Current date | `2026-04-24` |

**Example**
```bash
python prometheus.py send file.zip \
  --subject "Sending: {filename} ({size})" \
  --body "Date: {date}"
```

---

## Intermediate Files

Prometheus stores intermediate files in `./temp/`:

| Command | Files |
|---------|-------|
| `send` | `*.b64` (default) or original files (`--no-base64`) |
| `split-and-send` | `*.7z.001`, `*.7z.002`, ... |

These files are kept after sending for reference. Delete `./temp/` manually to clean up.

---

## Requirements

- Python 3.10+
- SMTP access to an email server
- `7z` command (for split-and-send only)

Install 7z on macOS:
```bash
brew install p7zip
```

Install 7z on Ubuntu/Debian:
```bash
sudo apt install p7zip-full
```

---

## License

MIT
