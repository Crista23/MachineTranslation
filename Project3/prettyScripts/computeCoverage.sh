EXPERIMENT=/home/sveldhoen/MTProject3/real
PHRASETABLELOCATION=$EXPERIMENT/coverage/phrasetables
PHRASETABLE1=$PHRASETABLELOCATION/heldout/phrases.fr-en.union.mix
PHRASETABLE2=$PHRASETABLELOCATION/training/phrases.fr-en.union.mix
#sort and remove duplicates from phrasetable1
sort -u $PHRASETABLE1 > "SORTEDPHRASETABLEUNIONMIX1"
#mv "SORTEDPHRASETABLE1" "$PHRASETABLE1"
#sort and remove duplicates from phrasetable2
sort -u $PHRASETABLE2 > "SORTEDPHRASETABLEUNIONMIX2"
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
	if grep -q "$NEWLINE" SORTEDPHRASETABLEUNIONMIX2; then
		echo "found"
		#$KNOWN=$(($KNOWN+1))
		(( KNOWN++ ))
		echo "$KNOWN"
	else
		echo "not found"
		#$UNKNOWN=$(($UNKNOWN+1))
		(( UNKNOWN++ ))
		echo "$UNKNOWN"
	fi
done < SORTEDPHRASETABLEUNIONMIX1
echo "Total Known"
echo $KNOWN
echo "Total Unknown"
echo $UNKNOWN
TOTAL=$((KNOWN+UNKNOWN))
echo "Their sum is"
echo "$TOTAL"
echo "Coverage for the phrases.fr-en.union.mix experiment is"
COVERAGE=$(bc <<<"scale=2;$KNOWN/$TOTAL")
echo "$COVERAGE"