source=$1
target=$2
run=$3-$source-$target
root=/home/sveldhoen/MTProject3/
data=$root/data/$source-$target

#Get Giza alignments

/apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl     \
--parallel     \
-external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
--root-dir $root/mosesOutput/$run \
--corpus $data/cleanLC  \
--f $source    \
--e $target    \
--first-step 1 \
--last-step 2  \
-mgiza -mgiza-cpus 4

#Then, run step 3 seven times to get alignment for the different heuristics:

for al in intersect, union, grow, grow-final, grow-diag, grow-diag-final, grow-diag-final-and
do
  /apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl     \
  --parallel     \
  -external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
  --root-dir $root/mosesOutput/$run \
  --corpus $data/cleanLC  \
  --f $source    \
  --e $target    \
  --first-step 3 \
  --last-step 3  \
  --giza-f2e $ROOT/giza-$source-$target \
  --giza-e2f $ROOT/giza-$target-$source \
  -mgiza -mgiza-cpus 4
  --alignment $al
done



#Reference: All Training Parameters
#--root-dir     # root directory, where output files are stored
#--corpus       # corpus file name (full pathname), excluding extension
#--e            # extension of the English corpus file
#--f            # extension of the foreign corpus file
#--lm           # language model:<factor>:<order>:<filename>(option can be repeated)
#--first-step   # first step in the training process (default 1)
#--last-step    # last step in the training process (default 7)
#--parts        # break up corpus in smaller parts before GIZA++ training
#--corpus-dir   # corpus directory (default $ROOT/corpus)
#--lexical-dir  # lexical translation probability directory (default $ROOT/model)
#--model-dir    # model directory (default $ROOT/model)
#--extract-file # extraction file (default $ROOT/model/extract)
#--giza-f2e     # GIZA++ directory (default $ROOT/giza.$F-$E)
#--giza-e2f     # inverse GIZA++ directory (default $ROOT/giza.$E-$F)
#--alignment    # heuristic used for word alignment: intersect, union, grow, grow-final, grow-diag, grow-diag-final(default), grow-diag-final-and, srctotgt, tgttosrc
#--max-phrase-length # maximum length of phrases entered into phrase table (default 7)
#--giza-option       # additional options for GIZA++ training
#--verbose           # prints additional word alignment information
#--no-lexical-weighting # only use conditional probabilities for the phrase table, notlexical weighting
#--parts             # prepare data for GIZA++ by running snt2cooc in parts
#--direction         # run training step 2 only in direction 1 or 2 (for parallelization)
#--reordering        # specifies which reordering models to train using a comma-separated list of config-strings, see FactoredTraining.BuildReorderingModel (Section 5.10). (default distance)
#--reordering-smooth # specifies the smoothing constant to be used for training lexicalized reordering models. If the letter "u" follows the constant, smoothing is based on actual counts. (default 0.5)
#--alignment-factors
#--translation-factors
#--reordering-factors
#--generation-factors
#--decoding-steps
