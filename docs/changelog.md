# Changelog

## [v1.8.2]
- `--aligner minimap2` now runs on individual target sequences to reduce the memory footprint and improve performances in large distributed systems
- updated dependencies (minimap2 v2.26.0, last v1454, crossmap v0.6.4, bedtools v2.31.0, lastz v1.04.22)
- fix bug in creating report using singularity/docker images
- better lastz management of the input files

## [v1.8.1]
- Now `--source`/`--target` have to be used to pass local, remote or accession IDs (GCAs, GCFs and iGenomes alike)
- `--ncbi_source`, `--ncbi_target`, `--igenomes_source` and `--igenomes_target` now have to be specified alongside `--source`/`--target` to tell nf-LO when the files are from the two databases, but do not need any input.
- Documentation updated to reflect the change

## [v1.7.0]
- fix bug aforementioned preventing the lastz alignment of small source contigs or small fragmented source genomes
- add support to mamba through the `--mamba` flag
- updated minimal version of nextflow to 21.10.6 in order to support the mamba installation of dependencies
- added a new anaconda environment for mafTools
- added the possibility of providing custom conservation scores with the --qscores option, followed by the appropriate Q-score file

## [v1.5.1]
- Lastz has now two extra pre-configurations (primate and general) based on the ensembl pairwise genome alignments parameters
- chainNet is now split into three submodules (netChain, netSynt and chainsubset)
- There are now three ways to define the source genome (`--source`, `--ncbi_source` and `--igenome_source`)
- Similarly, there are now three ways to define the target genome (`--target`, `--ncbi_target` and `--igenome_target`)
- Fixed several bugs and stability issues

## [v1.5.0]
- Initial tagged version