Config files
====

There are three types of config files, General use, Module specific and System parameters.

**General use** 

  Are those that are used by the main script to feed specific locations or general configuration parameters 

**Module specific** 
  
  Are configurations that are used by the module. The names of these config files start with the wbench prefix.

**System parameters** 
  
  These configs hold the values of colors and others misculations variables for ease of access.

General use
^^^^^^^^^^^
 * software_dirs.cfg
 * workdirs.cfg

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

		p_val_threshold=1.0E-4
		min_abundance=2
		
  * paresnip.cfg - `PAREsnip <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/paresnip/>`_




System parameters
^^^^^^^^^^^^^^^^^

These are generally hardcoded, don't change these unless you know what you are doing.

  * term-colors.cfg - Colors for terminal and other usefull vars.


