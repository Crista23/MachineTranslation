##### Corpus preprocessing: #####
corpusRaw=/home/sveldhoen/MTProject3/data/corpusRaw
corpusClean=/home/sveldhoen/MTProject3/data/corpusClean
corpusAligned = /home/sveldhoen/MTProject3/data/corpusAligned
corpusReady=/home/sveldhoen/MTProject3/data/corpusReady

### run cleanCorpus.perl from the Moses distribution ###
#   lowercase, remove empty lines,
#   remove sentences that are too long

target=en
sources=(da de el es fr it nl pt)

for source in ${sources[*]}
do
    if [ -f $corpusClean/$source-$target.$target ];
    then
        echo "Corpus $source-$target in place"
    else
        echo "Preprocessing corpus $source-$target..."
        /apps/smt_tools/decoders/mosesdecoder/scripts/training/clean-corpus-n.perl \
        -lc \
        $corpusRaw/$source-$target/europarl-v7.$source-$target\
        $source $target \
        $corpusClean/$source-$target \
        1 50
        echo "Done"
    fi
done

### align parallel corpora ###
#   Align the source files with sentences
#   that are translated into the same target sentence

python alignCorpus.py

### Split into train- and test set ###
mkdir $corpusReady/train
mkdir $corpusReady/test
for source in ${sources[*]}
do
    cat $corpusAligned/$source-en.$source \
    | awk -v                              \
    '{if(NR % 50 < 1){print $0 > "tmp.test"} else {print $0 > "tmp.train"}'                           \
    cat tmp.test > $corpusReady/test/corpus.$source
done
cat $corpusAligned/en.en \
| awk -v                              \
'{if(NR % 50 < 1){print $0 > "tmp.test"} else {print $0 > "tmp.train"}'                           \
cat tmp.test > $corpusReady/test/corpus.en
rm tmp.test
rm tmp.train