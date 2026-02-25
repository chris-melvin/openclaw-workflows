#!/bin/bash
# Linear API helper for OpenClaw workflows
# Usage: source linear.sh && fetch_linear_issues

LINEAR_API_KEY="${LINEAR_API_KEY:-}"
LINEAR_TEAM="${LINEAR_TEAM:-ENG}"

if [ -z "$LINEAR_API_KEY" ]; then
    echo "Error: LINEAR_API_KEY not set" >&2
    return 1
fi

# Fetch recent issues updated in last 24 hours
fetch_linear_issues() {
    local since="${1:-24h}"
    
    curl -s -X POST \
        -H "Authorization: $LINEAR_API_KEY" \
        -H "Content-Type: application/json" \
        https://api.linear.app/graphql \
        -d "{
            \"query\": \"query { 
                issues(
                    filter: { 
                        team: { name: { eq: \\"$LINEAR_TEAM\\" } },
                        updatedAt: { gt: \\"-$since\\" }
                    },
                    first: 50
                ) { 
                    nodes { 
                        id 
                        title 
                        state { name } 
                        assignee { name } 
                        updatedAt
                        url
                    } 
                } 
            }\"
        }"
}

# Get single issue details
get_issue() {
    local issue_id="$1"
    
    curl -s -X POST \
        -H "Authorization: $LINEAR_API_KEY" \
        -H "Content-Type: application/json" \
        https://api.linear.app/graphql \
        -d "{
            \"query\": \"query { 
                issue(id: \\"$issue_id\\") { 
                    id 
                    title 
                    description
                    state { name } 
                    assignee { name }
                    createdAt
                    updatedAt
                    url
                } 
            }\"
        }"
}

# Create new issue
create_issue() {
    local title="$1"
    local description="${2:-}"
    
    curl -s -X POST \
        -H "Authorization: $LINEAR_API_KEY" \
        -H "Content-Type: application/json" \
        https://api.linear.app/graphql \
        -d "{
            \"query\": \"mutation { 
                issueCreate(
                    input: {
                        title: \\"$title\\"
                        description: \\"${description//\"/\\\"}\\"
                        teamId: \\"$LINEAR_TEAM\\"
                    }
                ) { 
                    success
                    issue { id url }
                } 
            }\"
        }"
}

# Format issues for standup report
format_standup_report() {
    local issues_json="$1"
    
    echo "$issues_json" | jq -r '
        .data.issues.nodes | 
        group_by(.assignee.name) |
        .[] |
        "**\(.[0].assignee.name // "Unassigned"):**\n" +
        (.[] | "- \(.title) [\(.state.name)]" | @text)
    '
}

# Example usage:
# issues=$(fetch_linear_issues)
# report=$(format_standup_report "$issues")
# echo "$report"
