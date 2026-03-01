#!/usr/bin/env bash
#MISE description="Create a new workspace"
#MISE dir="{{cwd}}"

set -e

if [ ! -d "templates" ]; then
  gum log --level error "No templates directory found in the current directory."
  exit 1
fi

# Get gh token and append to .env
WS_GH_TOKEN=$(gh auth token 2>/dev/null)

if [ ! -n "$WS_GH_TOKEN" ]; then
  gum log --level error "GitHub token is required for cloning the repository. Please run 'gh auth login' to authenticate with GitHub CLI."
  exit 1
fi

# Prompt for project, branch, and subdomain
project_templates=$(ls -d templates/*/ | xargs -n 1 basename)

export WS_PROJECT_ID=$(gum choose $project_templates --header "Select the project template to use")

if [[ -z "$WS_PROJECT_ID" ]]; then
  gum log --level error "Project template selection is required."
  exit 1
fi

export WS_SOURCE_BRANCH=$(gum input --placeholder "The source branch or tag to use" --value "" --header "Source Branch/Tag - Blank for default")
export WS_WORK_BRANCH=$(gum input --placeholder "The name of the new branch to create" --header "New Branch Name")
if [[ -z "$WS_WORK_BRANCH" ]]; then
  gum log --level error "Branch name is required."
  exit 1
fi

export WS_SUBDOMAIN=$(gum input --placeholder "The sub-domain to use for the new dev container" --header "Subdomain" --value "$(echo "$WS_WORK_BRANCH" | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)")
if [[ -z "$WS_SUBDOMAIN" ]]; then
  gum log --level error "Subdomain is required."
  exit 1
fi

export WS_WORKSPACE_ID="${WS_PROJECT_ID}-${WS_SUBDOMAIN}"

TEMPLATE_PATH="${PWD}/templates/${WS_PROJECT_ID}"
if [ ! -d "$TEMPLATE_PATH" ]; then
  gum log --level error "Template not found: ${TEMPLATE_PATH}"
  exit 1
fi

WORKSPACE_PATH="${PWD}/workspaces/${WS_WORKSPACE_ID}"
if [ -d "$WORKSPACE_PATH" ]; then
  gum log --level error "Workspace already exists: ${WORKSPACE_PATH}"
  exit 1
fi

mkdir -p "$WORKSPACE_PATH"

# Create the vars.yaml file with the necessary variables for templates
cat >"$WORKSPACE_PATH/vars.yaml" <<EOL
project_id: ${WS_PROJECT_ID}
workspace_id: ${WS_WORKSPACE_ID}
gh_token: ${WS_GH_TOKEN}
source_branch: ${WS_SOURCE_BRANCH}
work_branch: ${WS_WORK_BRANCH}
subdomain: ${WS_SUBDOMAIN}
EOL

gomplate \
  -c .="$WORKSPACE_PATH/vars.yaml" \
  --input-dir="$TEMPLATE_PATH" \
  --output-dir="$WORKSPACE_PATH/.devcontainer"

gum log --level info "Workspace created successfully at ${WORKSPACE_PATH}"
gum log --level info "Run 'mr ws:open' to open the workspace in PhpStorm."
