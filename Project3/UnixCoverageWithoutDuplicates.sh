EXPERIMENT=/home/sveldhoen/MTProject3/real
PHRASETABLELOCATION=$EXPERIMENT/coverage/phrasetables
PHRASETABLE1=$PHRASETABLELOCATION/heldout/phrases.fr-en.union.mix
PHRASETABLE2=$PHRASETABLELOCATION/training/phrases.fr-en.union.mix

while read LINEPHTABLE1
	NEWLINE=${LINEPHTABLE1% ||| *}
	echo "$NEWLINE" >> NODUPLICATESPH1
done < PHRASETABLE1

echo "done"