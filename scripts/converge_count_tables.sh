
novel=$1
tasi=$2
cons=$3
awk '{if(NR>1){print $1}}' $tasi > tasi.seq
grep -w -f tasi.seq $novel | awk '{print $1}' | xargs -n 1 -I pattern sed -ir "s:pattern\tnovel\t:pattern\tnovel-tasi\t:g" $novel 
grep "tasi" $novel | awk '{print $1}' > novel-tasi.seq
grep -v "lib" $tasi | grep -wvf novel-tasi.seq >> $novel
grep -v "lib" $cons >> $novel
