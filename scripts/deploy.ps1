# Script de despliegue opcional (requisito 6 del enunciado).
# Flujo: toma el codigo -> genera una nueva version de la imagen -> pushea la
# imagen a DockerHub -> despliega la nueva version en el Azure Container App.
param(
    [switch]$SkipTerraform,
    [switch]$NoAutoApprove
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\config.ps1"

$InfraRoot = Resolve-Path "$PSScriptRoot\.."
$AppRoot   = Resolve-Path "$InfraRoot\..\codigo-fuente"

# 1. Generar version automatica
$DateStamp  = Get-Date -Format "yyyyMMddHHmm"
$ShortSha   = (git -C $AppRoot rev-parse --short HEAD 2>$null)
if (-not $ShortSha) { $ShortSha = "local" }
$Version    = "1.0.$DateStamp-$ShortSha"
Write-Host "== Version generada: $Version ==" -ForegroundColor Green

# 2. Validar que exista el valor del secreto
if ([string]::IsNullOrWhiteSpace($SecretValue)) {
    throw "Falta el secreto. Ejecutar: `$env:TF_VAR_secret_value='<valor>' antes de correr este script (no se versiona)."
}

# 3. Build + push de la imagen
Push-Location $AppRoot
try {
    Write-Host "== Docker build ==" -ForegroundColor Green
    docker build --platform linux/amd64 -t "$ImageName`:$Version" .
    if ($LASTEXITCODE -ne 0) { throw "Fallo el docker build" }

    Write-Host "== Docker login DockerHub ==" -ForegroundColor Green
    docker login
    if ($LASTEXITCODE -ne 0) { throw "Fallo el docker login (credenciales DockerHub invalidas). Detengo el proceso." }

    Write-Host "== Docker push ==" -ForegroundColor Green
    docker push "$ImageName`:$Version"
    if ($LASTEXITCODE -ne 0) { throw "Fallo el docker push" }
}
finally {
    Pop-Location
}

# 4. Terraform deploy
if (-not $SkipTerraform) {
    Push-Location $InfraRoot
    try {
        $Approval = @()
        if (-not $NoAutoApprove) { $Approval = @("-auto-approve") }

        Write-Host "== Terraform init ==" -ForegroundColor Green
        terraform init -reconfigure -backend-config="resource_group_name=$StateRG" -backend-config="storage_account_name=$StateStorageAcct" -backend-config="container_name=$StateContainer" -backend-config="key=$StateKey"
        if ($LASTEXITCODE -ne 0) { throw "Fallo el terraform init" }

        Write-Host "== Terraform apply ==" -ForegroundColor Green
        $env:TF_VAR_subscription_id = $SubscriptionId
        $env:TF_VAR_tenant_id       = $TenantId
        $env:TF_VAR_location        = $Location
        $env:TF_VAR_environment     = $Environment
        $env:TF_VAR_prefix          = $Prefix
        $env:TF_VAR_suffix          = $Suffix
        $env:TF_VAR_image_tag       = $Version
        $env:TF_VAR_secret_value    = $SecretValue

        terraform apply @Approval
        if ($LASTEXITCODE -ne 0) { throw "Fallo el terraform apply" }

        Write-Host "== Outputs ==" -ForegroundColor Green
        terraform output
    }
    finally {
        Pop-Location
    }
}

Write-Host "== Despliegue completado. Version: $Version ==" -ForegroundColor Green
