#!/bin/sh

set -e

unzip -p $1 occurrence_*.txt | awk '!seen[$0]++' > occurrence.txt

zip -jqr9X $1 occurrence.txt

rm occurrence.txt

zip -djqr9X $1 occurrence_*.txt

unzip -p $1 meta.xml > meta.xml

sed -i '/<location>/c\      <location>occurrence.txt</location>' meta.xml

uniq meta.xml > meta.xml.new

mv meta.xml.new meta.xml

zip -jqr9X $1 meta.xml

rm meta.xml

exit 0
