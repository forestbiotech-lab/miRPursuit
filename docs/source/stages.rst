======
Stages
======

This is an overview of the organizational structure of miRPursuit. This is useful if you want to re-do the analysis of the pipeline with different parameters only from a specific stage onward. This way you can avoid unnecessary repeating of stages.

The workflow is divided in 4 main stages:
 * `Pre-preprocessing`_
 * `Filtering`_
 * `Annotation`_
 * `Reporting`_


.. image:: https://raw.githubusercontent.com/forestbiotech-lab/sRNA-workflow/master/images/Figure1-miRPursuit.png
	:alt: miRPursuit workflow schema
**Image 1** - miRPursuit general schema.
   

--------------------
_`Pre-preprocessing`
--------------------
There are multiple entry points depending on the form of the raw data.
Some NGS sequencing service providers might ship your data already trimmed for adaptors, or you might want to use the raw data provided directly by the sequencing equipment, or you might want to use fasta files compiled from another source. 

By using miRPursuit you can specify the type of input file you will use. 
The most simple is the **- -fasta** flag that searches the inserts_dir path ( see config files `workdir.cfg <config.html#workdirs>`_ ) for the target .fa/.fasta libraries and makes a copy to the project folder. In case no .fa/.fasta files are found the program will also search for compressed .fa.gz/.fasta.gz files and proceed to uncompress them.


In case the libraries are still in the fastq format the **- -fastq** flag should be given. This method does a quality control (fastqc not yet but soon) and then converts the fastq libraries to .fasta, analogously to what is done with "fasta" files, compressed fq.gz/fastq.gz files will be uncompressed if no .fq/.fastq file is found. 


Additionally, the **- -trim** flag can be set to remove adaptor sequences. This requires the adaptor sequence to be stored in the adaptor var (see config files `workdir.cfg <config.html#workdirs>`_ ).



------------
_`Filtering`
------------
**Filtering Databases**
 The fasta sequences are filtered based on their length, abundance, low complexity and t/r RNA are removed. These parameters can be set in the `wbench_filter.cfg <config.html#wbench-filter>`_ configuration file.


**Genome and miRBase** 
 The reads are further filtered by mapping them to the setup genome file with '0' mismatches using patman. These parameters can be set in the `patman_genome.cfg <config.html#patman-genome>`_ configuration file.

-------------
_`Annotation`
-------------
**Identification of conserved miRNAs (miRBase)**
 The mapped reads are then aligned to the miRBase⁺ (ref) database using miRProf with the parameter set in the `wbench_mirprof.cfg <config.html#wbench-mirprof>`_ configuration file.
 The genome mapped reads are separated into two files per library those that mapped with miRBase (conserved reads) and those that did not (non conserved reads).

.. Important:: Adding previously known sequences to the miRBase set, requires following some rules. The fasta headers of the known sequences must respect the following rules:

Plants: Three letter code of sepecies "-" miR + identification of the source with letters + serialization

Example:: 

	>ath-miRmyDB00001

	Outputs:
	>all-combined-mirmydb00001_1_Abundance(XX)



**tasiRNA prediction**
 The non conserved reads are run through the `ta-si predictor <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/ta-si-prediction/>`_ to identify trans acting siRNA (tasi-RNA) using the parameters in the `wbench_tasi.cfg <config.html#wbench-tasi>`_

**Novel miRNA** 
 .. [This will soon be changed to use conserved miRNAs alongside with non-conserved]
 .. [detail this more? It isn't the pipeline that is  responsible for this]

 The non conserved reads are also used to predict novel miRNA with `miRCat <http://srna-workbench.cmp.uea.ac.uk/tools/analysis-tools/mircat/>`_ by searching the genome for their respective precursor nucleotide sequences in the setup genome file. The parameters used by miRCat are set in the `wbench_mircat.cfg <config.html#wbench-mircat>`_ configuration file and the genome file is set in the `workdirs.cfg <config.html#workdirs>`_ . If  memory (RAM) restrictions apply, the genome can be split into several parts and miRCat will be run once for each part. The various parts should all be held in the same directory with a common name which includes the word part and the sequential number. Afterwards the resulting files will be merged and filtered to remove miRNAs that paired with more genome sites than those specified in the configuration file `wbench_mircat.cfg <config.html#wbench-mircat>`_.

------------
_`Reporting`
------------
**Merging results and stepwise stats**
 The number of sequences kept in each step are given for each library, both total numbers and distinct numbers of sequences. The identified sequences and their respective absolute count are stored in a tab separate value file (.tsv). This provides easy exportation to most statistical softwares as well as MS Excel.
 The precursor predictions are agregated in the /counts/global-miRCat.csv file, Showing all the non-redundant precursores predicted for each miRNA. 


.. TODO
.. Various other tables and a report file is generated. 


----------
_`Targets`
----------
**Validation of targets**
 Target validation is done based on the supplied degradome and transcriptome information, which are both necessary to perform this analysis. The file paths are stored in the `workdirs.cfg <config.html#workdirs>`_  configuration file and the parameters are stored in `wbench_paresnip.cfg <config.html#wbench-paresnip>`_ configuration file.
