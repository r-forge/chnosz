# CHNOSZ/util.formula.R
# Functions to compute some properties of chemical formulas

i2A <- function(formula) {
  ## Assemble the stoichiometric matrix (A)
  ## for the given formulas  20120108 jmd
  if(is.matrix(formula)) {
    # dDo nothing if the argument is already a matrix
    A <- formula
  } else if(is.numeric(formula) & !is.null(names(formula))) {
    # Turn a named numeric object into a formula matrix
    A <- t(as.matrix(formula))
  } else {
    # Get the elemental makeup of each formula, counting
    # zero for elements that appear only in other formulas
    msz <- makeup(formula, count.zero = TRUE)
    # Convert formulas into a stoichiometric matrix with elements on the columns
    A <- t(sapply(msz, c))
    # Add names from character argument
    # or from thermo()$OBIGT for numeric argument
    if(is.numeric(formula[1])) rownames(A) <- get("thermo", CHNOSZ)$OBIGT$name[formula]
    else rownames(A) <- formula
  }
  return(A)
}

as.chemical.formula <- function(makeup, drop.zero = TRUE) {
  # Make a formula character string from the output of makeup()
  # or from a stoichiometric matrix (output of i2A() or protein.formula())
  # First define a function to work with a single makeup object
  cffun <- function(makeup) {
    # First strip zeroes if needed
    if(drop.zero) makeup <- makeup[makeup != 0]
    # Z always goes at end
    makeup <- c(makeup[names(makeup) != "Z"], makeup[names(makeup) == "Z"])
    # The elements and coefficients
    elements <- names(makeup)
    coefficients <- as.character(makeup)
    # Any 1's get zapped
    coefficients[makeup == 1] <- ""
    # Any Z's get zapped (if they're followed by a negative number)
    # or turned into a plus sign (to indicate a positive charge)
    elements[elements == "Z" & makeup < 0] <- ""
    elements[elements == "Z" & makeup >= 0] <- "+"
    # Put the elements and coefficients together
    formula <- paste(elements, coefficients, sep = "", collapse = "")
    # If the formula is uncharged, and the last element has a negative
    # coefficient, add an explicit +0 at the end
    if(!"Z" %in% names(makeup) & tail(makeup,1) < 0) 
      formula <- paste(formula, "+0", sep = "")
    return(formula)
  }
  # Call cffun() once for a single makeup, or loop for a matrix
  if(is.matrix(makeup)) out <- sapply(1:nrow(makeup), function(i) {
    mkp <- makeup[i, ]
    return(cffun(mkp))
  }) else out <- cffun(makeup)
  return(out)
}

mass <- function(formula) {
  # Calculate the mass of elements in chemical formulas
  thermo <- get("thermo", CHNOSZ)
  formula <- i2A(get.formula(formula))
  ielem <- match(colnames(formula), thermo$element$element)
  if(any(is.na(ielem))) stop(paste("element(s)",
    colnames(formula)[is.na(ielem)], "not available in thermo()$element"))
  mass <- as.numeric(formula %*% thermo$element$mass[ielem])
  return(mass)
}

entropy <- function(formula) {
  # Calculate the standard molal entropy at Tref of elements in chemical formulas
  thermo <- get("thermo", CHNOSZ)
  formula <- i2A(get.formula(formula))
  ielem <- match(colnames(formula), thermo$element$element)
  if(any(is.na(ielem))) warning(paste("element(s)",
    paste(colnames(formula)[is.na(ielem)], collapse = " "), "not available in thermo()$element"))
  # Entropy per atom
  Sn <- thermo$element$s[ielem] / thermo$element$n[ielem]
  # If there are any NA values of entropy, put NA in the matrix, then set the value to zero
  # this allows mixed finite and NA values to be calculated 20190802
  ina <- is.na(Sn)
  if(any(ina)) {
    for(i in which(ina)) {
      hasNA <- formula[, i] != 0
      formula[hasNA, i] <- NA
    }
    Sn[ina] <- 0
  }
  entropy <- as.numeric( formula %*% Sn )
  # Convert to Joules 20220325
  convert(entropy, "J")
}

GHS <- function(formula, G = NA, H = NA, S = NA, T = 298.15, E_units = "J") {
  # For all NA in G, H and S, do nothing
  # For no  NA in G, H and S, do nothing
  # For one NA in G, H and S, calculate its value from the other two:
  # G - standard molal Gibbs energy of formation from the elements
  # H - standard molal enthalpy of formation from the elements
  # S - standard molal entropy
  # Argument checking
  if(!all(diff(sapply(list(formula, G, H, S), length)) == 0))
    stop("formula, G, H and S arguments are not same length")
  # Calculate Se (entropy of elements)
  Se <- entropy(formula)
  if(E_units == "cal") Se <- convert(Se, "cal")
  # Calculate one of G, H, or S if the other two are given
  GHS <- lapply(seq_along(G), function(i) {
    G <- G[i]
    H <- H[i]
    S <- S[i]
    Se <- Se[i]
    if(is.na(G)) G <- H - T * (S - Se)
    else if(is.na(H)) H <- G + T * (S - Se)
    else if(is.na(S)) S <- (H - G) / T + Se
    list(G, H, S)
  })
  # Turn the list into a matrix and add labels
  GHS <- t(sapply(GHS, c))
  colnames(GHS) <- c("G", "H", "S")
  rownames(GHS) <- formula
  GHS
}

ZC <- function(formula) {
  # Calculate average oxidation state of carbon 
  # from chemical formulas of species
  # If we haven't been supplied with a stoichiometric matrix, first get the formulas
  formula <- i2A(get.formula(formula))
  # Is there carbon there?
  iC <- match("C", colnames(formula))
  if(is.na(iC)) stop("carbon not found in the stoichiometric matrix")
  # The nominal charges of elements other than carbon
  # FIXME: add more elements, warn about missing ones
  knownelement <- c("H", "N", "O", "S", "Z")
  charge <- c(-1, 3, 2, 2, 1)
  # Where are these elements in the formulas?
  iknown <- match(knownelement, colnames(formula))
  # Any unknown elements in formula get dropped with a warning
  iunk <- !colnames(formula) %in% c(knownelement, "C")
  if(any(iunk)) warning(paste("element(s)", paste(colnames(formula)[iunk], collapse = " "),
    "not in", paste(knownelement, collapse = " "), "so not included in this calculation"))
  # Contribution to charge only from known elements that are in the formula
  formulacharges <- t(formula[, iknown[!is.na(iknown)]]) * charge[!is.na(iknown)]
  # Sum of the charges; the arrangement depends on the number of formulas
  if(nrow(formula) == 1) formulacharge <- rowSums(formulacharges) 
  else formulacharge <- colSums(formulacharges)
  # Numbers of carbons
  nC <- formula[, iC]
  # Average oxidation state
  ZC <- as.numeric(formulacharge/nC)
  return(ZC)
}

### Unexported functions ###

# Accept a numeric or character argument; the character argument can be mixed
#   (i.e. include quoted numbers). as.numeric is tested on every value; numeric values
#   are then interpreted as species indices in the thermodynamic database (rownumbers of thermo()$OBIGT),
#   and the chemical formulas for those species are returned.
# Values that can not be converted to numeric are returned as-is.
get.formula <- function(formula) {
  # Return the argument if it's a matrix or named numeric
  if(is.matrix(formula)) return(formula)
  if(is.numeric(formula) & !is.null(names(formula))) return(formula)
  # Return the argument as matrix if it's a data frame
  if(is.data.frame(formula)) return(as.matrix(formula))
  # Return the values in the argument, or chemical formula(s) for values that are species indices
  # For numeric values, get the formulas from those rownumbers of thermo()$OBIGT
  i <- suppressWarnings(as.integer(formula))
  # We can't have more than the number of rows in thermo()$OBIGT
  thermo <- get("thermo", CHNOSZ)
  iover <- i > nrow(thermo$OBIGT)
  iover[is.na(iover)] <- FALSE
  if(any(iover)) stop(paste("species number(s)", paste(i[iover], collapse = " "), 
    "not available in thermo()$OBIGT"))
  # We let negative numbers pass as formulas
  i[i < 0] <- NA
  # Replace any species indices with formulas from thermo()$OBIGT
  formula[!is.na(i)] <- thermo$OBIGT$formula[i[!is.na(i)]]
  return(formula)
}
