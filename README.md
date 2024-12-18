# De Novo Mutation Detection  

This guide provides an easy way to detect de novo mutations using scripts. De novo mutations are variants that are absent in both parents but present in the proband (child).
## Outline
![image](https://github.com/user-attachments/assets/1ef31795-8403-435c-bc12-b895c1dbd387)

## Prerequisites
- **scripts** take all the scripts in a directory:
- 1. denovo_tool.sh
  2. ped_extract.R
  3. vcf_format.R
  4. vcf_process.sh
  5. Slivar
  6. slivar-functions.js
 
     
You need VCF files with the following required fields:

- **GQ** (Genotype Quality)  
- **AD** (Allele Depth)  
- **DP** (Read Depth)  
- **QUAL** (Quality Score)  
- **FILTER**  
- **GT** (Genotype)  
- **CHR** (Chromosome)  
- **POS** (Position)  
- **REF** (Reference Allele)  
- **ALT** (Alternate Allele)  
- ,.etc

## Sample Details File

Prepare an Excel file or table with the following columns:

| IID   | PID   | MID   | Gender |  
|-------|-------|-------|--------|  
| SS1   | SS2   | SS3   | .      |  
| SB1   | SB2   | SB3   | .      |  

- **IID**: Proband or child sample ID where de novo mutations will be detected.  
- **PID**: Father’s sample ID.  
- **MID**: Mother’s sample ID.  

**Note**: Ensure that the `IID`, `PID`, and `MID` match the sample IDs in your VCF files.

## Execution on HPC

This process can be run on an HPC system using simple commands.

### Command Example:
first you should get all scripts in your directory, to get those:
```bash
wget https://github.com/brentp/slivar/releases/download/v0.2.8/slivar
chmod a+x ./slivar
wget https://raw.githubusercontent.com/brentp/slivar/master/js/slivar-functions.js
wget https://raw.githubusercontent.com/dev-code-dc/Denovo_mutation_detection/main/Scripts_to_Get/denovo_tool.sh
chmod a+x denovo_tool.sh
wget https://raw.githubusercontent.com/dev-code-dc/Denovo_mutation_detection/main/Scripts_to_Get/ped_extract.R
wget https://raw.githubusercontent.com/dev-code-dc/Denovo_mutation_detection/main/Scripts_to_Get/vcf_format.R
wget https://raw.githubusercontent.com/dev-code-dc/Denovo_mutation_detection/main/Scripts_to_Get/vcf_process.sh

```

make sure you have all the required files and scripts in your directory.
then :

```
chmod a+x *.sh
```

alright!! you can then execute the command, example:
To get quick help:
```bash
./denovo_tool.sh --help
```
Usage: ./denovo_tool.sh -ns <node_list> -pt <partition_name> -pj <parallel_jobs> -vcf_list <vcf_list_file> -ped_xl <ped_file>

  -ns         Comma-separated list of nodes (e.g., node55,node56,node57)
  -pt         Partition name (e.g., cbr_q_t)
  -pj         Number of parallel jobs per node (e.g., 4)
  -vcf_list   Path to the VCF list file
  -ped_xl     Path to the PED file (e.g., Trio_List.xlsx)

# Example:
```bash
./denovo_tool.sh -ns node55,node56,node57 -pt partition_q_t -pj 4 -vcf_list SNVs_list.txt -ped_xl Trio_List.xlsx

```
### Explanation of Command Options:

- **`-ns`**: Provide the list of nodes separated by commas (e.g., `node1,node2,node3`).
  
  This specifies the list of nodes that will be used for the job execution. You can list multiple nodes separated by commas.

- **`-pt`**: Specify the partition name for job submission in the HPC (e.g., `cbr_q_t`).
  
  This indicates the partition in which the job should run on the HPC system. Each partition is associated with different resource allocations.

- **`-pj`**: Set the number of parallel jobs per node. Be mindful of available memory and storage.
  
  This option defines how many parallel jobs will run per node. Adjust this number according to the available resources (memory, disk space). Running too many parallel jobs on limited resources can cause failures or slow performance.

If your intermediate processed VCF files are 50 GB each and you have 200 GB of total storage, it's better to use a single node with parallel jobs limited to 2. This way, you ensure that the total storage used by the two parallel jobs (50 GB + 50 GB = 100 GB) will fit into the available disk space, leaving 100 GB of storage for processing intermediate steps or other data.

- **`-vcf_list`**: this should be the full path of your vcf files segregated by chromosomes:

/gpfs/data/../../../../Samples_SNV_chr8_v2-0.vcf.gz

/gpfs/data/../../../../Samples_SNV_chr9_v2-0.vcf.gz

- **`-ped_xl`**: the ped excel file, mentioned above in the samples format

  # Output Files:
- After successfully completed all the steps, you wil find:
- Separate folders for different chromosomes and inside them you will find corresponding Denovo mutation vcf in .vcf format and along with the summary file of denovo mutations in a tsv format.

# Additional Steps:
- You can then use the Annotation tools separately like VEP, or SnpEff or other annotation tools to annotate the variants to get consiquences and to dig more about your variants.
- you can also apply further Allele Frequency Filter comparing to gnomAD or your population cohort AF <= 0.05

# reference:
- https://www.nature.com/articles/s41525-021-00227-3
