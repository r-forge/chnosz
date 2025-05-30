# CHNOSZ/demo/Pourbaix.R
# Eh-pH diagram for Fe-O-H with equisolubility lines
# After Pourbaix (1974, p. 312)
# 20210301 jmd first version

library(CHNOSZ)

# Load OBIGT database without organic species
# (speeds up and reduces memory needed for C diagram)
OBIGT(no.organics = TRUE)

### PARAMETERS (to be changed by the user) ###

# Choose an element
# Some mostly working ones: Fe, Cu, Au, Rh, Mn, C
# Incomplete: Al (no native metal), Ni, ...
# Not working: Cr, ...
#  (Cr has no solids in OBIGT)
element <- "Fe"

# Set temperature and pressure
T <- 25
# Can use "Psat" for T >= 100 degC
P <- 1
# Ionic strength (mol/kg)
IS <- 0

# Set plot limits and resolution
pH <- c(-2, 16)
Eh <- c(-2, 2)
res <- 700

# Assign levels for equisolubility lines
levels <- seq(-6, 0, 2)

# Switches for using colors
color.fields <- TRUE
color.water <- TRUE
color.lines <- TRUE
color.names <- TRUE

# Names of aqueous species to move down
# (to avoid conflict with water lines or mineral names)
namesdown <- c("MnOH+", "MnO", "Cu+2", "CuO")
# Names of aqueous species to move down even more
namesdown2 <- c("Fe+3", "FeOH+2", "FeO+", "HFeO2", "FeO2-",
"HMnO2-", "MnO2-2")

### SCRIPT (can also be changed by the user if wanted!) ###

# Find a species with this element
# (to be used as a basis species)
elem_basis <- element
if(is.na(suppressMessages(info(elem_basis)))) {
  elem_basis <- paste0(element, "+")
  if(is.na(suppressMessages(info(elem_basis)))) {
    elem_basis <- paste0(element, "+2")
    if(is.na(suppressMessages(info(elem_basis)))) {
      elem_basis <- paste0(element, "+3")
    }
  }
}

# Define system
basis(c(elem_basis, "H2O", "H+", "e-"))

# Find species
icr <- retrieve(element, c("O", "H"), "cr", T = T, P = P)
iaq <- retrieve(element, c("O", "H"), "aq", T = T, P = P)

# Add solids with unit activity
species(icr, 0)
# Add aqueous species with activity for first equisolubility line
species(iaq, levels[1], add = TRUE)

# Calculate affinities of formation of species
# from basis species as a function of Eh and pH
a_all <- affinity(pH = c(pH, res), Eh = c(Eh, res), T = T, P = P, IS = IS)

# Plot diagram (LAYER 1: colors for all fields)
limit.water <- fill <- NULL
if(!color.water) limit.water <- FALSE
if(!color.fields) fill <- NA
d_all <- diagram(a_all, names = FALSE, lty = 0, min.area = 0.1, limit.water = limit.water, fill = fill)

# Calculate affinities for minerals
species(icr)
# Calculate overall solubility (i.e. minimum solubility given all candidate minerals)
s <- solubility(iaq, pH = c(pH, res), Eh = c(Eh, res), T = T, P = P, IS = IS, in.terms.of = element)

# Plot diagram (LAYER 2: equisolubility lines)
diagram(s, levels = levels, contour.method = "flattest", add = TRUE, lwd = 1.5)

# Calculate affinities for aqueous species
# FIXME: should be able to remove cr species from previous affinity object
species(iaq, 0)
a_aq <- affinity(pH = c(pH, res), Eh = c(Eh, res), T = T, P = P, IS = IS)

# Plot diagram (LAYER 3: equal-activity lines for aqueous species)
col <- ifelse(color.lines, 4, 1)
# Use a white background to improve contrast
# (so the line remains visible if it coincides with an equisolubility contour)
diagram(a_aq, add = TRUE, col = "white", lwd = 1.3, names = FALSE)

# Plot diagram (LAYER 4: labels for aqueous species fields)
# Apply y offset for specified names
dy <- rep(0, nrow(a_aq$species))
dy[a_aq$species$name %in% namesdown] <- -0.3
dy[a_aq$species$name %in% namesdown2] <- -0.5
# Use a white background for names
rx <- diff(par("usr")[1:2])
for(ddx in c(-rx/700, rx/700))
  diagram(a_aq, add = TRUE, lty = 2, lwd = 0.6, col = col, dx = ddx, dy = dy, col.names = "white", bold = TRUE)
ry <- diff(par("usr")[3:4])
for(ddy in c(-ry/700, ry/700))
  diagram(a_aq, add = TRUE, lty = 2, lwd = 0.6, col = col, dy = dy + ddy, col.names = "white", bold = TRUE)
col.names <- ifelse(color.names, 4, 1)
diagram(a_aq, add = TRUE, lty = 0, col = col, dy = dy, col.names = col.names)

# Add solids with unit activity
species(icr, 0)
# Add aqueous species with activity for last equisolubility line
# (i.e. unit activity)
species(iaq, levels[length(levels)], add = TRUE)

# Calculate affinities of formation of species
# from basis species as a function of Eh and pH
a_all_0 <- affinity(pH = c(pH, res), Eh = c(Eh, res), T = T, P = P, IS = IS)

# Plot diagram (LAYER 5: mineral stability boundaries and water lines)
d_all_0 <- diagram(a_all_0, fill = NA, names = FALSE, lty = 0, lty.cr = 1, lwd = 3, add = TRUE)
water.lines(d_all_0, lty = 5, lwd = 1.3)

# Plot diagram (LAYER 6: large bold labels for all mineral fields)
# (this is the last layer, so names are above equal-activity lines,
# but we use positions calculated with the first equisolubility line
# so that names are within the shrunken parts of the mineral fields)
# Create labels using chemical formulas instead of name of minerals
formulas <- info(a_all$species$ispecies, check.it = FALSE)$formula
formulas[a_all$species$state == "aq"] <- ""
diagram(a_all, fill = NA, names = formulas, bold = TRUE, cex.names = 1.2, lty = 0, add = TRUE)

# Add title
Texpr <- lT(T)
Pexpr <- lP(P)
main <- bquote(.(element)*"-O-H at "*.(Texpr)*" and "*.(Pexpr))
title(main = main)

# Reset OBIGT database to run other demos
reset()
