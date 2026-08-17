# Bootstrap del storage remoto para el estado de Terraform.
# Crea el resource group y la storage account privada donde se guarda el .tfstate.
param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

# Cargar configuracion
. "$PSScriptRoot\config.ps1"

function Invoke-AzCmd {
    param([string]$Command)
    if ($WhatIf) {
        Write-Host "[DRY-RUN] $Command" -ForegroundColor Yellow
    }
    else {
        Write-Host "> $Command" -ForegroundColor Cyan
        Invoke-Expression $Command
        if ($LASTEXITCODE -ne 0) { throw "Fallo el comando az: $Command" }
    }
}

Write-Host "== Bootstrap del backend de estado ==" -ForegroundColor Green
Invoke-AzCmd "az account set --subscription `"$SubscriptionId`""

Invoke-AzCmd "az group create --name `"$StateRG`" --location `"$Location`""

Invoke-AzCmd "az storage account create --name `"$StateStorageAcct`" --resource-group `"$StateRG`" --location `"$Location`" --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false --min-tls-version TLS1_2"

Invoke-AzCmd "az storage container create --name `"$StateContainer`" --account-name `"$StateStorageAcct`" --auth-mode login"

Write-Host "== Backend listo. Storage: $StateStorageAcct/$StateContainer ==" -ForegroundColor Green
Write-Host "Inicializar con: terraform init -backend-config=`"resource_group_name=$StateRG`" -backend-config=`"storage_account_name=$StateStorageAcct`" -backend-config=`"container_name=$StateContainer`" -backend-config=`"key=$StateKey`""