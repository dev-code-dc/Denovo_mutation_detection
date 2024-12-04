#install.packages("vcfR")
library(tidyverse)
library(vcfR)
args = commandArgs(trailingOnly = TRUE)
##dnepvo ped creating:
ped_file = read.delim(args[1], header = F)
#candidates = unique(c(ped_file$V2, ped_file$V3, ped_file$V4))
#candidates = candidates[candidates != "."]


#candidates = c(candidates, "FORMAT")
###loading the vcf
vcf = read.vcfR(args[2])
gt = as.data.frame(vcf@gt)


#gt = as.data.frame(gt2[,c(candidates)]) %>%
#  select(FORMAT, everything())
fix = as.data.frame(vcf@fix)

# # Function to transform AD field
# transform_ad <- function(vcf_row) {
#   fields <- strsplit(vcf_row, ":")[[1]]
#   gt <- fields[1]
#   ad <- as.integer(fields[3])
#   dp <- as.integer(fields[8])
#   
#   if (gt %in% c("0/0", "0|0")) {
#     ad <- sprintf("%d,0", ad)
#   } else {
#     ad <- sprintf("%d,%d", dp - ad, ad)
#   }
#   
#   fields[3] <- ad
#   return(paste(fields, collapse = ":"))
# }
# 
# # Apply the transformation to all columns except the first one
# for (col in colnames(gt)[-5]) {
#   gt[[col]] <- sapply(gt[[col]], transform_ad)
# }
# 
# head(gt2[,childs])

#################################

# Function to transform AD field
transform_ad <- function(vcf_row) {
  fields <- strsplit(vcf_row, ":")[[1]]  # Split the row into individual fields
  gt <- fields[1]  # Extract the genotype (GT) field
  
  # Only transform AD if GT is "0/0" or "0|0"
  if (gt %in% c("0/0", "0|0")) {
    ad <- as.integer(fields[3])  # Extract the AD field as an integer
    ad_transformed <- sprintf("%d,0", ad)  # Set AD to "RD,0"
    fields[3] <- ad_transformed  # Update the AD field
  }
  
  return(paste(fields, collapse = ":"))  # Combine the fields back into a single string
}

# Apply the transformation to all columns except the first one
for (col in colnames(gt)[-1]) {
  gt[[col]] <- sapply(gt[[col]], transform_ad)
}
meta = vcf_content <- gsub("ID=AD,Number=\\.", "ID=AD,Number=R", vcf@meta)


new_vcf <- new("vcfR", meta = meta, fix = as.matrix(fix), gt = as.matrix(gt))

write.vcf(new_vcf,paste0("formatted_",gsub(".gz","",basename(args[2]))))
