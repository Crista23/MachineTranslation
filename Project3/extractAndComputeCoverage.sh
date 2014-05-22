#CORPUS=/home/sveldhoen/MTProject3/data/corpusAligned/training
CORPUS=/home/sveldhoen/MTProject3/data/corpusMiniTest/training

TARGET=en
SOURCES=(da de es fr it nl pt)

#EXPERIMENT=real
EXPERIMENT=mini

ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
COVERAGE=$ROOT/COVERAGE

mkdir -p $COVERAGE/corpus
mkdir -p $COVERAGE/alignments

# For computing the coverage:
# Split the training corpus into train and heldout
cp $CORPUS/training/* $COVERAGE/corpus
bash splitCorpus.sh $COVERAGE/corpus heldout

# And accordingly split the aignment files
for SOURCE in ${SOURCES[*]};
do
  cp $ROOT/model/$SOURCE-$TARGET/aligned.* $COVERAGE/alignments
done
bash splitCorpus.sh $COVERAGE/alignments heldout

split -a 3    \
      -d      \
      -l 1000 \
      $COVERAGE/corpus/*

