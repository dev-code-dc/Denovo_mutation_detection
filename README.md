# Denovo_mutation_detection
you can detect denovo mutation in easy way with the scripts.
variants that are not present in either of your parents, but does exist in the proband(child)
you need to have, vcf files with required columns like, GQ, AD, DP QUALITY, FILTER, GT, CHR, POS, REF, ALT etc.
you need to have one excel file with samples details as follows:
IID	PID	MID	IID Gender
SS1	SS2	SS3	.
SB1	SB2	SB3	.
IID: representing the proband or child samples, where you want to detect the denovo mutations
PID: father samples ID
MID: mother samples ID
please note that IID, PID, MID should get matched with your VCF samples IDs.
*this process can be run on HPC, with just easy commands:
Commands:
