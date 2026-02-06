#!/bin/bash

# create-stage-branches.sh
# Creates stage1 and stage2 branches for all student repos
# stage1: Last commit before 2/4 11:59 PM Pacific
# stage2: Current HEAD (for Stage 2 development)

set -e

ORG="e3python"
TEMPLATE_REPOS=(
    "e3-web-design-mod2-fan-page-fan-page"
    "e3-web-design-mod3-fan-page-fan-page"
    "e3-web-design-mod5-fan-page-fan-page"
)

# Cutoff time: 2026-02-04 23:59:59 Pacific (-08:00 = -0800)
CUTOFF="2026-02-05 07:59:59 UTC"  # 2/4 11:59 PM Pacific in UTC

WORK_DIR="/tmp/stage-branch-creation-$$"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "🔄 Creating stage1 and stage2 branches for all forks..."
echo "Stage 1 cutoff: $CUTOFF"
echo ""

for TEMPLATE_REPO in "${TEMPLATE_REPOS[@]}"; do
    echo "📦 Processing forks of $TEMPLATE_REPO..."
    
    # Get all forks
    FORKS=$(curl -s "https://api.github.com/repos/$ORG/$TEMPLATE_REPO/forks?per_page=100" | grep '"full_name"' | sed 's/.*"\([^"]*\)".*/\1/')
    
    for FORK in $FORKS; do
        REPO_NAME=$(echo "$FORK" | cut -d'/' -f2)
        
        echo "  ✓ $REPO_NAME"
        
        # Clone the repo
        git clone --quiet "https://github.com/$FORK.git" "$REPO_NAME" 2>/dev/null || true
        
        if [ ! -d "$REPO_NAME" ]; then
            echo "    ⚠️ Failed to clone $FORK"
            continue
        fi
        
        cd "$REPO_NAME"
        
        # Find last commit before cutoff
        STAGE1_COMMIT=$(git log --until="$CUTOFF" --format="%H" | head -1)
        
        if [ -z "$STAGE1_COMMIT" ]; then
            echo "    ⚠️ No commits before cutoff for $REPO_NAME"
            cd "$WORK_DIR"
            continue
        fi
        
        # Create stage1 branch from cutoff commit
        git branch stage1 "$STAGE1_COMMIT" 2>/dev/null || git branch -f stage1 "$STAGE1_COMMIT"
        
        # Create stage2 branch from current HEAD
        git branch stage2 HEAD 2>/dev/null || git branch -f stage2 HEAD
        
        # Push both branches
        git push -u origin stage1 2>/dev/null || git push -u origin stage1
        git push -u origin stage2 2>/dev/null || git push -u origin stage2
        
        echo "    ✅ Branches created (stage1: ${STAGE1_COMMIT:0:7}, stage2: current)"
        
        cd "$WORK_DIR"
    done
    
    echo ""
done

# Cleanup
cd /
rm -rf "$WORK_DIR"

echo "✨ Done! All student repos now have stage1 and stage2 branches."
echo "   stage1 = Last submission before 2/4 11:59 PM Pacific"
echo "   stage2 = Current HEAD for Stage 2 development"
