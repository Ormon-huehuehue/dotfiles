#!/usr/bin/env bash
#
# sync-bitbucket-commit.sh — push a mirror commit to a private GitHub repo
# whenever a commit is pushed to Bitbucket, keeping the contribution graph in sync.
#
# Usage: sync-bitbucket-commit.sh <repo_name> <iso_date> <commit_message>

set -euo pipefail

SYNC_DIR="$HOME/.local/share/sync_bitbucket_commits"
REMOTE="git@github.com:Ormon-huehuehue/sync_bitbucket_commits.git"
LOCKFILE="/tmp/sync-bitbucket-commit.lock"
LOG_FILE="sync_log.txt"

repo_name="$1"
commit_date="$2"
commit_msg="$3"

# Acquire a file lock so concurrent pushes don't clobber each other
exec 9>"$LOCKFILE"
flock -w 60 9 || { echo "[sync] could not acquire lock, skipping"; exit 0; }

# Unset any inherited git env vars from the calling repo
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES 2>/dev/null || true

# Ensure a local clone exists
if [ ! -d "$SYNC_DIR/.git" ]; then
    git clone "$REMOTE" "$SYNC_DIR" 2>/dev/null
fi

cd "$SYNC_DIR"

# Pull latest to avoid conflicts
git fetch origin main 2>/dev/null || true
git reset --hard origin/main 2>/dev/null || true

# Format a clean date for the log entry
display_date=$(date -d "$commit_date" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "$commit_date")

# Append entry
echo "$display_date" >> "$LOG_FILE"
echo "$repo_name -> $commit_msg" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

git add "$LOG_FILE"

# Commit with the ORIGINAL timestamp so GitHub's contribution graph
# shows the activity on the correct day
GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" \
    git commit -m "sync: $repo_name - $commit_msg" --quiet

git push origin main --quiet 2>/dev/null

# Release lock
exec 9>&-
