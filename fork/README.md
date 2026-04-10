# MyTodoList

Full-stack Todo app built for Oracle Cloud Infrastructure (OCI). Spring Boot backend + React frontend + Oracle ATP database, deployed on Kubernetes.

## Project Structure

```
oci_devops/
├── backend/         ← Spring Boot app
├── frontend/        ← React app (embedded into the JAR at build time)
├── infrastructure/  ← Terraform + deployment scripts
└── build_spec.yaml  ← OCI Build Pipeline config
```

---

## Important Files & Where to Run Them

### `oci_devops/backend/`

| File | What it does | How to run |
|------|-------------|------------|
| `build.sh` | Builds the JAR + Docker image, pushes to registry | `cd oci_devops/backend && ./build.sh` |
| `deploy.sh` | Deploys to Kubernetes (`mtdrworkshop` namespace) | `cd oci_devops/backend && ./deploy.sh` |
| `undeploy.sh` | Removes the Kubernetes deployment | `cd oci_devops/backend && ./undeploy.sh` |
| `Dockerfile` | Production image (used by `build.sh`) | Referenced automatically |
| `DockerfileDev` | Development image | `docker build -f DockerfileDev .` |
| `pom.xml` | Maven build — also builds frontend | `cd oci_devops/backend && mvn clean package spring-boot:repackage` |

### `oci_devops/frontend/`

| File | What it does | How to run |
|------|-------------|------------|
| `package.json` | Frontend dependencies and scripts | `cd oci_devops/frontend && npm install` |

```bash
cd oci_devops/frontend
npm start      # dev server on :3000, proxies API to localhost:8080
npm run build  # production build (also triggered automatically by Maven)
```

### `oci_devops/infrastructure/`

| File | What it does | How to run |
|------|-------------|------------|
| `setup.sh` | Provisions all OCI infrastructure | `cd oci_devops/infrastructure && ./setup.sh` |
| `destroy.sh` | Tears down all OCI infrastructure | `cd oci_devops/infrastructure && ./destroy.sh` |
| `env.sh` | Sets environment variables (sourced by other scripts) | `source oci_devops/infrastructure/env.sh` |
| `utils/main-setup.sh` | Full setup orchestration | Run via `setup.sh` |
| `utils/main-destroy.sh` | Full teardown orchestration | Run via `destroy.sh` |
| `utils/db-setup.sh` | Oracle ATP database setup | `cd oci_devops/infrastructure && ./utils/db-setup.sh` |
| `utils/oke-setup.sh` | OKE Kubernetes cluster setup | `cd oci_devops/infrastructure && ./utils/oke-setup.sh` |
| `utils/terraform.sh` | Runs Terraform for OCI infra | `cd oci_devops/infrastructure && ./utils/terraform.sh` |

### `oci_devops/`

| File | What it does |
|------|-------------|
| `build_spec.yaml` | OCI Build Pipeline spec — triggered automatically by OCI DevOps, not run manually |
