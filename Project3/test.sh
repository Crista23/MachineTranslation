source=$1
target=$2
run=$3-$source-$target

#Preprocess the corpus (if necessary)
# i.e.: lowercase, remove empty lines, remove long sentences (50<)
echo "Corpus in place, start Moses"