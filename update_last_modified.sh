#!/bin/sh

# Get a list of staged markdown files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$')

# Iterate over each staged markdown file
echo "$staged_files" | while read file; do
    # Get the last modified date for the file
    last_modified=$(git log -1 --format="%ad" -- "$file")

    # Update the last_modified line in the file
    sed -i '' -e "0,/last_modified:.*/s//last_modified: $last_modified/" "$file"
done

# Continue with the commit
exit 0
