# Extracted from test.Modules.R:11

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "BioCro", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
modules_to_skip <- c()

# test -------------------------------------------------------------------------
expect_no_error(
        test_module_library(
            'BioCro',
            file.path('..', 'module_test_cases'),
            modules_to_skip
        )
    )
