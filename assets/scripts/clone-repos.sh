#!/bin/bash

get_clone_method() {
    echo "Choose clone method:"
    echo "1) HTTPS"
    echo "2) SSH"
    read -p "Enter 1 or 2: " method
    if [ "$method" == "1" ]; then
        clone_method="https"
    elif [ "$method" == "2" ]; then
        clone_method="ssh"
    else
        echo "Invalid input. Please choose 1 or 2."
        get_clone_method
    fi
}

clone_repositories() {
    local repo_file="$1"

    if [ ! -f "$repo_file" ]; then
        echo "File not found: $repo_file"
        exit 1
    fi

    # Read each line from the provided text file
    while IFS= read -r repo || [[ -n "$repo" ]]; do
        username=$(echo "$repo" | cut -d '/' -f 1)  # Extract GitHub username
        repo_name=$(echo "$repo" | cut -d '/' -f 2) # Extract repository name

        # Define target directory in /opt/
        target_dir="/opt/$username/$repo_name"

        # Check if the target directory already exists
        if [ -d "$target_dir" ]; then
            echo "Directory $target_dir already exists, skipping $repo."
            continue
        fi

        # Create the target directory if it doesn't exist
        mkdir -p "$target_dir"

        # Build the appropriate git URL
        if [ "$clone_method" == "https" ]; then
            git_url="https://github.com/$repo.git"
        elif [ "$clone_method" == "ssh" ]; then
            git_url="git@github.com:${repo}.git"
        fi

        # Clone the repository into the target directory
        echo "Cloning $repo from $git_url into $target_dir"
        git clone "$git_url" "$target_dir"

    done < "$repo_file"
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 path_to_repository_list.txt"
    exit 1
fi

repo_file="$1"
get_clone_method
clone_repositories "$repo_file"

echo "Done."
