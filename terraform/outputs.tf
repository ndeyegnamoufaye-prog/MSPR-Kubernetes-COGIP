# IP publique poste de travail
output "poste_travail_ip" {
  description = "IP publique du poste de travail"
  value       = aws_instance.poste_travail.public_ip
}

# IP publique control-plane
output "control_plane_ip" {
  description = "IP publique du control-plane"
  value       = aws_instance.control_plane.public_ip
}

# IP publique worker 1
output "worker1_ip" {
  description = "IP publique du worker 1"
  value       = aws_instance.worker1.public_ip
}

# IP publique worker 2
output "worker2_ip" {
  description = "IP publique du worker 2"
  value       = aws_instance.worker2.public_ip
}



# Elastic IP
output "elastic_ip" {
  description = "Elastic IP pour l'Ingress Odoo"
  value       = aws_eip.mspr_eip.public_ip
}

# Commandes SSH
output "ssh_poste_travail" {
  description = "Commande SSH poste de travail"
  value       = "ssh -i mspr-key.pem ubuntu@${aws_instance.poste_travail.public_ip}"
}

output "ssh_control_plane" {
  description = "Commande SSH control-plane"
  value       = "ssh -i mspr-key.pem ubuntu@${aws_instance.control_plane.public_ip}"
}