workdir=

cd ${workdir}/data/mircat
mkdir -p ${workdir}/count/graph
awk -F "," '{printf $7"\t"$6"\t"$2"\t"$3"-"$4"\n"}' Lib02_filt-18_26_5_corkoak-v0.2_mirbase_noncons_output_filtered.csv > ../../count/graph/miRCat-nodes.tsv
cd ../../count/
cat all_seq_counts_cons.tsv | awk '{if(NR>1){printf $1"\t"$2"\n"}}' > graph/cons.dic
cd graph
awk '{print $1}' cons.dic | sort | uniq > cons.seq
awk '{print $1}' miRCat-nodes.tsv | sort | uniq | grep -vw -f cons.seq > novel.seq
awk '{printf $1"\tnov00"NR"\n"}' novel.seq > novel.dic
cat cons.dic novel.dic > cons_novel.dic
~/mergeFile.py --input2 cons_novel.dic --input1 miRCat-nodes.tsv --output miRCat-nodes-named.tsv --col_key_num_input1 0 --col_key_num_input2 0 --col_value_num_input2 1
awk '{printf $2"\t"NR"\n"}' cons_novel.dic > mir.nodes
awk '{if(NR>1){print $3}}' miRCat-nodes-named.tsv | sort | uniq > genome.seq
id=$(tail -1 mir.nodes | awk '{print $2}')
awk -v start=$id '{printf $1"\t"NR+start"\n"}' genome.seq > genome.nodes
echo "id\tLabel" > nodes.tsv;cat mir.nodes genome.nodes | awk '{printf $2"\t"$1"\n"}' >> nodes.tsv
~/mergeFile.py --input2 mir.nodes --input1 miRCat-nodes-named.tsv --output miRCat-nodes-named-mir.tsv --col_key_num_input1 4 --col_key_num_input2 0 --col_value_num_input2 1
~/mergeFile.py --input2 genome.nodes --input1 miRCat-nodes-named-mir.tsv --output miRCat-nodes-named-mir-genome.tsv --col_key_num_input1 2 --col_key_num_input2 0 --col_value_num_input2 1
echo "Source\tTarget" > edges.tsv; awk '{if(NR > 1){printf $6"\t"$7"\n"}}' miRCat-nodes-named-mir-genome.tsv >> edges.tsv

#missing classification in cons novel and genome
#missing star
