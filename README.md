# Denovo_mutation_detection
you can detect denovo mutation in easy way with the scripts.
variants that are not present in either of your parents, but does exist in the proband(child)
you need to have, vcf files with required columns like, GQ, AD, DP QUALITY, FILTER, GT, CHR, POS, REF, ALT etc.
- **Sample Details File**:  
   Create an Excel file or table with these columns:

   | IID  | PID  | MID  | Gender |
   |------|------|------|--------|
   | SS1  | SS2  | SS3  | .      |
   | SB1  | SB2  | SB3  | .      |

   - **IID**: Proband or child sample ID where de novo mutations are to be detected.  
   - **PID**: Father’s sample ID.  
   - **MID**: Mother’s sample ID.  

   **Note**: Ensure `IID`, `PID`, and `MID` match the sample IDs in your VCF files.

*this process can be run on HPC, with just easy commands:
- Commands:

- ./submit_script.sh -ns node55,node56,node57 -pt cbr_q_t -pj 4 -vcf_list SNVs_list.txt -ped_xl Trio_List.xlsx

