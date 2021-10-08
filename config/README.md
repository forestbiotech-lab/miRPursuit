This folder holds all the config files.
=======================================

Each config holds parameters necessary to run each program within the pipeline.

Start by setting up the software_dirs.cfg

Afterwards set the workdir.cfg 

The filters dir holds pre-set filters to be used.
================================================
 To create a new filter just copy the default file wbench_filter_default.cfg in defaults directory, and change the name from default to the desired filter_sufix.
 Each time the program is run the parameters from the chosen filter are copied to the wbench_filter_in_use.cfg

For more information on each file please checkout: http://srna-workflow.readthedocs.org/en/master/config.html




File outputs map
================


-> counts_merge.sh

  all_seq_counts_novel.tsv
  all_seq_counts_nonCons.tsv
  all_seq_counts_tasi.tsv
  all_seq_counts_novelTasi.tsv
  all_seq_counts_cons.tsv
  all_seq_cons.seq
  all_seq_star.seq
  all_seq.tsv

-> ??scripts/count_abundance.sh??
all_seq_novel.seq
all_seq_novelTasi.seq
all_seq_tasi.seq


-> counts_merge.sh>merge_conserved.py
  
  all_seq_counts_cons_merged.tsv


-> write_report.sh>scripts/graph_sizedistr.R

  images


-> write_report.sh

  miRPursuit_REPORT-RunXXXXXX.tex


-> write_report.sh>scripts/size-fasta.py

  LibXX-filtered-profile.tsv
  LibXX-profile.tsv


-> scripts/report.sh

  Cons-LibXXX-XXX.tsv
  Fasta-LibXXX-XXX.tsv
  Filter-LibXXX-XXX.tsv
  Genome-LibXXX-XXX.tsv
  Novel-Global-LibXXX-XXX.tsv
  Novel-LibXXX-XXX.tsv
  TASI-LibXXX-XXX.tsv
