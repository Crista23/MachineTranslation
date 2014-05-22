
#CORPUS=/home/sveldhoen/MTProject3/data/corpusAligned
CORPUS=/home/sveldhoen/MTProject3/data/corpusMiniTest
#note that in the end:
# trainingCorpus is $CORPUS/training/training
# heldout-corpus is $CORPUS/training/heldout

#EXPERIMENT=real
EXPERIMENT=mini


ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
GIZADIR=$ROOT/giza #/source-target
MODELDIR=$ROOT/model #/source-target
CORPUSDIR=$ROOT/corpus #/source-target

TARGET=en
SOURCES=(da de es fr it nl pt)

#Split into test and train set:
echo "Split corpus in test and train"
/bin/bash ./splitCorpus.sh $CORPUS test

#Run Giza on the train set:
for SOURCE in ${SOURCES[*]};
do
  echo "Starting Giza for $SOURCE-$TARGET"
  /apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl     \
  --parallel     \
  -external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
  --root-dir $ROOT \
  --corpus $CORPUS/training/corpus  \
  --f $SOURCE    \
  --e $TARGET    \
  --corpus-dir $CORPUSDIR/$SOURCE-$TARGET          \
  --lexical-dir $MODELDIR/$SOURCE-$TARGET          \
  --model-dir $MODELDIR/$SOURCE-$TARGET            \
  --extract-file $MODELDIR/$SOURCE-$TARGET/extract \
  --giza-f2e $GIZADIR/$SOURCE-$TARGET \
  --giza-e2f $GIZADIR/$TARGET-$SOURCE \
  --first-step 1 \
  --last-step 2  \
  -mgiza -mgiza-cpus 4
 Now you have Giza Viterbi alignments
 Run different symmetrization heuristics:
  echo "Giza's viterbi alignments obtained"
  for al in intersect union grow-diag-final;
  do
    echo "Starting symmetrization $al ($SOURCE-$TARGET)"
    /apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl     \
    --parallel     \
    -external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
    --root-dir $MODEL \
    --corpus $CORPUS/training/corpus  \
    --f $SOURCE    \
    --e $TARGET    \
  --corpus-dir $CORPUSDIR/$SOURCE-$TARGET          \
  --lexical-dir $MODELDIR/$SOURCE-$TARGET          \
  --model-dir $MODELDIR/$SOURCE-$TARGET            \
  --extract-file $MODELDIR/$SOURCE-$TARGET/extract \
  --giza-f2e $GIZADIR/$SOURCE-$TARGET \
  --giza-e2f $GIZADIR/$TARGET-$SOURCE \    --first-step 3 \
    --last-step 3  \
    -mgiza -mgiza-cpus 4
    --alignment $al
  done
done

# Split the training corpus,
# and accordingly the giza alignments,
# into train and heldout
bash splitCorpus.sh $CORPUS/train heldout
bash splitCorpus.sh $GIZA heldout
