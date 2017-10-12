============
Installation
============

This pipeline is intended to be run in a Linux environment. Installation can be accomplished by grabbing a copy of the project from `github <https://github.com/forestbiotech-lab/miRPursuit>`_ and then running the installation script. Below are a few lines to help guide you through the installation process.

* The pipeline is optimized to run in the command line as detailed below.
* To open a terminal on a debian based system press: **CTRL + ALT + T**
* To install on a remote machine, make a connection via ssh and navigate to the desired path of installation. 
 

Download program
================

**Grab a copy from `github <https://github.com/forestbiotech-lab/miRPrusuit>`_**

- If you have git installed on you machine. 
   Simply navigate to your chosen directory::
	
		#Clone project with git
    #This might prompt you for your github credentials. If authentication fails
    #try again and it should run without any prompts. 
		git clone https://github.com/forestbiotech-lab/miRPrusuit 
		cd miRPursuit

- Without git installed on your system. Installing using git clone is preferred since it allows updating to remove bugs or get new features. 
   Simply visit `github project <https://github.com/forestbiotech-lab/miRPursuit>`_ and download `.zip <https://github.com/forestbiotech-lab/miRPursuit/archive/master.zip>`_ file. ::
   
		#Download through command line
		wget https://github.com/forestbiotech-lab/miRPursuit/archive/master.zip -O miRPursuit.zip

   Extract contents to chosen directory ::

   	#Extract contents of archive
		unzip miRPursuit.zip 


Install Script
==============

*Run the install.sh file*:: 

	cd [toPath]/miRPrusuit
	./install.sh

.. Important:: Make sure you restart your terminal/computer to update your `path <install.html#id2>`_ so PatMaN can be accessed.

Alternatively you can source your startup shell file. Example for Bash shell.::

    source ~/.bashrc

Congratulations you should now have miRPursuit installed in your system.

Check `help <help.html>`_ section for information on help and how to send feedback about this project.

**Configure parameters**
   Now check that all the parameters are set to your convenience.

   `Go to configuration <config.html>`_ page.

Dependencies
============
- `FastQC <http://www.bioinformatics.babraham.ac.uk/projects/fastqc/>`_ 
- `PatMaN <https://bioinf.eva.mpg.de/patman/>`_
- `Java <https://www.java.com>`_
- `FASTX-Toolkit <http://hannonlab.cshl.edu/fastx_toolkit/>`_
- `UEA workbench <http://srna-workbench.cmp.uea.ac.uk/>`_

Path 
====
To ensure persistence of `environmental variables (PATH) <https://en.wikipedia.org/wiki/PATH_(variable)>`_  throughout sessions, the paths to the dependencies are stored in shell scripts. 
The installation script checks which shell is being used by the system and saves the path to the corresponding initiation shell script.

`Table 1 <install.html#table-1>`_ shows which shells are contemplated in the installation script. If your system uses a shell that is not listed (others) then the file $HOME/.profile is created. You should ensure that your shell is reading given shell script. In case your shell is not using the listed shell file, add the following line of code, to a shell script that is executed on startup of the shell you use.::
   
   source $HOME/.profile

_`Table 1` - List of shells and it's associated shell script.

+--------+---------------------------------+
| Shell  | Shell scripts                   |
+========+=================================+
| bash   | $HOME/.bashrc                   |
+--------+---------------------------------+
| zsh  	 | $HOME/.zshrc                    |
+--------+---------------------------------+
| fish	 | $HOME/.config/fish/config.fish  |
+--------+---------------------------------+
| ksh 	 | $HOME/.profile                  |
+--------+---------------------------------+
| tcsh 	 | $HOME/.login                    |
+--------+---------------------------------+
| others | $HOME/.profile                  |
+--------+---------------------------------+



Detailed installation guide
===========================

Step by step guide through installation script.

Installation of dependencies 
----------------------------
The default directory for storing dependencies is ${HOME}/.Software, it will be created if it doesn't exist. To use another directory change the variable SOFTWARE in `software_dirs.cfg <config.html#software-dirs>`_.

PatMaN
......
The installation script starts by checking if `PatMaN <https://bioinf.eva.mpg.de/patman/>`_ is installed on the system. If it is not available on the system it will be downloaded to the directory in the variable SOFTWARE. The downloaded archive is extracted and added to the path.

Java
.... 
miRPursuit works best with Oracle's `Java v.8 <https://www.java.com>`_. So instead of changing your system's installed Java VM miRPursuit uses the Java VM in the variable JAVA_DIR in `software_dirs.cfg <config.html#software-dirs>`_. If the variable is empty the installation script will download Java, extract it and set JAVA_DIR variable to the correct directory.    

FASTX-Toolkit
.............
If `fastq_to_fasta <http://hannonlab.cshl.edu/fastx_toolkit/commandline.html#fastq_to_fasta_usage>`_ from `FASTX-Toolkit <http://hannonlab.cshl.edu/fastx_toolkit/>`_ is not on available on the system it will be downloaded to the directory in the variable SOFTWARE. The downloaded archive will extracted and added to the path.

UEA sRNA workbench
..................
`UEA sRNA workbench <http://srna-workbench.cmp.uea.ac.uk/>`_ is run by miRPursuit from the WBENCH_DIR variable in `software_dirs.cfg <config.html#software-dirs>`_. If the variable isn't set the installation script will download the workbench and set up the variable.
Since usage of UEA sRNA workbench requires acceptance of it's terms of use. On your first run you will be prompted to read and accept their term of use. Alternatively you can run their GUI and accept their terms of use in a graphical environment.  

Setting variables in workdirs.cfg
---------------------------------

This section will guide you through the command prompts that will be issued.

1. Create source data folder?
   This creates a directory for storing resources such as genomes, miRBase, etc. As a good practise it is recommend to store every thing in a common folder structure. Default is $HOME/source_data
     - Y|y - Default directory is created.
     - N|n - Specify an alternate directory. 

.. 2. **?**
.. 3. dfsf  
.. 4. fsdfsd










