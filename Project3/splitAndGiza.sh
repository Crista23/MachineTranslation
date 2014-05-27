
#CORPUS=/home/sveldhoen/MTProject3/data/corpusAligned
CORPUS=/home/sveldhoen/MTProject3/data/corpusMini23

#note that in the end:
# trainingCorpus is $CORPUS/training/training
# heldout-corpus is $CORPUS/training/heldout

#EXPERIMENT=real
EXPERIMENT=miniExperimentSara

ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
GIZADIR=$ROOT/giza #/source-target
MODELDIR=$ROOT/model #/source-target
CORPUSDIR=$ROOT/corpus #/source-target

TARGET=en
SOURCES=(da de fr it nl pt)

#Split into test and train set:
for SOURCE in ${SOURCES[*]};
do
  mv $CORPUS/*.$SOURCE $CORPUS/corpusAligned.$SOURCE
done
mv $CORPUS/*.$TARGET $CORPUS/corpusAligned.$TARGET

echo "Split corpus in test and train"
/bin/bash ./splitCorpus.sh $CORPUS test

#Run Giza on the train set:
for SOURCE in ${SOURCES[*]};
do
  echo "Starting Giza for $SOURCE-$TARGET"
  nohup  /apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl     \
  --parallel     \
  -external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
  --root-dir $ROOT \
  --corpus $CORPUS/training/corpusAligned  \
  --f $SOURCE    \
  --e $TARGET    \
  --corpus-dir $CORPUSDIR/$SOURCE-$TARGET          \
  --model-dir $MODELDIR/$SOURCE-$TARGET            \
  --extract-file $MODELDIR/$SOURCE-$TARGET/extract \
  --giza-f2e $GIZADIR/$SOURCE-$TARGET \
  --giza-e2f $GIZADIR/$TARGET-$SOURCE \
  --first-step 1 \
  --last-step 2  \
  -mgiza -mgiza-cpus 4 \
  > $ROOT/giza.$SOURCE-$TARGET.out &
# Now you have Giza Viterbi alignments
# Run different symmetrization heuristics:
done

