variable "subscription_id" {
  description = "Id de la suscripcion de Azure"
  type        = string
}

variable "tenant_id" {
  description = "Id del tenant de Azure"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
  default     = "East US 2"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "Prefijo para la nomenclatura de recursos"
  type        = string
  default     = "iac-final"
}

variable "suffix" {
  description = "Sufijo numerico de la nomenclatura"
  type        = string
  default     = "001"
}

variable "tags" {
  description = "Etiquetas de los recursos"
  type        = map(string)
  default = {
    Environment = "dev"
    Proyecto    = "Evaluacion Final IaC"
    Aula        = "DMC"
  }
}

variable "image_name" {
  description = "Imagen Docker del microservicio (DockerHub)"
  type        = string
  default     = "jmeza17/iac-final-app"
}

variable "image_tag" {
  description = "Tag de la imagen Docker"
  type        = string
}

variable "secret_name" {
  description = "Nombre del secreto en Key Vault y de la variable APP_SECRET"
  type        = string
  default     = "app-secret"
}

variable "secret_value" {
  description = "Valor del secreto que expone el endpoint /secreto"
  type        = string
  sensitive   = true
}