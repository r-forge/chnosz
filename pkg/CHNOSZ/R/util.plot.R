# CHNOSZ/util.plot.R
# Functions to create and modify plots

thermo.plot.new <- function(xlim,ylim,xlab,ylab,cex = par('cex'),mar = NULL,lwd = par('lwd'),side = c(1,2,3,4),
  mgp = c(1.7,0.3,0),cex.axis = par('cex'),col = par('col'),yline = NULL,axs = 'i',plot.box = TRUE,
  las = 1,xline = NULL, grid = "", col.grid = "gray", ...) {
  # Start a new plot with some customized settings
  thermo <- get("thermo", CHNOSZ)
  # 20120523 store the old par in thermo()$opar
  if(is.null(thermo$opar)) {
    thermo$opar <- par(no.readonly = TRUE)
    assign("thermo", thermo, CHNOSZ)
  }
  # 20090324 mar handling: NULL - a default setting; NA - par's setting
  # 20090413 changed mar of top side from 2 to 2.5
  marval <- c(3, 3.5, 2.5, 1)
  if(identical(mar[1], NA)) marval <- par("mar")
  # 20181007 get mar from the current device (if it exists) and par("mar") is not the default
  if(!is.null(dev.list())) {
    if(!identical(par("mar"), c(5.1, 4.1, 4.1, 2.1))) marval <- par("mar")
  }
  # Assign marval to mar if the latter is NULL or NA
  if(!is.numeric(mar)) mar <- marval
  par(mar = mar,mgp = mgp,tcl = 0.3,las = las,xaxs = axs,yaxs = axs,cex = cex,lwd = lwd,col = col,fg = col, ...)
  plot.new()
  plot.window(xlim = xlim,ylim = ylim)
  if(plot.box) box()
  # Labels
  if(is.null(xline)) xline <- mgp[1]
  thermo.axis(xlab,side = 1,line = xline,cex = cex.axis,lwd = NULL)
  if(is.null(yline)) yline <- mgp[1]
  thermo.axis(ylab,side = 2,line = yline,cex = cex.axis,lwd = NULL)
  # (optional) tick marks
  if(1 %in% side) thermo.axis(NULL,side = 1,lwd = lwd, grid = grid, col.grid = col.grid, plot.line = !plot.box)
  if(2 %in% side) thermo.axis(NULL,side = 2,lwd = lwd, grid = grid, col.grid = col.grid, plot.line = !plot.box)
  if(3 %in% side) thermo.axis(NULL,side = 3,lwd = lwd, plot.line = !plot.box)
  if(4 %in% side) thermo.axis(NULL,side = 4,lwd = lwd, plot.line = !plot.box)
}

label.plot <- function(label, xfrac = 0.07, yfrac = 0.93, paren = FALSE, italic = FALSE, ...) {
  # Make a text label e.g., "(a)" in the corner of a plot
  # xfrac, yfrac: fraction of axis where to put label (default top right)
  # paren: put a parenthesis around the text, and italicize it?
  if(italic) label <- bquote(italic(.(label)))
  if(paren) label <- bquote(group("(", .(label), ")"))
  pu <- par('usr')
  x <- pu[1]+xfrac*(pu[2]-pu[1])
  y <- pu[3]+yfrac*(pu[4]-pu[3])
  # Conversion for logarithmic axes
  if(par("xlog")) x <- 10^x
  if(par("ylog")) y <- 10^y
  text(x, y, labels = label, ...)
}

usrfig <- function() {
  # Function to get the figure limits in user coordinates
  # Get plot limits in user coordinates (usr) and as fraction [0,1] of figure region (plt)
  xusr <- par('usr')[1:2]; yusr <- par('usr')[3:4]
  xplt <- par('plt')[1:2]; yplt <- par('plt')[3:4]
  # Linear model to calculate figure limits in user coordinates
  xlm <- lm(xusr ~ xplt); ylm <- lm(yusr ~ yplt)
  xfig <- predict.lm(xlm, data.frame(xplt = c(0, 1)))
  yfig <- predict.lm(ylm, data.frame(yplt = c(0, 1)))
  return(list(x = xfig, y = yfig))
}

label.figure <- function(label, xfrac = 0.05, yfrac = 0.95, paren = FALSE, italic = FALSE, ...) {
  # Function to add labels outside of the plot region  20151020
  f <- usrfig()
  # Similar to label.plot(), except we have to set xpd here
  opar <- par(xpd = NA)
  if(italic) label <- bquote(italic(.(label)))
  if(paren) label <- bquote(group("(", .(label), ")"))
  # Calculate location for label
  x <- f$x[1] + xfrac * (f$x[2] - f$x[1])
  y <- f$y[1] + yfrac * (f$y[2] - f$y[1])
  # Conversion for logarithmic axes
  if(par("xlog")) x <- 10^x
  if(par("ylog")) y <- 10^y
  text(x, y, labels = label, ...)
  par(opar)
}

water.lines <- function(eout, which = c('oxidation','reduction'),
  lty = 2, lwd = 1, col = par('fg'), plot.it = TRUE) {

  # Draw water stability limits for Eh-pH, logfO2-pH, logfO2-T or Eh-T diagrams
  # (i.e. redox variable is on the y axis)

  # Get axes, T, P, and xpoints from output of affinity() or equilibrate()
  if(missing(eout)) stop("'eout' (the output of affinity(), equilibrate(), or diagram()) is missing")
  # Number of variables used in affinity()
  nvar1 <- length(eout$vars)
  # If these were on a transect, the actual number of variables is less
  dim <- dim(eout$loga.equil[[1]]) # for output from equilibrate()
  if(is.null(dim)) dim <- dim(eout$values[[1]]) # for output from affinity()
  nvar2 <- length(dim)
  # We only work on diagrams with 1 or 2 variables
  if(!nvar1 %in% c(1, 2) | !nvar2 %in% c(1, 2)) return(NA)

  # If needed, swap axes so redox variable is on y-axis
  # Also do this for 1-D diagrams 20200710
  if(is.na(eout$vars[2])) eout$vars[2] <- "nothing"
  swapped <- FALSE
  if(eout$vars[2] %in% c("T", "P", "nothing")) {
    eout$vars <- rev(eout$vars)
    eout$vals <- rev(eout$vals)
    swapped <- TRUE
  }
  xaxis <- eout$vars[1]
  yaxis <- eout$vars[2]
  xpoints <- eout$vals[[1]]
  # Make xaxis "nothing" if it is not pH, T, or P 20201110
  # (so that horizontal water lines can be drawn for any non-redox variable on the x-axis)
  if(!identical(xaxis, "pH") & !identical(xaxis, "T") & !identical(xaxis, "P")) xaxis <- "nothing"

  # T and P are constants unless they are plotted on one of the axes
  T <- eout$T
  if(eout$vars[1] == "T") T <- envert(xpoints, "K")
  P <- eout$P
  if(eout$vars[1] == "P") P <- envert(xpoints, "bar")
  # logaH2O is 0 unless given in eout$basis
  iH2O <- match("H2O", rownames(eout$basis))
  if(is.na(iH2O)) logaH2O <- 0 else logaH2O <- as.numeric(eout$basis$logact[iH2O])
  # pH is 7 unless given in eout$basis or plotted on one of the axes
  iHplus <- match("H+", rownames(eout$basis))
  if(eout$vars[1] == "pH") pH <- xpoints
  else if(!is.na(iHplus)) {
    minuspH <- eout$basis$logact[iHplus]
    # Special treatment for non-numeric value (happens when a buffer is used, even for another basis species)
    if(can.be.numeric(minuspH)) pH <- -as.numeric(minuspH) else pH <- NA
  }
  else pH <- 7

  # O2state is gas unless given in eout$basis
  iO2 <- match("O2", rownames(eout$basis))
  if(is.na(iO2)) O2state <- "gas" else O2state <- eout$basis$state[iO2]
  # H2state is gas unles given in eout$basis
  iH2 <- match("H2", rownames(eout$basis))
  if(is.na(iH2)) H2state <- "gas" else H2state <- eout$basis$state[iH2]

  # Where the calculated values will go
  y.oxidation <- y.reduction <- NULL
  if(xaxis %in% c("pH", "T", "P", "nothing") & yaxis %in% c("Eh", "pe", "O2", "H2")) {
    # Eh/pe/logfO2/logaO2/logfH2/logaH2 vs pH/T/P
    if('reduction' %in% which) {
      logfH2 <- logaH2O # usually 0
      if(yaxis == "H2") {
        logK <- suppressMessages(subcrt(c("H2", "H2"), c(-1, 1), c("gas", H2state), T = T, P = P, convert = FALSE))$out$logK
        # This is logfH2 if H2state == "gas", or logaH2 if H2state == "aq"
        logfH2 <- logfH2 + logK
        y.reduction <- rep(logfH2, length.out = length(xpoints))
      } else {
        logK <- suppressMessages(subcrt(c("H2O", "O2", "H2"), c(-1, 0.5, 1), c("liq", O2state, "gas"), T = T, P = P, convert = FALSE))$out$logK 
        # This is logfO2 if O2state == "gas", or logaO2 if O2state == "aq"
        logfO2 <- 2 * (logK - logfH2 + logaH2O)
        if(yaxis == "O2") y.reduction <- rep(logfO2, length.out = length(xpoints))
        else if(yaxis == "Eh") y.reduction <- convert(logfO2, 'E0', T = T, P = P, pH = pH, logaH2O = logaH2O)
        else if(yaxis == "pe") y.reduction <- convert(convert(logfO2, 'E0', T = T, P = P, pH = pH, logaH2O = logaH2O), "pe", T = T)
      }
    }
    if('oxidation' %in% which) {
      logfO2 <- logaH2O # usually 0
      if(yaxis == "H2") {
        logK <- suppressMessages(subcrt(c("H2O", "O2", "H2"), c(-1, 0.5, 1), c("liq", "gas", H2state), T = T, P = P, convert = FALSE))$out$logK 
        # This is logfH2 if H2state == "gas", or logaH2 if H2state == "aq"
        logfH2 <- logK - 0.5*logfO2 + logaH2O
        y.oxidation <- rep(logfH2, length.out = length(xpoints))
      } else {
        logK <- suppressMessages(subcrt(c("O2", "O2"), c(-1, 1), c("gas", O2state), T = T, P = P, convert = FALSE))$out$logK 
        # This is logfO2 if O2state == "gas", or logaO2 if O2state == "aq"
        logfO2 <- logfO2 + logK
        if(yaxis == "O2") y.oxidation <- rep(logfO2, length.out = length(xpoints))
        else if(yaxis == "Eh") y.oxidation <- convert(logfO2, 'E0', T = T, P = P, pH = pH, logaH2O = logaH2O)
        else if(yaxis == "pe") y.oxidation <- convert(convert(logfO2, 'E0', T = T, P = P, pH = pH, logaH2O = logaH2O), "pe", T = T)
      }
    }
  } else return(NA)

  # Now plot the lines
  if(plot.it) {
    if(swapped) {
      if(nvar1 == 1 | nvar2 == 2) {
        # Add vertical lines on 1-D diagram 20200710
        abline(v = y.oxidation[1], lty = lty, lwd = lwd, col = col)
        abline(v = y.reduction[1], lty = lty, lwd = lwd, col = col)
      } else {
        # xpoints above is really the ypoints
        lines(y.oxidation, xpoints, lty = lty, lwd = lwd, col = col)
        lines(y.reduction, xpoints, lty = lty, lwd = lwd, col = col)
      }
    } else {
      lines(xpoints, y.oxidation, lty = lty, lwd = lwd, col = col)
      lines(xpoints, y.reduction, lty = lty, lwd = lwd, col = col)
    }
  }
  # Return the values
  return(invisible(list(xpoints = xpoints, y.oxidation = y.oxidation, y.reduction = y.reduction, swapped = swapped)))
}

mtitle <- function(main, line = 0, spacing = 1, ...) {
  # Make a possibly multi-line plot title 
  # Useful for including expressions on multiple lines 
  # 'line' is the margin line of the last (bottom) line of the title
  len <- length(main)
  for(i in 1:len) mtext(main[i], line = line + (len - i)*spacing, ...)
}

# Get colors for range of ZC values 20170206
ZC.col <- function(z) {
  # Scale values to [1, 1000]
  z <- z * 999/diff(range(z))
  z <- round(z - min(z)) + 1
  # Diverging (blue - light grey - red) palette
  # dcol <- colorspace::diverge_hcl(1000, c = 100, l = c(50, 90), power = 1)
  # Use precomputed values
  file <- system.file("extdata/misc/bluered.txt", package = "CHNOSZ")
  dcol <- read.table(file, as.is = TRUE)[[1]]
  # Reverse the palette so red is at lower ZC (more reduced)
  rev(dcol)[z]
}

# Function to add axes and axis labels to plots,
#   with some default style settings (rotation of numeric labels)
# With the default arguments (no labels specified), it plots only the axis lines and tick marks
#   (used by diagram() for overplotting the axis on diagrams filled with colors).
thermo.axis <- function(lab = NULL, side = 1:4,line = 1.5, cex = par('cex'), lwd = par('lwd'),
  col = par('col'), grid  =  "", col.grid = "gray", plot.line = FALSE) {
  if(!is.null(lwd)) {
    for(thisside in side) {

      ## Get the positions of major tick marks
      at <- axis(thisside,labels = FALSE,tick = FALSE) 
      # Get nicer divisions for axes that span exactly 15 units 20200719
      if(thisside %in% c(1,3)) lim <- par("usr")[1:2]
      if(thisside %in% c(2,4)) lim <- par("usr")[3:4]
      if(abs(diff(lim)) == 15) at <- seq(lim[1], lim[2], length.out = 6)
      if(abs(diff(lim)) == 1.5) at <- seq(lim[1], lim[2], length.out = 4)
      # Make grid lines
      if(grid %in% c("major", "both") & thisside == 1) abline(v = at, col = col.grid)
      if(grid %in% c("major", "both") & thisside == 2) abline(h = at, col = col.grid)
      ## Plot major tick marks and numeric labels
      do.label <- TRUE
      if(missing(side) | (missing(cex) & thisside %in% c(3,4))) do.label <- FALSE
      # col and col.ticks: plot the tick marks but no line (we make it with box() in thermo.plot.new()) 20190416
      # mat: don't plot ticks at the plot limits 20190416
      if(thisside %in% c(1, 3)) pat <- par("usr")[1:2]
      if(thisside %in% c(2, 4)) pat <- par("usr")[3:4]
      mat <- setdiff(at, pat)
      if(plot.line) axis(thisside, at = mat, labels = FALSE, tick = TRUE, lwd = lwd, col.axis = col, col = col)
      else axis(thisside, at = mat, labels = FALSE, tick = TRUE, lwd = lwd, col.axis = col, col = NA, col.ticks = col)
      # Plot only the labels at all major tick points (including plot limits) 20190417
      if(do.label) axis(thisside, at = at, tick = FALSE, col = col)

      ## Plot minor tick marks
      # The distance between major tick marks
      da <- abs(diff(at[1:2]))
      # Distance between minor tick marks
      di <- da / 4
      if(!da %% 3) di <- da / 3
      else if(da %% 2 | !(da %% 10)) di <- da / 5
      # Number of minor tick marks
      if(thisside %in% c(1,3)) {
        ii <- c(1,2) 
        myasp <- par('xaxp')
      } else {
        ii <- c(3,4)
        myasp <- par('yaxp')
      }
      myusr <- par('usr')[ii]
      daxis <- abs(diff(myusr))
      nt <- daxis / di + 1
      ## If nt isn't an integer, it probably
      ## means the axis limits don't correspond
      ## to major tick marks (expect problems)
      ##at <- seq(myusr[1],myusr[2],length.out = nt)
      # Start from (bottom/left) of axis?
      bl <- 1
      #if(myasp[2] == myusr[2]) bl <- 2
      # Is forward direction (top/right)?
      tr <- 1
      if(xor(myusr[2] < myusr[1] , bl == 2)) tr <- -1
      #at <- myusr[bl] + tr * di * seq(0:(nt-1))
      # Well all of that doesn't work in a lot of cases,
      # where none of the axis limits correspond to
      # major tick marks. perhaps the following will work
      at <- myusr[1] + tr * di * (0:(nt-1))
      # Apply an offset
      axt <- axTicks(thisside)[1]
      daxt <- (axt - myusr[1])/di
      daxt <- (daxt-round(daxt))*di
      at <- at + daxt
      ## Get the positions of major tick marks and make grid lines
      if(grid %in% c("minor", "both") & thisside == 1) abline(v = at, col=col.grid, lty = 3)
      if(grid %in% c("minor", "both") & thisside == 2) abline(h = at, col=col.grid, lty = 3)
      tcl <- par('tcl') * 0.5
      at <- setdiff(at, pat)
      if(plot.line) axis(thisside, labels = FALSE, tick = TRUE, lwd = lwd, col.axis = col, at = at, tcl = tcl, col = col)
      else axis(thisside, labels = FALSE, tick = TRUE, lwd = lwd, col.axis = col, at = at, tcl = tcl, col = NA, col.ticks = col)
    }
  }
  # Rotate labels on side axes
  for(thisside in side) {
    if(thisside %in% c(2,4)) las <- 0 else las <- 1
    if(!is.null(lab)) mtext(lab, side = thisside, line = line, cex = cex, las = las)
  }
}
