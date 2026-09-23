#!/usr/bin/env bash
set -e

nDist="$1"; nStand="$2"; zones="$3"; zones_s="$4"

if [[ -z "$zones" ]]; then
    echo "usage: ./run.sh <nDist> <nStand> <zones> <zones_s>" >&2
    exit 1
fi

query() {
    cat inertgas.smt2 - <<SMT | z3 -in | tail -n +2
(assert (= nDist $nDist))
(assert (= nStand $nStand))
(assert (= zones $zones))
(assert (= zones_s $zones_s))
(check-sat)
(eval $1)
SMT
}

echo "== Distribution =="
query bom-dist | ./pretty-bom.sh

echo
echo "== Stand-alone =="
query bom-stand | ./pretty-bom.sh