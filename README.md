# 🚀 Quote App on AWS ECS Fargate — Infrastructure-as-Code

A fully containerized, production-grade quote-of-the-day app deployed on AWS ECS using Terraform.  
Frontend served by Nginx, backend provides a JSON quote API — all secured inside private subnets with a public ALB entry point.

## 🌐 Live Demo

**URL:** http://<ALB-DNS-HERE>

## 📦 Project Structure
```
timursamanchi@Timurs-Air ~/p/ecs-jekyll [fix/lb] (tf:dev) % tree
.
├── LICENSE
├── README.md
├── backup
│   └── new-horizon-ecs-main.zip
├── docker
│   ├── backend
│   │   └── Dockerfile
│   ├── frontend
│   │   ├── Dockerfile
│   │   ├── default.conf
│   │   └── index.html
│   └── jekyll
│       ├── Dockerfile
│       ├── _config.yml
│       ├── index.md
│       └── nginx.conf
├── json
│   ├── quote-backend.json
│   └── quote-frontend.json
├── scripts
│   ├── connet-ecs.sh
│   ├── healthcheck.sh
│   └── reset-buildx.sh
├── secrets
├── terraform
│   ├── 000-variables.tf
│   ├── 001-providers.tf
│   ├── 002-vpc.tf
│   ├── 003-igw.tf
│   ├── 004-sg.tf
│   ├── 005-subnets.tf
│   ├── 006-nat.tf
│   ├── 007-rt.tf
│   ├── 008-iam.tf
│   ├── 009-logGroups.tf
│   ├── 010-ecsCluster.tf
│   ├── 011-taskDefinition.tf
│   ├── 012-ecsServices.tf
│   ├── 013-alb.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── terraform.tfvars
└── terraform.tfstate.d
    └── dev

11 directories, 34 files
timursamanchi@Timurs-Air ~/p/ecs-jekyll [fix/lb] (tf:dev) % 
```

## 🛠️ Features

- 🟢 ECS Fargate (no server management)
- 🔄 ALB routing to frontend service
- 🔐 Backend API inside **private subnets**
- 🌐 Frontend app accessible via public ALB
- 📦 Dockerized frontend/backend
- 📖 Logs routed to CloudWatch
- ✅ Health checks + container insights
- 🧭 Service Discovery (optional)
- ⚙️ Fully managed by Terraform

## 🧱 Architecture

```
                      +------------------------+
                      |     AWS ALB (Public)   |
                      |  - Routes / → frontend |
                      +-----------+------------+
                                  |
                                  v
                     +------------+-------------+
                     |   ECS Cluster (Fargate)  |
                     |                          |
                     |  +--------------------+  |
                     |  |   Frontend Task    |  |
                     |  | Nginx / Jekyll     |  |
                     |  +--------------------+  |
                     |             |             |
                     |             v             |
                     |  +--------------------+  |
                     |  |   Backend Task     |  |
                     |  |  Quote API (8080)  |  |
                     |  +--------------------+  |
                     +--------------------------+

```
Network:

    ALB in Public Subnets

    Tasks in Private Subnets

    NAT Gateway for outbound traffic

## 🔒 Security

- ✅ No container publicly exposed
- ✅ Only ALB is in public subnet
- ✅ Backend only accessible by frontend (via security groups)
- ✅ HTTPS-ready architecture (add ACM + cert-manager)

## 📄 How to Deploy

### Prerequisites

- AWS CLI configured
- Terraform installed
- Docker + ECR access

### ✅ Step 1: Clone & Build Containers

```bash
cd docker/backend
docker build -t quote-backend .
docker tag quote-backend:latest <your-ecr>/quote-backend:v1
docker push <your-ecr>/quote-backend:v1

cd ../frontend
docker build -t quote-frontend .
docker tag quote-frontend:latest <your-ecr>/quote-frontend:v1
docker push <your-ecr>/quote-frontend:v1
```
### ✅ Step 2: Deploy with Terraform

 Outputs:

    ALB DNS URL

    Logs in CloudWatch

    Services in ECS Console


### ⚡ Troubleshooting
| Problem                            | Fix                                                                 |
| ---------------------------------- | ------------------------------------------------------------------- |
| Backend container keeps restarting | Check logs in `/ecs/quote-backend` (likely networking or DNS issue) |
| ALB returns 502                    | Backend service might be unhealthy or security group misconfigured  |
| Quote not showing in frontend      | Ensure `proxy_pass` and backend hostname is correct                 |
| Port 8080 exposed?                 | No — backend is private, only frontend and ALB use port 80          |


## 🙌 Credits

Built by Timur Samanchi
Guided and debugged live via ChatGPT
Inspired by real-world cloud production architectures.
