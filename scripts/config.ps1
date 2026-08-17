# Configuracion compartida de scripts (NO versionar secretos aqui)
$script:SubscriptionId = "7664be55-774e-45fd-a02c-40627b5a7a58"
$script:TenantId       = "20f4acc9-f9f2-4ee9-b614-bc33742ece36"
$script:Location       = "East US 2"
$script:Environment    = "dev"
$script:Prefix         = "joe-meza-iac"
$script:Suffix         = "001"

# Storage remoto del estado de Terraform
$script:StateRG          = "rg-joe-meza-iac-state-eus2-001"
$script:StateStorageAcct = "stjoemezaiacstate001"
$script:StateContainer   = "tfstate"
$script:StateKey         = "iac-final-app.terraform.tfstate"

# Imagen Docker
$script:DockerUser = "jmeza17"
$script:ImageName  = "jmeza17/iac-final-app"

# Secretos: se toman de variables de entorno, nunca de archivos versionados
$script:SecretValue = $env:TF_VAR_secret_value
