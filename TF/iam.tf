# CodePipeline Role
resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "CodePipelinePermissions"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:*",
            "codecommit:*",
            "codedeploy:*",
            "codebuild:*",
            "iam:PassRole",
            "sts:AssumeRole"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        }
      ]
    })
  }
}

# CodeBuild Role
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "CodeBuildPermissions"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "ecr:*",
            "s3:*",
            "logs:*",
            "cloudwatch:*",
            "codebuild:*",
            "codepipeline:*",
            "codecommit:*"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          "Resource": [
            "arn:aws:secretsmanager:us-east-1:339712721384:secret:docker-us-JYDQoe"
          ]
        }
      ]
    })
  }
}

# CodeDeploy Role
resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the CodeDeploy role
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
