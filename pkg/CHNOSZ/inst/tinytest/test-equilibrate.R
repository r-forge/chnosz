# Load default settings for CHNOSZ
reset()

# Set up some simple systems
# One acid
basis("CHNOS+")
species("acetic acid")
aone <- suppressMessages(affinity())
# Acids
species(c("formic acid", "formate", "acetate"), add = TRUE)
aacid <- suppressMessages(affinity())
# Acids plus a sulfur species
species("H2S", add = TRUE)
aacidS <- suppressMessages(affinity())
# Proteins
species(c("LYSC_CHICK", "MYG_PHYCA", "RNAS1_BOVIN", "CYC_BOVIN"))
aprot <- suppressMessages(affinity())

info <- "equilibrate() gives expected messages and errors for balance calculation"
# The following error is triggered by equil.react, not equil.boltzmann
expect_error(equilibrate(aone), "at least two species needed", info = info)
expect_message(equilibrate(aacid), "balance: on moles of CO2", info = info)
expect_message(equilibrate(aacid), "n.balance is 2 1 1 2", info = info)
expect_message(equilibrate(aacid), "loga.balance is -2.221848", info = info)
expect_message(equilibrate(aacid, loga.balance = -3), "loga.balance is -3", info = info)
expect_error(equilibrate(aacid, balance = "length"), "some species are not proteins", info = info)
expect_error(equilibrate(aacidS), "no basis species is present in all formation reactions", info = info)
expect_message(equilibrate(aacidS, balance = 1), "balance: on supplied numeric argument", info = info)
expect_message(equilibrate(aacidS, balance = 1), "n.balance is 1 1 1 1 1", info = info)
expect_message(equilibrate(aacidS, balance = 1), "loga.balance is -2.301029", info = info)
expect_error(equilibrate(aacidS, balance = "CO2"), "some species have no CO2 in the formation reaction", info = info)
expect_message(equilibrate(aprot), "balance: on protein length", info = info)
expect_message(equilibrate(aprot), "n.balance is 129 153 124 104", info = info)
expect_message(equilibrate(aprot), "loga.balance is -0.292429", info = info)
expect_message(equilibrate(aprot, normalize = TRUE), "using 'normalize' for molar formulas", info = info)

info <- "equilibrate() gives expected messages and errors for species selection"
# An error if we select no species
expect_error(equilibrate(aacid, ispecies = numeric()), "the length of ispecies is zero", info = info)
# An error if all affinities are NA
aNA <- aacid
aNA$values[1:2] <- NA
expect_error(equilibrate(aNA, ispecies = 1:2), "all species have NA affinities", info = info)
# A message if we select only certain of the species
expect_message(equilibrate(aacid, ispecies = 1:2), "using 2 of 4 species", info = info)

info <- "equilibrate() keeps the same total loga.balance for normalize = TRUE or FALSE"
# Use the proteins
e.norm <- equilibrate(aprot, normalize = TRUE)
e <- equilibrate(aprot)
# The total activity of the balance in the two cases
sumact.balance.norm <- sum(10^unlist(e.norm$loga.equil)*e.norm$m.balance)
sumact.balance <- sum(10^unlist(e$loga.equil)*e$n.balance)
expect_equal(sumact.balance.norm, sumact.balance, info = info)

info <- "equilibrate() reproduces an example from the literature"
# The reference values are the equilibrium logarithms of activities
# of sulfur species at logfO2 = -30 from Seewald, 2001
# We name them here because S5O6-2 isn't on the plot at logfO2 = -30, 
# and to get them in order
species.ref <- c("S3O6-2", "S2O6-2", "S2O4-2", "S3-2", "S2-2", "S2O3-2", "HSO3-", "SO2", "HSO4-", "H2S")
# These values were read from the plot using g3data
loga.ref <- c(-28.82, -24.70, -22.10, -14.19, -12.12, -11.86, -8.40, -7.40, -6.54, -1.95)
# Set up the system - see ?diagram for an example showing the entire plot
basis("CHNOS+")
basis(c("pH", "O2"), c(5, -30))
# We include here all the species shown by Seewald, 2001
species(c("H2S", "S2-2", "S3-2", "S2O3-2", "S2O4-2", "S3O6-2", "S5O6-2", "S2O6-2", "HSO3-", "SO2", "HSO4-"))
a <- affinity(T = 325, P = 350)
# loga.balance = -2 signifies 10 mmolal total sulfur
e <- equilibrate(a, loga.balance = -2)
# Get the calculated activities of the reference species
loga.equil <- unlist(e$loga.equil[match(species.ref, e$species$name)])
# The test... the tolerance may seem high, but consider that the reference values
# were read from a plot with 30 logfO2 units spanning 4 inches
expect_true(all(abs(loga.equil-loga.ref) < 0.36), info = info)

info <- "equilibrate() can be used for huge values of Astar"
## Working out some bugs and testing new 'method' argument 20151109

## First, demonstrate that equil.reaction works where equil.boltzmann doesn't
# Minimal example: Astar = c(0, 0), n.balance = c(1, 1), loga.balance = 0
# results in equal activities of two species
eb0 <- equil.boltzmann(c(0, 0), c(1, 1), 0)
expect_equal(unlist(eb0), rep(log10(0.5), 2), info = info)
# Astar = c(-330, -330)
# Result is NaN (we probably get an Inf-Inf somewhere)
eb330 <- equil.boltzmann(c(-330, -330), c(1, 1), 0)
expect_equal(unlist(eb330), rep(NaN, 2), info = info)
# (fixed bug: while loop in equil.reaction tested a NaN value)
# (dlogadiff.dAbar <- 0 / 0)
er330 <- equil.reaction(c(-330, -330), c(1, 1), 0)
expect_equal(er330, eb0, info = info)

## Second, set up extreme test case and show boltzmann method produces NaN (is.na)
basis("CHNOS")
basis("O2", 200)
species(c("glycine", "alanine", "proline"))
a <- affinity()
expect_message(eb <- equilibrate(a, balance = 1), "using boltzmann method", info = info)
expect_true(all(is.na(unlist(eb$loga.equil))), info = info)

## Third, check we can use method = "reaction"
expect_message(er1 <- equilibrate(a, balance = 1, method = "reaction"), "using reaction method", info = info)
expect_false(any(is.na(unlist(er1$loga.equil))), info = info)
# Is it an equilibrium solution?
species(1:3, unlist(er1$loga.equil))
a1 <- affinity()
expect_equal(diff(range(unlist(a1$values))), 0, info = info)

## Fourth, check that we can use arbitrary numeric balance specification
# (balance <> 1 here means equilibrate will call equil.reaction)
expect_message(er11 <- equilibrate(a, balance = 1.000001), "using reaction method", info = info)
species(1:3, unlist(er11$loga.equil))
a11 <- affinity()
expect_equal(unlist(a1$values), unlist(a11$values), info = info)

## Fifth, check that equil.boltzmann won't run for balance <> 1
expect_error(equilibrate(a, balance = 1.000001, method = "boltzmann"), "won't run equil.boltzmann", info = info)

info <- "equilibrate() can be used with a vector of loga.balance values"
# System is balanced on CO2; species have different number of C, so loga.balance affects the equilibrium activities
basis("CHNOS")
species(c("formic acid", "acetic acid", "propanoic acid"))
# Calculate reference values at logfO2 = -80, log(aCO2tot) = -6
basis("O2", -80)
a <- affinity()
e80.6 <- unlist(equilibrate(a, loga.balance = -6)$loga.equil)
# Calculate reference values at logfO2 = -60, log(aCO2tot) = -8
basis("O2", -60)
a <- affinity()
e60.8 <- unlist(equilibrate(a, loga.balance = -8)$loga.equil)
# Calculate affinity on a transect: logfO2 from -80 to -60
O2 <- seq(-80, -60)
aO2 <- affinity(O2 = O2)
# Values calculated at the ends of the transect should be the same as above
eO2.6 <- equilibrate(aO2, loga.balance = -6)$loga.equil
expect_equal(list2array(eO2.6)[1, ], e80.6, info = info)
eO2.8 <- equilibrate(aO2, loga.balance = -8)$loga.equil
expect_equal(list2array(eO2.8)[21, ], e60.8, info = info)
# Make an vector of loga.balance to go with the logfO2 transect
# First we make a vector with non-matching length, and get an error
logaCO2.wronglen <- seq(-6, -8)
expect_error(equilibrate(aO2, loga.balance = logaCO2.wronglen), "length of loga.balance \\(3) doesn't match the affinity values \\(21)", info = info)
# Now do it with the correct length
logaCO2 <- seq(-6, -8, length.out = length(O2))
eO2 <- equilibrate(aO2, loga.balance = logaCO2)
# Now the first set of conditions is logfO2 = -80, log(aCO2tot) = -6
expect_equal(list2array(eO2$loga.equil)[1, ], e80.6, info = info)
# and the final set is logfO2 = -80, log(aCO2tot) = -6
expect_equal(list2array(eO2$loga.equil)[21, ], e60.8, info = info)

info <- "normalizing formulas of only selected species works as expected"
iC6 <- info("hexane", "liq")
iC12 <- info("dodecane", "liq")
`n-alkane` <- iC6:iC12
i2C6 <- info("2-methylpentane", "liq")
i2C9 <- info("2-methyloctane", "liq")
`2-isoalkane` <- i2C6:i2C9
basis("CHNOS")
basis("O2", -49.5)
species(`n-alkane`)
species(`2-isoalkane`, add = TRUE)
# Approximate conditions of Computer Experiment 27 (Helgeson et al., 2009, GCA)
a <- affinity(T = 150, P = 830, exceed.Ttr = TRUE)
# Using full chemical formulas
efull <- equilibrate(a)
dloga_isoalkane_full <- diff(unlist(efull$loga.equil[c(8, 11)]))
# Normalize all the formulas
enorm <- equilibrate(a, normalize = TRUE)
dloga_nalkane_norm <- diff(unlist(enorm$loga.equil[c(1, 7)]))
dloga_isoalkane_norm <- diff(unlist(enorm$loga.equil[c(8, 11)]))
# Normalize only the n-alkane formulas
isalk <- species()$ispecies %in% `n-alkane`
emix <- equilibrate(a, normalize = isalk)
# The activity ratios for the normalized formulas should be the same in both calculations
dloga_nalkane_mix <- diff(unlist(emix$loga.equil[c(1, 7)]))
expect_equal(dloga_nalkane_mix, dloga_nalkane_norm, info = info)
# The actvitity ratios for the not-normalized formulas should be similar in both calculations
# (not identical becuase they are affected by total activity, unlike normalized formulas)
dloga_isoalkane_mix <- diff(unlist(emix$loga.equil[c(8, 11)]))
maxdiff <- function(x, y) max(abs(y - x))
expect_true(maxdiff(dloga_isoalkane_mix, dloga_isoalkane_full) < 0.07, info = info)
# However, the difference between normalized and not-normalized formulas is much greater
expect_true(maxdiff(dloga_isoalkane_mix, dloga_isoalkane_norm) > maxdiff(dloga_isoalkane_mix, dloga_isoalkane_full), info = info)

info <- "solids are not equilibrated, but their stability fields are calculated"
# Added 20191111; based on an example sent by Feng Lai on 20191020
Cu_aq <- c("CuCl", "CuCl2-", "CuCl3-2", "CuHS", "Cu(HS)2-", "CuOH", "Cu(OH)2-")
Cu_cr <- c("copper", "chalcocite")
basis(c("Cu+", "HS-", "Cl-", "H2O", "H+", "oxygen"))
basis("O2", -35)
basis("H+", -5)
species(Cu_aq, -3)
species(Cu_cr, add = TRUE)
a <- affinity("Cl-" = c(-3, 0, 200), "HS-" = c(-10, 0, 200), T = 325, P = 500)
apredom <- diagram(a, plot.it = FALSE)$predominant
e <- equilibrate(a)
epredom <- diagram(e, plot.it = FALSE)$predominant
expect_equal(apredom, epredom, info = info)
# Also test that equilibrate() works with *only* solids 20200715
species(Cu_cr)
acr <- affinity(a)
ecr <- equilibrate(acr)
expect_identical(e$values[8:9], ecr$values, info = info)

# Reference

# Seewald, J. S. (2001) 
#   Aqueous geochemistry of low molecular weight hydrocarbons at elevated temperatures and
#   pressures: Constraints from mineral buffered laboratory experiments
#   Geochim. Cosmochim. Acta 65, 1641--1664. https://doi.org/10.1016/S0016-7037(01)00544-0
