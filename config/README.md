This folder holds all the config files.
=======================================

Each config holds parameters necessary to run each program within the pipeline.

Start by setting up the software_dirs.cfg

Afterwards set the workdir.cfg 

The filters dir holds pre-set filters to be used.
================================================
 To create a new filter just copy the default file wbench_filter_default.cfg in defaults directory, and change the name from default to the desired filter_sufix.
 Each time the program is run the parameters from the chosen filter are copied to the wbench_filter_in_use.cfg

For more information on each file please checkout: http://srna-workflow.readthedocs.org/en/master/config.html

