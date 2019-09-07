# Apresenta variáveis de saída facilitando a consulta de alguns dados considerados 
# importantes para o usuário do terraform
output "ip" {
  value = "${azurerm_public_ip.publicip.ip_address}"
}

output "os_sku" {
  value = "${lookup(var.sku, var.location)}"
}

output "os_dist" {
  value = ["${var.os_dist}", "${var.publi}"]
}

output "vm_size" {
  value = "${var.vm_size}"
}

output "location" {
  value = "${var.location}"
}



