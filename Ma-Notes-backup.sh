#!/bin/bash

# Navigate to your text repository folder
cd /home/rachel/Ma-Notes || exit

# 1. Pull remote changes first to prevent conflicts
git pull --rebase

# 2. Stage all text changes
git add .

# 3. Commit with a clear timestamp note
git commit -m "Automated backup: $(date '+%Y-%m-%d %H:%M:%S')"

# 4. Push securely using your passwordless SSH key
git push

