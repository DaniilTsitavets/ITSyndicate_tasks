resource "aws_ecr_repository" "task1_ecr" {
  name                 = "itsyndicate/week8"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}