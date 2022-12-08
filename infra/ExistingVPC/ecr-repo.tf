resource "aws_ecr_repository" "k8s_quickstart_angular" {
  name                 = "k8s-quickstart-angular"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "k8s_quickstart_react" {
  name                 = "k8s-quickstart-react"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}