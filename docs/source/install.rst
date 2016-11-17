Installation
============

This pipeline is intended to be run in a linux environment. Installation is quite simple and can be accomplished by grabbing a copy of the project from `github <https://github.com/forestbiotech-lab/miRPursuit>`_ and then running the installation script. Below are a few lines to help guide you through the installation process.

* The pipeline is optimized to run in the command line so the following steps will focus on that approach.
* To open a terminal on a debian based system press: **CTRL + ALT + T**
* To install on a remote machine connect via ssh to it and navigate to the desired path of installation. 
 

Download program
^^^^^^^^^^^^^^^^

**Grab a copy from github**

- If you have git installed on you machine. 
   Simply navigate to your chosen directory::
	
		#Clone project with git 
		git clone https://github.com/forestbiotech-lab/miRPrusuit 
		cd miRPrusuit

- Without git installed on your system. 
   Simply visit `github project <https://github.com/forestbiotech-lab/miRPursuit>`_ and download `.zip <https://github.com/forestbiotech-lab/miRPursuit/archive/master.zip>`_ file. ::
   
		#Download through command line
		wget https://github.com/forestbiotech-lab/miRPursuit/archive/master.zip

   Extract contents to chosen directory ::

   		#Extract contents of archieve
		unzip miRPrusuit 


Install
^^^^^^^

 *Run the install.sh file*:: 

	cd [toPath]/miRPrusuit
	./install.sh

 Make sure you restart your terminal/computer to update your path so patman can be accessed.
 Alternatively you can source you startup shell file. Ex:Bash. ::
	
		source ~/.bashrc

 Congratulations you should now have miRPursuit installed in your system.

 Check `help <help.html>`_ section for information on help and how to send feedback about this project.

**Configure parameters**
    Now check that all the parameters are set to your conviniance.

    `Go to configuration <config.html>`_ page.

Dependancies
^^^^^^^^^^^^
FastQC (Not implemented yet.)

Patman 

Fastatoolkit

Java

UEA workbench

    
