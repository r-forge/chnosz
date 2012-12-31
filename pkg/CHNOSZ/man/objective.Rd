\name{objective}
\alias{objective}
\alias{SD}
\alias{CV}
\alias{shannon}
\alias{DGmix}
\alias{qqr}
\alias{logact}
\alias{spearman}
\alias{pearson}
\alias{RMSD}
\alias{CVRMSD}
\alias{DDGmix}
\alias{DGinf}
\alias{DGtr}
\alias{get.objfun}
\title{Objective Functions}
\description{
Calculate statistical and thermodynamic quantities for activities of species.
These functions can be specified as objectives in \code{\link{revisit}} and \code{\link{findit}} in order to identify optimal chemical conditions.
}

\usage{
  SD(a1)
  CV(a1)
  shannon(a1)
  DGmix(loga1)
  qqr(loga1)
  logact(loga1, loga2)
  spearman(loga1, loga2)
  pearson(loga1, loga2)
  RMSD(loga1, loga2)
  CVRMSD(loga1, loga2)
  DDGmix(loga1, loga2)
  DGinf(a1, a2)
  DGtr(loga1, loga2, Astar)
  get.objfun(objective)
}

\arguments{
  \item{a1}{numeric matrix, chemical activities of species}
  \item{loga1}{numeric matrix, logarithms of activity}
  \item{loga2}{numeric, reference values of logarithms of activity}
  \item{a2}{numeric, reference values of activity}
  \item{Astar}{numeric, reference values of chemical affinity}
  \item{objective}{character, name of objective function}
}

\details{

The value in \code{a1} or \code{loga1} is a matrix of chemical activities or logarithms of activity with a column for each species, and a row for each chemical condition.
Except for calculations of the Shannon entropy, all logarithmic bases (including in the equations below) are decimal.

\code{SD}, \code{CV} and \code{shannon} calculate the standard deviation, coefficient of variation, and Shannon entropy for the values in each row of \code{a1}. The Shannon entropy is calculated from the fractional abundances: H = sum(-p * log(p)) (natural logarithm), where p=a1/sum(a1).

\code{DGmix} calculates the Gibbs energy/2.303RT of ideal mixing from pure components corresponding to one molal (unit activity) solutions: DGmix/2.303RT = sum(a1 * loga1) (cf. Eq. 7.20 of Anderson, 2005).

\code{qqr} calculates the correlation coefficient on a quantile-quantile (Q-Q) plot (see \code{\link{qqnorm}}) for each row of \code{loga1}, giving some indication of the resemblance of the chemical activities to a log-normal distribution.

\code{logact} returns the logarithm of activity of a single species identified by index in \code{loga2} (which of the species in the system).

\code{spearman}, \code{pearson}, \code{RMSD} and \code{CVRMSD} calculate Spearman's rank correlation coefficient, the Pearson correlation coefficient, the root mean sqaured deviation (RMSD) and the coefficient of variation of the RMSD between each row of \code{loga1} and the values in \code{loga2}.
The CVRMSD is computed as the RMSD divided by the mean of the values in \code{loga1}.

\code{DDGmix} calculates the difference in Gibbs energy/2.303RT of ideal mixing between the assemblages with logarithms of activity \code{loga1} and \code{loga2}.

\code{DGinf} calculates the difference in Gibbs energy/2.303RT attributed to relative informatic entropy between an initial assemblage with activities \code{a2} and final assemblage(s) with activities with activities in each row of \code{a1}.
The equation used is DGinf/2.303RT = sum(p2 * (logp2 - logp1)), where p1 and p2 are the proportions, i.e. p1 = a1 / sum(a1) and p2 = a2 / sum(a2). 
This equation has the form of the Kullback-Leibler divergence, sometimes known as relative entropy (Ludovisi and Taticchi, 2006).
In specific cases (systems where formulas of species are normalized by the balancing coefficients), the values of \code{DGinf} and \code{DGtr} are equal.

\code{DGtr} calculates the change in Gibbs energy/2.303RT of a system in which species with initial logarithms of activitiy (\code{loga1}) are transformed to the same species with different final logarithms of activity (\code{loga2}) at constant temperature, pressure and chemical potentials of basis species.
It is calculated as the sum over species of (G2-G1) where G1/RT = -a1*Astar + a1*loga1 - a1 + a constant (where a1 is 10^loga1), likewise for G2, and where \code{Astar} is the starved affinity, that is the affinity of the reaction to form one mole of the species at unit activity from the basis species in their defined activities.
The equation used arises from integrating dG = -A/dxi = -A/dn where xi is the reaction progress variable, dn/dxi = 1 is the reaction coefficient on the species, and A = Astar - 2.303RTloga is the chemical affinity. 

Each objective function has an attribute (see \code{\link{attributes}} and \code{\link{structure}}) named \samp{optimum} that takes the value of \samp{minimal} (\code{SD}, \code{CV}, \code{RMSD}, \code{CVRMSD}, \code{DGmix}, \code{DDGmix}, \code{DGtr}) or \samp{maximal} (\code{logact}, \code{shannon}, \code{qqr}, \code{spearman}, \code{pearson}).
This attribute is used in \code{\link{optimal.index}} and \code{\link{extremes}} to identify the conditions having optimal values of the objective functions.

\code{get.objfun} returns the objective function named in \code{objective}, or produces an error if the function has no \samp{optimum} attribute.

}

\seealso{
\code{\link{get.objfun}} for retrieving these functions by name, and \code{\link{revisit}} and \code{\link{findit}} for applications of these functions in chemical systems.
}

\examples{
## a made-up system: 4 species, 1 condition
loga1 <- t(-4:-1)
loga2 <- loga1 + 1
stopifnot(qqr(loga1) < 1)
stopifnot(RMSD(loga1, loga1) == 0)
stopifnot(RMSD(loga1, loga2) == 1)
stopifnot(CVRMSD(loga1, loga2) == -0.4) # 1 / mean(-4:-1)
stopifnot(spearman(loga1, loga2) == 1)
stopifnot(spearman(loga1, rev(loga2)) == -1)
# less statistical, more thermodynamical...
stopifnot(all.equal(DGmix(loga1), -0.1234)) # as expected for decimal logarithms
stopifnot(all.equal(DDGmix(loga1, loga2), 0.0004))

## transforming an equilibrium assemblage of n-alkanes
basis(c("CH4", "H2"), c("gas", "gas"))
species(c("methane", "ethane", "propane", "n-butane"), "liq")
# calculate equilibrium assemblages over a range of logaH2
a <- affinity(H2=c(-10, -5, 101), exceed.Ttr=TRUE)
e <- equilibrate(a)
# take a reference equilibrium distribution at logfH2 = -7.5
loga1 <- list2array(e$loga.equil)[51, ]
Astar <- list2array(e$Astar)[51, ]
# equilibrium at any other logfH2 is not equilibrium at logfH2 = -7.5
DGtr.out <- DDGmix.out <- numeric()
for(i in 1:length(a$vals[[1]])) {
  loga2 <- list2array(e$loga.equil)[i, ]
  DGtr.out <- c(DGtr.out, DGtr(t(loga1), loga2, t(Astar)))
  DDGmix.out <- c(DDGmix.out, DDGmix(t(loga1), loga2))
}
# all(DGtr >= 0) is TRUE
stopifnot(all(DGtr.out >= 0))
# all(DDGmix >= 0) is FALSE
stopifnot(!all(DDGmix.out >= 0))
# a plot is also nice
thermo.plot.new(xlim=range(a$vals[[1]]), xlab=axis.label("H2"),
  ylim=range(DDGmix.out, DGtr.out), ylab="energy")
abline(h=0, lty=2)
abline(v=-7.5, lty=2)
text(-7.6, 2, "reference condition", srt=90)
lines(a$vals[[1]], DDGmix.out)
lines(a$vals[[1]], DGtr.out)
text(-6, 5.5, expr.property("DDGmix/2.303RT"))
text(-6, 2.3, expr.property("DGtr/2.303RT"))
title(main=paste("transformation between metastable equilibrium\n",
  "assemblages of n-alkanes"))
# take-home message: use DGtr to measure distance from equilibrium in 
# open-system transformations (constant T, P, chemical potentials of basis species)
}

\references{

  Anderson, G. M. (2005) \emph{Thermodynamics of Natural Systems}, 2nd ed., Cambridge University Press, 648 p. \url{http://www.worldcat.org/oclc/474880901}

  Ludovisi, A. and Taticchi, M. I. (2006) Investigating beta diversity by Kullback-Leibler information measures. \emph{Ecological Modelling} \bold{192}, 299--313. \url{http://dx.doi.org/10.1016/j.ecolmodel.2005.05.022}


}

\keyword{secondary}