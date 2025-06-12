#!/bin/bash
set -e

apt update -y
apt install -y nginx python3 python3-pip python3-venv libpq-dev build-essential git awscli

rm -rf /opt/sample-django
git clone https://github.com/DaniilTsitavets/sample-django.git /opt/sample-django
cd /opt/sample-django

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

DB_NAME=$(aws ssm get-parameter --name "/task3_db_name" --with-decryption --query "Parameter.Value" --output text --region eu-north-1)
DB_USER=$(aws ssm get-parameter --name "/task3_db_username" --with-decryption --query "Parameter.Value" --output text --region eu-north-1)
DB_PASSWORD=$(aws ssm get-parameter --name "/task3_db_password" --with-decryption --query "Parameter.Value" --output text --region eu-north-1)
SECRET_KEY=$(aws ssm get-parameter --name "/task3_secret_key" --with-decryption --query "Parameter.Value" --output text --region eu-north-1)
RDS_HOST="${rds_host}"

cat > /opt/sample-django/.env <<EOF
DEBUG=False
SECRET_KEY=$SECRET_KEY
ALLOWED_HOSTS=127.0.0.1
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$RDS_HOST
DATABASE_URL=postgres://$DB_USER:$DB_PASSWORD@$RDS_HOST:5432/$DB_NAME
DJANGO_ALLOWED_HOSTS="*"
EOF

source venv/bin/activate
export $(cat .env | xargs)  # Загружаем переменные среды из .env
python manage.py migrate
python manage.py collectstatic --noinput

mkdir -p /var/log/gunicorn
chown www-data:www-data /var/log/gunicorn

cat > /etc/systemd/system/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=www-data
Group=www-data
EnvironmentFile=/opt/sample-django/.env
WorkingDirectory=/opt/sample-django
ExecStart=/opt/sample-django/venv/bin/gunicorn mysite.wsgi:application \\
  --bind 0.0.0.0:8000 \\
  --workers 3 \\
  --chdir /opt/sample-django \\
  --access-logfile /var/log/gunicorn/access.log \\
  --error-logfile /var/log/gunicorn/error.log
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable gunicorn
systemctl start gunicorn

cat > /etc/nginx/sites-available/sample-django <<EOF
server {
    listen 80;
    server_name _ ;

    location /static/ {
        alias /opt/sample-django/static/;
    }

    location /media/ {
        alias /opt/sample-django/media/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_log  /var/log/nginx/django_error.log;
    access_log /var/log/nginx/django_access.log;
}
EOF

ln -s /etc/nginx/sites-available/sample-django /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx
