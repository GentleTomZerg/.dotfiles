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

## Configuration

See `config.ini.example` for all options.
