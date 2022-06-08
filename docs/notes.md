# Release notes

**UPDATE 07/06/2022**: Added the possibility of providing customized conservation scores in the q-format via the `--qscores` flag.  

**UPDATE 08/06/2022**: fixed a bug in which lastz would not align small fragmented genomes, as well as small contigs, in the source assembly. Anyone interested in these small contigs should discard the previous version of `nf-LO` using `nextflow drop evotools/nf-LO`, and repeat the analyses.  
