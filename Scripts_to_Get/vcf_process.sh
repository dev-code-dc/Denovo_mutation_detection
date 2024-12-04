#!/bin/bash
#SBATCH --job-name=test_p_Denovo
#SBATCH --output=job-cbr.%J.out
#SBATCH --error=job-cbr.%J.err
#SBATCH --mem=180G
#SBATCH --ntasks-per-node=64
# Load necessary modules
module load R/4.4.1
module load gnu-parallel

# Accept inputs
vcf_list_file="$1"   # The dynamically passed VCF list file
parallel_jobs="$2"   # Number of parallel jobs per node
ped_file="$3"

# Extract PED file information
Rscript ped_extract.R $ped_file

# Function to process each VCF file
process_vcf() {
    vcf=$1
    chromosome=$(basename "$vcf" | sed 's/.*HWE-IC-Recal-Filter_//; s/.vcf.gz//')

   mkdir -p "chr${chromosome}"

    output_file=$(echo $(basename NIBMG_Trio_List_copy_added_sex_dot.xlsx .xlsx).ped)
    formatted_output=$(echo -e "formatted${output_file}")

    samples=$(awk '{print $2"\n"$3"\n"$4}' ${formatted_output} | grep -v -E '^\.$|^0$|^1$' | sort | uniq | paste -sd "," -)
    vcf_name=$(basename ${vcf})
    formatted_vcf="formatted_${vcf_name%.gz}"

    module load bcftools-1.18
    bcftools view ${vcf} -s ${samples} --threads 64 | head -10000 > "sampls_${formatted_vcf}"

    Rscript vcf_format.R "$formatted_output" "sampls_${formatted_vcf}"
    bcftools view --threads 64 "formatted_sampls_${formatted_vcf}" > "conv_${formatted_vcf}"

    rm "formatted_sampls_${formatted_vcf}" "sampls_${formatted_vcf}"
    cp ${formatted_output} "chr${chromosome}/"
    mv conv_formatted*_"${chromosome}"* "chr${chromosome}/"

    cd "chr${chromosome}"

    conv_vcf="conv_formatted_$(basename "$vcf" .gz)"
    slivar_output="244_sample_chr${chromosome}_denov.vcf"
    slivar_ped=${formatted_output}


#        ./slivar expr --pass-only --vcf "${conv_vcf}" --ped "${slivar_ped}" --js slivar-functions.js --out-vcf "without_AF_filter_${slivar_output}" --info "variant.FILTER == 'PASS' && variant.call_rate > 0.90" --trio "example_denovo:denovo(kid, dad, mom) && kid.het && mom.hom_ref && dad.hom_ref && (mom.AD[1] + dad.AD[1]) == 0 && kid.GQ >= 20 && mom.GQ >= 20 && dad.GQ >= 20 && kid.DP >= 10 && mom.DP >= 10 && dad.DP >= 10"

#        ./slivar expr --pass-only -g gnomad.hg38.genomes.v3.fix.zip --vcf "${conv_vcf}" --ped "${slivar_ped}" --js slivar-functions.js --out-vcf "filtered_AF_${slivar_output}" --info "INFO.gnomad_popmax_af < 0.05 && variant.FILTER == 'PASS' && variant.call_rate > 0.90" --trio "example_denovo:denovo(kid, dad, mom) && kid.het && mom.hom_ref && dad.hom_ref && (mom.AD[1] + dad.AD[1]) == 0 && kid.GQ >= 20 && mom.GQ >= 20 && dad.GQ >= 20 && kid.DP >= 10 && mom.DP >= 10 && dad.DP >= 10"


#./slivar expr --pass-only -g gnomad.hg38.genomes.v3.fix.zip --vcf "${conv_vcf}" --ped "${slivar_ped}" --js slivar-functions.js --out-vcf "filtered_AF_${slivar_output}" --info "INFO.gnomad_popmax_af < 0.05 && variant.FILTER == 'PASS' && variant.call_rate > 0.90" --trio "homalt_denovo:kid.hom_alt | kid.het && mom.hom_ref && dad.hom_ref && (mom.AD[1] + dad.AD[1]) == 0 && kid.GQ >= 20 && mom.GQ >= 20 && dad.GQ >= 20 && kid.DP >= 10 && mom.DP >= 10 && dad.DP >= 10"

.././slivar expr --pass-only --vcf "${conv_vcf}" --ped "${slivar_ped}" --js ../slivar-functions.js --out-vcf "without_AF_filter_${slivar_output}" --info "variant.FILTER == 'PASS' && variant.call_rate > 0.90" --trio "homalt_denovo:kid.hom_alt | kid.het && mom.hom_ref && dad.hom_ref && (mom.AD[1] + dad.AD[1]) == 0 && kid.GQ >= 20 && mom.GQ >= 20 && dad.GQ >= 20 && kid.DP >= 10 && mom.DP >= 10 && dad.DP >= 10"





 #   ./slivar tsv -p "${slivar_ped}" -s example_denovo "filtered_AF_${slivar_output}" > "summary_filtered_244_sample_chr${chromosome}_denov_1.tsv"

#cat "summary_filtered_244_sample_chr${chromosome}_denov_1.tsv" | tr '\t' '$'| sed 's/\$\$\$/\$/g' | tr '$' '\t' > "summary_filtered_244_sample_chr${chromosome}_denov.tsv"

.././slivar tsv -p "${slivar_ped}" -s homalt_denovo "without_AF_filter_${slivar_output}" > "summary_without_filter_244_sample_chr${chromosome}_denov_1.tsv"

cat "summary_without_filter_244_sample_chr${chromosome}_denov_1.tsv" | tr '\t' '$'| sed 's/\$\$\$/\$/g' | tr '$' '\t' > "summary_without_filter_244_sample_chr${chromosome}_denov.tsv"
    rm "${conv_vcf}"
    cd ..
}

export -f process_vcf

# Run the process in parallel
cat "$vcf_list_file" | parallel -j "$parallel_jobs" process_vcf

