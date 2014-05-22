1. Preprocessing the corpus
Downloading, cleaning, aligning
the script preprocessing.sh



2. 

the script splitAndGiza.sh assumes the aligned corpus in a directory $CORPUS with files that have the same name, but different extensions (e.g. corpus.en, corpus.de, corpus.fr, etc).

Run the script:
nohup bash splitAndGiza > splitAndGiza.out &

