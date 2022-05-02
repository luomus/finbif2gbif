#!/bin/bash

unzip -p $1 occurrence_*.txt | awk -F'\t' '!seen[$1]++' > occurrence.txt

zip -jqr9X $1 occurrence.txt

rm occurrence.txt

zip -djqr9X $1 occurrence_*.txt

unzip -l $1 | grep -q media_

if [ "$?" == "0" ]

then

  unzip -p $1 media_*.txt | awk -F'\t' '!seen[$1]++' > media.txt

  zip -jqr9X $1 media.txt

  rm media.txt

  zip -djqr9X $1 media_*.txt

fi

unzip -p $1 meta.xml > meta.xml

sed -i '/<location>occurrence_/c\      <location>occurrence.txt</location>' meta.xml

sed -i '/<location>media_/c\      <location>media.txt</location>' meta.xml

uniq meta.xml > meta.xml.new

mv meta.xml.new meta.xml

zip -jqr9X $1 meta.xml

rm meta.xml

exit 0
