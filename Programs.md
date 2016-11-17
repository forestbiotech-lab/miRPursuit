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
<br>The template must be a substring of the file preceading the lib number. Template + lib number should identify only one file in the inserts_dir _directory  
<ul>Configs: config/workdir.cfg
    <ul>INSERTS_DIR if a range of arguments is supplied </ul>
    <ul>ADAPTOR adaptor sequence to be clipped</ul>
    <ul>LCSCIENCE_LIB if only one lib is to be extracted this value will be used</ul>
</ul>
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


<ul><strong>pipe_filter_wbench.sh</strong>
<br>Description: Given an interval of libraries the script filters them through the workbench filter using the configs in the config file.
Mirbase database in config file workpath.cfg
<ul>input: [First_lib] [Last_lib]</ul>
<ul>Output: Filtered fasta, filter_overview</ul>
</ul>

<ul><strong>pipe_filter_genome_mirbase.sh</strong>
<br>Description: Given an interval of libraries the script aligns them to a reference genome and keeps reads that align with a mismatch of X, using patman.
Align previous reads with mirbase v20 matrue.fa. Reads that align are sent to the cons file while those that don't are sent to the noncons file. This filter using the configs in the config file.
Mirbase database in config file workpath.cfg
<br>config/workdirs.cfg [THREAD] [GENOME]
<br> missing a config file (Next update)
<ul>input: [First_lib] [Last_lib] </ul>
<ul>Output:
  <ul>[workdir]data/filter_genome/libX_filt-${FILTER_SUF}_${GENOME}${_REPORT.csv,.fa}</ul>
  <ul>[workdir]/mirprof/libxx_filt-${FILTER_SUF}_${GENOME}_mibase{.uniq,_profile.csv,srna.fa}</ul>
  <ul>Cons fasta libxx_filt-${FILTER_SUF}_${GENOME}_mirbase_cons.fa</ul>
  <ul>Noncons fasta libxx_filt-${FILTER_SUF}_${GENOME}_mirbase_noncons.fa</ul>
  <ul>[workdir]/data/count (?)</ul>
</ul>
<ul>Dependencies: 
  <ul> java >= 7</ul>
  <ul> Patman </ul>
  <ul> UEA workbench (mirprof)</ul>
</ul>_
</ul>

<ul><strong>pipe_mircat.sh</strong>
<br>Description: process an interval of libraries though UEA workbench mircat
Memory intensive script, java has to be run with memory settings. Big genome have to be broken down into parts. For a 32G machine it can handle around 3-4Gb parts. So play round this parameters.
<ul>Configure: Set MEMORY and THREADS var in the config/workdirs.cfg file.</ul>
<ul>input: [First lib] [Last lib] [Genome]</ul>
<ul>output:
  <ul>Basename=libxx_filt-${FILTER_SUF}_${GENOME}_mirbase_noncons</ul>
  <ul>mircat/${basename}_miRNA.fa</ul>
  <ul>mircat/${basename}_miRNA_hairpins.txt</ul>
  <ul>mircat/${basename}_ouput.csv _</ul>
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
<ul>ouputs: [workdir]/data/tasi/libxx_filt-${FILTER_SUF}_${GENOME}_mirbase_noncons_tasi_{srnas.txt,locuslist.csv}</ul>
<ul>Dependencies:
  <ul>Java ~1.7</ul>
  <ul>UEA workbench</ul>
</ul>
</ul>

<ul><strong>pipe_fasta.sh</strong>
<br>Description: Copies fasta files to workdir based on template.<br>The template provided must be any identifying array of charactersimediatly before the serialization.<br>Ex: Test-data-1.fa use --fasta data- or --fasta Test-data-
<ul>Configuration: Set inserts_dir var in config/workidr.cfg _</ul>
<ul>inputs: [First_lib][Last_lib][template] </ul>
<ul>ouputs: [workdir]/data/fasta/</ul>
</ul>

<ul><strong>pipe_fastq.sh</strong>
<br>Description: Copies fastq files to workdir based on template.<br>The template provided must be any identifying array of charactersimediatly before the serialization.<br>Ex: Test-data-1.fq use --fastq data- or --fastq Test-data-
<br>Can run a single file if only the first argument is given
<br>If no .fastq or .fq file is present in the directory (var inserts in config file) will check for fastq.gz .fq.gz files with the given template and extract them.
<br>Serialization mas be zero based ex: 1 should be 01 2-->02, ...
<br>Isn't removing adaptors currently a flag will be added later for this function.
<br>
<ul>Configuration: Set inserts_dir var in config/workidr.cfg _</ul>
<ul>inputs: [First_lib][Last_lib][template] </ul>
<ul>ouputs: [workdir]/data/fasta/</ul>
</ul>

<ul><strong>counts_merge.sh</strong>
<br>Description: Produces and merges together the count tables for the project
<br>
<ul>Configuration: Set THREADS,workdir in config/workdir.cfg</ul>
<ul>inputs: Config file only no arguments necessary</ul>
<ul>ouputs: [workdir]/counts/</ul>
</ul>