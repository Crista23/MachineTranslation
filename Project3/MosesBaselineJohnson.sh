#rootdir=$1 #/home/ggarbacea/SSLP
#trainingCorpus=$2 #/home/ggarbacea/SSLP/Project2/training/p2_training, /home/sveldhoen/MTProject3/data, /home/ggarbacea/SSLP/Project3
#alignedCorpus="$trainingCorpus/corpusAligned"
#testCorpus=$3 #should be /home/bart/project2_data/test, after concatenating with the source it should be /home/bart/project2_data/test/p2_test.nl
			  # on Deze: /home/sveldhoen/MTProject3/data/corpusMiniTest/test
#translationLocation=$4 # should be /home/ggarbacea/SSLP/Project3TranslationResults, whole path is /home/ggarbacea/SSLP/TranslationResults/translat#edtestNLtoENG.en


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
ALIGNEDCORPUS=/home/sveldhoen/MTProject3/data/corpusMiniTest/corpusAligned
TRANSLATIONDIR=$ROOT/TranslationResults

TARGET=en
SOURCES=(da de es fr it nl pt)

for SOURCE in ${SOURCES[*]}
do
	echo "Source language is:"
	echo $SOURCE
	
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
	
	echo "Evaluation begins"
	/apps/smt_tools/decoders/mosesdecoder/bin/moses \
	-f "$MODELDIR/$SOURCE-$TARGET/moses.ini" 				#"$rootdir/MosesBaseline/$source/model/moses.ini" \ 	 			#/home/ggarbacea/SSLP/MosesResults/model/moses.ini \
	< "$CORPUS/test/corpusAligned.$SOURCE"   				#"$testCorpus/p2_test.$source" \
	> "$TRANSLATIONDIR/translated$SOURCE-$TARGET.$TARGET"   #"$translationLocation/translatedtest$source-to$target.$target" \ 	#/home/ggarbacea/SSLP/TranslationResults/translatedtestNLtoENG.en \
	2> "$TRANSLATIONDIR/translation$SOURCE-$TARGET.out"
	
	echo "Compute Bleu scores"
	#ask Moses to translate
	#/apps/smt_tools/decoders/mosesdecoder/bin/moses \
	#-f "$rootdir/MosesBaseline/$source/model/moses.ini" \ 	 			#/home/ggarbacea/SSLP/MosesResults/model/moses.ini \
	#< "$testCorpus/corpus.$source" \
	#> "$translationLocation/translatedtest$source-to$target.$target" \ 	#/home/ggarbacea/SSLP/TranslationResults/translatedtestNLtoENG.en \
	#2> "$translationLocation/$source-translation.out" 					#/home/ggarbacea/SSLP/TranslationResults/translation.out
	
	#evaluate on test
	
done

#Run baseline on train and evaluate on test
#Run Johnson on train & evaluate on test
#cat phrase-table |  /apps/smt_tools/decoders/mosesdecoder/scripts/training/threshold-filter.perl 0.0001 >  phrase-table.reduced