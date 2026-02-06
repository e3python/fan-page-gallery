#!/bin/bash

# trigger-grader.sh
# Triggers Stage 1 or Stage 2 grader via GitHub Actions API
# Usage:
#   ./trigger-grader.sh --stage 1 --repos all
#   ./trigger-grader.sh --stage 2 --repos exemplar
#   ./trigger-grader.sh --stage 1 --repos "fan-page-student1 fan-page-student2"

set -e

# Parse arguments
STAGE=""
REPOS=""
TOKEN="${GITHUB_TOKEN}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --stage)
            STAGE="$2"
            shift 2
            ;;
        --repos)
            REPOS="$2"
            shift 2
            ;;
        --token)
            TOKEN="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$STAGE" ]; then
    echo "❌ Error: --stage argument required (1 or 2)"
    exit 1
fi

if [ -z "$REPOS" ]; then
    echo "❌ Error: --repos argument required (all, exemplar, or space-separated list)"
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable not set"
    echo "   Set it with: export GITHUB_TOKEN='your-token'"
    exit 1
fi

ORG="e3python"
BRANCH_NAME="stage$STAGE"
WORKFLOW_NAME="stage$STAGE.yml"

# Determine which repos to process
if [ "$REPOS" = "all" ]; then
    # Get all student repos from all templates
    TEMPLATE_REPOS=(
        "e3-web-design-mod2-fan-page-fan-page"
        "e3-web-design-mod3-fan-page-fan-page"
        "e3-web-design-mod5-fan-page-fan-page"
    )
    
    REPO_LIST=""
    for TEMPLATE_REPO in "${TEMPLATE_REPOS[@]}"; do
        FORKS=$(curl -s "https://api.github.com/repos/$ORG/$TEMPLATE_REPO/forks?per_page=100" | grep '"full_name"' | sed 's/.*"\([^"]*\)".*/\1/')
        for FORK in $FORKS; do
            REPO_NAME=$(echo "$FORK" | cut -d'/' -f2)
            REPO_LIST="$REPO_LIST $REPO_NAME"
        done
    done
elif [ "$REPOS" = "exemplar" ]; then
    REPO_LIST="fan-page-e3-cerruti"
else
    REPO_LIST="$REPOS"
fi

echo "🚀 Triggering Stage $STAGE Grader"
echo "   Workflow: $WORKFLOW_NAME"
echo "   Branch: $BRANCH_NAME"
echo ""

SUCCESS=0
FAILED=0

for REPO_NAME in $REPO_LIST; do
    REPO="$ORG/$REPO_NAME"
    
    # Verify branch exists
    BRANCH_EXISTS=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/branches/$BRANCH_NAME" | grep '"name"')
    
    if [ -z "$BRANCH_EXISTS" ]; then
        echo "⚠️  $REPO_NAME: Branch '$BRANCH_NAME' not found"
        FAILED=$((FAILED + 1))
        continue
    fi
    
    # Trigger workflow
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_NAME/dispatches" \
        -d "{\"ref\":\"$BRANCH_NAME\"}")
    
    if echo "$RESPONSE" | grep -q "error"; then
        echo "❌ $REPO_NAME: Failed"
        FAILED=$((FAILED + 1))
    else
        echo "✅ $REPO_NAME: Workflow triggered"
        SUCCESS=$((SUCCESS + 1))
    fi
done

echo ""
echo "📊 Summary:"
echo "   ✅ Triggered: $SUCCESS"
echo "   ❌ Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
