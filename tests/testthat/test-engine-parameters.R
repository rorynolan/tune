context("engine-specific tuning paramters")

library(parsnip)
library(dials)

## -----------------------------------------------------------------------------

test_that('check for finalization with engine parameters', {
  pset_1 <- parameters(mtry(), penalty(), mixture())
  pset_2 <- pset_1
  pset_2$object[[3]] <- NA

  pset_3 <- parameters(mtry(1:2), penalty(), mixture())
  pset_4 <- pset_3
  pset_4$object[[3]] <- NA

  expect_true(needs_finalization(pset_1))
  expect_true(needs_finalization(pset_2))
  expect_true(needs_finalization(pset_1, "potato"))
  expect_true(needs_finalization(pset_2, "potato"))

  expect_false(needs_finalization(pset_1, "mtry"))
  expect_false(needs_finalization(pset_2, "mtry"))
  expect_false(needs_finalization(pset_3, "mtry"))
  expect_false(needs_finalization(pset_4, "mtry"))
  expect_false(needs_finalization(pset_3))
  expect_false(needs_finalization(pset_4))
})

## -----------------------------------------------------------------------------

test_that('tuning with engine parameters with dials objects', {
  skip_if_not_installed("randomForest")
  skip_if(utils::packageVersion("dials") <= "0.0.7")

  rf_mod <-
    rand_forest(min_n = tune()) %>%
    set_engine("randomForest", maxnodes = tune()) %>%
    set_mode("regression")

  set.seed(192)
  rs <- rsample::vfold_cv(mtcars)

  set.seed(19828)
  expect_error(
    rf_tune <- rf_mod %>% tune_grid(mpg ~ ., resamples = rs, grid = 3),
    regex = NA
  )
  expect_error(
    p <- autoplot(rf_tune),
    regex = NA
  )

  set.seed(283)
  expect_error(
    rf_search <- rf_mod %>% tune_bayes(mpg ~ ., resamples = rs, initial = 3, iter = 2),
    regex = NA
  )
  expect_error(
    p <- autoplot(rf_search),
    regex = NA
  )
})

## -----------------------------------------------------------------------------

test_that('tuning with engine parameters without dials objects', {
  skip_if_not_installed("randomForest")
  skip_if(utils::packageVersion("dials") <= "0.0.7")

  ## ---------------------------------------------------------------------------

  rf_mod <-
    rand_forest(min_n = tune()) %>%
    set_engine("randomForest", corr.bias = tune()) %>%
    set_mode("regression")

  grid <-
    data.frame(min_n = c(5, 10, 5, 10),
               corr.bias = c(TRUE, TRUE, FALSE, FALSE))

  set.seed(192)
  rs <- rsample::vfold_cv(mtcars)

  ## ---------------------------------------------------------------------------

  expect_error(
    rf_tune <- rf_mod %>% tune_grid(mpg ~ ., resamples = rs, grid = 3),
    regex = "missing some parameter objects"
  )

  ## ---------------------------------------------------------------------------

  expect_error(
    rf_tune <- rf_mod %>% tune_grid(mpg ~ ., resamples = rs, grid = grid),
    regex = NA
  )
  expect_error(
    p <- autoplot(rf_tune),
    regex = "Some parameters do not have corresponding"
  )

  ## ---------------------------------------------------------------------------

  set.seed(283)
  expect_error(
    rf_search <- rf_mod %>% tune_bayes(mpg ~ ., resamples = rs),
    regex = "missing some parameter objects"
  )
})


