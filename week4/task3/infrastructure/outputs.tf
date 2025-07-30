output "ansible_inventory_data" {
  value = {
    bastion = module.bastion.public_ip
    web     = module.web.private_ip
    db      = module.db.private_ip
  }
}

output "alb_dns" {
  value = module.alb.dns_name
}