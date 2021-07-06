# Resources
## Resource management
By default, *nf-LO* will attempt to use all cores available - 1 and the total amount of memory reserved by the java virtual machine. For most installation, it means that the workflow will use up to 3.GB of memory and almost all cores accessible. 
Users can customize these values in case the memory and/or cpus requested are not enough, or if the user is running the workflow on a cluster system.
To do so, users can specify the settings as follow:
 1. `--max_cpus`: maximum number of cpus requested and used by the tasks (e.g. `--max_cpus 4` will use at most 4 cpus for a single job)
 2. `--max_time`: maximum time to use for a single job (e.g. `--max_time 12.h` will run a task for at most 12 hours)
 3. `--max_memory`: maximum memory used by a single job (e.g. `--max_memory 16.GB` will use at most 16 GB of ram for a job)
