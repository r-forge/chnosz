# Load default settings for CHNOSZ
reset()

info <- "add.protein works as expected"
# Factors causing problems again ...
f <- system.file("extdata/protein/POLG.csv", package = "CHNOSZ")
aa <- read.csv(f, as.is = TRUE)
# This adds the proteins
ip1 <- add.protein(aa)
# This replaces the proteins (with the same ones)
ip2 <- add.protein(aa)
expect_equal(ip1, ip2, info = info)

info <- "Errors and messages occur in some circumstances"
expect_error(add.protein(canprot::count_aa("AAA")), "does not have the same columns as thermo\\(\\)\\$protein", info = info)
expect_message(add.protein(pinfo(pinfo("CYC_BOVIN"))), "replaced 1 existing protein\\(s\\)", info = info)

info <- "group additivity for proteins gives expected values"
# Values for chicken lysozyme calculated using group additivity values
# from Dick et al., 2006 [DLH06] (Biogeosciences 3, 311-336)
G <- -4206050
Cp <- 6415.5
V <- 10421
formula <- "C613H959N193O185S10"
# To reproduce, use superseded properties of [Met], [Gly], and [UPBB] (Dick et al., 2006)
mod.OBIGT("[Met]", G = -35245, H = -59310, S = 40.38)
mod.OBIGT("[Gly]", G = -6075, H = -5570, S = 17.31)
mod.OBIGT("[UPBB]", G = -21436, H = -45220, S = 1.62)
lprop <- info(info("LYSC_CHICK"))
expect_equal(G, lprop$G, info = info)
expect_equal(Cp, lprop$Cp, tolerance = 1e-5, info = info)
expect_equal(V, lprop$V, tolerance = 1e-4, info = info)
expect_equal(formula, lprop$formula, info = info)

info <- "add.protein() works with output of canprot::read_fasta()"
ffile <- system.file("extdata/protein/rubisco.fasta", package = "CHNOSZ")
aa8 <- canprot::read_fasta(ffile, 1:8)
expect_message(ip1 <- add.protein(aa8), "added 8 new protein\\(s\\)", info = info)
expect_message(ip2 <- add.protein(aa8), "replaced 8 existing protein\\(s\\)", info = info)
# add.protein should return the correct indices for existing proteins
expect_equal(ip1, ip2, info = info)
