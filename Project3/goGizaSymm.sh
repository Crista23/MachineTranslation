source=$1
target=$2
run=$3-$source-$target

#Get Giza alignments for different heuristics:
# intersect, union, grow, grow-final, grow-diag, grow-diag-final(default), grow-diag-final-and

for al in intersect, union, grow, grow-final, grow-diag, grow-diag-final, grow-diag-final-and
do
  /apps/smt_tools/decoders/mosesdecoder/scripts/training/train-model.perl     \
  --parallel     \
  -external-bin-dir /apps/smt_tools/alignment/mgizapp-0.7.3/manual-compile \
  --root-dir /home/sveldhoen/MTProject3/mosesOutput/$run \
  --corpus /home/sveldhoen/MTProject3/data/$source-$target/europarl-v7.$source-$target  \
  --f $source    \
  --e $target    \
  --first-step 3 \
  --last-step 3  \
  --giza-f2e $ROOT/giza-$source-$target \
  --giza-e2f $ROOT/giza-$target-$source \
  -mgiza -mgiza-cpus 4
  --alignment $al
done
