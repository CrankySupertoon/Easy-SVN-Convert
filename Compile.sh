mkdir bin 2> /dev/null
mkdir build 2> /dev/null
mv build/easysvnconvert.c src/easysvnconvert.sh.x.c  2> /dev/null
echo Building easysvnconvert
shc -vf src/easysvnconvert.sh -o bin/easysvnconvert
echo Build Succeeded
mv src/easysvnconvert.sh.x.c build/easysvnconvert.c 2> /dev/null
