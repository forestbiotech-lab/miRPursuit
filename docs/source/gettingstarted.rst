===============
Getting Started
===============

So at this point you have already completely installed<install>_ miRPursuit you should be familiar to the various steps<steps> in the workflow and have step up all the necessary configuration file[refer to config]. You are now ready to run miRPursuit for the first time.

()You can run with the default parameter settings or you can start with your customized settings.


como correr o programa::
	./miRPursuit.sh --


Detalhar as várias opções. etc.

 Libraries are inputted to the program based on a pre given sequential numbering system. The numbering can be of any kind as long as it is sequential and there is a preceding . The common  string that precedes the sequential numbering is then used to retreive the libraries from the variable in the configuration file that holds the path in which the libaties are present. 

[]warning accept license for sRNA workbench


Installation is very simple and can be acomplished by running the installation script (install.sh). The install script checks available software and downloads all the thrid party software necessary to run miRPursuit.
The install script also sets up all the machine specific variables (RAM, CPUs etc.) as well as paths of all the necessary files (databases) in the config files with a series of prompts filled with suggestions.
The config files specific to each individual program it provided with its default variables and doesn't need to be changed do be able to run miRPursuit. 

miRPursuit stores all intermediary files used in the workflow for debugging and other uses (Might be needed for some other reason). These files along with the results are stored in the path given in the workdir variable in the config file (workdirs.cfg? link)
For each project a path should be given to store run data and results.

Once all the necessary configuration files have been set up.  