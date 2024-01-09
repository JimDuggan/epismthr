library(fable)
library(dplyr)
library(lubridate)
library(tsibble)

#-------------------------------------------------------------------------------------
#' Creates an epi forecast based on an input tibble.
#'
#' \code{epi_forecast} returns a short term forecast of epi-cases
#'
#' @param data is a tibble that contains two columns: Date (date) and Cases (numeric)
#' @param look_ahead (default is 5), which is the forecast horizon
#' @param damped (default is FALSE for Additive Holt-Winters’ method)
#' @param level (default is 95), which is confidence interval for the results
#'
#' @return A list containing plots, projections, training measures and all generated fable tibbles
#' @export
epi_forecast <- function(data, look_ahead=5, level = 95, damped=FALSE){
  check1 <- !any(names(data) %in% c("Date"))
  check2 <- !any(names(data) %in% c("Cases"))

  if(check1)
    stop("Error, column Date should be defined!")
  else if (check2)
    stop("Error, column cases should be defined!")

  check3 <- !lubridate::is.Date(data$Date)
  if(check3)
    stop("Error, column Date should be in Date format!")

  check4 <- !is.numeric(data$Cases)
  if(check4)
    stop("Error, column Cases should be numeric!")

  # Create tsibble
  data_ts <- data  |>
              tsibble::as_tsibble(index=Date)

  if(damped == FALSE)
    trend_comp <- "A"
  else
    trend_comp <- "Ad"

  # Get the model fit, Holt Winters adaptive algorithm
  fit <- data_ts |>
           fabletools::model(fable::ETS(Cases ~ error("A") +
                                                trend(trend_comp) +
                                                season("N")))

  ts_accuracy <- fit |>
    fabletools::accuracy()

  # Generate the forecast
  fcast  <- fit |>
             fabletools::forecast(h=look_ahead)


  # Extract the confidence intervals
  hilo_summ <- fabletools::hilo(fcast,
                                level=level) |>
    dplyr::select(Date,.mean,contains("%"))

  names(hilo_summ) <- c("Date","Mean","CI")

  hilo_summ <- dplyr::mutate(hilo_summ,
                             Level=CI$level,
                             Lower=CI$lower,
                             Upper=CI$upper) |>
               dplyr::select(Date,Mean,Level,Lower,Upper)


  # Create useful plots
  plot1 <- fcast %>%
            autoplot(data_ts) +
            geom_line(aes(y=.fitted),col="#D55E00",data=fabletools::augment(fit))+
            scale_x_date(date_breaks = "1 day",minor_breaks = "1 day",date_labels="%b %e")+
            theme(axis.text.x=element_text(angle=90))

  plot2 <- fabletools::components(fit) |>
                    autoplot()

  # Return all results
  list(hilo=hilo_summ,
       ts_accuracy=ts_accuracy,
       plot_fcast=plot1,
       plot_comp=plot2,
       fable_outputs=list(fit=fit,
                          fcast=fcast,
                          hilo=fabletools::hilo(fcast)))
}
