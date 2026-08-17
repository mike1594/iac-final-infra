# Configuracion compartida de scripts (NO versionar secretos aqui)
$script:SubscriptionId = "b497fd69-266c-46a9-b55b-8be0cd579667"
$script:TenantId       = "20f4acc9-f9f2-4ee9-b614-bc33742ece36"
$script:Location       = "East US 2"
$script:Environment    = "dev"
$script:Prefix         = "iac-final"
$script:Suffix         = "001"

# Storage remoto del estado de Terraform
$script:StateRG          = "rg-iac-final-state-eastus2-001"
$script:StateStorageAcct = "stiacfinaltfstate001"
$script:StateContainer   = "tfstate"
$script:StateKey         = "iac-final-app.terraform.tfstate"

# Imagen Docker
$script:DockerUser = "jmeza17"
$script:ImageName  = "jmeza17/iac-final-app"

# Secretos: se toman de variables de entorno, nunca de archivos versionados
$script:SecretValue = $env:TF_VAR_secret_value