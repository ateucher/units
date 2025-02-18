test_that("mixed units work", {
   m = c(set_units(1:3, km), set_units(4:6, g), allow_mixed = TRUE)

   # select a subset
   expect_s3_class(m[3:4], "mixed_units")
   expect_s3_class(m[3], "mixed_units")

# select a single units object:
   expect_s3_class(m[[3]], "units")

   m <- set_units(m, c(rep(c("m", "kg"), each = 3)))
   expect_s3_class(m, "mixed_units")
   units(m) = rep(c("mm", "mg"), each = 3)
   expect_s3_class(m, "mixed_units")
   # does the value get recycled?
   expect_s3_class(set_units(m[1:3], "m"), "mixed_units")

   # convert to units:
   expect_s3_class(as_units( m[1:3] ), "units")

# round-trip via units:
   m0 <- mixed_units(as_units(m[1:3]))
   expect_identical(m[1:3], m0)

# Ops using by single unit: needs to be explicitly coerced to mixed_units:
   expect_s3_class(m[1:3] * mixed_units(set_units(1, mm)), "mixed_units")
   expect_s3_class(m[1:3] / mixed_units(set_units(1, mm)), "mixed_units")
   expect_s3_class(m[1:3] + mixed_units(set_units(1, mm)), "mixed_units")
   expect_s3_class(m[1:3] - mixed_units(set_units(1, mm)), "mixed_units")
   expect_type(m[1:3] == mixed_units(set_units(1, mm)), "logical")
   expect_type(m[1:3] != mixed_units(set_units(1, mm)), "logical")
   expect_error(m[1:3] ^ mixed_units(set_units(1, mm)))

   # FIXME: Ops.mixed_units and Ops.units must be the same method
   # to avoid the warning and the error.
   # We can discriminate by switchpatching.
   expect_error(expect_warning(m[1:3] * set_units(1, mm)))

   expect_s3_class(units(m), "mixed_symbolic_units")
   expect_type(format(m), "character")
   expect_type(as.character(units(m)), "character")
   expect_equal(drop_units(m), sapply(m, as.numeric))

   units_options(allow_mixed = TRUE)
   m = c(set_units(1:3, km), set_units(4:6, g))
   expect_s3_class(m, "mixed_units")
   expect_equal(m, mixed_units(1:6, c(rep("km", 3), rep("g", 3))))
   units_options(allow_mixed = FALSE)
})

test_that("order is preserved", {
   x <- 1:10
   u <- rep(c("m", "l"), 5)
   m <- mixed_units(x, u)
   m <- set_units(m, paste0("k", u), mode = "standard")

   expect_equal(as.numeric(m), x / 1000)
})

test_that("unique.mixed_units works", {
   x <- c(set_units(c(1, 1, 2), kg), set_units(c(4, 4, 5), s), allow_mixed = TRUE)
   expect_equal(unique(x), c(set_units(c(1, 2), kg), set_units(c(4, 5), s), allow_mixed = TRUE))

   y <- c(set_units(c(1, 1, 1), m/s), set_units(c(1, 1, 1), kg/s), allow_mixed = TRUE)
   expect_equal(unique(y), c(set_units(1, m/s), set_units(1, kg/s), allow_mixed = TRUE))

   z <- c(set_units(c(1, 2), kg), set_units(c(3, 4), s), set_units(c(2, 3), kg), allow_mixed = TRUE)
   expect_equal(unique(z), c(set_units(c(1, 2), kg), set_units(c(3, 4), s), set_units(3, kg), allow_mixed = TRUE))
})
