library(deSolve)
library(dplyr)


seir <- function(time, stocks, auxs){
  with(as.list(c(stocks, auxs)),{
    beta   <- R0 * alpha / N
    lambda <- beta * I

    dS_dt  <- -lambda * S
    dE_dt  <- lambda * S - kappa*E
    dI_dt  <- kappa*E - I*alpha
    dR_dt  <- I*alpha
    dTI_dt <- rf*kappa*E

    return (list(c(dS_dt,
                   dE_dt,
                   dI_dt,
                   dR_dt,
                   dTI_dt),
                 lambda=lambda,
                 IR=lambda * S,
                 ER=kappa*E,
                 RR=alpha*I,
                 CheckSum=S+E+I+R,
                 Beta=beta,
                 auxs))
  })
}


#------------------------------------------------------------------------------
# A function to run the model, parameterised
run_sim_seir <- function(N=100000,
                         init_infected=1,
                         R0=2.0,
                         rf=0.3,
                         kappa=1.0/1.9,
                         alpha=1/4.1,
                         start_time=0,
                         end_time=100,
                         step=0.125){

  simtime <- seq(start_time,end_time,by=step)
  stocks  <- c(S=N-init_infected,
               E=0,
               I=init_infected,
               R=0,
               TI=0)

  auxs    <- c(N=N,
               R0=R0,
               rf=rf,
               kappa=kappa,
               alpha=alpha)

  # Note we add on daily cases as a lagged difference of 1/step between cumulative cases
  res <- ode(y=stocks,
             times=simtime,
             func = seir,
             parms=auxs,
             method="euler") |>
    data.frame() |>
    dplyr::as_tibble() |>
    dplyr::filter(time%% 1 == 0) |>
    dplyr::mutate(DI=TI-lag(TI,1,default = 0))
}


