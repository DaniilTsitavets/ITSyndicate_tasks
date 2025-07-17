[ungrouped]
jumpbox ansible_host=127.0.0.1 ansible_connection=local

[control_plane]
server ansible_host=${control_plane.private_ip} ansible_user=ubuntu

[worker_nodes]
%{ for node in workers ~}
${node.name} ansible_host=${node.private_ip} ansible_user=ubuntu
%{ endfor }