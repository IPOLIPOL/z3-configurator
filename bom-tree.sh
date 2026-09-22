#!/usr/bin/env bash
set -e

input=$(cat)
input=$(printf '%s\n' "$input" | tr '\n' ' ' | sed 's/(/ ( /g; s/)/ ) /g')
read -ra tokens <<< "$input"

i=0
advance() { token="${tokens[i]}"; i=$((i + 1)); }

parse_node() {
    local indent="$1"
    local branch="$2"

    advance                      # (
    advance                      # node
    advance                      # "Name"
    local name="${token//\"/}"
    advance                      # qty
    local qty="$token"
    advance                      # children marker: nil, or ( starting a cons list

    printf '%s%s%s × %s\n' "$indent" "$branch" "$name" "$qty"

    if [[ "$token" == "nil" ]]; then
        advance                  # )  closes this node
        return
    fi

    parse_list "$indent    "     # token is already "(" of the child list
    advance                      # )  closes this node
}

parse_list() {
    local indent="$1"

    advance                      # (
    if [[ "$token" == "nil" ]]; then
        advance                  # )  closes the empty list
        return
    fi

    advance                      # cons
    parse_node "$indent" "├── "  # leaves token positioned right after its own )
    parse_list "$indent"         # tail, same indent — siblings don't nest deeper
    advance                      # )  closes this cons cell
}

parse_node "" ""