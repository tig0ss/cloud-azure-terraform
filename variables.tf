# Neste arquivo constam as váriáveis que serão utilizadas no arquivo main e arquivo output
# O arquivo facilita o compartilhamento entre outras infraestruturas e versionamento 
variable "location" { 
    type    = "string"
    default = "eastus"
}

variable "prefix" {
    type      = "string"
    default   = "my"
}

variable "tags" {
    type  ="map"
    default   = {
        Environment   = "NAC1-SEMESTRE-II"
        Dept          = "2TDCR"
    }
}

variable "sku" {
    default = {
        westus  = "16.04-LTS"
        eastus  = "18.04-LTS"
    } 
}

variable "os_dist" {
    type    = "string"    
    default = "UbuntuServer"
}

variable "publi" {
    type    = "string"
    default = "Canonical"
}

variable "vm_size" {
    type    = "string"
    default = "Standard_DS1_v2"
}



