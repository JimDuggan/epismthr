library(epismthr)
library(ggplot2)
library(dplyr)
library(fable)

all_data <- generate_cases()

test_data <- all_data |>
  filter(Date <= as.Date("2023-10-31"))

ggplot(test_data,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")

result <- epi_forecast(test_data,
                       look_ahead = 7,
                       damped = FALSE,
                       seasonal = TRUE)

result$plot_fcast
result$plot_comp
