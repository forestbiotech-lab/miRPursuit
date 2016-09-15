#Used to convert legacy conserved fasta to acuall and vice-versa

list=$1

for i in list
 do
 tmp=tmp123
 sed -r "s:all-combined:all combined:g" $i > $tmp
 mv $tmp $i 
done
