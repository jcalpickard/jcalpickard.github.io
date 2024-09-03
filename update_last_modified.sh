#!/bin/sh

# Find all markdown files
find . -name "*.md" | while read file; do
  # Get the last modified date
  last_modified=$(git log -1 --format="%ad" -- $file)

  # Replace the last_modified line in the file
  sed -i '' -e "0,/last_modified:.*/s//last_modified: $last_modified/" $file
done
