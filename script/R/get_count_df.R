library(readr)
cnt_dir <- "~/rnaseq_te/results/te_local_counts"
files <- list.files(cnt_dir, pattern = "\\.cntTable$", full.names = TRUE)
print(files)


read_cnt <- function(f) {
  df <- read.delim(f, header = TRUE, quote = "\"", 
                   check.names = FALSE, stringsAsFactors = FALSE)
  colnames(df) <- c("feature", sub("\\.cntTable$","",basename(f)))
  df
}
cnt_list <-lapply(files, read_cnt)

sample_sheet <- read_tsv('~/rnaseq_te/config/samples.tsv')


counts_df <- Reduce(function(a,b) merge(a,b,by = 'feature', all = TRUE), cnt_list)

counts_df[is.na(counts_df)] <- 0

dim(counts_df)

counts <- as.matrix(counts_df[,-1])
rownames(counts) <- counts_df$feature

mode(counts) <- "integer"
dim(counts)
head(counts)
coldata <- data.frame(
  sample    = colnames(counts),
  day       = sub("_.*", "", colnames(counts)),   # D25 / D28 / D57
  treatment = sub(".*_", "", colnames(counts)),   # AZA / D0 / D5
  
  row.names = colnames(counts)
)
coldata$treatment <- factor(coldata$treatment, levels = c("D0", "D5", "AZA"))

coldata$condition <- c("D5_stim_AZA","D0_unstim","D5_stim","D5_stim_AZA","D0_unstim","D5_stim","D5_stim_AZA","D0_unstim","D5_stim")
coldata$condition <- factor(coldata$condition, levels = c("D0_unstim", "D5_stim","D5_stim_AZA"))
head(counts)
head(coldata)
colnames(counts_df) <- c("feature","D5_stim_AZA","D0_unstim","D5_stim","D5_stim_AZA","D0_unstim","D5_stim","D5_stim_AZA","D0_unstim","D5_stim")
head(counts_df)
