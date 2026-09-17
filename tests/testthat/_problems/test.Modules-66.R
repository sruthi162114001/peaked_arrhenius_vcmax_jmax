# Extracted from test.Modules.R:66

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "BioCro", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
modules_to_skip <- c()

# test -------------------------------------------------------------------------
fvcb_module <- 'BioCro:FvCB'
basic_fvcb_inputs <- list(
        Gstar = 38.6,
        J = 170,
        Kc = 259,
        Ko = 179,
        Oi = 210,
        RL = 1,
        TPU = 11.8,
        Vcmax = 100,
        alpha_TPU = 0,
        electrons_per_carboxylation = 4,
        electrons_per_oxygenation = 4
    )
neg_ci_error_msg <- 'Caught exception in R_evaluate_module: Thrown in FvCB_assim: Ci is negative.'
expect_error(
        evaluate_module(
            fvcb_module,
            within(basic_fvcb_inputs, {Ci = -1}),
            stop_on_exception = TRUE
        ),
        neg_ci_error_msg
    )
