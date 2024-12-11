#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 -ns <node_list> -pt <partition_name> -pj <parallel_jobs> -vcf_list <vcf_list_file> -ped_xl <ped_file>"
  echo
  echo "  -ns         Comma-separated list of nodes (e.g., node55,node56,node57)"
  echo "  -pt         Partition name (e.g., cbr_q_t)"
  echo "  -pj         Number of parallel jobs per node (e.g., 4)"
  echo "  -vcf_list   Path to the VCF list file"
  echo "  -ped_xl     Path to the PED file (e.g., Trio_List.xlsx)"
  exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -ns) node_list_str="$2"; shift 2 ;;
    -pt) partition="$2"; shift 2 ;;
    -pj) parallel_jobs="$2"; shift 2 ;;
    -vcf_list) vcf_list_file="$2"; shift 2 ;;
    -ped_xl) ped_file="$2"; shift 2 ;;
    *) usage ;;
  esac
done

# Check if all arguments are provided
if [[ -z "$node_list_str" || -z "$partition" || -z "$parallel_jobs" || -z "$vcf_list_file" || -z "$ped_file" ]]; then
  echo "Error: Missing required arguments."
  usage
fi

# Convert comma-separated node list into an array
IFS=',' read -r -a node_list <<< "$node_list_str"

# Check if at least one node is specified
if [[ ${#node_list[@]} -lt 1 ]]; then
  echo "Error: Please specify at least one node."
  exit 1
fi

# Validate the VCF list file exists
if [[ ! -f "$vcf_list_file" ]]; then
  echo "Error: VCF list file '$vcf_list_file' does not exist."
  exit 1
fi

# Validate the PED file exists
if [[ ! -f "$ped_file" ]]; then
  echo "Error: PED file '$ped_file' does not exist."
  exit 1
fi

# Process the VCF list file
total_vcfs=$(wc -l < "$vcf_list_file")
vcfs_per_node=$((total_vcfs / ${#node_list[@]}))
remaining_vcfs=$((total_vcfs % ${#node_list[@]}))

# Split the VCF list file for each node
split_prefix="vcf_list_part_"
split -l "$vcfs_per_node" -d --additional-suffix=.list "$vcf_list_file" "$split_prefix"

# Add remaining VCFs to the last split part if there are any
if [[ $remaining_vcfs -ne 0 ]]; then
  last_file="${split_prefix}$(printf "%02d" $(( ${#node_list[@]} - 1 ))).list"
  tail -n "$remaining_vcfs" "$vcf_list_file" >> "$last_file"
fi

# Submit jobs to the nodes
for i in "${!node_list[@]}"; do
  node="${node_list[$i]}"
  vcf_part_file="${split_prefix}$(printf "%02d" "$i").list"

  # Validate that the split file exists before submitting
  if [[ ! -f "$vcf_part_file" ]]; then
    echo "Error: VCF part file '$vcf_part_file' not found for node '$node'."
    continue
  fi

  sbatch --job-name="test_p_Denovo_$node" \
         --output="job-cbr.%J.out" \
         --error="job-cbr.%J.err" \
         --partition="$partition" \
         --mem=180G \
         --ntasks-per-node=32 \
         --nodes=1 \
         --nodelist="$node" \
         --wrap="./vcf_process.sh $vcf_part_file $parallel_jobs $ped_file"
  
  if [[ $? -ne 0 ]]; then
    echo "Error: Job submission failed for node '$node' with file '$vcf_part_file'."
  fi
done
