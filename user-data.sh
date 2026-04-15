#!/bin/bash
# EC2 User Data script — RTMP relay: OBS → EC2 → YouTube + VK
# Region: eu-central-1, Instance: t3.small, Ubuntu 24.04
# Security Group: open ports 22 (SSH) and 1935 (RTMP)

set -e

apt-get update
apt-get install -y nginx libnginx-mod-rtmp

# Backup original config
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Write RTMP block into nginx config
cat >> /etc/nginx/nginx.conf << 'NGINX'

rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            record off;

            # Only your IP can publish
            allow publish YOUR_IP;
            deny publish all;
            deny play all;

            # YouTube
            push rtmp://a.rtmp.youtube.com/live2/YOUR_YOUTUBE_STREAM_KEY;

            # VK
            push rtmp://ovsu.okcdn.ru/input/YOUR_VK_STREAM_KEY;
        }
    }
}
NGINX

nginx -t
systemctl restart nginx
systemctl enable nginx

echo "RTMP relay is ready on port 1935"
