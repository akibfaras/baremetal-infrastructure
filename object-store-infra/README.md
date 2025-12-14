# Bare-Metal Object Storage + Container Registry Platform

This repository provides a **production-ready, bare-metal platform
setup** for:

-   **MinIO** (S3-compatible distributed object storage)
-   **Harbor** (enterprise-grade private container image registry)

The design mirrors cloud-native patterns (S3 + ECR) but runs fully
**on-prem / bare metal**.

------------------------------------------------------------------------

## Architecture Overview

    Developers / CI
          |
          v
    Harbor (UI, Registry, Security)
          |
          v
    MinIO (Distributed Object Storage)
          |
          v
    Bare-Metal Disks

Key principles: - Storage decoupled from services - Stateless Harbor -
TLS everywhere - Least-privilege access - Scalable and reproducible

------------------------------------------------------------------------

## Components

### 1. MinIO (Object Store)

-   Distributed mode (4+ nodes)
-   Erasure coding
-   S3-compatible API
-   Used as backend for Harbor images

### 2. Harbor (Container Registry)

-   Private Docker registry
-   RBAC & audit logs
-   Vulnerability scanning (Trivy)
-   Image retention & garbage collection

------------------------------------------------------------------------

## Node Roles

  Node Type      Purpose
  -------------- -------------------------------------------
  MinIO Nodes    Object storage cluster
  Harbor Nodes   Registry + UI
  LB Node        TLS termination & routing (NGINX/HAProxy)

------------------------------------------------------------------------

## Directory Layout

    /data
     ├── minio
     │   ├── disk1
     │   ├── disk2
     │   ├── docker-compose.yml
     │   └── minio.env
     └── harbor
         ├── harbor.yml
         └── data

------------------------------------------------------------------------

## Setup Script

A single script is used for all nodes, similar to k3s-style installs.

### Script: `setup.sh`

Modes: - `prereqs` → install Docker, Compose, base dirs - `minio` →
deploy distributed MinIO - `harbor` → deploy Harbor using MinIO backend

------------------------------------------------------------------------

## Installation Flow

### 1. All nodes

``` bash
./setup.sh prereqs
```

### 2. MinIO nodes

``` bash
./setup.sh minio
```

### 3. Create MinIO resources (one-time)

-   Bucket: `harbor-registry`
-   Service account: `harbor-minio`
-   Bucket policy: least privilege

### 4. Harbor nodes

``` bash
./setup.sh harbor
```

------------------------------------------------------------------------

## DNS Requirements

    minio.platform.local   → MinIO load balancer
    harbor.platform.local  → Harbor load balancer

------------------------------------------------------------------------

## Security Notes

-   TLS is mandatory
-   Do not expose MinIO root credentials
-   Use service accounts for Harbor
-   Enable image scanning & retention policies

------------------------------------------------------------------------

## Backup Strategy

-   MinIO replication or snapshots
-   Harbor DB backups stored in MinIO
-   Configs stored in Git

------------------------------------------------------------------------

## When to Use This Setup

✔ On-prem / bare metal\
✔ Regulated environments\
✔ No cloud dependency\
✔ Platform / DevOps teams

------------------------------------------------------------------------

## Next Improvements (Planned)

-   TLS automation
-   MinIO bootstrap automation
-   Harbor HA with external Postgres
-   Monitoring & alerting
-   Disaster recovery runbooks

------------------------------------------------------------------------

## Summary

This setup provides a **cloud-like registry and object storage
experience** on bare metal using proven open-source tools.

MinIO = S3\
Harbor = ECR

Fully owned. Fully controlled.
