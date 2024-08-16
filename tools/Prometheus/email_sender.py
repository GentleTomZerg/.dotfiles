import argparse
import configparser
import smtplib
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# read email config
config = configparser.ConfigParser()
config.read("config.ini")
server_password = config.get("EMAIL", "SERVER_PASSWORD")
smtp_ssl_domain = config.get("EMAIL", "SMTP_SSL_DOMAIN")
smtp_ssl_port = config.getint("EMAIL", "SMTP_SSL_PORT")
send_email = config.get("EMAIL", "SEND_EMAIL")
recv_email = config.get("EMAIL", "RECV_EMAIL")

parser = argparse.ArgumentParser(description="send email according to config.ini")
parser.add_argument("--subject", required=True, help="The subject of the email.")
parser.add_argument("--body", required=True, help="The body of the email.")
parser.add_argument(
    "--attachment", required=False, help="The file to attach to the email."
)

args = parser.parse_args()

# Email content
subject = args.subject
body = args.body
filename = args.attachment

# Create the email object
msg = MIMEMultipart()
msg["From"] = send_email
msg["To"] = recv_email
msg["Subject"] = subject

# Attach the body of the email to the message
msg.attach(MIMEText(body, "plain"))

# Attach the file to the email
with open(filename, "rb") as attachment:
    part = MIMEBase("application", "octet-stream")
    part.set_payload(attachment.read())
    encoders.encode_base64(part)
    part.add_header("Content-Disposition", f"attachment; filename= {filename}")
    msg.attach(part)

# Connect to the SMTP server and send the email
server = None
try:
    server = smtplib.SMTP_SSL(smtp_ssl_domain, smtp_ssl_port)  # Connect using SSL
    server.login(send_email, server_password)  # Login to email account
    text = msg.as_string()  # Convert the email object to a string
    server.sendmail(send_email, recv_email, text)  # Send the email
    print("Email sent successfully!")
except Exception as e:
    print(f"Failed to send email: {e}")
finally:
    if server:
        server.quit()  # Close the connection
