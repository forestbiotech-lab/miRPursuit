Steps
=====

**Pre-preocessing.**
 Libraries are fead to the program based on a pre given sequential numbering system. The numbering can be of any kind as long as it is sequential and there is a preceding . The common  string that precedes the sequential numbering is then used to retreive the libraries from the variable in the configuration file that holds the path in which the libaties are present. 
 There are various options to specify the input type. The most simple is the --fasta flag that searches the path for the target .fa/.fasta libraries and makes a copy to the project  folder. 
 In case  the libraries are still in the fastq format the --fastq flag should be given. This method does a quality control (fastqc not yet but soon) and then converts the fastq libra ries  to fasta (even if they don't pass the quality control, should check and send warnings for this either cmd or email). 
 There are two other methods for precessing libraries sequenced by Fasteris and LCscience. These extract and merge files within the libraries.
 additionally the --trim flag can be set to remove adaptor sequences. Thos requires the adptor var to be set in the configuration file wordirs.cfg


**Filtering**
 The fasta sequences are filtered based on their lenght, abundance, low complexity and r t RNA are removed. These parameters can be set in the wbench_filter.cfg configuration file.

**Genome and mirbase**
 The reads are further filtered by mapping them to the setup genome file with zero mismatches using patman. The mapped reads are then mapped to the miRBase database using miRProf with  the parameter set in the wbench_mirprof.cfg configuration file.
 The genome mapped reads are seperated into two files per library those that mapped with mirbase (conserved reads) and those that don't (non conserved reads?).

**Tasi prediction**
 The non conserved reads are run through the tasi predictor to identify trans acting siRNA using the parameters in the wbench_tasi.cfg

 Novel miRNA (This will soon be changed to use conserved miRNAs alongside with non-conserved)
 The non conserved reads are also used to predict novel miRNA with miRCat by searching the genome for their respective precursor RNA (detail this more? It isn't the pipeline that is  responsible for this) in the setup genome file. The parameters used by miRCat are set in the wbench_mircst.cfg configuration file and the genome file is set in the workdirs.cfg. If  memory (RAM) restrictions apply the genome can be split into several parts and miRCat will be run once for each part. The various part should all be held in the same directory with  a  common name with the word part and the sequential number. Afterwards the resulting files will be merged and filtered to remove miRNAs that paired with more genome sites than those  specified in the configuration file wbench_mIrcat.cfg.

**Merging results and stepwise stats**
 The number of sequences kept in each step are calculated for each library, both total number and distinct number of sequences. The identified sequences and their respective absolute  count are stored in a tab separate value file (.tsv). This provide easy importation to most statistical softwares as well as MS excel.

**Validation of targets**
 Target validation is done based on the supplied degradome and transcriptome, which are both necessary to preform this analysis. The file paths are stored in the workdirs.cfg  configuration file and the parameters are stored in wbench_paresnip.cfg configuration file.
