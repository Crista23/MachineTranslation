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
	#KIND=union
	do
		for i in $(seq 0 $LENGTH);
		do
			echo "line $i"
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
			"$COVERAGE/phrasetables/phrases.fr-en.$KIND.mix"
		done
	done
done