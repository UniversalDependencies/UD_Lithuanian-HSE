#!/bin/bash

udapy -h >/dev/null || { echo "udapy is not installed, see https://github.com/udapi/udapi-python"; exit 1; }

L=lt

for a in train dev test; do
    cat $L-ud-$a.conllu | sed 's/newpar_id/newpar id/' | udapy -s \
      util.Eval node='node.misc = "En=" + str(node.misc)[:-2].replace(" ", "_")' \
      util.Eval node='if node.lemma[0].isupper() and (node.form[0].islower() or (node.ord==1 and node.upos!="PROPN" and node.misc["En"][0].islower())): node.lemma=node.lemma.lower()' \
      util.Eval node='if node.lemma[0].isupper() and node.upos=="NOUN": node.upos="PROPN"' \
      util.Eval node='if node.feats["Degree"]=="Pos" and node.upos not in ("ADJ", "ADV"): del node.feats["Degree"]' \
      util.Eval node='if node.deprel=="flat" and node.parent.upos=="NOUN": node.deprel="appos"' \
      ud.FixPunctChild \
      ud.SetSpaceAfterFromText \
    > ../$L-ud-$a.conllu
done

cat ../$L-ud-{train,dev,test}.conllu | udapy -HAMC ud.MarkBugs skip='no-(PronType|VerbForm|NumType)' > bugs.html
