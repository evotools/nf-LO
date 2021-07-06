# Resources
By default, *nf-LO* will attempt to use all cores but one and an amount of memory equal to the one reserved by the java virtual machine. For most cases, will have to customize these values to match the requirements to successfully run the workflow. 
To do so, users can specify the settings as follow:
 1. --max_cpus: maximum number of cpus requested and used by the tasks (e.g. --max_cpus 4 will use at most 4 cpus for a single job)
 2. --max_time: maximum time to use for a single job (e.g. --max_time 12.h will run a task for at most 12 hours)
 3. --max_memory: maximum memory used by a single job (e.g. --max_memory 16.GB will use at most 16 GB of ram for a job)
