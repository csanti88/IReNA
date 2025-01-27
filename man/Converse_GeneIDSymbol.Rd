% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ID_change.R
\name{Converse_GeneIDSymbol}
\alias{Converse_GeneIDSymbol}
\title{ID change}
\usage{
Converse_GeneIDSymbol(Gene1, GeneInf1 = NULL, Spec1 = "")
}
\arguments{
\item{Gene1}{vector, indicating original gene ids}

\item{GeneInf1}{data.frame, correspondence file of gene ID, row names should
be ENSEMBLE ID, first column should be Symbol ID, if GeneInf1 = NULL this
function will be built-in corresponding gene ID file.}

\item{Spec1}{If you don’t have a gene ID corresponding file, you can also use
our built-in corresponding gene ID file, 'Mm' for mus musculus}
}
\value{
return a data.frame contain original gene ids and conversed gene ids
}
\description{
Function to transfer Symbol ID to ENSEMBEL or ENSEMBEL to Symbol
}
\examples{
load(system.file("extdata", "test_clustering.rda", package = "IReNA"))

Converse_GeneIDSymbol(rownames(test_clustering), Spec1 = 'Hs')
}
