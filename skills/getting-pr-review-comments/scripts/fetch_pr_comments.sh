#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <pr-number> [output-file]" >&2
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
fi

PR_NUMBER="$1"
OUTPUT_FILE="${2:-pr_${PR_NUMBER}_all_comments.json}"

if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "PR number must be numeric: $PR_NUMBER" >&2
  exit 1
fi

require_command gh
require_command jq

REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

GENERAL_RAW="$TMP_DIR/general_raw.json"
REVIEWS_RAW="$TMP_DIR/reviews_raw.json"
REVIEW_SUMMARIES_RAW="$TMP_DIR/review_summaries_raw.json"
GENERAL_NORMALIZED="$TMP_DIR/general.json"
REVIEWS_NORMALIZED="$TMP_DIR/reviews.json"
REVIEW_SUMMARIES_NORMALIZED="$TMP_DIR/review_summaries.json"

gh api --paginate --slurp "repos/${REPO}/issues/${PR_NUMBER}/comments" > "$GENERAL_RAW"
gh api --paginate --slurp "repos/${REPO}/pulls/${PR_NUMBER}/comments" > "$REVIEWS_RAW"
gh api --paginate --slurp "repos/${REPO}/pulls/${PR_NUMBER}/reviews" > "$REVIEW_SUMMARIES_RAW"

jq '[.[][] | {
  id,
  type: "general_discussion",
  author: .user.login,
  date: .created_at,
  updated_at,
  html_url,
  body
}]' "$GENERAL_RAW" > "$GENERAL_NORMALIZED"

jq '[.[][] | {
  id,
  type: "code_review",
  author: .user.login,
  date: .created_at,
  updated_at,
  file: .path,
  line: (.line // .original_line),
  start_line: (.start_line // .original_start_line),
  original_line,
  original_start_line,
  side,
  start_side,
  reply_to: .in_reply_to_id,
  review_id: .pull_request_review_id,
  diff_hunk,
  html_url,
  body
}]' "$REVIEWS_RAW" > "$REVIEWS_NORMALIZED"

jq '[.[][] | select((.body // "") != "") | {
  id,
  type: "review_summary",
  author: .user.login,
  date: .submitted_at,
  state,
  commit_id,
  html_url,
  body
}]' "$REVIEW_SUMMARIES_RAW" > "$REVIEW_SUMMARIES_NORMALIZED"

jq -s 'add | sort_by(.date // "")' \
  "$GENERAL_NORMALIZED" \
  "$REVIEWS_NORMALIZED" \
  "$REVIEW_SUMMARIES_NORMALIZED" > "$OUTPUT_FILE"

echo "Wrote $OUTPUT_FILE"
jq 'group_by(.type) | map({type: .[0].type, count: length})' "$OUTPUT_FILE"
