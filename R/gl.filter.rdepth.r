#' Filter loci in a genlight \{adegenet\} object based on counts of sequence tags scored at a locus (read depth)
#'
#' SNP datasets generated by DArT report AvgCountRef and AvgCountSnp as counts of sequence tags for the reference and alternate alleles respectively.
#' These can be added for an index of Read Depth. Filtering on Read Depth can be on the basis of loci with exceptionally low counts, or
#' loci with exceptionally high counts.
#' 
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param lower -- lower threshold value below which loci will be removed [default 5]
#' @param upper -- upper threshold value above which loci will be removed [default 50]
#' @param v -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]
#' @return     Returns a genlight object retaining loci with a Read Depth in the range specified by the lower and upper threshold.
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' gl.report.rdepth(testset.gl)
#' result <- gl.filter.rdepth(testset.gl, lower=8, upper=50, v=3)

gl.filter.rdepth <- function(x, lower=5, upper=50, v=2) {

# ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  # Work around a bug in adegenet if genlight object is created by subsetting
  x@other$loc.metrics <- x@other$loc.metrics[1:nLoc(x),]
  
  if (v < 0 | v > 5){
    cat("    Warning: verbosity must be an integer between 0 [silent] and 5 [full report], set to 2\n")
    v <- 2
  }
  
  if (v > 0) {
    cat("Starting gl.filter.rdepth: Filtering on read depth\n")
  }
  
  n0 <- nLoc(x)
  if (v > 2) {cat("Initial no. of loci =", n0, "\n")}

    # Remove SNP loci with rdepth < threshold
    if (v > 1){cat("  Removing loci with rdepth <",lower,"and >",upper,"\n")}
    index <- (x@other$loc.metrics["rdepth"]>=lower & x@other$loc.metrics["rdepth"]<= upper)
    x2 <- x[, index]
    # Remove the corresponding records from the loci metadata
    x2@other$loc.metrics <- x@other$loc.metrics[index,]
    if (v > 2) {cat ("  No. of loci deleted =", (n0-nLoc(x2)),"\n")}
    
  # REPORT A SUMMARY
  if (v > 2) {
    cat("Summary of filtered dataset\n")
    cat(paste("  read depth >=",lower,"and read depth <=",upper,"\n"))
    cat(paste("  No. of loci:",nLoc(x2),"\n"))
    cat(paste("  No. of individuals:", nInd(x2),"\n"))
    cat(paste("  No. of populations: ", length(levels(factor(pop(x2)))),"\n"))
  }  
  
  if ( v > 0) {cat("gl.filter.rdepth completed\n")}
  
  return(x2)
  
}