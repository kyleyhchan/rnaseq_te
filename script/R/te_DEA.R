suppressMessages({library(DESeq2); library(tidyverse); library(ggrepel)})

head(counts)

dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = coldata,
                              design = ~condition)
keep <- rowSums(counts(dds) >= 10) >=3
dds <-dds[keep,]
nrow(dds)


dds <-DESeq(dds)

vsd <- vst(dds, blind = TRUE)
pca <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)

pv <- round(100* attr(pca, "percentVar"))

ggplot(pca, aes(PC1, PC2, colour = condition)) +
  geom_point(size = 4) +
  xlab(paste0("PC1: ", pv[1], "%")) + ylab(paste0("PC2: ", pv[2], "%")) +
  theme_bw() + ggtitle("PCA (vst)")

run_contrast <- function(dds, num, den, padj_cut = 0.05, lfc_cut = 1) {
  res <- results(dds, contrast = c("condition", num, den), alpha = padj_cut)
  df  <- as.data.frame(res)
  df$feature <- rownames(df)
  df$type    <- ifelse(grepl(":", df$feature), "TE", "Gene")
  df$sig     <- !is.na(df$padj) & df$padj < padj_cut & abs(df$log2FoldChange) > lfc_cut
  df$direction <- ifelse(df$sig & df$log2FoldChange > 0, "Up",
                         ifelse(df$sig & df$log2FoldChange < 0, "Down", "NS"))
  df <- df[order(df$padj), ]
  
  tag <- paste0(num, "_vs_", den)
  write.csv(df, paste0("DESeq2_", tag, "_all.csv"), row.names = FALSE)
  write.csv(df[df$type == "TE", ], paste0("DESeq2_", tag, "_TE.csv"), row.names = FALSE)
  
  cat("\n==", tag, "==\n")
  print(table(df$type, df$direction))
  df
}

res_stim   <- run_contrast(dds, "D5_stim",     "D0_unstim")   # stimulation effect
res_aza    <- run_contrast(dds, "D5_stim_AZA", "D5_stim")     # AZA effect (on top of stim)
res_aza_d0 <- run_contrast(dds, "D5_stim_AZA", "D0_unstim")


volcano <- function(df, title) {
  ggplot(df[!is.na(df$padj), ],
         aes(log2FoldChange, -log10(padj))) +
    geom_point(data = function(d) d[d$type == "Gene", ],
               colour = "grey75", size = 0.6, alpha = 0.5) +
    geom_point(data = function(d) d[d$type == "TE", ],
               aes(colour = direction), size = 1.4) +
    scale_colour_manual(values = c(Up = "firebrick", Down = "steelblue", NS = "grey40")) +
    geom_vline(xintercept = c(-1, 1), linetype = "dashed") +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
    theme_bw() + ggtitle(title) + labs(colour = "TE")
}
volcano(res_aza,  "D5_stim_AZA vs D5_stim")
volcano(res_stim, "D5_stim vs D0_unstim")

library(pheatmap)
te_vsd <- assay(vsd)[grepl(":", rownames(vsd)), ]
top_te <- head(order(apply(te_vsd, 1, var), decreasing = TRUE), 50)
pheatmap(te_vsd[top_te, ], scale = "row",
         annotation_col = coldata[, "condition", drop = FALSE],
         fontsize_row = 6, main = "Top 50 variable TEs")
X›