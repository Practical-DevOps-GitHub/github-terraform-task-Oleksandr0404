provider "github" {
  token = var.github_token  
}

resource "github_repository" "my_repo" {
  name        = "github-terraform-task-Oleksandr0404"  
  description = "A repository for managing pull requests." 
  private     = true
}

resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.my_repo.name
  username   = "softservedata"  
  permission = "push"             
}

resource "github_branch" "develop" {
  repository = github_repository.my_repo.name
  branch     = "develop"          
}

resource "github_branch_default" "default_branch" {
  repository = github_repository.my_repo.name
  branch     = github_branch.develop.branch 
}

resource "github_branch_protection" "main" {
  repository = github_repository.my_repo.name
  branch     = "main"

  required_pull_request_reviews {
    dismissal_restrictions {
      users = ["softservedata"]   
    }
    required_approving_review_count = 1
  }

  enforce_admins           = true
  required_status_checks {
    strict = true
    contexts = []
  }
}

resource "github_branch_protection" "develop" {
  repository = github_repository.my_repo.name
  branch     = github_branch.develop.branch 

  required_pull_request_reviews {
    required_approving_review_count = 2
  }

  enforce_admins           = true
  required_status_checks {
    strict = true
    contexts = []
  }
}

resource "github_codeowners" "main_codeowners" {
  repository = github_repository.my_repo.name
  path       = "/*"
  owners     = ["softservedata"]   
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.my_repo.name
  file       = ".github/pull_request_template.md"
  content    = <<EOF
Describe your changes
Issue ticket number and link

Checklist before requesting a review:
- I have performed a self-review of my code
- If it is a core feature, I have added thorough tests
- Do we need to implement analytics?
- Will this be part of a product update? If yes, please write one phrase about this update
EOF
}

resource "github_deploy_key" "deploy_key" {
  repository = github_repository.my_repo.name
  title      = "DEPLOY_KEY"       
  key        = var.deploy_key      
  read_only  = true
}

resource "github_actions_secret" "pat" {
  repository = github_repository.my_repo.name
  secret_name = "PAT"             
  plaintext_value = var.pat         
}


resource "null_resource" "discord_webhook" {
  provisioner "local-exec" {
    command = "curl -X POST -H 'Content-Type: application/json' -d '{\"content\": \"Pull request created in ${github_repository.my_repo.name}\"}' https://discord.com/api/webhooks/1286948244949172234/gCcuL55shG48zsQycoJwmBUAS-YBYWSO876mZrLjuT5ibJEJs90lJwmLtap8CCNvHOQx/github"
  }
}

variable "github_token" { type = string }
variable "deploy_key" { type = string }
variable "pat" { type = string }
