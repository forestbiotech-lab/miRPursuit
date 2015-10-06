# sRNA-workflow
Analysis workflow for smallRNA sequencing data.

<img src="http://www.itqb.unl.pt/labs/forest-biotech/forest-biotechnology" height="200px"/>

This pipeline was build around a core of several modules from the publicly available University of East Anglia small RNA workbench (UEA sRNA WB, [2]), which can be deployed to any unix server to be used via the command line interface, with unix shell scripts performing basic data input and output operations.

The pipeline is optimized to preform batch operations on multiple libraries.
This version is based on the output given by fasteris (tar.gz files need to have *GZT-[lib_n]*.tar.gz format or be put in this format.
However if the .fastq files are in .gz archieves they can also be used given the pattern before the library number.


This is a collection of scripts used to process sRNA based on the Univeristy of east Anglia small RNA workbench 

Stocks MB, Moxon S, Mapleson D, Woolfenden HC, Mohorianu I, Folkes L, Dalmay T, Moulton V: The UEA sRNA workbench: a suite of tools for analysing and visualizing nex generation sequencing microRNA and small RNA datasets.


This version is based on the output given by fasteris (tar.gz files need to have *GZT-[lib_n]*.tar.gz format or be put in this format).

<a href="https://www.fasteris.com/dna/" target="_blank">Fasteris</a>

<h3>How to start:</h3>
  <ul> Make sure you have all the software necessary (Check list) 
    <ul> UEA Workbench Optimized for linux version (~3.2) </ul>
    <ul> Srna-tools ??? toolbench?? perl version?? </ul>
    <ul> Java optimized for version (~1.7) </ul>
  </ul>
  <ul> Set up the variables in the config dir.</ul>
  <ul>You should also have the following software configured in your path
    <ul> [Patman](https://bioinf.eva.mpg.de/patman/)</ul>
    <ul> [Tar](http://linuxcommand.org/man_pages/tar1.html) sudo apt-get install tar</ul>
    <ul> [Fastx Toolkit](http://hannonlab.cshl.edu/fastx_toolkit/) </ul>
  </ul>
  <ul>run sRNAworkFlow.sh</ul>

<h3>Analysing inserts from fasteris</h3>
  !not finished!
  Currently only running for fasteris 
  run extract_fasteris_inserts

<strong>config</strong> - Directory that has all the variables for the workflow.

<ul>workdirs.cfg- Sets variables with directories and files necessary for the project.
  <ul>workdir - path to workdir (will create one if it doesn't exist)</ul>
  <ul>genomes path to genomes</ul>
  <ul>GENOME_MIRCAT  _The path to the genome to be used by mircat. Set to ${GENOME} if you don't need to run various parts. (My be necessary if you have short amount of ram.)"</ul>
  <ul>FILTER_SUF _Filter-suffix to chose the predefined filter settings to be used.</ul>
  <ul>MEMORY  - Amount of memory to be used my java when using memory intensive scripts. Ex:10g, 2000m ... </ul>
  <ul>THREADS - Number of cores to be used during execution</ul>
  <ul>INSERTS_DIR Path to the inserts directory (Fasteris)</ul> 
  <ul>MIRBASE Path to mirbase database</ul>
</ul>
  
<ul>software_dirs.cfg - Sets the directory paths to all major programs</ul>

<ul>filter*.cfg - General parameters for wbench *</ul>
<ul>wbench_mircat.cfg - General parameters for mircat</ul>
<ul>wbench_tasi.cfg - General parameters for TaSi.</ul>

<h3>Programs</h3>

<ul><strong>sRNAworkFlow.sh</strong>
<br>Description: This is the main script that runs the full pipeline.
Some commands are being changed to config files.
<ul>inputs:
  <ul>-f|--lib-first "First library to be processed"</ul>
  <ul>-l|--lib-last "last Library to be processed"</ul>
  <ul>-h|--help "Display help" </ul>
</ul>
<ul>Optional arguments:
  <ul>-s|--step Step is an optional argument used to jump steps and start analysis from a different point.
    <ul>Step 1: Wbench Filter</ul>
    <ul>Step 2: Filter Genome & mirbase</ul>
    <ul>Step 3: Tasi</ul>
    <ul>Step 4: Mircat</ul>
    <ul>Step 5: PareSnip</ul>
  </ul>
  <ul>-t|--template Set the program to begin in lcmode instead of fs mode. The preceading substring from the lib num (Pattern) Template + Lib num mas identify only one file in the inserts_dir
  </ul>
</ul>
<ul>Outputs:
  <ul>mirbase hits</ul>
  <ul>predicted targets</ul>
  <ul>predicted mRNA</ul>
  <ul>[workdir]/logs</ul>
  <ul>[workdir]/counts</ul>
</ul>
</ul>

------

<ul><strong>predict_target.sh</strong>
<br>Description: This is last step of the pipeline responsible for identifying sRNA targets in the transcriptome through degradome mediated search.
<ul>inputs:
  <ul>-f|--lib-first "First library to be processed"</ul>
  <ul>-l|--lib-last "last Library to be processed"</ul>
</ul>
<ul>Optional arguments: (If no degradome file parameter is given the script will give a list of options based on the location of the last used degradome file
  <ul>-d|--degradome "Degradome location"</ul>
  <ul>-h|--help "Display help"</ul>
</ul>
<ul>Outputs:
  <ul>targets</ul>
</ul>
</ul>

------

For detailed file names check the corresponding pipline. This program executes the following programs in that order.
Stats on the number of reads are stored in the count directory.
The count file is not really a tsv it is in fact a space seperated values. But I though i was close enough to a tsv.
The format used for counts is  %y%m%d:%h%m&s-type-lib[lib_first]-[lib_last].tsv

The log directory has alot of information about what happened during the execution of the scripts. It has a similar file notations as the cout
files. %y%m%d:%h%m%s-type.log or *.log.ok if it ran till the end. *.

------

<ul><strong>extract_fasteris_inserts.sh</strong>
<br>Description: Given a directory with fasteris inserts (no adaptors) and an interval of libraries. The libraries are extracted, concatenated and converted to fasta.  
Fastq quality scores are ploted
<ul>inputs: [First_lib][Last_Lib] </ul>
<ul>outputs: 
  <ul>[workdir]/data/fastq</ul>
  <ul>[workdir]/data/fasta</ul>
  <ul>[workdir]/data/quality</ul> 
  <ul>[workdir]/count </ul>
</ul>
<ul>dependencies:
  <ul>tar</ul>
  <ul>fastq_to_fasta</ul>
  <ul>fastx_quality_stats</ul>
  <ul>fastq_quality_boxplot_graph.sh</ul>
  <ul>fastq_xtract.sh, lib_cat, fq_to_fa.sh</ul>
</ul>
</ul>



<ul><strong>extract_lcscience_inserts.sh _</strong>
<br>Description: The libraries in [.fastq.gz] format are extracted and converted to fasta.  
Fastq quality scores are ploted. The template arguments is necessary if a range of lib are given.
The template must be a substring of the file preceading the lib number. Template + lib number should identify only one file in the inserts_dir _directory  
<ul>Configs: config/workdir.cfg
    <ul>INSERTS_DIR if a range of arguments is supplied </ul>
    <ul>ADAPTOR adaptor sequence to be clipped</ul>
    <ul>LCSCIENCE_LIB if only one lib is to be extracted this value will be used</ul>
</ul>
<ul>inputs: [First_lib] [Last_Lib] [TEMPLATE]</ul>
<ul>outputs: 
  <ul>[workdir]/data/fastq</ul>
  <ul>[workdir]/data/fasta</ul>
  <ul>[workdir]/data/quality</ul> 
</ul>
<ul>dependencies:
  <ul>tar</ul>
  <ul>fastq_to_fasta</ul>
  <ul>fastx_quality_stats</ul>
  <ul>fastq_quality_boxplot_graph.sh</ul>
  <ul>fastq_xtract.sh, lib_cat, fq_to_fa.sh</ul>
</ul>
</ul>


<ul><strong>Pipe_filter_wbench.sh</strong>
<br>Description: Given an interval of libraries the script filters them through the workbench filter using the configs in the config file.
Mirbase database in config file workpath.cfg
<ul>input: [First_lib] [Last_lib] [Filter Suffix]</ul>
<ul>Output: Filtered fasta, filteroverview</ul>
</ul>

<ul><strong>Pipe_filter_genome_bt_mirbase.sh</strong>
<br>Description: Given an interval of libraries the script aligns them to a reference genome and keeps reads that alig with a mismatch of 0, using bowtie1.
Align previous reads with mirbase v20 matrue.fa. Reads that align are sent to the cons file while those that don't are sent to the noncons file. This filter using the configs in the config file.
Mirbase database in config file workpath.cfg
<ul>input: [First_lib] [Last_lib] [Threads] [Genome] [Filter Suffix] </ul>
<ul>Output:
  <ul>Cons fasta</ul>
  <ul>Noncons fasta</ul>
  <ul>[workdir]/count</ul>
</ul>
</ul>

<ul><strong>pipe_mircat.sh</strong>
<br>Description: process an interval of libraries though UEA workbench mircat
Memory intensive script, java has to be run with memory settings. Big genome have to be broken down into parts. For a 32G machine it can handle around 3-4Gb parts. So play round this parameters.
<ul>Configure: Set MEMORY and THREADS var in the config/workdirs.cfg file.</ul>
<ul>input: [First lib] [Last lib] [Genome]</ul>
<ul>output:
  <ul>mircat/[basename]miRNA.fa</ul>
  <ul>mircat/[basename]miRNA_hairpins.txt</ul>
  <ul>mircat/[basename]ouput.csv _</ul>
</ul>
<ul>Dependencies:
  <ul>Java ~1.7</ul>
  <ul>UEA workbench (mircat)</ul>
</ul>
</ul>

<ul><strong>pipe_tasi.sh</strong>
<br>Description: Processes various file through the Tasi from UEA workbench. 
This script is not memory intensive no memory settings have to be set to run the java file. So far now genome size restrictions have been detected. (Tested up to 18G genome)
<ul>Configuration: Set TASI_GENOME var in config/workidr.cfg _</ul>
<ul>inputs: [First_lib][Last_lib]</ul>
<ul>ouputs: [workdir]/data/tasi/[see scripts/tasi.sh, outputs]
<ul>Dependencies:
  <ul>Java ~1.7</ul>
  <ul>UEA workbench</ul>
</ul>
</ul>


References:
<ul>Stocks MB, Moxon S, Mapleson D, Woolfenden HC, Mohorianu I, Folkes L, Dalmay T, Moulton V: The UEA sRNA workbench: a suite of tools for analysing and visualizing nex generation sequencing microRNA and small RNA datasets.</ul>
