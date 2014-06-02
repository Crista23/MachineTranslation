#CORPUS=/home/sveldhoen/MTProject3/data/corpusAligned3/training
CORPUS=/home/sveldhoen/MTProject3/data/corpusAlignedReal

TARGET=en
SOURCES=(da de es fr it nl pt)
FOCUS=fr
MIX=(it nl)
SAME=(it es)
DIFF=(da nl)
ALL=(da de es it nl pt)
KINDS=(union intersect grow-diag-final)

#EXPERIMENT=realExperimentWithoutSpanish
EXPERIMENT=real

ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
COVERAGE=$ROOT/coverage

mkdir -p $COVERAGE/corpus
mkdir -p $COVERAGE/alignments
mkdir -p $COVERAGE/phrasetables

# For computing the coverage:
# Split the training corpus into train and heldout
cp $CORPUS/training/* $COVERAGE/corpus
bash splitCorpus.sh $COVERAGE/corpus heldout
echo "split the corpus into train and heldout"

# And accordingly split the aignment files
for SOURCE in ${SOURCES[*]};
do
  for KIND in ${KINDS[*]};
  do
    cp $ROOT/model/$SOURCE-$TARGET/aligned.$KIND $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND
  done
done
bash splitCorpus.sh $COVERAGE/alignments heldout
echo "split the alignment files into train and heldout"

LOCATIONS=(training heldout)
for LOCATION in ${LOCATIONS[*]};
do
	echo "Now extracting phrase pairs for "
	echo $LOCATION
	echo 'EXPERIMENT: union/ intersection/ grow-diag-final'
	LENGTH=$(cat $COVERAGE/corpus/$LOCATION/corpusAligned.$TARGET|wc -l)
	for KIND in ${KINDS[*]};
	do
		for i in $(seq 0 $LENGTH);
		do
			echo "line $i"
			#mix
			echo "Mix"
			ELINE=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$TARGET | tail -1)
			FLINES=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$FOCUS | tail -1)
			ALLINES=$(head -$i $COVERAGE/alignments/$FOCUS-$TARGET.aligned.grow-diag-final | tail -1)
			for SOURCE in ${MIX[*]};
			do
			  FLINES+=@@$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$SOURCE | tail -1)
			  ALLINES+=,$(head -$i $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND | tail -1)
			done
			echo "eline is | $ELINE | ### fLines is | $FLINES | ### alLines is | $ALLINES |"
			python extendedPhraseExtraction.py \
			"$ELINE" \
			"$FLINES" \
			"$ALLINES" \
			"$COVERAGE/phrasetables/phrases.fr-en.$KIND-$LOCATION.mix"
			
			#same
			echo "Same"
			SELINE=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$TARGET | tail -1)
			SFLINES=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$FOCUS | tail -1)
			SALLINES=$(head -$i $COVERAGE/alignments/$FOCUS-$TARGET.aligned.grow-diag-final | tail -1)
			for SOURCE in ${SAME[*]};
			do
			  SFLINES+=@@$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$SOURCE | tail -1)
			  SALLINES+=,$(head -$i $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND | tail -1)
			done
			echo "eline is | $SELINE | ### fLines is | $SFLINES | ### alLines is | $SALLINES |"
			python extendedPhraseExtraction.py \
			"$SELINE" \
			"$SFLINES" \
			"$SALLINES" \
			"$COVERAGE/phrasetables/phrases.fr-en.$KIND-$LOCATION.same"
			
			#diff
			echo "Diff"
			DELINE=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$TARGET | tail -1)
			DFLINES=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$FOCUS | tail -1)
			DALLINES=$(head -$i $COVERAGE/alignments/$FOCUS-$TARGET.aligned.grow-diag-final | tail -1)
			for SOURCE in ${DIFF[*]};
			do
			  DFLINES+=@@$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$SOURCE | tail -1)
			  DALLINES+=,$(head -$i $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND | tail -1)
			done
			echo "eline is | $DELINE | ### fLines is | $DFLINES | ### alLines is | $DALLINES |"
			python extendedPhraseExtraction.py \
			"$DELINE" \
			"$DFLINES" \
			"$DALLINES" \
			"$COVERAGE/phrasetables/phrases.fr-en.$KIND-$LOCATION.diff"
			
			#all
			echo "All"
			AELINE=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$TARGET | tail -1)
			AFLINES=$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$FOCUS | tail -1)
			AALLINES=$(head -$i $COVERAGE/alignments/$FOCUS-$TARGET.aligned.grow-diag-final | tail -1)
			for SOURCE in ${DIFF[*]};
			do
			  AFLINES+=@@$(head -$i $COVERAGE/corpus/$LOCATION/corpusAligned.$SOURCE | tail -1)
			  AALLINES+=,$(head -$i $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND | tail -1)
			done
			echo "eline is | $AELINE | ### fLines is | $AFLINES | ### alLines is | $AALLINES |"
			python extendedPhraseExtraction.py \
			"$AELINE" \
			"$AFLINES" \
			"$AALLINES" \
			"$COVERAGE/phrasetables/phrases.fr-en.$KIND-$LOCATION.all"
		done
	done
done