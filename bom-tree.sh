
#!/usr/bin/env bash
set -e

input=$(cat)
input=$(printf '%s\n' "$input" | tr '\n' ' ' | sed 's/(/ ( /g; s/)/ ) /g')
read -ra tokens <<< "$input"

i=0

advance() {
    token="${tokens[i]}"
    i=$((i + 1))
}

parse_node() {
    local indent="$1"
    local branch="$2"

    advance                      # (
    advance                      # node

    local name="${token//\"/}"
    advance                      # quantity

    local qty="$token"
    advance                      # children

    printf '%s%s%s × %s\n' "$indent" "$branch" "$name" "$qty"

    if [[ "$token" == "nil" ]]; then
        advance                  # )
        return
    fi

    parse_list "$indent    "
    advance                      # )
}

parse_list() {
    local indent="$1"

    advance                      # (
    if [[ "$token" == "nil" ]]; then
        advance                  # )
        return
    fi

    advance                      # cons

    parse_node "$indent" "├── "
    parse_list "$indent"

    advance                      # )
}

parse_node "" ""

