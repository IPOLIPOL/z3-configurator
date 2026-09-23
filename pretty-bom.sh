#!/usr/bin/env bash
set -e
awk '
function advance() { i++; tok = tokens[i] }

function parse_node(   class, variant, qty) {
    advance(); advance()                  # ( node
    advance(); class = tok
    gsub(/"/, "", class)
    advance(); variant = tok
    gsub(/"/, "", variant)
    advance(); qty = tok
    advance()                             # children marker: "nil", or "(" starting (cons ...)

    if (root_done) {
        n++
        labels[n] = class ": " variant
        qtys[n]   = qty
    } else {
        root_label = class ": " variant
        root_qty   = qty
        root_done  = 1
    }

    if (tok == "nil") { advance(); advance(); return }  # consume "nil" AND this node own closing ")"
    parse_list()
    advance()                             # closing ")" of this node, after a non-leaf child list
}

# A list value is either the bare atom "nil" (no wrapping parens) or a
# compound "(cons head tail)". Check for the bare atom BEFORE advancing,
# since there is no "(" to skip past in that case.
function parse_list() {
    if (tok == "nil") { advance(); return }
    advance()                             # ( of "(cons head tail)"
    parse_node()                          # entry tok == "cons"; parse_node consumes it itself
    parse_list()                          # tail
    advance()                             # closing ")" of this cons cell
}

{ full_text = full_text " " $0 }

END {
    gsub(/\(/, " ( ", full_text)
    gsub(/\)/, " ) ", full_text)
    split(full_text, tokens)

    i = 0
    root_done = 0
    n = 0
    parse_node()

    if (n == 0) {
        print "Error: no components found" > "/dev/stderr"
        exit 1
    }

    width = 0
    for (k = 1; k <= n; k++) if (length(labels[k]) > width) width = length(labels[k])

    printf "%s x %s\n", root_label, root_qty
    for (k = 1; k <= n; k++) {
        marker = (k == n) ? "\\__ " : "|-- "
        printf "%s%-*s x %s\n", marker, width, labels[k], qtys[k]
    }
}
'