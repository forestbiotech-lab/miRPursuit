<h3>Scripts</h3>

<ul><strong>fastq_extract.sh</strong>
<br>Description: Extracts the specified library number in fasteris format to a fasta file.
The files are extracted and concatenated to a lib#_ln#.fq file. The extracted files areremoved after concatenation. Caution: the directory should not have other x_GZT-x.fastq files or they will be concatenated into the lib#_ln#.fq file.  
<ul>Input: [lib_no] [insert_dir] [workdir]</ul>
<ul>Output: [workdir]/data/fasta</ul>
</ul>

<ul><strong>lib_cat.sh</strong>
<br>Description: Check if the same library comes from multiple lanes.
The file lib#_ln#.fq is concatenated to lib#.fq The original files are saved to /two_lane_dir 
<ul>Inputs: [lib_no] [.ext] [workdir]</ul>
<ul>Outputs: [workdir]/data/fasta</ul>
</ul>

<ul><strong>fq_to_fa_exe.sh</strong>
<br>Description: Converts fastq to fasta. Plots quality scores
<ul>input: [workdir] [Lib_no] Fastq files (lib#.fq)</ul>
<ul>output:
  <ul>Fasta files lib#.fa</ul>
  <ul>Quality plots lib#.stat</ul>
  <ul>lib#.pdf</ul>
</ul>
</ul>

<ul><strong>filter_wbench.sh</strong>
<br>Description: Filters the library through the workbench filter removing low abundance reads, t/rRNA, low complexity reads, etc. Based on the parameter set in the config file.
<ul>Inputs: [lib_no] [.ext] [workdir] [source]</ul>
<ul>Outputs: [workdir]/data/fasta</ul>
</ul>

<ul><strong>fq_to_fa_exe.sh</strong>
<br>Description: Converts fastq to fasta. Plots quality scores
<ul>input: Fastq files lib#.fq</ul>
<ul>output: Fasta files lib#.fa</ul>
</ul>

<ul><strong>filter_wbench.sh</strong>
<br>Description: Filters the fasta file based on the configuration file.
<ul>input: [File] [filter_suffix] [workdir] [source]</ul>
<ul>output: 
  <ul>/data/filter_overview/Lib#_filt-[filter_suffix].fa</ul>
  <ul>data/filter_overview/Lib#_filt-[filter_suffix].csv]</ul>
</ul>
<ul>Dependencies: Java, UEA Workbench (Filter)</ul>
</ul>

<ul><strong>filter_genome_bt_mirbase.sh</strong>
<br>Description: Uses bowtie to align reads with genome in order to filter reads.
Filters reads with patman through mirbase mature database
Requires indexed genomes to be added.
<ul> Inputs: [file] [Genome] [Threads] [workdir] [Mirbase]</ul>
<ul>Ouputs:
  <ul>/FILTER-Genome/Lib#_filt_x_BOWTIE1_[Genome]_REPORT.csv</ul>
  <ul>/patman_mb/lib#_filt_x_[Genome]_mirbase.csv #Alignment results mirbase</ul>
  <ul>/patman_mb/lib#_filt_x_[Genome]_mirbase.uniq #Uniq reads</ul>
  <ul>/lib#_filt_x_[Genome].fa</ul>
  <ul>/lib#_filt_x_[Genome]_mirbase_cons.fa</ul>
  <ul>/lib#_filt_x_[Genome]_mirbase_noncons.fa</ul>
</ul>
<ul>Dependencies:
  <ul>Bowtie1</ul>
  <ul>Patman</ul>
</ul>
</ul>

<ul><strong>tasi.sh</strong>
<br>Description: Runs the workbench program tasi. To predict putative TaSi reads
<ul>Configure: Set TASI_GENOME var in /config/workdirs.cfg _</ul>
<ul>inputs: [File][Source]</ul>
<ul>ouputs: 
  <ul>[workdir]/data/tasi/[File(root)]_locuslist.csv</ul>
  <ul>[workdir]/data/tasi/[File(root)]_srnas.txt</ul>
</ul>
</ul>

<ul><strong>mircat.sh</strong>
<br>Description: Processes a file through the mircat program of the UEA workbench
if a file with the word part is presented as the genome file. The script will iterate through all parts and concatenate the results. 
<ul>input:[file] [genome] [source]</ul> 
<ul>output:
  <ul>mircat/[basename]miRNA.fa</ul>
  <ul>mircat/[basename]miRNA_hairpins.txt</ul>
  <ul>mircat/[basename]output.csv</ul>
</ul>
<ul>Dependencies: UEA workbench_</ul>
</ul>

<ul><strong>target.sh</strong>
<br>Description: Searches for targets of small RNAs using the degradome and transcriptome. Runs PARESNIP a UEA Workbench program.
<ul>Configure: 
  <ul>Set TRANSCRIPTOME,DEGRADOME vars in the <workdir.cfg> config file.</ul>
  <ul>Set PAREsnip parameters in <paresnip.cfg> 
</ul>
<ul>input:[lib_first][lib_last][source]</ul>
<ul>output: </ul>
</ul>



<ul><strong>Count_reads.sh</strong>
<br>Description: Counts the number of reads of a concatenated fa file where the read abundance in within parenthesis "()"
Report(Outfile): %y%m%d:%h%m%s%-c[type].tsv
<ul>input: [First Lib][Last_Lib][Model File][Report(Out File)][Header]</ul>
<ul>Output: [workdir]/count/[Report]</ul>
</ul>

<ul><strong>extract_lcscience.sh</strong>
<br>Description: Extracts lib |Attention this doesn't concatenate split libs|
<ul>Configure: LCSIENCE_LIB (This it the path to the gunzip file)_ in config/workdirs.cfg</ul>
<ul>inputs: [source] [lib (output num)] [EXTRACT_LIB]_ </ul>
<ul>ouputs: [workdir]/fastq/libXX.fq</ul>
<ul>Dependencies: gunzip</ul>
</ul>

<ul><strong>trim-lcscience.sh</strong>
<br>Description: Trims adaptores
<ul>Configure: ADAPTOR var in config/workdirs.cfg</ul>
<ul>input: [source] [Lib]</ul>
<ul>output:
  <ul>[workdir]/fasta/libXX.fa</ul>
  <ul>[workdir]/fasta/summary
  <ul>[workdir]/fasta/discardedreads</ul>
</ul>
<ul>Dependencies: fastx_toolbench _</ul>
</ul>

<ul><strong>count_abundance.sh</strong>
<br>Description: Produces a count matrix paths with wildcard must be given in quotes so that they are considered the same argument.
<ul>Configure: Threads from workdir can be used to suplement uniform parallezation throughout pipeline</ul>
<ul>input ["paths(allows wildcards, use quotes)"] [Threads (Optional)] </ul> 
<ul>output:
  <ul>standard output it used in threaded mode some results may apear only after program is finished running.  </ul>
</ul>
</ul>
--------
<h3>Auxiliar Scripts:</h3>
<ul><strong>extract_x_seqs.sh</strong>
<br>Description: Extracts x sequences from a fasta file with y offset.

<ul>Input: [Fasta file] [Start(offset-Zero based)] [Number of sequences]</ul>
<ul>Output: Standard output</ul>
</ul>

