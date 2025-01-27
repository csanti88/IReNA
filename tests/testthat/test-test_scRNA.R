test_that("multiplication works", {
  load(system.file("extdata", "test_seurat.rda", package = "IReNA"))

  monocle_object <- get_pseudotime(test_seurat)
  seurat_with_time <- add_pseudotime(test_seurat, monocle_object)
  expression_profile <- get_SmoothByBin_PseudotimeExp(seurat_with_time)
  expression_profile_filter <- filter_expression_profile(expression_profile, FC=0.01)
  clustering <- clustering_Kmeans(expression_profile_filter, K1=4)
  col1 <- c('#67C1E3','#EF9951','#00BFC4','#AEC7E8','#C067A9','#E56145','#2F4F4F')
  plot_kmeans_pheatmap(clustering, ModuleColor1 = col1)
  Kmeans_clustering_ENS <- add_ENSID(clustering, Spec1='Hs')
  expect_equal(nrow(Kmeans_clustering_ENS),100)
  motif1 <- Tranfac201803_Hs_MotifTFsF
  regulatory_relationships <- get_cor (Kmeans_clustering_ENS,motif1,0.6)
  TFs_list <- network_analysis(regulatory_relationships,Kmeans_clustering_ENS,TFFDR1 = 10,TFFDR2 = 10)
  plot_tf_network(TFs_list)
  plot_intramodular_network(TFs_list)
  expect_true(nrow(TFs_list[[8]])>1)
})
