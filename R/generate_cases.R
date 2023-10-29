library(dplyr)
library(purrr)

#-------------------------------------------------------------------------------------
#' Creates synthetic epi data using SEIR model and negative binomial distribution
#'
#' \code{generate_cases} Create synthetic case data to test the forecasting function
#'
#' @param N the population size for the SEIR model
#' @param init_infected The initial number of people infected
#' @param R0 the value for the reproduction number
#' @param rf the reporting fraction for cases
#' @param kappa 1/average duration at latent stage
#' @param alpha 1/average duration at infectious stage
#' @param end_time end of simulation time (numeric)
#' @param size dispersion parameter for negative binomial
#' @param start_day YYYY-MM-DD string format for start of simulation
#' @param seed True or False for using a seed
#' @param seed_val value of seed (default 100)
#' @return a tibble with day number, date, model output and cases
#' @export

generate_cases <- function(N=10000,
                           init_infected=1,
                           R0=2.0,
                           rf=0.3,
                           kappa=1.0/1.9,
                           alpha=1/4.1,
                           end_time=100,
                           size=50,
                           start_day="2023-09-01",
                           seed=F,
                           seed_val=100){

  sim <- run_sim_seir(N,
                      init_infected,
                      R0,
                      rf,
                      kappa,
                      alpha,
                      0,
                      end_time)


  if(seed)
    set.seed(seed_val)

  syn_cases <- purrr::map_dbl(sim$DI,~rnbinom(1,mu=.x,size=size))

  day_1 <- as.Date(start_day)

  tibble::tibble(Day=1:length(syn_cases),
                 Date=day_1+(Day-1),
                 Model=sim$DI,
                 Cases=syn_cases)

}
