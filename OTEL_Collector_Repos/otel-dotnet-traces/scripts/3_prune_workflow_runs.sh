thisRepo=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\).git/\1/')

echo "Pruning workflow runs for repository: $thisRepo"

gh run list --repo $thisRepo --workflow "deploy.yml" --limit 1000 | while read -r run; do
    # Print the line we're processing for debugging
    echo "Processing run: $run"
    
    # Use cut to get the run ID - it should be the 7th to last field
    run_id=$(echo "$run" | rev | cut -f3 | rev)
    
    echo "Deleting run ID: $run_id"
    gh run delete "$run_id" --repo $thisRepo
done