# This is a long test ... only run it "at home" 20220129
if(!at_home()) exit_file("Skipping long test")

# Load default settings for CHNOSZ
reset()

info <- "Errors come as expected"
expect_error(affinity(iprotein = 7), "basis species are not defined", info = info)
expect_error(affinity(iprotein = NA), "has some NA values", info = info)
expect_error(affinity(iprotein = 0), "are not rownumbers", info = info)
basis("CHNOS")
expect_error(affinity(), "species have not been defined", info = info)
species("CO2")
expect_error(affinity(pe = c(-10, 10), pH = c(0, 14)), "pe.*does not match any basis species", info = info)
expect_error(affinity(O2 = c(-80, -60), pH = c(0, 14)), "pH.*does not match any basis species", info = info)

info <- "Output gives T and P in user's units"
basis("CHNOS")
species("5a(H),14b(H)-cholestane")
a.C_bar <- affinity(T = c(0, 100, 10), P = c(10, 1000, 10))
expect_equal(range(a.C_bar$vals[[1]]), c(0, 100), info = info)
expect_equal(range(a.C_bar$vals[[2]]), c(10, 1000), info = info)
T.units("K")
P.units("MPa")
a.K_MPa <- affinity(T = c(273.15, 373.15, 10), P = c(1, 100, 10))
expect_equal(range(a.K_MPa$vals[[1]]), c(273.15, 373.15), info = info)
expect_equal(range(a.K_MPa$vals[[2]]), c(1, 100), info = info)
# different units, same T,P ... same affinities
expect_equal(a.C_bar$values, a.K_MPa$values, info = info)
# Go back to original units for the remaining tests
T.units("C")
P.units("bar")

info <- "pe, pH and Eh are correctly handled"
basis("CHNOSe")
species(c("HS-", "H2S", "SO4-2"))
Eh <- c(-1, 1)
pe <- convert(Eh, "pe", T = convert(100, "K"))
a.Eh <- affinity(Eh = Eh, T = 100)
a.pe <- affinity(pe = pe, T = 100)
# They should give the same result
# ... except for names(dim(.)), so set check.attributes = FALSE
expect_equal(a.Eh$values, a.pe$values, check.attributes = FALSE, info = info)
# The variables should have the right names
expect_equal(c(a.Eh$vars, a.pe$vars), c("Eh", "pe"), info = info)
# Now for an Eh-pH example
pH <- c(0, 14)
a <- affinity(pH = pH, Eh = Eh)
expect_equal(a$vars, c("pH", "Eh"), info = info)
expect_equal(range(a$vals[[1]]), pH, info = info)
expect_equal(range(a$vals[[2]]), Eh, info = info)
expect_equal(length(a$vals[[2]]), 256, info = info)
# Since Eh has to be reconstructed, check it's done correctly
a129 <- affinity(pH = pH, Eh = c(Eh, 129))
expect_equal(length(a129$vals[[2]]), 129, info = info)

info <- "affinity() in 3D returns values consistent with manual calculation"
# Our "manual" calculation will be for H2(aq) + 0.5O2(aq) = H2O(l)
# The equilibrium constants at 25 and 100 degrees C
# (the logK are tested against literature values in test-subcrt.R)
logK.25 <- subcrt(c("H2", "O2", "H2O"), "aq", c(-1, -0.5, 1), T = 25)$out$logK
logK.100 <- subcrt(c("H2", "O2", "H2O"), "aq", c(-1, -0.5, 1), T = 100)$out$logK
# The value of A/2.303RT at 25 degrees and logaH2 = -10, logaO2 = -10 and logaH2O = 0
A.2303RT.25.10.10 <- logK.25 - ( (-1)*(-10) + (-0.5)*(-10) )
# The value of A/2.303RT at 100 degrees and logaH2 = -5, logaO2 = -10 and logaH2O = 0
A.2303RT.100.5.10 <- logK.100 - ( (-1)*(-5) + (-0.5)*(-10) )
# Set up basis and species
basis(c("H2", "O2"), "aq")
species("H2O")
# We will run affinity() in 3D
# T = 0, 25, 50, 75, 100, 125 degrees
# log_a(H2) = -20, -15, -10, -5, 0
# log_a(O2) = -20, -15, -10, -5, 0
# First test: the dimensions are correct
a.logK <- affinity(T = c(0, 125, 6), H2 = c(-20, 0, 5), O2 = c(-20, 0, 5), property = "logK")
expect_equal(dim(a.logK$values[[1]]), c(6, 5, 5), check.names = FALSE, info = info)
# Second and third tests: the logK values used by affinity() are correct
expect_equal(a.logK$values[[1]][2, 3, 3], logK.25, info = info)
expect_equal(a.logK$values[[1]][5, 4, 3], logK.100, info = info)
# Fourth and fifth tests: the A/2.303RT values returned by affinity() are correct
a.A <- affinity(T = c(0, 125, 6), H2 = c(-20, 0, 5), O2 = c(-20, 0, 5))
expect_equal(a.A$values[[1]][2, 3, 3], A.2303RT.25.10.10, info = info)
expect_equal(a.A$values[[1]][5, 4, 3], A.2303RT.100.5.10, info = info)

info <- "'iprotein' gives consistent results on a transect"
# From Dick and Shock, 2011, values of A/2.303RT for the per-residue
# formation reactions of overall model proteins at five sampling sites
# at Bison Pool, with different temperature, pH and log_a(H2)
# These are the maximum values for each site from Table 5 in the paper
A.2303RT_ref <- c(-18.720, -27.894, -35.276, -36.657, -41.888)
# The measured temperatures and pHs
T <- c(93.3, 79.4, 67.5, 65.3, 57.1)
pH <- c(7.350, 7.678, 7.933, 7.995, 8.257)
# Eq. 24 of the paper
H2 <- -11+T*3/40
# Remove "RESIDUE" entries in thermo()$OBIGT (clutter from first test)
reset()
basis(c("HCO3-", "H2O", "NH3", "HS-", "H2", "H+"),
  "aq", c(-3, 0, -4, -7, 999, 999))
sites <- c("N", "S", "R", "Q", "P")
ip <- pinfo("overall", c("bisonN", "bisonS", "bisonR", "bisonQ", "bisonP"))
# To reproduce, use superseded properties of [Met], [Gly], and [UPBB] (Dick et al., 2006)
mod.OBIGT("[Met]", G = -35245, H = -59310, S = 40.38)
mod.OBIGT("[Gly]", G = -6075, H = -5570, S = 17.31)
mod.OBIGT("[UPBB]", G = -21436, H = -45220, S = 1.62)
a <- affinity(T = T, pH = pH, H2 = H2, iprotein = ip)
# Divide A/2.303RT by protein length
pl <- protein.length(ip)
A.2303RT <- t(sapply(a$values, c)) / pl
# Find the maximum for each site
A.2303RT_max <- apply(A.2303RT, 2, max)
# We're off a bit in the second decimal ... 
# maybe becuase of rounding of the aa composition?
expect_equal(A.2303RT_max, A.2303RT_ref, tolerance = 1e-3, info = info)
# TODO: add comparison with results from loading proteins via species()

info <- "affinity() for proteins (with/without 'iprotein') returns same value as in previous package versions"
## These values were calculated using versions 0.6, 0.8 and 0.9-7 (25 degrees C, 1 bar, basis species "CHNOS" or "CHNOS+")
#A.2303RT.nonionized <- -3795.297
#A.2303RT.ionized <- -3075.222
## Calculated with version 2.0.0 (util.units() has R = 8.314445)
#A.2303RT.nonionized <- -3795.291
#A.2303RT.ionized <- -3075.215
# Calculated with version 2.0.0-16 (util.units() has R = 8.314463)
A.2303RT.nonionized <- -3794.69
A.2303RT.ionized <- -3074.613
# First for nonionized protein
basis("CHNOS")
# Try it with iprotein
ip <- pinfo("CSG_HALJP")
expect_equal(affinity(iprotein = ip, loga.protein = -3)$values[[1]][1], A.2303RT.nonionized, tolerance = 1e-5, info = info)
# Then with the protein loaded as a species
species("CSG_HALJP")
expect_equal(affinity()$values[[1]][1], A.2303RT.nonionized, tolerance = 1e-5, info = info)
# Now for ionized protein
basis("CHNOS+")
expect_equal(affinity(iprotein = ip, loga.protein = -3)$values[[1]][1], A.2303RT.ionized, tolerance = 1e-5, info = info)
species("CSG_HALJP")
expect_equal(affinity()$values[[1]][1], A.2303RT.ionized, tolerance = 1e-5, info = info)

info <- "affinity() for proteins keeps track of pH on 2-D calculations"
# (relates to the "thisperm" construction in A.ionization() )
basis("CHNOS+")
species("LYSC_CHICK")
a1 <- affinity(pH = c(6, 8, 3))
a2 <- affinity(pH = c(6, 8, 3), T = c(0, 75, 4))
expect_equal(as.numeric(a1$values[[1]]), a2$values[[1]][, 2], info = info)

info <- "IS can be constant or variable"
# Inspired by an error from demo("phosphate")
# > a25 <- affinity(IS = c(0, 0.14), T = T[1])
# ...
# Error in subcrt(species  =  c(1017L, 20L, 19L), property  =  "logK", T  =  298.15,  : 
#   formal argument "IS" matched by multiple actual arguments
oldnon <- nonideal("Alberty")
basis("CHNOPS+")
species(c("PO4-3", "HPO4-2", "H2PO4-"))
a0 <- affinity()
a1 <- affinity(IS = 0.14)
a2 <- affinity(IS = c(0, 0.14))
expect_equal(unlist(lapply(a2$values, head, 1)), unlist(a0$values), info = info)
expect_equal(unlist(lapply(a2$values, tail, 1)), unlist(a1$values), info = info)
nonideal(oldnon)

info <- "Argument recall is usable"
# 20190127
basis("CHNOS")
species(c("CO2", "CH4"))
a0 <- affinity(O2 = c(-80, -60))
a1 <- affinity(O2 = c(-80, -60), T = 100)
a2 <- affinity(a0, T = 100)
a3 <- affinity(a1, T = 25)
expect_identical(a1, a2, info = info)
# We don't test entire output here becuase a0 doesn't have a "T" argument
expect_identical(a0$values, a3$values, info = info)

info <- "sout is processed correctly"
# 20190201
basis("CHNOS+")
# Previously, this test would fail when sout has
# more species than are used in the calculation
species(c("H2S", "CO2", "CH4"))
a0 <- affinity(T = c(0, 100))
sout <- a0$sout
# Test the calculation with just CH4
species(1:2, delete = TRUE)
a1 <- affinity(T = c(0, 100))
a2 <- affinity(T = c(0, 100), sout = a0$sout)
expect_equal(a1$values, a2$values, info = info)

info <- "return.sout = TRUE returns output of subcrt()"
# 20240206
# Caught by Mosaic Stacking 2 in multi-metal.Rmd
# (returned value was NULL in CHNOSZ_2.0.0-43,
#  creating weirdness in mineral-aqueous boundaries on diagram)
basis("CHNOS+")
species("CO2")
a <- affinity(return.sout = TRUE)
expect_equal(names(a), c("species", "out"), info = info)

# Test added 20250421
info <- "Using Eh works in transect mode of affinity()"
basis("CHNOSe")
species(c("NO3-", "NO2-", "NH4+", "NH3"))
T <- c(25, 50, 100, 125, 150)
Eh <- c(-1, -0.5, 0, 0.5, 1)
pH <- c(10, 8, 6, 4, 2)
# Calculate values on transect
a <- affinity(T = T, Eh = Eh, pH = pH)
# Calculate values at first point on transect
basis("Eh", -1)
basis("pH", 10)
a1 <- affinity(T = 25)
expect_equal(sapply(a$values, "[", 1), unlist(a1$values), info = info)
# Calculate values at last point on transect
# nb. we can't use basis("Eh", 1) because that uses pe at T = 25 C
pe <- convert(1, "pe", T = convert(150, "K"))
basis("pe", pe)
basis("pH", 2)
a5 <- affinity(T = 150)
expect_equal(sapply(a$values, "[", 5), unlist(a5$values), info = info)
