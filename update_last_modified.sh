#!/bin/sh

# Get a list of staged markdown files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$')

# Iterate over each staged markdown file
echo "$staged_files" | while read file; do
    # Get the last modified date for the file in the last commit
    last_modified_last_commit=$(git log -1 --format="%ad" -- "$file")

    # Get the last modified date for the file in the working directory
    last_modified_working_directory=$(git show :"$file" | grep '^Date:' | sed 's/Date: //')

    # If the file has been changed, update the last_modified line in the file
    if [ "$last_modified_last_commit" != "$last_modified_working_directory" ]; then
        sed -i '' -e "0,/last_modified:.*/s//last_modified: $last_modified_working_directory/" "$file"
    fi
done

# Continue with the commit
exit 0
