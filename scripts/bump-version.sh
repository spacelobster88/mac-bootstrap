#!/bin/bash
# bump-version.sh — Update a service's pinned commit in stack.json
#
# Usage:
#   ./scripts/bump-version.sh <service-name> [commit-sha]
#
# If commit-sha is omitted, the current main branch HEAD is fetched from GitHub.
#
# Examples:
#   ./scripts/bump-version.sh mini-claude-bot abc1234def5678
#   ./scripts/bump-version.sh centurion               # pins to current main HEAD

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STACK_FILE="$SCRIPT_DIR/stack.json"

SERVICE="${1:?Usage: bump-version.sh <service-name> [commit-sha]}"
REF="${2:-}"

if [[ ! -f "$STACK_FILE" ]]; then
    echo "Error: stack.json not found at $STACK_FILE"
    exit 1
fi

# Verify the service exists in stack.json
if ! python3 -c "import json; d=json.load(open('$STACK_FILE')); assert '$SERVICE' in d['services']" 2>/dev/null; then
    echo "Error: service '$SERVICE' not found in stack.json"
    echo "Available services:"
    python3 -c "import json; d=json.load(open('$STACK_FILE')); [print(f'  - {k}') for k in d['services']]"
    exit 1
fi

# If no ref provided, fetch current main HEAD from GitHub
if [[ -z "$REF" ]]; then
    REPO=$(python3 -c "import json; print(json.load(open('$STACK_FILE'))['services']['$SERVICE']['repo'])")
    echo "Fetching current main HEAD for $REPO..."
    REF=$(gh api "repos/$REPO/commits/main" --jq .sha)
fi

# Update stack.json
python3 -c "
import json
with open('$STACK_FILE') as f:
    d = json.load(f)
d['services']['$SERVICE']['ref'] = '$REF'
with open('$STACK_FILE', 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
"

echo "Updated $SERVICE to $REF in stack.json"
