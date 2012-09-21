# CHNOSZ/util.misc.R
# some utility functions for the CHNOSZ package
# speciate/thermo.R 20051021 jmd

dPdTtr <- function(x) {
  # calculate dP/dT for a phase transition
  # (argument is index of the lower-T phase)
  t1 <- subcrt(x,P=0,T=thermo$obigt$z.T[x],convert=FALSE,exceed.Ttr=TRUE)
  t2 <- subcrt(x+1,P=0,T=thermo$obigt$z.T[x],convert=FALSE,exceed.Ttr=TRUE)
  # if these aren't the same mineral all we can say is zero
  # actually, should be infinity ... the volume change is zero
  if(as.character(t1$species$name) != as.character(t2$species$name)) return(Inf)
  # we really hope the G's are the same ...
  #if(abs(t2$out[[1]]$G - t2$out[[1]]$G) > 0.1) warning('dP.dT: inconsistent values of G for different phases of ',x,call.=FALSE)
  dP.dT <- convert( ( t2$out[[1]]$S - t1$out[[1]]$S ) / ( t2$out[[1]]$V - t1$out[[1]]$V ), 'cm3bar' )
  return(dP.dT)
}

Ttr <- function(x,P=1,dPdT=NULL) {
  # calculate a phase transition temperature
  # taking account of P (from dP/dT)
  T <- thermo$obigt$z.T[x]
  if(is.null(dPdT)) dPdT <- dPdTtr(x)
  return(T + P / dPdT)
}

nonideal <- function(species,proptable,IS,T) {
  # generate nonideal contributions to thermodynamic properties
  # number of species, same length as proptable list
  # T in Kelvin, same length as nrows of proptables
  # a function that does a lot of the work
  loggamma2 <- function(Z,I,T,prop='log') {
    # extended Debye-Huckel equation ('log')
    # and its partial derivatives ('G','H','S','Cp')
    # T in Kelvin
    B <- 1.6
    # equation for A from Clarke and Glew, 1980
    #A <- expression(-16.39023 + 261.3371/T + 3.3689633*log(T)- 1.437167*(T/100) + 0.111995*(T/100)^2)
    # equation for alpha from Alberty, 2003 p. 48
    A <- alpha <- expression(1.10708 - 1.54508E-3 * T + 5.95584E-6 * T^2)
    # from examples for deriv to take first and higher-order derivatives
    DD <- function(expr,name, order = 1) {
      if(order < 1) stop("'order' must be >= 1")
      if(order == 1) D(expr,name)
      else DD(D(expr, name), name, order - 1)
    }
    # Alberty, 2003 Eq. 3.6-1
    loggamma <- function(a,Z,I,B) { - a * Z^2 * I^(1/2) / (1 + B * I^(1/2)) }
    # XXX check the following equations 20080208 jmd @@@
    if(prop=='log') return(loggamma(eval(A),Z,I,B))
    else if(prop=='G') return(thermo$opt$R * T * loggamma(eval(A),Z,I,B))
    else if(prop=='H') return(thermo$opt$R * T^2 * loggamma(eval(DD(A,'T',1)),Z,I,B))
    else if(prop=='S') return(- thermo$opt$R * T * loggamma(eval(DD(A,'T',1)),Z,I,B))
    else if(prop=='Cp') return(thermo$opt$R * T^2 *loggamma(eval(DD(A,'T',2)),Z,I,B))
  }
  if(!is.numeric(species[[1]])) species <- info(species,'aq')
  proptable <- as.list(proptable)
  # which gamma function to use
  #mlg <- get(paste('loggamma',which,sep=''))
  ndid <- 0
  for(i in 1:length(species)) {
    myprops <- proptable[[i]]
    # get the charge from the chemical formula
    # force a charge count even if it's zero
    mkp <- makeup(c("Z0", species[i]), sum=TRUE)
    Z <- mkp[grep("Z", names(mkp))]
    # don't do anything for neutral species
    if(Z==0) next
    # this would keep unit activity coefficient of the proton and electron
    #if(species[i] %in% c(info('H+',quiet=TRUE),info('e-',quiet=TRUE))) next
    didit <- FALSE
    for(j in 1:ncol(myprops)) {
      #if(colnames(myprops)[j]=='G') myprops[,j] <- myprops[,j] + thermo$opt$R * T * mlg(Z,IS,convert(T,'C'))
      cname <- colnames(myprops)[j]
      if(cname %in% c('G','H','S','Cp')) {
        myprops[,j] <- myprops[,j] + loggamma2(Z,IS,T,cname)
        didit <- TRUE
      }
    }
    # append a loggam column if we did any nonideal calculations of thermodynamic properties
    if(didit) myprops <- cbind(myprops,loggam=loggamma2(Z,IS,T))
    proptable[[i]] <- myprops
    if(didit) ndid <- ndid + 1
  }
  if(ndid > 0) cat(paste('nonideal:',ndid,'species were nonideal\n'))
  return(proptable)
}

# which.balance is used by transfer(),
# keep it as a global function
which.balance <- function(species) {
  # find the first basis species that
  # is present in all species of interest
  # ... it can be used to balance the system
  nbasis <- function(species) return(ncol(species)-4)
  ib <- NULL
  nb <- 1
  nbs <- nbasis(species)
  for(i in 1:nbs) {
    coeff <- species[,i]
    if(length(coeff)==length(coeff[coeff!=0])) {
      ib <- c(ib,i)
      nb <- nb + 1
    } else ib <- c(ib,NA)
  }
  return(ib[!is.na(ib)])
}

unitize <- function(logact=NULL,length=NULL,logact.tot=0) {
  # scale the logarithms of activities given in loga
  # so that the logarithm of total activity of residues
  # is zero (i.e. total activity of residues is one),
  # or some other value set in loga.tot.
  # length indicates the number of residues in each species.
  # if loga is NULL, take the logarithms of activities from
  # the current species definition. if any of those species
  # are proteins, get their lengths using protein.length.
  if(is.null(logact)) {
    if(is.null(thermo$species)) stop("loga is NULL and no species are defined")
    ts <- thermo$species
    logact <- ts$logact
    length <- rep(1,length(logact))
    ip <- grep("_",ts$name)
    if(length(ip) > 0) length[ip] <- protein.length(ts$name[ip])
  }
  # the lengths of the species
  if(is.null(length)) length <- 1
  length <- rep(length,length.out=length(logact)) 
  # remove the logarithms
  act <- 10^logact
  # the total activity
  act.tot <- sum(act*length)
  # the target activity
  act.to.get <- 10^logact.tot
  # the factor to apply
  act.fact <- act.to.get/act.tot
  # apply the factor
  act <- act * act.fact
  # take the logarithms
  logact <- log10(act)
  # done!
}

DGT <- function(loga1, loga2, Astar) {
  # calculate the Gibbs energy/2.303RT of transformation
  # from an initial to a final assemblage at constant T, P and 
  # chemical potentials of basis species 20120917
  # loga1 - logarithms of activity of species in the initial assemblage
  # loga2 - logarithms of activity of species in the final assemblage
  # Astar - starved (of activity of the species of interest) values of chemical affinity/2.303RT
  # first remove the logarithms
  a1 <- 10^loga1
  a2 <- 10^loga2
  # the molal Gibbs energy in the initial and final states
  # (derived from integrating A = Astar - RTln(a) from a1 to a2)
  G1 <- -a1*Astar + a1*loga1 - a1/log(10)
  G2 <- -a2*Astar + a2*loga2 - a2/log(10)
  # calculate the change in molal Gibbs energy for each species
  GT <- G2 - G1
  # return the sum
  return(sum(GT))
}