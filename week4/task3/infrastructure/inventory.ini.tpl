[ungrouped]
bastion ansible_host=127.0.0.1 ansible_connection=local

[web]
web ansible_host=${web} ansible_user=ubuntu

[db]
db ansible_host=${db} ansible_user=ubuntu