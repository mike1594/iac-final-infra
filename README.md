# Infraestructura como Código - Evaluación Final IaC

Terraform que despliega un microservicio en **Azure Container Apps** con secretos desde **Azure Key Vault** y estado remoto en **Azure Storage**.

## Recursos creados

| Recurso | Nombre |
|---|---|
| Resource Group | `rg-iac-final-dev-eastus2-001` |
| Log Analytics Workspace | `law-iac-final-dev-eastus2-001` |
| Container App Environment | `cae-iac-final-dev-eastus2-001` |
| Container App | `ca-iac-final-app-dev-eastus2-001` |
| User Assigned Identity | `id-iac-final-app-dev-eastus2-001` |
| Key Vault | `kv-iac-final-dev-001` |
| Key Vault Secret | `app-secret` |
| Storage Account (estado remoto) | `stiacfinaltfstate001` |

## Estructura

```
infraestructura/
├── provider.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── scripts/
│   ├── config.ps1
│   ├── bootstrap-state.ps1
│   └── deploy.ps1
└── docs/
    └── cicd-diagram.md
```

## Prerequisitos

- Azure CLI autenticado (`az login`)
- Terraform >= 1.5
- Docker y login en DockerHub (`docker login`)
- Variable de entorno con el secreto:
  ```powershell
  $env:TF_VAR_secret_value = "<tu-secreto>"
  ```

## Paso a paso

### 1. Crear el storage del estado

```powershell
.\scripts\bootstrap-state.ps1
```

### 2. Inicializar Terraform con backend remoto

```powershell
terraform init `
  -backend-config="resource_group_name=rg-iac-final-state-eastus2-001" `
  -backend-config="storage_account_name=stiacfinaltfstate001" `
  -backend-config="container_name=tfstate" `
  -backend-config="key=iac-final-app.terraform.tfstate"
```

### 3. Aplicar

```powershell
$env:TF_VAR_subscription_id = "<subscription-id>"
$env:TF_VAR_tenant_id       = "<tenant-id>"
$env:TF_VAR_secret_value    = "<tu-secreto>"
terraform plan
terraform apply
```

### 4. Verificar

```powershell
$url = terraform output -raw container_app_url
curl "$url/hello"
curl "$url/secreto"
```

## Script de despliegue (flujo Docker completo)

```powershell
$env:TF_VAR_secret_value = "<tu-secreto>"
.\scripts\deploy.ps1
```

Genera la version automaticamente (`1.0.<fecha>-<sha>`), hace build, login, push a DockerHub y `terraform apply`.

## Seguridad

- El `secret_value` **nunca se versiona**: se pasa por `TF_VAR_secret_value`.
- `.tfstate` se guarda en Azure Storage privado (no se sube a git).
- `terraform.tfvars` esta ignorado; usar `terraform.tfvars.example` como plantilla.

## Destruir

```powershell
terraform destroy
```