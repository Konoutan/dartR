#' Filter loci in a genlight \{adegenet\} object based on average repeatability of alleles at a locus
#'
#' SNP datasets generated by DArT have an index, RepAvg, generated by reproducing the data independently for 30% of loci.
#' RepAvg is the proportion of alleles that give a repeatable result, averaged over both alleles for each locus.
#' 
#' SilicoDArT datasets generated by DArT have a smilar index, Reproducibility. For these fragment presence/absence data, repeatability is the 
#' percentage of scores that are repeated in the technical replicate dataset.
#'
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param threshold -- threshold value below which loci will be removed [default 0.99]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, unless specified using gl.set.verbosity]
#' @return Returns a genlight object retaining loci with repeatability (Repavg or Reproducibility) greater than the specified threshold.
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' # SNP data
#'   gl.report.repeatability(testset.gl)
#'   result <- gl.filter.repeatability(testset.gl, threshold=0.99, verbose=3)
#' # Tag P/A data
#'   gl.report.repeatability(testset.gs)
#'   result <- gl.filter.repeatability(testset.gs, threshold=0.99)

gl.filter.repeatability <- function(x, threshold=0.99, verbose=NULL) {

# TRAP COMMAND, SET VERSION
  
  funname <- match.call()[[1]]
  build <- "Jacob"
  hold <- x
  
# SET VERBOSITY
  
  if (is.null(verbose)){ 
    if(!is.null(x@other$verbose)){ 
      verbose <- x@other$verbose
    } else { 
      verbose <- 2
    }
  } 
  
  if (verbose < 0 | verbose > 5){
    cat(paste("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to 2\n"))
    verbose <- 2
  }
  
# FLAG SCRIPT START
  
  if (verbose >= 1){
    if(verbose==5){
      cat("Starting",funname,"[ Build =",build,"]\n")
    } else {
      cat("Starting",funname,"\n")
    }
  }
  
# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  
  if (verbose >= 2){
    if (all(x@ploidy == 1)){
      cat("  Processing Presence/Absence (SilicoDArT) data\n")
    } else if (all(x@ploidy == 2)){
      cat("  Processing a SNP dataset\n")
    } else {
      stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)")
    }
  }
  
# FUNCTION SPECIFIC ERROR CHECKING
  
  if (threshold < 0 | threshold > 1){
    cat ("Warning: Threshold value for repeatability measure must be between 0 and 1, set to 0.99\n")
    threshold <- 0.99
  }
  if (all(x@ploidy == 1)){
    if (is.null(x@other$loc.metrics$Reproducibility)){
      stop("Fatal Error: Dataset does not include Reproducibility among the locus metrics, cannot be calculated!")
    }
  } 
  if (all(x@ploidy == 2)){
    if (is.null(x@other$loc.metrics$RepAvg)){
      stop("Fatal Error: Dataset does not include RepAvg among the locus metrics, cannot be calculated!")
    }
  } 

# DO THE JOB

  hold <- x
  na.counter <- 0
  loc.list <- array(NA,nLoc(x))
  
  if (verbose >= 2){
    cat("  Identifying loci with repeatability below :",threshold,"\n")
  }  
  
  # Tag presence/absence data
  if (all(x@ploidy==1)){
    repeatability <- x@other$loc.metrics$Reproducibility
    for (i in 1:nLoc(x)){
      if (repeatability[i] < threshold){
        loc.list[i] <- locNames(x)[i]
      }
    }                          
  } 
  
  # SNP data
  if (all(x@ploidy==2)){
    repeatability <- x@other$loc.metrics$RepAvg
    for (i in 1:nLoc(x)){
      if (repeatability[i] < threshold){
        loc.list[i] <- locNames(x)[i]
      }
    }                          
  } 
  
  # Remove NAs from list of loci to be discarded
  loc.list <- loc.list[!is.na(loc.list)]
  
  if(length(loc.list) > 0){
    # remove the loci with repeatability below the threshold
    if (verbose >= 2){
      cat("  Removing loci with repeatability less than",threshold,"\n")
    } 
    x <- gl.drop.loc(x,loc.list=loc.list,verbose=0)
  } else {
    if (verbose >= 2){
      cat("  No loci with repeatability less than",threshold,"\n")
    } 
  }  
  
  # REPORT A SUMMARY
  if (verbose >= 3) {
    cat("\n  Summary of filtered dataset\n")
    cat(paste("  Retaining loci with repeatability >=",threshold,"\n"))
    cat(paste("  Original no. of loci:",nLoc(hold),"\n"))
    cat(paste("  No. of loci discarded:",nLoc(hold)-nLoc(x),"\n"))
    cat(paste("  No. of loci retained:",nLoc(x),"\n"))
    cat(paste("  No. of individuals:", nInd(x),"\n"))
    cat(paste("  No. of populations: ", nPop(x),"\n\n"))
  }  
  
# ADD TO HISTORY
  nh <- length(x@other$history)
  x@other$history[[nh + 1]] <- match.call()   
  
# FLAG SCRIPT END

  if (verbose >= 1) {
    cat("Completed:",funname,"\n")
  }

  return(x)
  
}
