CORPUS=/home/sveldhoen/MTProject3/data/corpusAlignedReal
EXPERIMENT=real

TARGET=en
SOURCES=(da de es fr it nl pt)

FOCUS=fr
MIX=(it nl)
SAME=(it es)
DIFF=(da nl)
ALL=(de de es it nl pt)

KINDS=(grow-diag-final intersect union)

if [ ! -d "$ROOT/coverage" ]
then
  echo "preparing data..."
  ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
  COVERAGE=$ROOT/coverage

  mkdir -p $COVERAGE/corpus
  mkdir -p $COVERAGE/alignments
  mkdir -p $COVERAGE/phrasetables/heldout
  mkdir -p $COVERAGE/phrasetables/training

  # For computing the coverage:
  # Split the training corpus into train and heldout
  echo "...split the corpus into train and heldout..."
  cp $CORPUS/training/* $COVERAGE/corpus
  bash splitCorpus.sh $COVERAGE/corpus heldout
  rm $COVERAGE/corpusAligned.*

  # And accordingly split the aignment files
  echo "...split the alignment files into train and heldout..."
  for SOURCE in ${SOURCES[*]};
  do
    for KIND in ${KINDS[*]};
    do
      cp $ROOT/model/$SOURCE-$TARGET/aligned.$KIND $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND
    done
  done
  bash splitCorpus.sh $COVERAGE/alignments heldout
  rm $COVERAGE/alignments/*.aligned.*
fi
echo "Data ready."

LENGTH=$(cat $COVERAGE/corpus/training/corpusAligned.$TARGET|wc -l)



function extractPhrases {
KIND=$1
REFERENCES=$2
  for TYPE in training heldout;
  do
    for i in $(seq 1 $LENGTH);
    do
      ELINE=$(head -$i $COVERAGE/corpus/$TYPE/corpusAligned.$TARGET | tail -1)
      FLINES=$(head -$i $COVERAGE/corpus/$TYPE/corpusAligned.$FOCUS | tail -1)
      ALLINES=$(head -$i $COVERAGE/alignments/$TYPE/$FOCUS-$TARGET.aligned.grow-diag-final | tail -1)
      for SOURCE in ${REFERENCES[*]};
      do
        FLINES+=@@$(head -$i $COVERAGE/corpus/$TYPE/corpusAligned.$SOURCE | tail -1)
        ALLINES+=,$(head -$i $COVERAGE/alignments/$TYPE/$SOURCE-$TARGET.aligned.$KIND | tail -1)
      done
      python extendedPhraseExtraction.py \
		"$ELINE" \
	  	"$FLINES" \
	  	"$ALLINES" \
	  	"$COVERAGE/phrasetables/$TYPE/phrases.fr-en.$KIND.mix"
    done
  done
}


echo 'Starting experiment: alignment heuristics'
for KIND in ${KINDS[*]};
do
  extractPhrases $KIND $MIX
done


echo 'Starting experiment: similar reference languagues'
extractPhrases grow-diag-final $SIM

echo 'Starting experiment: different reference languagues'
extractPhrases grow-diag-final $DIFF

echo 'Starting experiment: all reference languagues'
extractPhrases grow-diag-final $ALL



echo "Experiments done."
