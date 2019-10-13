#' Report summary of RepAvg (repeatability averaged over both alleles for each locus) or reproducibility (repeatability of the scores
#' for fragment presence/absence).
#'
#' SNP datasets generated by DArT have an index, RepAvg, generated by reproducing the data independently for 30% of loci.
#' RepAvg is the proportion of alleles that give a repeatable result, averaged over both alleles for each locus.
#' 
#' In the case of fragment presence/absence data (SilicoDArT), repeatability is the percentage of scores that are repeated
#' in the technical replicate dataset.
#' 
#' A histogram and whisker plot are produced to aid in selecting a threshold.
#'
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]
#' #' @param boxplot -- if 'standard', plots a standard box and whisker plot; if 'adjusted',
#' plots a boxplot adjusted for skewed distributions [default 'adjusted']
#' #' @param range -- specifies the range for delimiting outliers [default = 1.5 interquartile ranges]
#' @return -- Tabulation of repeatability against prospective Thresholds
#' @importFrom graphics hist
#' @importFrom robustbase adjbox
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' gl.report.repavg(testset.gl)

gl.report.repeatability <- function(x, boxplot="adjusted", range=1.5, verbose=2) {

  # TIDY UP FILE SPECS
  
  build <- "Jacob"
  funname <- match.call()[[1]]
  hold <- x
  # Note does not draw upon or modify the loc.metrics.flags as RepAvg and Reproducibility cannot be recalculated.

  # FLAG SCRIPT START
  
  if (verbose < 0 | verbose > 5){
    cat("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to 2\n")
    verbose <- 2
  }
  
  cat("Starting",funname,"[ Build =",build,"]\n")

  # STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  
    if (all(x@ploidy == 1)){
      cat("  Processing Presence/Absence (SilicoDArT) data\n")
    } else if (all(x@ploidy == 2)){
      cat("  Processing a SNP dataset\n")
    } else {
      cat ("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)"); stop("Terminating Execution!")
    }

# DO THE JOB

  if (all(x@ploidy == 2)){
    repeatability <- x@other$loc.metrics$RepAvg
  } else {
    repeatability <- x@other$loc.metrics$Reproducibility
  } 
  xlimit <- min(repeatability)
  
    cat("  No. of loci =", nLoc(x), "\n")
    cat("  No. of individuals =", nInd(x), "\n")
    cat("  Miniumum repeatability: ",round(min(repeatability),2),"\n")
    cat("  Maximum repeatability: ",round(max(repeatability),2),"\n")
    cat("  Mean repeatability: ",round(mean(repeatability),3),"\n\n")

  # Determine the loss of loci for a given filter cut-off
  retained <- array(NA,21)
  pc.retained <- array(NA,21)
  filtered <- array(NA,21)
  pc.filtered <- array(NA,21)
  percentile <- array(NA,21)
  for (index in 1:21) {
    i <- (index - 1)/20
    i <- (i - 1)*(1-xlimit) + 1
    percentile[index] <- i
    retained[index] <- length(repeatability[repeatability >= percentile[index]])
    pc.retained[index] <- round(retained[index]*100/nLoc(x),1)
    filtered[index] <- nLoc(x) - retained[index]
    pc.filtered[index] <- 100 - pc.retained[index]
  }
  df <- cbind(percentile,retained,pc.retained,filtered,pc.filtered)
  df <- data.frame(df)
    colnames(df) <- c("Threshold", "Retained", "Percent", "Filtered", "Percent")
  df <- df[order(-df$Threshold),]
  rownames(df) <- NULL

  # Prepare for plotting
  # Save the prior settings for mfrow, oma, mai and pty, and reassign
  op <- par(mfrow = c(2, 1), oma=c(1,1,1,1), mai=c(0.5,0.5,0.5,0.5),pty="m")
  # Set margins for first plot
  par(mai=c(1,0.5,0.5,0.5))
  # Plot Box-Whisker plot
  if (all(x@ploidy==2)){
    title <- paste0("SNP data (DArTSeq)\nRepeatbility by Locus")
  } else {
    title <- paste0("Fragment P/A data (SilicoDArT)\nRepeatbility by Locus")
  }  
  if (boxplot == "standard"){
    boxplot(repeatability, 
            horizontal=TRUE, 
            col='red', 
            range=range, 
            ylim=c(min(repeatability),1),
            main = title)
    cat("Standard boxplot, no adjustment for skewness\n\n")
  } else {
    robustbase::adjbox(repeatability,
                       horizontal = TRUE,
                       col='red',
                       range=range,
                       ylim=c(min(repeatability),1),
                       main = title)
    cat("Boxplot adjusted to account for skewness\n\n")
  }  
  # Set margins for second plot
  par(mai=c(0.5,0.5,0,0.5))
  hist(repeatability, 
       main="", 
       xlab="", 
       col="red",
       xlim=c(min(repeatability),1),
       breaks=100)

  # FLAG SCRIPT END
  
  if (verbose > 0) {
    cat("Completed:",funname,"\n")
  }
  
  # Reset the par options    
  par(op)
  
  # Return the result
  return(df)

}
