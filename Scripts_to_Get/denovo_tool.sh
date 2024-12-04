#!/bin/bash

# Inputs: 
# $1 = node list (e.g., node55,node56)
# $2 = partition name (e.g., cbr_q_t)
# $3 = parallel jobs (e.g., 4)

node_list=(${1//,/ })   # Convert comma-separated node list into an array
partition=$2            # Partition name
parallel_jobs=$3        # Number of parallel jobs per node

# Check if at least 1 node is specified
if [ ${#node_list[@]} -lt 1 ]; then
  echo "Please specify at least one node."
  exit 1
fi

# Load the VCF list and split it into parts according to the number of nodes
vcf_list_file="SNVs_list_244_all_chr"
total_vcfs=$(cat "$vcf_list_file" | wc -l)
vcfs_per_node=$(($total_vcfs / ${#node_list[@]}))
remaining_vcfs=$(($total_vcfs % ${#node_list[@]}))

# Create split files for each node
split_prefix="vcf_list_part_"
split -l $vcfs_per_node -d --additional-suffix=.list "$vcf_list_file" "$split_prefix"

# Add remaining VCFs to the last split part (if there are any)
if [ $remaining_vcfs -ne 0 ]; then
  last_file="${split_prefix}$(printf "%02d" $((${#node_list[@]} - 1))).list"
  tail -n $remaining_vcfs "$vcf_list_file" >> "$last_file"
fi

# Submit jobs to the nodes
for i in "${!node_list[@]}"; do
  node="${node_list[$i]}"
  vcf_part_file="${split_prefix}$(printf "%02d" $i).list"

  sbatch --job-name=test_p_Denovo_$node \
         --output=job-cbr.%J.out \
         --error=job-cbr.%J.err \
         --partition=$partition \
         --mem=180G \
         --ntasks-per-node=32 \
         --nodes=1 \
         --nodelist=$node \
         --wrap="./vcf_process.sh $vcf_part_file $parallel_jobs"
done

