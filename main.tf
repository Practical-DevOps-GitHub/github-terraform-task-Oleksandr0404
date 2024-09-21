provider "github" {
  token = PAT
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
  branch     = "develop"          
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
  branch     = "develop"          

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
  title      = "DEPLOY_KEY"       # Назва ключа для деплою
  key        = var.deploy_key      # Ваш ключ для деплою
  read_only  = true
}

resource "github_actions_secret" "pat" {
  repository = github_repository.my_repo.name
  secret_name = "PAT"              # Назва секрету
  plaintext_value = var.pat         # Ваш Personal Access Token
}

# Замість 'YOUR_DISCORD_WEBHOOK_URL' вставте URL вашого Discord вебхука
resource "null_resource" "discord_webhook" {
  provisioner "local-exec" {
    command = "curl -X POST -H 'Content-Type: application/json' -d '{\"content\": \"Pull request created in ${github_repository.my_repo.name}\"}' YOUR_DISCORD_WEBHOOK_URL"
  }
}

variable "github_token" {PAT}            # Змінна для токена GitHub
variable "deploy_key" {ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD12+tYIiYy7wKTWsIu8fY34nWAX6Jocbahys2vLHqc4FunUwQEzFHbP8Vvc5qQ2AzvdvnEKizWL0MO5cndrwCfvWQPTsSAjVJy7s9aHEWb7rn/PT12L/Q/s4lEo3AYTXI5hZOueZrxIA8mPJHqVFXUNa9qy1vU1AMPaDpBkjBWbovEg4Zv/y3gkOJekOsQA32mBuwAiWRH3WA2RancPBUm3j0iFW0QJbDpcqbe/vYAgrM7GCD14v38BQwvt8YrzFCpT3tijxRIJd0IOduqIoxg6iD7eO/77nxlysZRdbqlqYuLs7JzwaMLuhnlKzaCeknWv1WgZ2Rmk+TNRlRjzzADmcUVsbkEfxR8jbQNaXSoN73sgrU5lYILwtAlJJcm/+Iy/EOUembECka0eLYae/U/b588SfyuKLfVYerOSl11SGiRmGn/wnOrmxV7gGDbFvEx8NtcgtAZCH7CA8zaikF2bMPfnocbjnV8OvA6zWC4SszxEQ0sN2puO0QJLLt+fue25VziCXNlNiA1jMdyOKPEStf7Gw2sGCecEkUhUVrAWoWKKFhW91q9jXQesWljg+8CpDBuUPlLBHp/XUWpjUJEhXFmeeDJGwa/EPWarW8JvURvdoxCDELJmpdQCk3ILVp832L5QJdJc0HZu1YubxZLiB+vN4/VaOsn2KDuI5sNQ== deploy_key}

variable "pat" {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}                      # Змінна для Personal Access Token
