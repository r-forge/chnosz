context("info")

test_that("info.character() produces expected results and messages", {
  expect_equal(info.character("acetate", "cr"), NA)
  expect_message(info.character("acetate", "cr"), "only 'aq' is available")
  expect_message(info.character("methane", "cr"), "only 'gas' 'liq' are available")
  expect_message(info.character("methane"), "also available in liq")
  expect_message(info.character("SiO2", "cr"), "also available in.*quartz")
  expect_message(info.character("chalcocite"), "found chalcocite\\(cr\\) with 2 phase transitions")
  # H2O is a special case
  expect_equal(info.character("H2O", "aq"), info.character("H2O", "liq"))
})

test_that("info.numeric() produces expected errors and messages", {
  expect_error(info.numeric(9999), "species index 9999 not found in thermo\\(\\)\\$OBIGT")
  iargon <- info("argon", "gas")
  expect_message(info.numeric(iargon), "Cp of argon\\(gas\\) is NA; set by EOS parameters to 4.97")
  iMgSO4 <- info("MgSO4")
  expect_message(info.numeric(iMgSO4), "V of MgSO4\\(aq\\) is NA; set by EOS parameters to 1.34")
})

test_that("info.approx() produces expected messages", {
  expect_message(info.approx("lactic"), "is similar to lactic acid")
  expect_message(info.approx("lactic acid"), "is ambiguous")
  # note though that info("lactic acid") finds a match because info.character is used first...
  expect_equal(info("lactic acid"), grep("lactic acid", thermo()$OBIGT$name))
  # looking in optional databases 20190127
  expect_message(info("dickite"), "is in an optional database")
})

test_that("info() can be used for cr and aq descriptions of the same species and proteins", {
  i2 <- info("LYSC_CHICK", c("cr", "aq")) 
  expect_equal(thermo()$OBIGT$state[i2], c("cr", "aq"))
  expect_equal(info(i2)[1, ], info(i2[1]), check.attributes=FALSE)
})

test_that("info() gives correct column names for species using the AkDi model", {
  # add an aqueous species conforming to the AkDi model
  iCO2 <- mod.OBIGT("CO2", abbrv = "AkDi", a = -8.8321, b = 11.2684, c = -0.0850)
  params <- info(iCO2)
  expect_equal(params$a, -8.8321)
  expect_equal(params$b, 11.2684)
  expect_equal(params$xi, -0.0850)
})
