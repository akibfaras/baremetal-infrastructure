#!/bin/bash
set -e

echo "🚀 Starting on-prem Kubernetes (k3s) setup..."

# -------------------------------
# 1. Basic system update
# -------------------------------
echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

# -------------------------------
# 2. Install essential packages
# -------------------------------
echo "📦 Installing base packages..."
sudo apt install -y \
  curl \
  wget \
  vim \
  git \
  ca-certificates \
  gnupg \
  lsb-release \
  ufw \
  fail2ban

# -------------------------------
# 3. SSH hardening
# -------------------------------
echo "🔐 Hardening SSH..."
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# -------------------------------
# 4. Firewall setup
# -------------------------------
echo "🔥 Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# -------------------------------
# 5. Fail2ban enable
# -------------------------------
echo "🛡 Enabling fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# -------------------------------
# 6. Disable swap (required by k8s)
# -------------------------------
echo "🧠 Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# -------------------------------
# 7. Install k3s
# -------------------------------
echo "☸ Installing k3s (lightweight Kubernetes)..."

curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --disable servicelb

# Wait for k3s
sleep 10

# -------------------------------
# 8. kubectl access
# -------------------------------
echo "⚙ Setting up kubectl..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# -------------------------------
# 9. Verify cluster
# -------------------------------
echo "✅ Verifying cluster..."
kubectl get nodes
kubectl get pods -A

# -------------------------------
# 10. Create base namespaces
# -------------------------------
echo "📁 Creating namespaces..."
kubectl create namespace gym || true
kubectl create namespace carwash || true
kubectl create namespace infra || true

# -------------------------------
# 11. Security defaults (basic)
# -------------------------------
echo "🔒 Applying default security limits..."

kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: gym
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "200m"
      memory: "256Mi"
    type: Container
EOF

# -------------------------------
# 12. Final message
# -------------------------------
echo ""
echo "🎉 SETUP COMPLETE!"
echo ""
echo "Next steps:"
echo "1️⃣ Point your domain DNS → this server public IP"
echo "2️⃣ Deploy apps using Kubernetes manifests"
echo "3️⃣ Use Traefik Ingress for HTTPS routing"
echo ""
echo "kubectl is ready to use 🚀"
