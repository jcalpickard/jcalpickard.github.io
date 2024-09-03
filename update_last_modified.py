#!/usr/bin/env python3

import os
import datetime
import frontmatter

# Get the current date and time
now = datetime.datetime.now()

# Loop through all of the markdown files in the current directory
for filename in os.listdir('.'):
    if filename.endswith('.md'):
        # Load the file's front matter
        with open(filename) as f:
            post = frontmatter.load(f)

        # Check if the file has been modified since the last time the script was run
        if 'last_modified' not in post or post['last_modified'] < os.path.getmtime(filename):
            # Update the last_modified date in the file's front matter
            post['last_modified'] = now

            # Write the updated front matter back to the file
            with open(filename, 'w') as f:
                f.write(frontmatter.dumps(post))