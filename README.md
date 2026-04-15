# RTMP Streaming Relay

OBS → AWS EC2 (nginx-rtmp) → YouTube + VK simultaneously.

## Quick Start

1. Set your stream keys in `user-data.sh`:
   - `YOUR_YOUTUBE_STREAM_KEY` — from YouTube Studio → Stream Settings
   - `YOUR_VK_STREAM_KEY` — from VK → Create Broadcast
   - `YOUR_IP` — your public IP for access control

2. Set your SSH key pair name in `deploy.sh`:
   - `KEY_NAME="your-key-pair-name"`

3. Configure AWS CLI: `aws configure`

4. Deploy:
   ```bash
   cd streaming-relay
   ./deploy.sh
   ```

5. OBS Settings:
   - Service: Custom
   - Server: `rtmp://YOUR_EC2_IP/live`
   - Stream Key: `stream`

## Costs

t3.small in eu-central-1 ~$15/mo running 24/7. Stop when not streaming:

```bash
aws ec2 stop-instances --instance-ids INSTANCE_ID --region eu-central-1
```

## Security

- Publishing restricted by IP (`allow publish`)
- RTMP port 1935 open only for inbound streams
- No stream key secrets stored in this repo
