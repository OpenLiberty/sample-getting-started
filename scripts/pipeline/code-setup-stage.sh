#!/bin/bash

SKIP_SETUP=$(get_env SKIP_SETUP)
if [[ "$SKIP_SETUP" != 1 ]]; then
    GHE_TOKEN=$(cat "$WORKSPACE/git-token")
    GHE_TOKEN=$(get_env git-token)
    GH_TOKEN=$(get_env git-token-GH)
    OWNER=$(jq -r '.services[] | select(.toolchain_binding.name=="app-repo") | .parameters.owner_id' /toolchain/toolchain.json)
    REPO=$(jq -r '.services[] | select(.toolchain_binding.name=="app-repo") | .parameters.repo_name' /toolchain/toolchain.json)
    REPO=${REPO%.git}
    REPO=sample-getting-started
    BRANCH=$(get_env branch)
    # The 'owner' is really the org, not the user with admin access to repo
    OWNER=OpenLiberty
    echo "Owner: $OWNER"
    echo "REPO: $REPO"
    echo "BRANCH: $BRANCH"

    curl -u :$GH_TOKEN https://api.github.com/repos/$OWNER/$REPO/branches/$BRANCH/protection -H "Accept: application/vnd.github.v3+json" -X PUT -d '{"required_pull_request_reviews":{"dismiss_stale_reviews":true,"required_approving_review_count":1},"enforce_admins":null,"restrictions":null,"required_status_checks":null}'

    // Update repo with Whitesource enabled
    WHITESOURCE_GHE_REPO=$(get_env WHITESOURCE_GHE_REPO)
    WHITESOURCE_GHE_DOMAIN=$(get_env WHITESOURCE_GHE_DOMAIN)
    echo "git push --prune https://$GHE_TOKEN@$WHITESOURCE_GHE_DOMAIN/$WHITESOURCE_GHE_REPO +refs/remotes/origin/$BRANCH:refs/heads/$BRANCH +refs/tags/*:refs/tags/*"
    git push --prune https://$GHE_TOKEN@$WHITESOURCE_GHE_DOMAIN/$WHITESOURCE_GHE_REPO +refs/remotes/origin/$BRANCH:refs/heads/$BRANCH +refs/tags/*:refs/tags/*
fi
