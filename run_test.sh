#!/bin/bash
# Usage: run_test.sh <repo_url> <buggy_commit> <fixed_commit>
# Example: run_test.sh https://github.com/aframevr/aframe abc123 def456

REPO_URL=$1
BUGGY_COMMIT=$2
FIXED_COMMIT=$3

echo "=== VR Bug Reproduction Test ==="
echo "Repo: $REPO_URL"
echo "Buggy commit: $BUGGY_COMMIT"
echo "Fixed commit: $FIXED_COMMIT"

# Clone and checkout buggy version
git clone --depth 100 "$REPO_URL" /app/repo
cd /app/repo
git checkout "$BUGGY_COMMIT"

# Try to install and serve
npm install 2>/dev/null
npx serve -l 8080 -s . &
SERVER_PID=$!
sleep 3

# Run playwright test on buggy version
echo "=== Testing BUGGY version ==="
node /app/test_bug.js http://localhost:8080 /app/screenshot_buggy.png
BUGGY_EXIT=$?

# Kill server
kill $SERVER_PID 2>/dev/null

# Checkout fixed version
git checkout "$FIXED_COMMIT"
npm install 2>/dev/null
npx serve -l 8080 -s . &
SERVER_PID=$!
sleep 3

# Run playwright test on fixed version
echo "=== Testing FIXED version ==="
node /app/test_bug.js http://localhost:8080 /app/screenshot_fixed.png
FIXED_EXIT=$?

kill $SERVER_PID 2>/dev/null

# Compare results
echo "=== Results ==="
echo "Buggy version exit code: $BUGGY_EXIT"
echo "Fixed version exit code: $FIXED_EXIT"

if [ $BUGGY_EXIT -ne 0 ] && [ $FIXED_EXIT -eq 0 ]; then
    echo "SUCCESS: Bug reproduced (buggy=fail, fixed=pass)"
elif [ $BUGGY_EXIT -eq 0 ] && [ $FIXED_EXIT -eq 0 ]; then
    echo "INCONCLUSIVE: Both versions pass"
else
    echo "INCONCLUSIVE: Unexpected result pattern"
fi
