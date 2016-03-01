Config files
====

There are three types of config files, General use, Module specific and System parameters.

**General use** 
  Are those that are used by the main script to feed specific locations or general configuration parameters 

**Module specific** 
  Are configurations that are used by the module. The names of these config files start with the wbench prefix.

**System parameters** 
  These configs hold the values of colors and others miscellanous variables for ease of access.

General use
^^^^^^^^^^^
  * software_dirs.cfg::

      #Path were install script will install software
      SOFTWARE=
      #Path to workbench http://srna-workbench.cmp.uea.ac.uk/
      WBENCH_DIR=
      #Path to java use 1.7 or greater
      JAVA_DIR=
      #Number of times program has been run
      RUN=0

  * workdirs.cfg::

      #Workdir is the path to the directory where this program will run data
      #workdir must end with trailing "/"
      workdir=
      #Path to the mirbase database. Go to http://www.mirbase.org or download latest from: ftp://mirbase.org/pub/mirbase/CURRENT/
      MIRBASE=${HOME}/Downloads/source_data/mirbase21/mature.fa
      #Used by java
      MEMORY="4g"
      #Set this to the max number of processed that can be used
      THREADS=
      #Path to the directory to get the input data
      INSERTS_DIR=~/Downloads/git/sRNA-workflow/testDataset
      #Path to the genome to be used
      GENOME=/home/brunocosta/Downloads/source_data/genomes/c.canephora/pseudomolecules.fa
      #Path to the genome to be used by mircat. Leave this, as ${GENOME} if no memory resctrictions apply to your case. Check manual on using parts      
      GENOME_MIRCAT=${GENOME}      
      #The suffix of the filter to be used. Check /config/workbench_filter_*.cfg      
      FILTER_SUF=18_26_5      
      #LCSciences      
      ADAPTOR="TGGAATTCTCGGGTGCCAAGG"      
      LCSCIENCE_LIB=      
      #These vars are only used for target prediction (PAREsnip)      
      TRANSCRIPTOME=
      DEGRADOME=

Module specific
^^^^^^^^^^^^^^^

There is a config file for each module in the sRNA-workflow/config directory. The default values are posted, for further reference, please consult the website of the respective tool. 

  * wbench_filter.cfg - `Filter <http://srna-workbench.cmp.uea.ac.uk/tools/helper-tools/filter/>`_ your sRNA sequences. Length, abundance, T/R RNA::

      #Broad range default values
      min_length=18
      max_length=26
      min_abundance=5
      max_abundance=2147483647
      norm_abundance=false
      filter_low_comp=true
      filter_invalid=true
      trrna=true
      trrna_sense_only=false
      filter_genome_hits=false
      filter_norm_abund=false
      filter_kill_list=false
      add_discard_log=false
      genome=null
      kill_list=null
      discard_log=null

  * wbench_mircat.cfg - `miRCat <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/mircat/>`_ predict novel miRNAs through alignment with genome to find putative precursors::
      
      #Default values (Broad) 
      extend=100.0
      min_energy=-25.0
      min_paired=17
      max_gaps=3
      max_genome_hits=16
      min_length=18
      max_length=26
      min_gc=20
      max_unpaired=60
      max_overlap_percentage=80
      min_locus_size=1
      orientation=80
      min_hairpin_len=60
      complex_loops=true
      pval=0.05
      min_abundance=1
      cluster_sentinel=200
      Thread_Count=12

  

      #Default (plants)
      extend=100.0
      min_energy=-25.0
      min_paired=17
      max_gaps=3
      max_genome_hits=16
      min_length=20
      max_length=22
      min_gc=20
      max_unpaired=50
      max_overlap_percentage=80
      min_locus_size=1
      orientation=80
      min_hairpin_len=60
      complex_loops=true
      pval=0.05
      min_abundance=1
      cluster_sentinel=200
      Thread_Count=20

  * wbench_mirprof.cfg - `miRProf <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/mirprof/>`_ identifies conserved miRNA, through alignment to the `miRBase <http:://mirbase.org>`_ database of miRNA:: 

      #Default values	
      mismatches=0
      overhangs=true
      group_mismatches=true
      group_organisms=true
      group_variant=true
      group_mature_and_star=false
      only_keep_best=true
      min_length=18
      max_length=26
      min_abundance=5

  * tasi.cfg - `ta-si predictor <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/ta-si-prediction/>`_, identifies phased 21nt sRNAs characterisctic of ta-siRNA loci::

      #Default values
      p_val_threshold=1.0E-4
      min_abundance=2

  * paresnip.cfg - `PAREsnip <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/paresnip/>`_ validates targets of regultation by sRNAs requires degradome and a transcriptome sequences::

  	  #Default values	
      min_sRNA_abundance=5
      subsequences_are_secondary_hits=false
      output_secondary_hits_to_file=false
      use_weighted_fragments_abundance=true
      category_0=true
      category_1=true
      category_2=true
      category_3=true
      category_4=false
      discard_tr_rna=true
      discard_low_complexity_srnas=false
      discard_low_complexity_candidates=false
      min_fragment_length=20
      max_fragment_length=21
      min_sRNA_length=19
      max_sRNA_length=24
      allow_single_nt_gap=false
      allow_mismatch_position_11=false
      allow_adjacent_mismatches=false
      max_mismatches=4.0
      calculate_pvalues=true
      number_of_shuffles=100
      pvalue_cutoff=0.05
      do_not_include_if_greater_than_cutoff=true
      number_of_threads=23
      auto_output_tplot_pdf=false


System parameters
^^^^^^^^^^^^^^^^^

These are generally hardcoded, don't change these unless you know what you are doing.

  * term-colors.cfg - Colors for terminal and other usefull vars.