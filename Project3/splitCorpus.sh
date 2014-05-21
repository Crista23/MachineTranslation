FILES=$1/*.*
SMALL=$2
mkdir -p "$1/$SMALL/"
mkdir -p "$1/training/"
for f in $FILES;
do
  cat $f \
  | awk '{if(NR % 50 < 1){print $0 > "tmp.01"} else {print $0 > "tmp.02"}}'
  name=${f##*/}
  mv "tmp.01" "$1/$SMALL/$name"
  mv "tmp.02" "$1/training/$name"
done