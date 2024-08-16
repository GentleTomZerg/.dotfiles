# Prometheus

A tool to bring fire to our life!

# Prerequsite

- python and related packages
- p7zip

## Usage

- Fill `config.ini`

```tex
[EMAIL]
SERVER_PASSWORD = your email server password
SMTP_SSL_DOMAIN = your email server domain eg:smtp.163.com
SMTP_SSL_PORT = your email server port (SSL Protocol)
SEND_EMAIL = your email address
RECV_EMAIL = target email address
```

- Execute `prometheus.sh`

```tex
# Examples:
# divide big files into small pieces
./prometheus.sh split_file /home/tom/Downloads/sonarlint-intellij-10.7.0.78874.zip 30m

.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:13 2024  sonarlint-intellij-10.7.0.78874.zip.7z.001
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.002
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.003
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.004
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.005
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.006
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.007
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:08 2024  sonarlint-intellij-10.7.0.78874.zip.7z.008
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:13 2024  sonarlint-intellij-10.7.0.78874.zip.7z.009
.rw-r--r-- tom tom  30 MB Thu Aug 15 17:20:13 2024  sonarlint-intellij-10.7.0.78874.zip.7z.010
.rw-r--r-- tom tom  10 MB Thu Aug 15 17:20:13 2024  sonarlint-intellij-10.7.0.78874.zip.7z.011

# send these pieces to the receive email
./prometheus.sh send_file "/home/tom/package*"                                                                <<<

Sending file: /home/tom/package.json
Email sent successfully!
Sending file: /home/tom/package-lock.json
Email sent successfully!
```
