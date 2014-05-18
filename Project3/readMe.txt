### Assume the following variables and files in place: ###
corpusRaw= /home/sara/MTProject3/data/corpusRaw/
#   the raw (downloaded) corpus directory
#   that has files: europarl-v7.$source-$target.$source and europarl-v7.$source-$target.$target
corpusClean= /home/sara/MTProject3/data/corpusClean
corpusAligned= /home/sara/MTProject3/data/corpusAligned
# the source and target languages:
target = en
sources = (fr, ro, nl)

### Corpus preprocessing: ###
- run cleanCorpus.perl from the Moses distribution
   lowercase, remove empty lines, remove sentences that are too long
- align parallel corpora
  Align the source files with sentences that are translated into the same target sentence
### Get word alignments: ###
- run Moses steps 1-2: mGiza, for all language pairs
- convert mGiza output to processable syntax: convertAlignments.py
- run Moses step 3 for all possible symmetrization heuristics
### Extract phrases: ###

### Decode and evaluate: ###
- Use the extracted phrases and probabilities in Moses decoding
  NB: somethign with smoothing? Other parameters?
- Run Moses baseline
- Run Moses with other filtering methods (Johnson, see page 166 in the Moses Manual)





