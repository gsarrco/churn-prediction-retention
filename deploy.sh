#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Save the current directory
current_dir=$(pwd)

# Render the book
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

# Ensure there are no existing worktrees pointing to the gh-pages branch
existing_worktree=$(git worktree list | grep "gh-pages" | awk '{print $1}')
if [ -n "$existing_worktree" ]; then
    git worktree remove "$existing_worktree" --force
fi

# Create a temporary directory for the gh-pages branch
tmp_dir=$(mktemp -d -t gh-pages-XXXXXXXXXX)

# Checkout the gh-pages branch into the temporary directory
git worktree add -B gh-pages $tmp_dir origin/gh-pages

# Remove all existing files in the gh-pages directory
rm -rf $tmp_dir/*

# Copy the rendered book into the temporary directory
cp -r ./_book/* $tmp_dir/

# Create a .nojekyll file to bypass Jekyll processing on GitHub Pages
touch $tmp_dir/.nojekyll

# Go to the temporary directory
cd $tmp_dir

# Add all changes to git
git add --all

# Commit the changes
git commit -m "Deploy book to GitHub Pages"

# Push the changes to the gh-pages branch
git push origin gh-pages

# Return to the original directory
cd $current_dir

# Cleanup: remove the temporary directory and worktree
git worktree remove $tmp_dir

echo "Book has been deployed to GitHub Pages!"
