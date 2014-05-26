#CORPUS=/home/sveldhoen/MTProject3/data/corpusAligned3/training
CORPUS=/home/sveldhoen/MTProject3/data/corpusMiniTest/training

TARGET=en
SOURCES=(da de fr it nl pt)
FOCUS=fr
MIX=(it nl)
SAME=(it pt)
DIFF=(da nl)
ALL=(de de it nl pt)
KINDS=(union intersect grow-diag-final)


#EXPERIMENT=realExperimentWithoutSpanish
EXPERIMENT=mini

ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
COVERAGE=$ROOT/COVERAGE

mkdir -p $COVERAGE/corpus
mkdir -p $COVERAGE/alignments
mkdir -p $COVERAGE/phrasetables

# For computing the coverage:
# Split the training corpus into train and heldout
cp $CORPUS/training/* $COVERAGE/corpus
bash splitCorpus.sh $COVERAGE/corpus heldout

# And accordingly split the aignment files
for SOURCE in ${SOURCES[*]};
do
  for KIND int ${KINDS[*]};
  do
    cp $ROOT/model/$SOURCE-$TARGET/aligned.$KIND $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND
  done
done
bash splitCorpus.sh $COVERAGE/alignments heldout



echo 'EXPERIMENT: union/ intersection/ grow-diag-final'
for $KIND in ${KINDS[*]};
do
  for i in $(seq 1 50);
  do
    ELINE=$(head -i $COVERAGE/corpus/training/corpusAligned.$TARGET | tail -1)
    FLINES=$(head -i $COVERAGE/corpus/training/corpusAligned.$FOCUS | tail -1)
    ALLINES=$(head -i $COVERAGE/alignments/$FOCUS-$TARGET.alignedg.grow-diag-final | tail -1)
    for SOURCE in ${MIX[*]};
    do
      FLINES+=,$(head -i $COVERAGE/corpus/training/corpusAligned.$SOURCE | tail -1)
      ALLINES+=,$(head -i $COVERAGE/alignments/$SOURCE-$TARGET.aligned.$KIND | tail -1)
    done
    python extendedPhraseExtraction $ELINE $FLINES $ALLINES $COVERAGE/phrasetables/phrases.fr-en.$KIND.mix
  done
done



