# Load default settings for CHNOSZ
reset()

info <- "which.pmax() properly applies attributes, and also works for lists of length 1"
x <- list(a = matrix(c(1, 2, 3, 4)), b = matrix(c(4, 3, 2, 1)))
xattr <- attributes(x[[1]])
expect_equal(attributes(which.pmax(x)), xattr, info = info)
expect_equal(as.numeric(which.pmax(x[1])), c(1, 1, 1, 1), info = info)

info <- "which.pmax() can handle NA values"
x <- list(a = matrix(c(1, 2, NA, 4)), b = matrix(c(4, 3, 2, 1)))
expect_equal(as.numeric(which.pmax(x)), c(2, 2, NA, 1), info = info)
