CORPUS=/home/sveldhoen/MTProject3/data/corpusMiniTest
EXPERIMENT=mini
ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
GIZADIR=$ROOT/giza
MODELDIR=$ROOT/model
CORPUSDIR=$ROOT/corpus
ALIGNEDCORPUS=/home/sveldhoen/MTProject3/data/corpusMiniTest/corpusAligned
TRANSLATIONDIR=$ROOT/TranslationResults
TARGET=en
SOURCES=(da de es fr it nl pt)
for SOURCE in ${SOURCES[*]}
do
	echo "Source language is:"
	echo $SOURCE
	echo "Train Moses"
	#run baseline on train
	/apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl \
	-external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
	-mgiza -mgiza-cpus 4 \
	--f $SOURCE --e $TARGET \
	--lm 0:3:/home/bart/project2_data/lm/europarl-v7.nl-en.train.blm.en:8  \
	--corpus $ALIGNEDCORPUS -alignment grow-diag-final-and -reordering msd-bidirectional-fe \
	--root-dir $ROOT \
	--model-dir $MODELDIR/$SOURCE-$TARGET  \
	--extract-file $MODELDIR/$SOURCE-$TARGET/extract \
	--giza-f2e $GIZADIR/$SOURCE-$TARGET \
	--giza-e2f $GIZADIR/$TARGET-$SOURCE \
	--first-step 3 \
	--last-step 9
	echo "Translation begins"
	/apps/smt_tools/decoders/mosesdecoder/bin/moses \
	-f "$MODELDIR/$SOURCE-$TARGET/moses.ini" \			
	< "$CORPUS/test/corpusAligned.$SOURCE"   \				
	> "$TRANSLATIONDIR/translated$SOURCE-$TARGET.$TARGET" \
	2> "$TRANSLATIONDIR/translation$SOURCE-$TARGET.out"
	echo "Compute Bleu scores"
	/apps/smt_tools/decoders/mosesdecoder/scripts/generic/multi-bleu.perl \
	"$CORPUS/test/corpusAligned.$TARGET"  \
	< "$TRANSLATIONDIR/translated$SOURCE-$TARGET.$TARGET"
done