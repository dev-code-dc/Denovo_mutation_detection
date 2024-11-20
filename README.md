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


