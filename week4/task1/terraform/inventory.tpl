[app]
%{ for id in app_ids ~}
${id}
%{ endfor ~}

[app:vars]
ansible_connection=aws_ssm
ansible_python_interpreter=/usr/bin/python3
ansible_ssm_region=${region}
ansible_user=ssm-user
ansible_aws_ssm_bucket_name=backend-58490149

[db]
%{ for id in db_ids ~}
${id}
%{ endfor ~}

[db:vars]
ansible_connection=aws_ssm
ansible_python_interpreter=/usr/bin/python3
ansible_ssm_region=${region}
ansible_user=ssm-user
ansible_aws_ssm_bucket_name=backend-58490149
