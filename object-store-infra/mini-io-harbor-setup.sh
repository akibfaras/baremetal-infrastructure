#!/usr/bin/env bash
# ==========================================================
# Bare Metal Platform Setup
# MinIO (Distributed Object Store) + Harbor (Image Registry)
# ==========================================================
# Assumptions:
# - Ubuntu/RHEL-like OS
# - Passwordless SSH between nodes (for automation later)
# - DNS or /etc/hosts entries already configured
# - This script is run node-by-node

# ----------------------------------------------------------
# 1. Common prerequisites (ALL NODES)
# ----------------------------------------------------------
set -e

install_prereqs() {
  echo "[INFO] Installing prerequisites"
  sudo apt-get update -y
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    docker.io \
    docker-compose \
    jq

  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
}

# ----------------------------------------------------------
# 2. Directory layout
# ----------------------------------------------------------
setup_directories() {
  echo "[INFO] Creating directories"
  sudo mkdir -p /data/minio/{disk1,disk2}
  sudo mkdir -p /data/harbor
  sudo chown -R $USER:$USER /data
}

# ----------------------------------------------------------
# 3. MinIO Distributed Configuration
# ----------------------------------------------------------
# Run on EACH MinIO node
# Adjust node hostnames accordingly

create_minio_env() {
cat <<EOF > /data/minio/minio.env
MINIO_ROOT_USER=minio-root
MINIO_ROOT_PASSWORD=ChangeMeStrongPassword
MINIO_PROMETHEUS_AUTH_TYPE=public
EOF
}

create_minio_compose() {
cat <<EOF > /data/minio/docker-compose.yml
version: '3.8'
services:
  minio:
    image: quay.io/minio/minio:latest
    container_name: minio
    restart: always
    env_file:
      - minio.env
    volumes:
      - /data/minio/disk1:/data1
      - /data/minio/disk2:/data2
    command: server \
      http://minio1/data{1...2} \
      http://minio2/data{1...2} \
      http://minio3/data{1...2} \
      http://minio4/data{1...2} \
      --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
EOF
}

start_minio() {
  echo "[INFO] Starting MinIO"
  docker-compose -f /data/minio/docker-compose.yml up -d
}

# ----------------------------------------------------------
# 4. Harbor Configuration (Harbor nodes)
# ----------------------------------------------------------

create_harbor_config() {
cat <<EOF > /data/harbor/harbor.yml
hostname: harbor.platform.local

https:
  port: 443
  certificate: /data/cert/harbor.crt
  private_key: /data/cert/harbor.key

harbor_admin_password: ChangeMeAdminPassword

data_volume: /data/harbor

storage_service:
  s3:
    region: us-east-1
    bucket: harbor-registry
    accesskey: harbor-minio
    secretkey: ChangeMeMinIOSecret
    endpoint: https://minio.platform.local
    secure: true

trivy:
  enabled: true
EOF
}

# ----------------------------------------------------------
# 5. Harbor install wrapper
# ----------------------------------------------------------
install_harbor() {
  echo "[INFO] Installing Harbor"
  cd /data/harbor
  ./install.sh
}

# ----------------------------------------------------------
# 6. Execution control
# ----------------------------------------------------------
case "$1" in
  prereqs)
    install_prereqs
    setup_directories
    ;;
  minio)
    create_minio_env
    create_minio_compose
    start_minio
    ;;
  harbor)
    create_harbor_config
    install_harbor
    ;;
  *)
    echo "Usage: $0 {prereqs|minio|harbor}"
    exit 1
    ;;
esac
