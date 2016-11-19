# miRPursuit

[![DOI](https://zenodo.org/badge/36737158.svg)](https://zenodo.org/badge/latestdoi/36737158)

**Check out our read the docs page for a more structed overview of this project:**
<ul> [Documentation](http://goo.gl/HHijqe) </ul>
Soon will be changed to miRPursuit
  
**miRPursuit: a pipeline for analysis of large-scale plant small RNA datasets**

Costa B.V.<sup>1</sup>, Rodrigues A<sup>1,2</sup>, Chaves I<sup>1</sup>, Bohn A<sup>2</sup>, Miguel C<sup>1,2</sup>

<sup>1</sup>iBET, Instituto de Biologia Experimental e Tecnológica, Apartado 12, 2781-901 Oeiras, Portugal

<sup>2</sup>Instituto de Tecnologia Química e Biológica António Xavier, Universidade Nova de Lisboa, Av. República, 2780-157 Oeiras, Portugal

<img src="http://www.itqb.unl.pt/labs/forest-biotech/forest-biotechnology" height="200px"/>

## Table of Contents
- [Abstract](#abstract)




## Abstract
Small non-coding RNAs (sRNAs) are pivotal in the regulation of gene expression during plant growth and development, and in response to abiotic and biotic stresses. The affordable, high-throughput sequencing provided by NGS platforms is an attractive approach to discover the small RNAs involved in the regulation of important biological processes in plants. However, the large amounts of data generated by such type of studies can be staggering and requires efficient tools to quickly analyze the data produced.

This pipeline has been built around a publicly available software package, the University of East Anglia sRNA workbench[1], which includes various tools which can be used to identify sRNA classes, such as micro RNAs (miRNAs) and trans-acting siRNA (tasi), both conserved and novel and predict their precursor RNA using a user specified reference genome. Moreover, the target genes can be predicted and validated by using degradome fragment sequences and a reference transcriptome.

By setting up a workflow, a predefined sequence of tools can be run autonomously. The NGS raw data obtained from various libraries can be supplied as input files, allowing the user to process multiple libraries in one command line interaction. The degree of customization in this pipeline provides the ability to fine tune the workflow with the freedom to use user supplied omics data.

Thus, the main advantage of using this system over the workbench's individual tools is minimizing the need to perform manual repetitive tasks. The pipeline automatically connects each step by processing the data flow between tools. This sRNA workflow was implemented in bash which is optimal to be run on unix servers allowing uninterrupted runs on high capacity clusters enabling the processing of large scale multiple datasets. The end result provides the identification and annotation of conserved and novel miRNAs and tasiRNAs, along with the expression matrix of the libraries from the input dataset, which can be easily imported to excel or R to perform differential expression analyses.

As future work the development of the pipeline will include, a database of the annotations generated and a user friendly graphic interface.



This pipeline was build to simplify the manipulation of NGS sequenced data. Use of this pipeline provides a seemless  classification of sRNA, prediction of TaSi and sRNA targets from FASTQ files.

This version was based on the output given by fasteris (tar.gz files need to have *GZT-[lib_n]*.tar.gz format or be put in this format).
However if the .fastq files are in .gz archives they can also be used, given the pattern before the library number.


<h3>How to start:</h3>
<ul> Make sure you have all the software necessary (Check list) 
  <ul> UEA Workbench Optimized for linux version (~3.2) </ul>
  <ul> perl version (5.8) </ul>
  <ul> Java optimized for version (~1.7) </ul>
</ul>
<ul> Set up the variables in the config dir.</ul>
<ul>You should also have the following software configured in your path
    <ul> [Patman](https://bioinf.eva.mpg.de/patman/) (Can be installed with install script)</ul>
    <ul> [Tar](http://linuxcommand.org/man_pages/tar1.html) sudo apt-get install tar</ul>
    <ul> [Fastx Toolkit](http://hannonlab.cshl.edu/fastx_toolkit/) (Can be install with install script)</ul>
</ul>
<ul>run miRPursuit.sh</ul>


<h3>Installation</h3>
<h5>From git hub</h5>

    cd /toDesiredLocation/
    git clone https://github.com/forestbiotech-lab/miRPursuit.git
    cd miRPursuit

<h5>From tar</h5>

    Download archeive from github
    cd /toDesiredLocation/
    unzip miRPursuit-master.zip

<h5>Dependancies</h5> 
<ul>To install the necessary dependancies you can run install.sh in the main folder</ul>

    cd /pathtoMiRPursuit/
    ./install.sh

<h5>Custom Installation</h5>
<ul>Set software dir in config file</ul>
<ul>Fill out the software variables in the software.cfg file. <br>Set the paths to any program listed if already installed.</ul>

    cd /pathtoMiRPusuit/
    vim config/software_dirs.cfg


<h5>Running test dataset</h5>
<ul>A test dataset was provided to ensure the pipeline is installed successfully
   <ul>edit config/workdirs.cfg </ul>
   <ul>Set INSERTS_DIRS=pathToMiRPursuit/testDataset (Example for test dataset)</ul>
   <ul>Use as referenece genome a simple plant genome. (Dataset has sRNAS detected by C.canephora genome)</ul>
</ul>   

<ul>Example code to analyse test_dataset (Make sure all var above mentions are already set):</ul>

    bash pathToMirPursuit/miRPursuit.sh -f 1 -l 2 --fasta test_dataset-


<h3>Analysing sRNA</h3>

Works for fastq and fasta input formats. 
  
<strong>config</strong> - Directory that has all the variables for the workflow.

<ul><strong>workdirs.cfg</strong>- Sets variables with directories and files necessary for the project.
  <ul>workdir - path to workdir (will create one if it doesn't exist)</ul>
  <ul>genomes path to genomes</ul>
  <ul>GENOME_MIRCAT  _The path to the genome to be used by mircat. Set to ${GENOME} if you don't need to run various parts. (My be necessary if you have short amount of ram.)"</ul>
  <ul>FILTER_SUF _Filter-suffix to chose the predefined filter settings to be used.</ul>
  <ul>MEMORY  - Amount of memory to be used my java when using memory intensive scripts. Ex:10g, 2000m ... </ul>
  <ul>THREADS - Number of cores to be used during execution</ul>
  <ul>INSERTS_DIR Path to the inserts directory (Fasteris)</ul> 
  <ul>MIRBASE Path to mirbase database</ul>
</ul>
<br>  
<ul><strong>software_dirs.cfg</strong> - Sets the directory paths to all major programs</ul>
<br>
<ul><strong>patman_genome.cfg</strong> - General genome filtering parameters </ul>
<br>
<ul><strong>wbench_mircat.cfg</strong> - General parameters for mircat</ul>
<br>
<ul><strong>wbench_tasi.cfg</strong> - General parameters for TaSi.</ul>

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
  <ul>--lc Set the program to begin in lcmode instead of fs mode. The preceading substring from the lib num (Pattern) Template + Lib num mas identify only one file in the inserts_dir</ul>
  <ul>--fasta Set the program to start using fasta files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fa, Lib_2.fa, .. --> argument should be Lib_</ul>
  <ul>--fastq Set the program to start using fastq files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fq, Lib_2.fq, .. --> argument should be Lib, will also extract the file if extension is fastq.gz </ul
</ul>
<ul>Outputs:
  <ul>mirbase hits</ul>
  <ul>predicted targets</ul>
  <ul>predicted mRNA</ul>
  <ul>[workdir]/logs</ul>
  <ul>[workdir]/counts</ul>
</ul>
</ul>

<img src="https://raw.githubusercontent.com/forestbiotech-lab/miRPursuit/master/images/workflow.png" />

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

References:
<ul>Stocks MB, Moxon S, Mapleson D, Woolfenden HC, Mohorianu I, Folkes L, Dalmay T, Moulton V: The UEA sRNA workbench: a suite of tools for analysing and visualizing nex generation sequencing microRNA and small RNA datasets.</ul>
<a href="https://www.fasteris.com/dna/" target="_blank">Fasteris</a>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-47286927-5', 'auto');
  ga('send', 'pageview');

</script>