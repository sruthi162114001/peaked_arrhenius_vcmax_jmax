# Extracted from test.c3photo.R:135

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "BioCro", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
c3photo_res <- module_response_curve(
        'BioCro:c3_assimilation',
        within(soybean$parameters, {
            StomataWS = 1
            Tleaf = 32
            gbw = 1.2
            rh = 0.7
            temp = 30
        }),
        expand.grid(
            Qabs = seq(0, 900, by = 150),
            Catm = seq(20, 620, by = 100)
        )
    )
c3_parameters_inputs <-
        module_info('BioCro:c3_parameters', verbose = FALSE)$inputs
c3_parameters_res <- module_response_curve(
        'BioCro:c3_parameters',
        list(),
        c3photo_res[, c3_parameters_inputs]
    )
solo <- function(LeafT) {
        (0.047 - 0.0013087 * LeafT + 2.5603e-05 * LeafT^2 - 2.1441e-07 * LeafT^3) / 0.026934;
    }
Oi <- c3photo_res$O2 * solo(c3photo_res$Tleaf)
j_from_jmax <- function(absorbed_ppfd, dark_adapted_phi_PSII, beta_PSII, Jmax, theta) {
        I2 <- absorbed_ppfd * dark_adapted_phi_PSII * beta_PSII
        (Jmax + I2 - sqrt((Jmax + I2)^2 - 4.0 * theta * I2 * Jmax)) / (2.0 * theta)
    }
J <- sapply(seq_len(nrow(c3photo_res)), function(i) {
        j_from_jmax(
            c3photo_res$Qabs[i],
            c3_parameters_res$phi_PSII[i],
            soybean$parameters$beta_PSII,
            c3_parameters_res$Jmax_norm[i] * soybean$parameters$Jmax_at_25,
            c3_parameters_res$theta[i]
        )
    })
fvcb_res <- module_response_curve(
        'BioCro:FvCB',
        list(
            alpha_TPU = 0 # hard-coded to 0 in c3photoC
        ),
        data.frame(
            Ci = c3photo_res$Ci,
            Gstar = c3_parameters_res$Gstar,
            J = J,
            Kc = c3_parameters_res$Kc,
            Ko = c3_parameters_res$Ko,
            Oi = Oi,
            RL = c3_parameters_res$RL_norm * soybean$parameters$RL_at_25,
            TPU = c3_parameters_res$Tp_norm * soybean$parameters$Tp_at_25,
            Vcmax = c3_parameters_res$Vcmax_norm * soybean$parameters$Vcmax_at_25,
            electrons_per_carboxylation = c3photo_res$electrons_per_carboxylation,
            electrons_per_oxygenation = c3photo_res$electrons_per_oxygenation
        )
    )
