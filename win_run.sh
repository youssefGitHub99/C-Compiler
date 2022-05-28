bison -b y -d bas_organized.y
flex bas.l
gcc lex.yy.c y.tab.c number.c 
./a.exe
$SHELL