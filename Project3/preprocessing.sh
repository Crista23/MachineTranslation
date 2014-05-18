### Assume the following variables and files in place: ###
corpusRaw=/home/sveldhoen/MTProject3/data/corpusRaw
#   the raw (downloaded) corpus directory
#   that has files: europarl-v7.$source-$target.$source and europarl-v7.$source-$target.$target
corpusClean=/home/sveldhoen/MTProject3/data/corpusClean
corpusAligned=/home/sveldhoen/MTProject3/data/corpusAligned
# the source and target languages:
target=en
sources=(da de el es fr it en nl pt)

### Corpus preprocessing: ###
# - run cleanCorpus.perl from the Moses distribution
#   lowercase, remove empty lines, remove sentences that are too long
#   bash command (on Deze):

   for source in ${sources[*]}
   do
       if [ -f $corpusClean/$source-$target.$target];
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
#- align parallel corpora
#  Align the source files with sentences that are translated into the same target sentence
#   input: $corpusClean/$source-$target.$source and  $corpusClean/$source-$target.$target for all sources
#   output: $corpusAligned/$source-$target.$source and $corpusAligned/$target.$target
