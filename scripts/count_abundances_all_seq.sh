#!/usr/bin/sh
#file where the seq are going
#       destination=~/test-data/liballmir21/
#       mkdir -p $destination
#       seq=${destination}comb_Pt_m_lib1-16_25-43_lc1-3.seq
#       seqR=${destination}comb_Pt_m_lib1-16_25-43_LC1-3.seqR
#       touch $seq
#       #~/lcAll/data/lib0*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa ~/lc-mapped/data/lib0*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa;
#       #for y in ~/sRNA25_30/data/lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa ~/sRNAall/data/lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa ~/sRNA31_36/data/lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa ~/sRNA37_43/data/lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa ~/lcAll/data/lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa   
#
#       for y in ~/sRNAmir21/data/lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa
#       do
#         #echo $y
#         awk -F "[-_\n]" 'BEGIN{RS=">"}{print $3" "$6}' $y >> $seqR
#         awk -F "\n" 'BEGIN{RS=">"}{print $2}' $y >> $seq
#       done
#       #Set where to store common uniq seq
#       uniq=${seq/.seq/.uniq}
#       sort $seq | uniq > $uniq
uniq=~/test-data/allNonCons/lc/allmir-sorted.list

printf "lib01\tlib02\tlib03\tlib04\tlib05\tllib06\tlib07\tlib08\tlib09\tlib10\tlib11\tlib12\tlib13\tlib14\tlib15\tlib16\tLC1\tLC2\tLC3\tlib25\tlib26\tlib27\tlib28\tlib29\tlib30\tlib31\tlib32\tlib33\tlib34\tlib35\tlib36\tlib37\tlib38\tlib39\tlib40\tlib41\tlib42\tlib43\n" # > ~/test-data/allmiR/noncounts-count.tsv

#printf "lib25\tlib26\tlib27\tlib28\tlib29\tllib30\n"

nl=$(wc -l $uniq | awk '{print $1}')
echo $nl
lib1_5=~/test-data/allmiR/all/lib15_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase.fa
libLC=${lib1_5/sRNAall/lcAll}
#libLCm=${lib1_5/sRNAall/lc-mapped}
#lib1_5=${lib15_16/sRNA7/sRNA1-5}
lib25_30=~/sRNA25_30/data/lib15_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa
lib31_36=~/sRNA31_36/data/lib15_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa
lib37_43=~/sRNA37_43/data/lib15_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa
for i in {1..21350}; 
do line=$(head -$i $uniq | tail -1 )
   #mir=$(grep -w -m1 $line $seqR | awk '{ print $1 }') 
     
   lib1=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib01} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib2=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib02} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib3=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib03} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib4=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib04} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib5=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib05} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib6=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib06} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib7=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib07} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib8=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib08} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib9=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib09} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib10=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib10} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib11=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib11} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib12=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib12} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib13=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib13} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib14=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib14} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib15=$(grep -B0 -w -m1 $line $lib1_5 | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib16=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib16} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   LC1=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib17} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   LC2=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib18} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   LC3=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib19} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib25=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib25} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib26=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib26} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib27=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib27} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib28=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib28} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib29=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib29} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib30=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib30} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
 
   lib31=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib31} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib32=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib32} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib33=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib33} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib34=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib34} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib35=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib35} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib36=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib36} | awk -F "[()]" '{ if( NR==1 ){print $2}}')

   lib37=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib37} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib38=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib38} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib39=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib39} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib40=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib40} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib41=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib41} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib42=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib42} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   lib43=$(grep -B0 -w -m1 $line ${lib1_5/lib[0-9][0-9]/lib43} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   
#   LC1=$(grep -B0 -w -m1 $line ${libLC/lib[0-9][0-9]/lib01} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#   LC2=$(grep -B0 -w -m1 $line ${libLC/lib[0-9][0-9]/lib02} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#   LC3=$(grep -B0 -w -m1 $line ${libLC/lib[0-9][0-9]/lib03} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  LC1m=$(grep -B0 -w -m1 $line ${libLCm/lib[0-9][0-9]/lib01} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  LC2m=$(grep -B0 -w -m1 $line ${libLCm/lib[0-9][0-9]/lib02} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  LC3m=$(grep -B0 -w -m1 $line ${libLCm/lib[0-9][0-9]/lib03} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
  
#  lib25=$(grep -B0 -w -m1 $line ${lib25_30/lib[0-9][0-9]/lib25} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib26=$(grep -B0 -w -m1 $line ${lib25_30/lib[0-9][0-9]/lib26} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib27=$(grep -B0 -w -m1 $line ${lib25_30/lib[0-9][0-9]/lib27} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib28=$(grep -B0 -w -m1 $line ${lib25_30/lib[0-9][0-9]/lib28} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib29=$(grep -B0 -w -m1 $line ${lib25_30/lib[0-9][0-9]/lib29} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib30=$(grep -B0 -w -m1 $line ${lib25_30/lib[0-9][0-9]/lib30} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#
#  lib31=$(grep -B0 -w -m1 $line ${lib31_36/lib[0-9][0-9]/lib31} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib32=$(grep -B0 -w -m1 $line ${lib31_36/lib[0-9][0-9]/lib32} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib33=$(grep -B0 -w -m1 $line ${lib31_36/lib[0-9][0-9]/lib33} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib34=$(grep -B0 -w -m1 $line ${lib31_36/lib[0-9][0-9]/lib34} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib35=$(grep -B0 -w -m1 $line ${lib31_36/lib[0-9][0-9]/lib35} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib36=$(grep -B0 -w -m1 $line ${lib31_36/lib[0-9][0-9]/lib36} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#
#  lib37=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib37} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib38=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib38} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib39=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib39} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib40=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib40} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib41=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib41} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib42=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib42} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
#  lib43=$(grep -B0 -w -m1 $line ${lib37_43/lib[0-9][0-9]/lib43} | awk -F "[()]" '{ if( NR==1 ){print $2}}')
   wait
   if [ -z "$lib1" ]; then
     lib1=0
   fi
   if [ -z "$lib2" ]; then
     lib2=0
   fi
   if [ -z "$lib3" ]; then
     lib3=0
   fi
   if [ -z "$lib4" ]; then
     lib4=0
   fi
   if [ -z "$lib5" ]; then
     lib5=0
   fi
   if [ -z "$lib6" ]; then
     lib6=0
   fi
  if [ -z "$lib7" ]; then
    lib7=0
  fi
  if [ -z "$lib8" ]; then
    lib8=0
  fi
  if [ -z "$lib9" ]; then
    lib9=0
  fi
  if [ -z "$lib10" ]; then
    lib10=0
  fi
  if [ -z "$lib11" ]; then
    lib11=0
  fi
  if [ -z "$lib12" ]; then
    lib12=0
  fi
  if [ -z "$lib13" ]; then
    lib13=0
  fi
  if [ -z "$lib14" ]; then
    lib14=0
  fi
  if [ -z "$lib15" ]; then
    lib15=0
  fi
  if [ -z "$lib16" ]; then
    lib16=0
  fi  
  if [ -z "$LC1" ]; then
    LC1=0
  fi
  if [ -z "$LC2" ]; then
    LC2=0
  fi
  if [ -z "$LC3" ]; then
    LC3=0
  fi
#  if [ -z "$LC1m" ]; then
#    LC1m=0
#  fi
#  if [ -z "$LC2m" ]; then
#    LC2m=0
#  fi
#  if [ -z "$LC3m" ]; then
#    LC3m=0
#  fi  
   if [ -z "$lib25" ]; then
     lib25=0
   fi
   if [ -z "$lib26" ]; then
     lib26=0
   fi
  if [ -z "$lib27" ]; then
    lib27=0
  fi
  if [ -z "$lib28" ]; then
    lib28=0
  fi
  if [ -z "$lib29" ]; then
    lib29=0
  fi
  if [ -z "$lib30" ]; then
    lib30=0
  fi  
   if [ -z "$lib31" ]; then
     lib31=0
   fi
   if [ -z "$lib32" ]; then
     lib32=0
   fi
   if [ -z "$lib33" ]; then
     lib33=0
   fi
   if [ -z "$lib34" ]; then
     lib34=0
   fi
   if [ -z "$lib35" ]; then
     lib35=0
   fi
   if [ -z "$lib36" ]; then
     lib36=0
   fi
  if [ -z "$lib37" ]; then
    lib37=0
  fi
  if [ -z "$lib38" ]; then
    lib38=0
  fi
  if [ -z "$lib39" ]; then
    lib39=0
  fi
  if [ -z "$lib40" ]; then
    lib40=0
  fi
  if [ -z "$lib41" ]; then
    lib41=0
  fi
  if [ -z "$lib42" ]; then
    lib42=0
  fi
  if [ -z "$lib43" ]; then
    lib43=0
  fi
   printf $line"\t"$mir"\t"$lib1"\t"$lib2"\t"$lib3"\t"$lib4"\t"$lib5"\t"$lib6"\t"$lib7"\t"$lib8"\t"$lib9"\t"$lib10"\t"$lib11"\t"$lib12"\t"$lib13"\t"$lib14"\t"$lib15"\t"$lib16"\t"$LC1"\t"$LC2"\t"$LC3"\t"$lib25"\t"$lib26"\t"$lib27"\t"$lib28"\t"$lib29"\t"$lib30"\t"$lib31"\t"$lib32"\t"$lib33"\t"$lib34"\t"$lib35"\t"$lib36"\t"$lib37"\t"$lib38"\t"$lib39"\t"$lib40"\t"$lib41"\t"$lib42"\t"$lib43"\n" #>> ~/test-data/allmiR/noncounts-count.tsv
#   printf $line"\t"$mir"\t"$lib1"\t"$lib2"\t"$lib3"\t"$lib4"\t"$lib5"\t"$lib6"\n"

done

