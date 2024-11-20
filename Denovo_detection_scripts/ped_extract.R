library(tidyverse)
##dnepvo ped creating:
library(xlsx)
args = commandArgs(trailingOnly = TRUE)


ped = read.xlsx(args[1], sheetIndex = 1)

mod_ped <- ped %>%
  mutate(FAM_ID = as.character(c(1:length(ped$IID)))) %>%
  mutate(IID.Gender = ifelse(IID.Gender == "Male", 1, 
                             ifelse(IID.Gender == "Female", 2, 
                                    ifelse(IID.Gender == ".", ".", IID.Gender))))

# Create the new mod_ped frame
trans_ped <- data.frame(
  FAMID = rep(mod_ped$FAM_ID, times = 3),
  SAMPLE = c(mod_ped$IID, mod_ped$PID, mod_ped$MID, mod_ped$IID, mod_ped$PID, mod_ped$MID, mod_ped$IID, mod_ped$PID, mod_ped$MID)[1:(3 * nrow(mod_ped))],
  PATERNALID = c(mod_ped$PID, rep(".", length(mod_ped$PID)), rep(".", length(mod_ped$PID)))[1:(3 * nrow(mod_ped))],
  MATERNALID = c(mod_ped$MID, rep(".", length(mod_ped$MID)), rep(".", length(mod_ped$MID)))[1:(3 * nrow(mod_ped))],
  SEX = c(mod_ped$IID.Gender, rep(1, length(mod_ped$IID.Gender)), rep(2, length(mod_ped$IID.Gender)))[1:(3 * nrow(mod_ped))]
)

trans_ped =  trans_ped %>%
  arrange(FAMID) %>%
  mutate(Phenotype = ".")

write.table(trans_ped, paste0("formatted",gsub(".xlsx", ".ped" ,basename(args[1]))), col.names = F, quote = F, row.names = F, sep = '\t')
