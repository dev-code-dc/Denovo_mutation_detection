# De Novo Mutation Detection  

This guide provides an easy way to detect de novo mutations using scripts. De novo mutations are variants that are absent in both parents but present in the proband (child).

## Prerequisites

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

```bash
./submit_script.sh -ns node55,node56,node57 -pt cbr_q_t -pj 4 -vcf_list SNVs_list.txt -ped_xl Trio_List.xlsx

```
### Explanation of Command Options:

- **`-ns`**: Provide the list of nodes separated by commas (e.g., `node1,node2,node3`).
  
  This specifies the list of nodes that will be used for the job execution. You can list multiple nodes separated by commas.

- **`-pt`**: Specify the partition name for job submission in the HPC (e.g., `cbr_q_t`).
  
  This indicates the partition in which the job should run on the HPC system. Each partition is associated with different resource allocations.

- **`-pj`**: Set the number of parallel jobs per node. Be mindful of available memory and storage.
  
  This option defines how many parallel jobs will run per node. Adjust this number according to the available resources (memory, disk space). Running too many parallel jobs on limited resources can cause failures or slow performance.

- **`-vcf_list`**: thsi should be the full path of your vcf files segregated by chromosomes:

/gpfs/data/user/bratati/common_resources/Final-MAC3_OverlapVariants_CBR-NIBMG/SNV/9772Samples_CBR-NIBMG_SNV_chr8_v2-0.vcf.gz
/gpfs/data/user/bratati/common_resources/Final-MAC3_OverlapVariants_CBR-NIBMG/SNV/9772Samples_CBR-NIBMG_SNV_chr9_v2-0.vcf.gz
  
  This option defines how many parallel jobs will run per node. Adjust this number according to the available resources (memory, disk space). Running too many parallel jobs on limited resources can cause failures or slow performance.

