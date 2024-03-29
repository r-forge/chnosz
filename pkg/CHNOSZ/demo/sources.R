# CHNOSZ/demo/sources.R
## Cross-checking sources
library(CHNOSZ)

# The reference sources
ref.source <- thermo()$refs$key
# Sources in the primary thermodynamic database
# Se omit the [S92] in "HDNB78 [S92]" etc.
tdata <- thermo()$OBIGT
ps1 <- gsub("\ .*", "", tdata$ref1)
ps2 <- gsub("\ .*", "", tdata$ref2)
# Sources in the optional datafiles
tdata <- read.csv(system.file("extdata/OBIGT/DEW.csv", package="CHNOSZ"), as.is=TRUE)
os1 <- gsub("\ .*", "", tdata$ref1)
os2 <- gsub("\ .*", "", tdata$ref2)
tdata <- read.csv(system.file("extdata/OBIGT/SLOP98.csv", package="CHNOSZ"), as.is=TRUE)
os3 <- gsub("\ .*", "", tdata$ref1)
os4 <- gsub("\ .*", "", tdata$ref2)
tdata <- read.csv(system.file("extdata/OBIGT/SUPCRT92.csv", package="CHNOSZ"), as.is=TRUE)
os5 <- gsub("\ .*", "", tdata$ref1)
os6 <- gsub("\ .*", "", tdata$ref2)
tdata <- read.csv(system.file("extdata/OBIGT/AS04.csv", package="CHNOSZ"), as.is=TRUE)
os7 <- gsub("\ .*", "", tdata$ref1)
os8 <- gsub("\ .*", "", tdata$ref2)
tdata <- read.csv(system.file("extdata/OBIGT/AD.csv", package="CHNOSZ"), as.is=TRUE)
os9 <- gsub("\ .*", "", tdata$ref1)
os10 <- gsub("\ .*", "", tdata$ref2)
tdata <- read.csv(system.file("extdata/OBIGT/GEMSFIT.csv", package="CHNOSZ"), as.is=TRUE)
os11 <- gsub("\ .*", "", tdata$ref1)
os12 <- gsub("\ .*", "", tdata$ref2)
# All of the thermodynamic data sources - some of them might be NA
OBIGT.source <- unique(c(ps1, ps2, os1, os2, os3, os4, os5, os6, os7, os8, os9, os10, os11, os12))
OBIGT.source <- OBIGT.source[!is.na(OBIGT.source)]
# These all produce character(0) if the sources are all accounted for
print("missing these sources for thermodynamic properties:")
print(unique(OBIGT.source[!(OBIGT.source %in% ref.source)]))
# Determine if all the reference sources are cited
# This should produce character(0)
print("these sources are present but not cited:")
print(ref.source[!(ref.source %in% OBIGT.source)])
