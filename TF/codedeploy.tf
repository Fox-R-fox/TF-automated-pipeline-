# AWS CodeDeploy Application
resource "aws_codedeploy_app" "webapp" {
  name = "WebApp"
}

# Deployment Group for QA Environment
resource "aws_codedeploy_deployment_group" "webapp_qa" {
  app_name              = aws_codedeploy_app.webapp.name
  deployment_group_name = "WebApp-Deployment-QA"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "fox"
      type  = "KEY_AND_VALUE"
      value = "QA-EC2-Instance"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# Deployment Group for Live Environment
resource "aws_codedeploy_deployment_group" "webapp_live" {
  app_name              = aws_codedeploy_app.webapp.name
  deployment_group_name = "WebApp-Deployment-Live"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "fox"
      type  = "KEY_AND_VALUE"
      value = "Live-EC2-Instance"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
