# On-Prem k3s Infrastructure Bootstrap

This repository provides a **single Bash script** to set up a **secure, production-ready on‑prem Kubernetes environment** using **k3s**.

It works for:
- ✅ Ubuntu Server (bare metal / VPS)
- ✅ Raspberry Pi running Ubuntu Server (ARM64)

Designed for:
- Hosting **multiple websites**
- Running **microservices**
- Full **on‑prem / self‑hosted** setup (no cloud dependency)

---

## 🚀 What This Script Does

The script automatically installs and configures:

### System & Security
- OS updates
- SSH hardening (disable password & root login)
- UFW firewall (only SSH, HTTP, HTTPS allowed)
- Fail2ban (brute-force protection)
- Swap disabled (required for Kubernetes)

### Kubernetes (k3s)
- Lightweight Kubernetes (k3s)
- containerd runtime
- CoreDNS
- kubectl configured for current user
- Starter namespaces:
  - `gym`
  - `carwash`
  - `infra`
- Default resource limits (basic protection)

This creates a **future‑proof base** to host:
- Multiple businesses
- Multiple domains
- Multiple microservices
- All on a single server initially

---

## 🧱 Architecture (High Level)

```
Internet
   |
Public IP
   |
Traefik Ingress (k3s)
   |
+-------------------+
|  Kubernetes       |
|                   |
|  gym namespace    |
|  carwash namespace|
|  infra namespace  |
+-------------------+
```

---

## 📋 Requirements

### Hardware (Minimum)
- CPU: 4 cores
- RAM: 4 GB (8 GB recommended)
- Storage: 32 GB (SSD / NVMe recommended)
- Internet access

### Software
- Ubuntu Server 20.04 / 22.04
- Sudo user access
- SSH key-based login

### Raspberry Pi Notes
- Use **Ubuntu Server 64‑bit**
- 4 GB RAM minimum (8 GB ideal)
- SSD over USB is strongly recommended (avoid SD cards)

---

## 📥 Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-org/onprem-k3s-bootstrap.git
cd onprem-k3s-bootstrap
```

### 2. Make the script executable

```bash
chmod +x setup-onprem-k3s.sh
```

### 3. Run the script

```bash
./setup-onprem-k3s.sh
```

⏱ Setup time: ~5–10 minutes

---

## ✅ After Installation

Verify cluster status:

```bash
kubectl get nodes
kubectl get pods -A
```

Expected:
- 1 node in `Ready` state
- Core system pods running

Namespaces created:

```bash
kubectl get ns
```

---

## 🌐 Hosting Websites & APIs

### DNS
Point your domains to the server public IP:

```
gym.com          → SERVER_IP
api.gym.com      → SERVER_IP
carwash.com      → SERVER_IP
```

### Traffic Routing
- Traefik Ingress routes traffic by domain
- HTTPS via Let's Encrypt (automatic)
- One public IP → many websites

---

## 🔐 Security Model

- Namespace isolation per business
- NetworkPolicies (can be added later)
- Secrets stored in Kubernetes Secrets
- TLS everywhere
- Resource limits to prevent abuse

Comparable to:
- AWS VPC
- Subnets
- Security Groups
- Load Balancers

…but fully on‑prem.

---

## 🔄 Scaling Later (No Redesign Needed)

- Add more websites → new namespace + ingress
- Add more servers → join them to k3s cluster
- Need load balancer → add MetalLB
- Need auth → add Keycloak

The base setup remains unchanged.

---

## 📂 Repository Structure

```
.
├── setup-onprem-k3s.sh
└── README.md
```

---

## 🛠 Recommended Next Steps

- Add Ingress templates for multi‑domain hosting
- Add NetworkPolicies for strict isolation
- Deploy PostgreSQL as StatefulSet
- Add backups & monitoring (Prometheus + Grafana)

---

## ⚠️ Disclaimer

This script is a **bootstrap foundation**.
You are responsible for:
- Application security
- Regular updates
- Backup strategy
- Compliance requirements

---

## 📜 License

MIT License
