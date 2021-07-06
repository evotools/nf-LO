# Reporting

## Runtime metrics
The workflow generates reports of the runtime automatically. These reports are saved within the `${OUTDIR}/reports` folder in html format, and can easily visualised within any browser.

## Chain metrics
The workflow can collect several metrics on the results of the analyses. To do so, the final chain file is converted back to maf using chainToAxt and then axtToMaf.
The resulting maf file is then used as input for [mafTools](https://github.com/dentearl/mafTools) to calculate some basic metrics on the alignments.
This software is installed directly within both the Docker and Singularity image provided as `Dockerfile` or `singularity.def`.
Alternatively, the user can install mafTools manually, and provide the installation path using the `--maf --mafTools /PATH/TO/mafTools/` options.
Resulting raw output files from the different analyses run are in the `${OUTDIR}/stats` folder

## Lifted features
If the users specifies a set of features, *nf-LO* will calculate the number of feature that are successfully lifted as a simple count. 
Also, if the dataset includes the annotation of the genes as "gene" flag (only for GFF/GTF/BED files), the workflow will count these entries as well and save them in a table. This simple table can be found in the `${OUTDIR}/stats` folder.

## Reporting
If either mafTools or an annotation are specified, *nf-LO* will then generate a report in HTML format describing the metrics collected. 
This will provide a first overview of how the analysis performed, and assist the user in adjusting and refining the parameters used.
This report will be saved, together with the nextflow reports, in the `${OUTDIR}/reports` folder.