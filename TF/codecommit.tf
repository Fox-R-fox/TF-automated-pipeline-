# AWS CodeCommit Repository
resource "aws_codecommit_repository" "webapp_repo" {
  repository_name = "WebAppRepo"

  description = "Repository for WebApp Code"
}
