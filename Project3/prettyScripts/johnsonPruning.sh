CORPUS=/home/sveldhoen/MTProject3/data/corpusAlignedReal
EXPERIMENT=real
ROOT=/home/sveldhoen/MTProject3/$EXPERIMENT
GIZADIR=$ROOT/giza
MODELDIR=$ROOT/modelJP09
CORPUSDIR=$ROOT/corpus
ALIGNEDCORPUS=/home/sveldhoen/MTProject3/data/corpusAlignedReal/corpusAligned
TRANSLATIONDIR=$ROOT/TranslationResultsJohnsonGrowDiagFinal01
TARGET=en
SOURCES=(da de es fr it nl pt)

mkdir $TRANSLATIONDIR

for SOURCE in ${SOURCES[*]}
do
	echo "1.Source language is:"
	echo $SOURCE
	#unzip the Moses phrase table
	gunzip "$MODELDIR/$SOURCE-$TARGET/phrase-table.gz"
	echo "2.finished unzipping"
	#perform (Johnson) prunning on this table
	cat "$MODELDIR/$SOURCE-$TARGET/phrase-table" | /apps/smt_tools/decoders/mosesdecoder/scripts/training/threshold-filter.perl 0.9 > "$MODELDIR/$SOURCE-$TARGET/phrase-table.reduced"
	echo "3.Obtained the reduced phrase table"
	#Feed the extracted phrase table back to Moses, starting with step 6 or 7
	#sed 's/phrase-table\.gz/phrase-table\.reduced/' < "$MODELDIR/$SOURCE-$TARGET/moses.ini" > "tmp_moses.ini"
	cd $MODELDIR/$SOURCE-$TARGET
	sed 's/phrase-table.gz/phrase-table.reduced/' < "moses.ini" > "tmp_moses.ini"
	echo "4.tmp_moses.ini should contain the reduced phrase table now"
	mv "tmp_moses.ini" "$moses.ini"
	cd ..
	cd ..
	echo "2.Train Moses"
	/apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl -external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile -mgiza -mgiza-cpus 4 --f $SOURCE --e $TARGET --lm 0:3:/home/bart/project2_data/lm/europarl-v7.nl-en.train.blm.en:8 --corpus $ALIGNEDCORPUS -alignment grow-diag-final-and -reordering msd-bidirectional-fe -root-dir $ROOT --first-step 6
	echo "3.Translation begins"
	/apps/smt_tools/decoders/mosesdecoder/bin/moses -f "$MODELDIR/$SOURCE-$TARGET/moses.ini" < "$CORPUS/test/corpusAligned.$SOURCE" > "$TRANSLATIONDIR/translated$SOURCE-$TARGET.$TARGET" 2> "$TRANSLATIONDIR/translation$SOURCE-$TARGET.out"
	echo "4.Compute Bleu scores"
	/apps/smt_tools/decoders/mosesdecoder/scripts/generic/multi-bleu.perl "$CORPUS/test/corpusAligned.$TARGET"	< "$TRANSLATIONDIR/translated$SOURCE-$TARGET.$TARGET"
done