#!/bin/bash

udapy -h >/dev/null || { echo "udapy is not installed, see https://github.com/udapi/udapi-python"; exit 1; }

L=lt

for a in train dev test; do
    cat $L-ud-$a.conllu | sed 's/newpar_id/newpar id/' | udapy -s \
    > ../$L-ud-$a.conllu
done

cat ../$L-ud-{train,dev,test}.conllu | udapy -HAMC ud.MarkBugs skip='no-(PronType|VerbForm|NumType)' > bugs.html
