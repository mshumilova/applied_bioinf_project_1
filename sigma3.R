library(tidyr)
library(stringr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
print(args)

a <- c(1,2,3) #args[1], args[2], args[3] - paths to the control 1,2,3 tables
sigmas <- c()  #create an empty vector

for (el in a) {
  cont = read.csv(args[el], sep = ',', header = T) # read 1,2,3 tables
  mean_freq <- mean(cont$freq) # count frequency mean 
  sd_freq <- sd(cont$freq)     # count frequency sd 
  sigma3_freq <- mean_freq + 3*sd_freq # count 3 sigma 
  sigmas <- append(sigmas, sigma3_freq) # add 3 sigma in the vector "sigmas"
}

average_3_sigma <- sum(sigmas)/3 # count average value of 3 sigma  

mate <- read.csv(args[4], sep = ',', header = T) # read the sample table
not_random_mate_variants <- filter(mate, mate$freq > average_3_sigma) #filter frequency more than 3 control sigma

#answer:
print(not_random_mate_variants$id) # print IDs of variants with frequency more than 3 sigma



