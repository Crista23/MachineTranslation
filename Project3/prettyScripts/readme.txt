This folder contains the following scripts:

- preprocessing.sh
       run Moses' built in preprocessing and run alignCorpus.sh
- alignCorpus.sh
       align the sentences of the various language pairs
- splitAndGiza.sh
       split the data into train and test
       train Giza (Moses step 1 and 2)
- splitCorpus.sh
       called by several scripts, to split a data folder: take each 50th line for test/ held-out
- symmetrizeAlignments.sh
       obtain symmetrized alignments for three heuristics (Moses step 3)

- extractPhraseTables.sh
       extract the phrase tables for the various experiments
       calls the script extendedPhraseExtraction.py
- extendedPhraseExtraction.py
       extended phrase extraction algorithm, that uses evidence from reference foreign alignments
- computeCoverage.sh
       compute the coverage of a phrase table as compared to a held-out one

- trainTranslateBleu.sh
       Baseline; Train Moses step 4-9
       Decode
       Compute Bleu
- johnsonPruning.sh
       applies the Johnson filtering method to the baseline phrase table, 
       and then feeds it back into Moses for translation