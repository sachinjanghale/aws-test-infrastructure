# Git Commands Reference

Quick reference for common Git operations for this project.

## 📦 Initial Setup (Already Done!)

```bash
# Initialize repository
git init

# Add remote
git remote add origin https://github.com/sachinjanghale/aws-test-infrastructure.git

# First push
git push -u origin main
```

## 🔄 Daily Workflow

### Making Changes

```bash
# Check status
git status

# Add all changes
git add .

# Or add specific files
git add README.md modules/compute/main.tf

# Commit with message
git commit -m "Add: New feature description"

# Push to GitHub
git push origin main
```

### Commit Message Conventions

Use these prefixes:
- `Add:` - New features or resources
- `Fix:` - Bug fixes
- `Update:` - Modify existing features
- `Docs:` - Documentation changes
- `Refactor:` - Code restructuring
- `Test:` - Add or update tests
- `Chore:` - Maintenance tasks

Examples:
```bash
git commit -m "Add: Support for AWS Backup service"
git commit -m "Fix: S3 bucket lifecycle policy syntax error"
git commit -m "Update: Increase Lambda memory to 256MB"
git commit -m "Docs: Add troubleshooting guide for VPC errors"
```

## 🌿 Branch Management

### Create Feature Branch

```bash
# Create and switch to new branch
git checkout -b feature/add-eks-support

# Or create branch without switching
git branch feature/add-eks-support
```

### Work on Branch

```bash
# Make changes
git add .
git commit -m "Add: EKS cluster module"

# Push branch to GitHub
git push origin feature/add-eks-support
```

### Merge Branch

```bash
# Switch to main
git checkout main

# Pull latest changes
git pull origin main

# Merge feature branch
git merge feature/add-eks-support

# Push to GitHub
git push origin main

# Delete local branch
git branch -d feature/add-eks-support

# Delete remote branch
git push origin --delete feature/add-eks-support
```

## 🏷️ Tagging and Releases

### Create Tag

```bash
# Create annotated tag
git tag -a v1.1.0 -m "Release version 1.1.0"

# Push tag to GitHub
git push origin v1.1.0

# Push all tags
git push origin --tags
```

### List Tags

```bash
# List all tags
git tag

# List tags with messages
git tag -n
```

### Delete Tag

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

## 🔍 Viewing History

### View Commits

```bash
# View commit history
git log

# View compact history
git log --oneline

# View last 5 commits
git log -5

# View commits with changes
git log -p

# View commits for specific file
git log -- README.md
```

### View Changes

```bash
# View unstaged changes
git diff

# View staged changes
git diff --staged

# View changes in specific file
git diff README.md

# View changes between branches
git diff main feature/new-feature
```

## ↩️ Undoing Changes

### Unstage Files

```bash
# Unstage all files
git reset

# Unstage specific file
git reset README.md
```

### Discard Changes

```bash
# Discard changes in working directory
git checkout -- README.md

# Discard all changes
git checkout -- .
```

### Undo Last Commit

```bash
# Undo commit but keep changes
git reset --soft HEAD~1

# Undo commit and discard changes
git reset --hard HEAD~1
```

### Revert Commit

```bash
# Create new commit that undoes changes
git revert <commit-hash>
```

## 🔄 Syncing with GitHub

### Pull Latest Changes

```bash
# Pull from main branch
git pull origin main

# Pull with rebase
git pull --rebase origin main
```

### Fetch Changes

```bash
# Fetch all branches
git fetch origin

# Fetch specific branch
git fetch origin main
```

### Push Changes

```bash
# Push to main
git push origin main

# Force push (use carefully!)
git push --force origin main

# Push all branches
git push --all origin
```

## 🔧 Configuration

### View Configuration

```bash
# View all config
git config --list

# View specific config
git config user.name
git config user.email
```

### Set Configuration

```bash
# Set user name
git config --global user.name "Sachin Janghale"

# Set user email
git config --global user.email "your.email@example.com"

# Set default editor
git config --global core.editor "nano"
```

## 🚨 Emergency Commands

### Stash Changes

```bash
# Stash current changes
git stash

# Stash with message
git stash save "Work in progress on feature X"

# List stashes
git stash list

# Apply latest stash
git stash apply

# Apply specific stash
git stash apply stash@{0}

# Apply and remove stash
git stash pop

# Delete stash
git stash drop stash@{0}
```

### Clean Untracked Files

```bash
# Preview what will be deleted
git clean -n

# Delete untracked files
git clean -f

# Delete untracked files and directories
git clean -fd
```

## 🔍 Troubleshooting

### Fix "Permission Denied"

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add SSH key
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings → SSH Keys
```

### Fix "Repository Not Found"

```bash
# Check remote URL
git remote -v

# Update remote URL (HTTPS)
git remote set-url origin https://github.com/sachinjanghale/aws-test-infrastructure.git

# Update remote URL (SSH)
git remote set-url origin git@github.com:sachinjanghale/aws-test-infrastructure.git
```

### Fix Merge Conflicts

```bash
# View conflicted files
git status

# Edit files to resolve conflicts
# Look for <<<<<<< HEAD markers

# After resolving, add files
git add .

# Complete merge
git commit -m "Merge: Resolve conflicts"
```

### Fix Detached HEAD

```bash
# Create branch from current state
git checkout -b temp-branch

# Switch to main
git checkout main

# Merge if needed
git merge temp-branch
```

## 📊 Useful Aliases

Add to `~/.gitconfig`:

```ini
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = log --oneline --graph --decorate --all
    amend = commit --amend --no-edit
```

Usage:
```bash
git st          # git status
git co main     # git checkout main
git br          # git branch
git ci -m "msg" # git commit -m "msg"
git visual      # pretty log
```

## 🎯 Project-Specific Workflows

### Update Documentation

```bash
git checkout -b docs/update-readme
# Edit documentation
git add README.md
git commit -m "Docs: Update installation instructions"
git push origin docs/update-readme
# Create PR on GitHub
```

### Add New AWS Service

```bash
git checkout -b feature/add-backup-service
# Create module
git add modules/backup/
git commit -m "Add: AWS Backup service module"
# Update documentation
git add README.md CHANGELOG.md
git commit -m "Docs: Add Backup service documentation"
git push origin feature/add-backup-service
# Create PR on GitHub
```

### Fix Bug

```bash
git checkout -b fix/s3-lifecycle-policy
# Fix the bug
git add modules/storage/main.tf
git commit -m "Fix: S3 lifecycle policy syntax error"
git push origin fix/s3-lifecycle-policy
# Create PR on GitHub
```

### Release New Version

```bash
# Update CHANGELOG.md
git add CHANGELOG.md
git commit -m "Docs: Update changelog for v1.1.0"

# Create tag
git tag -a v1.1.0 -m "Release v1.1.0"

# Push changes and tag
git push origin main
git push origin v1.1.0

# Create release on GitHub
gh release create v1.1.0 --title "v1.1.0" --notes "See CHANGELOG.md"
```

## 📚 Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Oh Shit, Git!?!](https://ohshitgit.com/)

## 🆘 Need Help?

```bash
# Get help for any command
git help <command>
git help commit
git help branch

# Quick help
git <command> --help
git commit --help
```

---

**Your Repository**: https://github.com/sachinjanghale/aws-test-infrastructure
