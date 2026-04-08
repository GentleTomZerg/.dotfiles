# Prometheus

Send files via email with optional splitting.

## Setup

1. Copy and configure the config files:
   ```bash
   cp config.ini.example config.ini
   cp .env.example .env
   ```

2. Edit `config.ini` with your email settings and `.env` with your password.

## Usage

### Send files

```bash
# Single file
python prometheus.py send report.pdf

# Multiple files
python prometheus.py send file1.pdf file2.zip

# Glob patterns
python prometheus.py send *.zip

# Custom subject/body templates
python prometheus.py send file.pdf --subject "Build: {filename}"

# Dry run (preview)
python prometheus.py send file.pdf --dry-run

# Verbose output (use -v, -vv, or -vvv for more detail)
python prometheus.py send file.pdf -v
```

### Attachment Encoding Options

By default, attachments are base64 encoded which ensures compatibility with all email servers. However, some receiving servers may flag certain file types (.js, .sh, .exe) as potentially malicious even when base64 encoded.

```bash
# Send as raw binary instead of base64
python prometheus.py send script.sh --no-base64

# Rename to .txt to bypass extension-based filters
python prometheus.py send script.sh --rename-to-txt

# Both options together (recommended for problematic file types)
python prometheus.py send script.sh --no-base64 --rename-to-txt
# Recipient will see: script.sh.txt
```

### Split and send

```bash
# Split large file into chunks, then send each
python prometheus.py split-and-send bigfile.zip 10m
```

## Template Variables

- `{filename}` - basename of the file
- `{size}` - file size in human-readable format
- `{date}` - current date

## Verbose Output

The `-v` flag controls verbosity level. Repeat for more detail:

| Flag | Level | Description |
|------|-------|-------------|
| (none) | 0 | No output except errors |
| `-v` | 1 | Show progress (files sent, splits) |
| `-vv` | 2 | Show each file being processed |
| `-vvv` | 3 | Debug-level detail |

## Configuration

See `config.ini.example` for all options.

### Default Attachment Settings

| Option | Default | Description |
|--------|---------|-------------|
| base64_encode | true | Base64 encode attachments for universal email compatibility |
| rename_to_txt | false | Append .txt to filename to bypass extension-based filters |

These defaults ensure attachments work with all email servers. Use `--no-base64` and/or `--rename-to-txt` when sending files that trigger false positives on the receiving server.
