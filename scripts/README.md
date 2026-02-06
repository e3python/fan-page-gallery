# Grading Automation Scripts

These scripts automate the creation of stage branches and triggering of graders across all student repositories.

## Setup

### 1. GitHub Personal Access Token

Create a Personal Access Token with `repo` scope:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token"
3. Select scope: `repo` (full control of private repositories)
4. Copy the token

Set it in your shell:
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Scripts

### create-stage-branches.sh

Creates `stage1` and `stage2` branches for all student repositories.

- **stage1**: Last commit before 2/4 23:59 PM Pacific (final Stage 1 submission)
- **stage2**: Current HEAD (for Stage 2 development)

**Usage:**
```bash
./scripts/create-stage-branches.sh
```

**What it does:**
- Fetches all forks from mod2, mod3, and mod5 template repos
- For each student repo:
  - Clones the repository
  - Identifies the last commit before the cutoff time
  - Creates `stage1` branch from that commit
  - Creates `stage2` branch from current HEAD
  - Pushes both branches to GitHub

**Time:** ~5-10 minutes for all students

---

### trigger-grader.sh

Triggers Stage 1 or Stage 2 grader via GitHub Actions for specified repositories.

**Usage:**

```bash
# Trigger Stage 1 for all students
./scripts/trigger-grader.sh --stage 1 --repos all

# Trigger Stage 2 for all students
./scripts/trigger-grader.sh --stage 2 --repos all

# Trigger for exemplar only
./scripts/trigger-grader.sh --stage 2 --repos exemplar

# Trigger for specific repos
./scripts/trigger-grader.sh --stage 1 --repos "fan-page-student1 fan-page-student2"
```

**Options:**
- `--stage`: `1` or `2` (required)
- `--repos`: `all`, `exemplar`, or space-separated repo names (required)
- `--token`: GitHub token (optional, uses GITHUB_TOKEN env var)

**What it does:**
- Verifies the branch exists in each repository
- Triggers the GitHub Actions workflow via API
- Reports success/failure for each repo

**Time:** ~10-30 seconds (API calls)

---

## Typical Workflow

### Before Stage 1 Final Grading

1. Verify Stage 1 work is complete (students have submitted)
2. Create branches:
   ```bash
   ./scripts/create-stage-branches.sh
   ```
3. Trigger Stage 1 grading:
   ```bash
   ./scripts/trigger-grader.sh --stage 1 --repos all
   ```
4. Review results in GitHub Actions → Stage 1 Grader

### Before Stage 2 Development

1. Announce Stage 2 work begins (students can now update `stage2` branch)
2. When ready, trigger Stage 2 grading:
   ```bash
   ./scripts/trigger-grader.sh --stage 2 --repos all
   ```

### If Grading Criteria Change

1. Update the grader script (e.g., `grade2.js`)
2. Push changes to exemplar repo
3. Re-trigger grading without recreating branches:
   ```bash
   ./scripts/trigger-grader.sh --stage 2 --repos all
   ```

### To Regrade a Single Student

```bash
./scripts/trigger-grader.sh --stage 1 --repos fan-page-studentname
```

---

## Troubleshooting

### "No commits before cutoff"
- Some repos may have no activity before the deadline
- The script will warn but continue
- You may need to manually set the branch in those cases

### "Branch not found"
- Verify the branch was created successfully
- Check GitHub manually: `https://github.com/e3python/REPO_NAME/branches`

### "Workflow failed to trigger"
- Verify `GITHUB_TOKEN` is set: `echo $GITHUB_TOKEN`
- Check token has `repo` scope
- Verify workflow file exists in that branch

### API Rate Limiting
- GitHub allows 5,000 API calls per hour
- These scripts should not exceed that limit
- If you hit limits, wait an hour and retry

---

## Notes

- Branches are created with full history intact
- Graders run automatically on push to `stage1` or `stage2` branches
- Results appear in GitHub Actions tab under the workflow name
- Each repo gets feedback via PR comment (if a PR exists) or grading-feedback.md file
