Config files
====

There are three types of config files, General use, Module specific and System parameters.

**General use** 
  Are those that are used by the main script to feed specific locations or general configuration parameters 

**Module specific** 
  Are configurations that are used by the module. The names of these config files start with the wbench prefix.

**System parameters** 
  These configs hold the values of colors and others misclanious variables for ease of access.

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
      #These var are only used for target prediction (PAREsnip)      
      TRANSCRIPTOME=
      DEGRADOME=

Module specific
^^^^^^^^^^^^^^^

There is a config file for each module in the sRNA-workflow/config directory

  * wbench_filter.cfg - `Filter <http://srna-workbench.cmp.uea.ac.uk/tools/helper-tools/filter/>`_ your sRNA sequences. Length, abundance, T/R RNA.
  * wbench_mircat.cfg - `miRCat <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/mircat/>`_ predict novel miRNAs through alignment with genome to find putative precursors.
  * wbench_mirprof.cfg - `miRProf <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/mirprof/>`_ identifies sequences:: 

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

  * tasi.cfg - `ta-si predictor <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/ta-si-prediction/>`_::

		#Default values
		p_val_threshold=1.0E-4
		min_abundance=2

  * paresnip.cfg - `PAREsnip <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/paresnip/>`_




System parameters
^^^^^^^^^^^^^^^^^

These are generally hardcoded, don't change these unless you know what you are doing.

  * term-colors.cfg - Colors for terminal and other usefull vars.


