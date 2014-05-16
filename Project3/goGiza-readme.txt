the script goGiza is in mijn directory: sveldhoen@deze.science.nl:MTProject3
Its current version is also in the github folder.
It calls upon Moses training steps 1-3, which is the traing up to the Giza alignments. No symmetrization is done, that can be done in training step 4.


To call this script (with nohup):

nohup bash goGiza.sh [source] [target] [run] > [outputfile] &

[source] - the source language extension, eg fr
[target] - the target language extension, probably always en
[run] - an identifier for the run, e.g. a number or date. Note that the script appends the source and target language to the run, so you can use the same runnumber for different language pairs if you run them simultaneously
[outputfile] - the file which the output should be written to, instead of nohup.out (tha latter is problematic when running multiple nohup commands at the same time)