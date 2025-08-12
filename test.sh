#!/bin/bash

# Script to test GitHub pull requests and comment results

set -e  # Exit on error

# Configuration
REPO_URL="https://github.com/VBota1/FastDemoRestApi.git"
REPO_DIR="FastDemoRestApi_temp"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    echo "See: https://github.com/cli/cli#installation"
    exit 1
fi

# Check if authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo "Not authenticated with GitHub CLI. Please run: gh auth login"
    exit 1
fi


# Cleanup function
cleanup() {
    echo "Cleaning up..."
    if [ -d "$REPO_DIR" ]; then
        rm -rf "$REPO_DIR"
    fi
}
# Trap to ensure cleanup happens on script exit
trap cleanup EXIT

# Clone the repository
echo "Cloning repository..."
git clone "$REPO_URL" "$REPO_DIR"
cd "$REPO_DIR"
echo "Cloning succesfull"

# Checkout the pull request
echo "Checking out PR #$PR_NUMBER..."
gh pr checkout "$PR_NUMBER"

# Install dependencies if needed (customize for your project)
echo "Installing dependencies..."
# Example for Node.js project:
# npm install
# Example for Python project:
# pip install -r requirements.txt

# Run tests and capture output
echo "Running tests..."
TEST_OUTPUT=$(mktemp)

# Customize this command for your project's test runner
# Example for Node.js project:
# npm test &> "$TEST_OUTPUT" || true
# Example for Python project:
# python -m pytest &> "$TEST_OUTPUT" || true

# For demonstration, we'll simulate tests
echo "Running simulated tests..."
sleep 2
cat << EOF > "$TEST_OUTPUT"
Running tests...
test_endpoint_1 ... OK
test_endpoint_2 ... FAILED
test_endpoint_3 ... OK

3 tests run, 2 passed, 1 failed
EOF

# Get test results summary
TEST_SUMMARY=$(tail -n 1 "$TEST_OUTPUT")
TESTS_PASSED=$(echo "$TEST_SUMMARY" | awk '{print $4}')
TESTS_FAILED=$(echo "$TEST_SUMMARY" | awk '{print $6}')

# Determine comment based on test results
if [ "$TESTS_FAILED" -eq 0 ]; then
    COMMENT="✅ All tests passed ($TESTS_PASSED passed)"
    EMOJI=":white_check_mark:"
else
    COMMENT="❌ Some tests failed ($TESTS_PASSED passed, $TESTS_FAILED failed)"
    EMOJI=":x:"
fi

# Add full test output as details
COMMENT="$COMMENT\n\n<details>\n<summary>Test output</summary>\n\n\`\`\`\n$(cat "$TEST_OUTPUT")\n\`\`\`\n</details>"

# Post comment to pull request
echo "Posting comment to PR #$PR_NUMBER..."
gh pr comment "$PR_NUMBER" --body "$COMMENT"

echo "Done! Results posted to PR #$PR_NUMBER"

echo "Pull request done"
