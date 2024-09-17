# AWS CodePipeline Setup
resource "aws_codepipeline" "webapp_pipeline" {
  name          = "WebApp-Pipeline"
  role_arn      = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"   # Specify V2 pipeline here

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  # Use parallel execution (specific to V2 pipelines)
  execution_mode = "PARALLEL"  # Or "QUEUED" depending on your requirement

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "mywebapp"   # Reference your existing repository
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.webapp_build.name
      }
    }
  }

  stage {
    name = "DeployQA"

    action {
      name            = "DeployQA"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.webapp.name
        DeploymentGroupName = aws_codedeploy_deployment_group.webapp_qa.deployment_group_name
      }
    }
  }

  stage {
    name = "DeployLive"

    action {
      name            = "DeployLive"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.webapp.name
        DeploymentGroupName = aws_codedeploy_deployment_group.webapp_live.deployment_group_name
      }
    }
  }
}
