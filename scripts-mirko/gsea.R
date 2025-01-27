library(clusterProfiler)
library(enrichplot)
library(ggplot2)
library(openxlsx)
library(ggridges)
organism = "org.Hs.eg.db"
library(organism, character.only = TRUE)

df = read.xlsx("./results/Results_Tb_vs_Normal_2024_full.xlsx")

# we want the log2 fold change 
original_gene_list <- df$log2FoldChange
names(original_gene_list) <- df$geneID
gene_list<-na.omit(original_gene_list)

# sort the list in decreasing order (required for clusterProfiler)
gene_list = sort(gene_list, decreasing = TRUE)


## Gene Set Enrichment
gse <- gseGO(geneList=gene_list, 
             ont ="ALL", 
             keyType = "ENSEMBL", 
             minGSSize = 1, 
             maxGSSize = 800, 
             pvalueCutoff = 0.05, 
             verbose = TRUE, 
             OrgDb = organism,
             pAdjustMethod = "fdr")

dotplot(gse, showCategory=10, split=".sign") + facet_grid(.~.sign)

gse <- pairwise_termsim(gse)
emapplot(gse, showCategory = 10)
