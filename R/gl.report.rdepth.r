#' Report summary of Read Depth calculated as the sum of AvgCountRef and AvgCountSnp for each locus in a genlight {adegenet} object
#'
#' SNP datasets generated by DArT report AvgCountRef and AvgCountSnp as counts of sequence tags for the reference and alternate alleles respectively.
#' These can be added for an index of Read Depth. Filtering on Read Depth can be on the basis of loci with exceptionally low counts, or
#' loci with exceptionally high counts.
#' 
#' A histogram and or a smearplot can be requested. Note that the smearplot is computationally intensive, and will take time to 
#' execute for large datasets.
#'
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param plot if TRUE, will produce a histogram of call rate [default FALSE]
#' @param smearplot if TRUE, will produce a smearplot of individuals against loci [default FALSE]
#' @return -- Tabulation of REad Depth against Threshold
#' @importFrom adegenet glPlot
#' @importFrom graphics hist
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' gl.report.rdepth(testset.gl)

# Last amended 3-Feb-19

gl.report.rdepth <- function(x, plot=FALSE, smearplot=FALSE) {

# TIDY UP FILE SPECS

  funname <- match.call()[[1]]

# FLAG SCRIPT START

    cat("Starting",funname,"\n")

# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
    
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }

  # Work around a bug in adegenet if genlight object is created by subsetting
    x@other$loc.metrics <- x@other$loc.metrics[1:nLoc(x),]

  # Set a population if none is specified (such as if the genlight object has been generated manually)
    if (is.null(pop(x)) | is.na(length(pop(x))) | length(pop(x)) <= 0) {
      cat("  Population assignments not detected, individuals assigned to a single population labelled 'pop1'\n")
      pop(x) <- array("pop1",dim = nLoc(x))
      pop(x) <- as.factor(pop(x))
    }

# DO THE JOB

  rdepth <- x@other$loc.metrics$rdepth
  lower <- round(min(rdepth)-1,0)
  upper <- round(max(rdepth)+1,0)
  
  cat("No. of loci =", nLoc(x), "\n")
  cat("No. of individuals =", nInd(x), "\n")
  cat("  Miniumum read depth: ",round(min(rdepth),2),"\n")
  cat("  Maximum read depth: ",round(max(rdepth),2),"\n")
  cat("  Mean read depth: ",round(mean(rdepth),3),"\n\n")

  # Determine the loss of loci for a given filter cut-off
  retained <- array(NA,21)
  pc.retained <- array(NA,21)
  filtered <- array(NA,21)
  pc.filtered <- array(NA,21)
  percentile <- array(NA,21)
  for (index in 1:21) {
    i <- (index - 1)/20
    i <- (i - 1)*(1-upper) + 1
    percentile[index] <- i
    retained[index] <- length(rdepth[rdepth >= percentile[index]])
    pc.retained[index] <- round(retained[index]*100/nLoc(x),1)
    filtered[index] <- nLoc(x) - retained[index]
    pc.filtered[index] <- 100 - pc.retained[index]
  }
  df <- cbind(percentile,retained,pc.retained,filtered,pc.filtered)
  df <- data.frame(df)
  colnames(df) <- c("Threshold", "Retained", "Percent", "Filtered", "Percent")
  df <- df[order(-df$Threshold),]
  rownames(df) <- NULL
  #print(df)
  
  # Plot a histogram of Call Rate
  par(mfrow = c(2, 1),pty="m")
  
  if (plot) {
    hist(rdepth, 
         main="Read Depth Profile", 
         xlab="Read Depth", 
         border="blue", 
         col="red",
         xlim=c(lower,upper),
         breaks=100)
  }  

  if (smearplot){
    glPlot(x)
  }
  
# FLAG SCRIPT END

    cat("Completed:",funname,"\n")

  return(NULL)

}
