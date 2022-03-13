library(tidyr)
library(stringr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE) # extract command line arguments
print(args)

variants <- read.csv(args[1], sep = ' ', header = F) # args1 - table with variants
frequency <- read.csv(args[2], sep =' ', header = F) # args2 - table with frequency
variants$freq <- frequency$V1 # additional column with the frequency
common_table <- variants
names(common_table) <- c('id', 'ref', 'alt', 'freq')
common_table$freq <- str_remove(common_table$freq, "%")  # remove % from the column
common_table$freq <- str_replace(common_table$freq, ",", ".") #replace comma on dot
common_table$freq <- as.numeric(common_table$freq) # change type of the column
common_table <- filter(common_table, common_table$freq < 90) #remove high frequency mutations

print(common_table)
write.csv(common_table, args[3], row.names = F, sep = ',') #args3 - path to output_dir/id



