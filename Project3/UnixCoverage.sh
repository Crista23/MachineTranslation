#EXPERIMENT=/home/sveldhoen/MTProject3/miniExperimentSara
#PHRASETABLELOCATION=$EXPERIMENT/coverage/phrasetables
#PHRASETABLE1=$PHRASETABLELOCATION/phrases.fr-en.grow-diag-final.mix
#PHRASETABLE2=$PHRASETABLELOCATION/phrases.fr-en.intersect.mix
#sort and remove duplicates from phrasetable1
#sort -u $PHRASETABLE1 > "SORTEDPHRASETABLE1"
#mv "SORTEDPHRASETABLE1" "$PHRASETABLE1"
#sort and remove duplicates from phrasetable2
#sort -u $PHRASETABLE2 > "SORTEDPHRASETABLE2"
#mv "SORTEDPHRASETABLE2" "$PHRASETABLE1"
KNOWN=0
UNKNOWN=0
while read LINEPHTABLE1
do
	echo "before delete"
    echo "$LINEPHTABLE1"
	echo "after delete"
	#echo "$LINEPHTABLE1" | sed -e 's/|||.*//g'
	NEWLINE=${LINEPHTABLE1% ||| *}
	#echo "$LINEPHTABLE1"
	echo "$NEWLINE"
	if grep -q "$NEWLINE" SORTEDPHRASETABLE2; then
		#echo "found"
		KNOWN=KNOWN+1
	else
		#echo "not found"
		UNKNOWN=UNKNOWN+1
	fi
done < SORTEDPHRASETABLE1
COVERAGE=KNOWN/(KNOWN+UNKNOWN)
echo "coverage is"
echo "$COVERAGE"