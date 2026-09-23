#!/usr/bin/env bash
set -e

input=$(cat)
input=$(printf '%s\n' "$input" | tr '\n' ' ' | sed 's/(/ ( /g; s/)/ ) /g')
read -ra tokens <<< "$input"

i=0
advance() { token="${tokens[i]}"; i=$((i + 1)); }

declare -a LABELS QTYS
root_label="" root_qty=""

parse_node() {
    advance; advance                       # ( node
    advance; local class="${token//\"/}"
    advance; local variant="${token//\"/}"
    advance; local qty="$token"
    advance                                # children marker: "nil", or "(" starting (cons ...)

    if [[ -n "$root_label" || "$root_seen" == "1" ]]; then
        LABELS+=("$class: $variant")
        QTYS+=("$qty")
    else
        root_label="$class: $variant"
        root_qty="$qty"
        root_seen=1
    fi

    if [[ "$token" == "nil" ]]; then advance; advance; return; fi   # "nil" AND this node's own ")"
    parse_list
    advance                                # ")" of this node, after a non-leaf child list
}

# A list value is either the bare atom "nil" (no wrapping parens) or a
# compound "(cons head tail)". Check for the bare atom before advancing,
# since there's no "(" to skip past in that case.
parse_list() {
    if [[ "$token" == "nil" ]]; then advance; return; fi
    advance                                # ( of "(cons head tail)"
    parse_node                             # entry token == "cons"; parse_node consumes it itself
    parse_list                             # tail
    advance                                # ")" of this cons cell
}

root_seen=0
parse_node

width=0
for l in "${LABELS[@]}"; do (( ${#l} > width )) && width=${#l}; done

printf '%s x %s\n' "$root_label" "$root_qty"
n=${#LABELS[@]}
for ((k = 0; k < n; k++)); do
    marker="|-- "; (( k == n - 1 )) && marker="\\__ "
    printf '%s%-*s x %s\n' "$marker" "$width" "${LABELS[k]}" "${QTYS[k]}"
done