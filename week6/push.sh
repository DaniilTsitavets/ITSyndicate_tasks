#!/bin/bash
REPO_URL=$(aws ecr describe-repositories --repository-names "itsyndicate/week6" --query "repositories[0].repositoryUri" --output text)
aws ecr get-login-password | docker login --username AWS --password-stdin $REPO_URL
docker build -t sample-django .
docker tag sample-django:latest $REPO_URL:latest
docker push $REPO_URL:latest
