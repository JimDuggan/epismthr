% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate_cases.R
\name{generate_cases}
\alias{generate_cases}
\title{Creates synthetic epi data using SEIR model and negative binomial distribution}
\usage{
generate_cases(
  N = 10000,
  init_infected = 1,
  R0 = 2,
  rf = 0.3,
  kappa = 1/1.9,
  alpha = 1/4.1,
  end_time = 100,
  size = 50,
  start_day = "2023-09-01",
  seed = F,
  seed_val = 100
)
}
\arguments{
\item{N}{the population size for the SEIR model}

\item{init_infected}{The initial number of people infected}

\item{R0}{the value for the reproduction number}

\item{rf}{the reporting fraction for cases}

\item{kappa}{1/average duration at latent stage}

\item{alpha}{1/average duration at infectious stage}

\item{end_time}{end of simulation time (numeric)}

\item{size}{dispersion parameter for negative binomial}

\item{start_day}{YYYY-MM-DD string format for start of simulation}

\item{seed}{True or False for using a seed}

\item{seed_val}{value of seed (default 100)}
}
\value{
a tibble with day number, date, model output and cases
}
\description{
\code{generate_cases} Create synthetic case data to test the forecasting function
}
