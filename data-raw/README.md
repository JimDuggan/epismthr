Generating a forecast from synthetic data
================

The first step (after installing the package) is to load the library
`epismthr`, along with other packages as shown below.

``` r
library(epismthr)
library(ggplot2)
library(dplyr)
library(fable)
```

Use the function `generate_cases()` to generate synthetic data, so that
we can test the forecasting algorithm.

``` r
all_data <- generate_cases()
all_data
```

    ## # A tibble: 101 × 4
    ##      Day Date        Model Cases
    ##    <int> <date>      <dbl> <dbl>
    ##  1     1 2023-09-01 0          0
    ##  2     2 2023-09-02 0.0281     0
    ##  3     3 2023-09-03 0.0706     0
    ##  4     4 2023-09-04 0.0958     0
    ##  5     5 2023-09-05 0.116      0
    ##  6     6 2023-09-06 0.135      0
    ##  7     7 2023-09-07 0.156      0
    ##  8     8 2023-09-08 0.180      1
    ##  9     9 2023-09-09 0.207      0
    ## 10    10 2023-09-10 0.238      1
    ## # ℹ 91 more rows

Get data from an earlier part of the epi curve in order to run a test.

``` r
test_data <- all_data %>%
  filter(Date <= as.Date("2023-10-24"))
```

Plot the SEIR model output and the generated data.

``` r
ggplot(test_data,aes(x=Date,y=Cases))+
  geom_line()+
  geom_point()+
  geom_line(aes(y=Model),colour="red")+
  scale_x_date(date_breaks = "1 week", minor_breaks = "1 day",date_labels="%b %e")
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

Call the function `epi_forecast()` to generate the forecast, with a
look-ahead duration of seven days. A list containing result data is
returned.

``` r
result <- epi_forecast(test_data,
                       look_ahead = 5)
```

First, we can plot the forecast.

``` r
result$plot_fcast
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Next, we can plot information on the overall fit.

``` r
result$plot_comp
```

    ## Warning: Removed 1 row containing missing values (`geom_line()`).

![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

We can also access the forecast values and the confidence intervals.

``` r
result$hilo
```

    ## # A tsibble: 5 x 5 [1D]
    ##   Date        Mean Level Lower Upper
    ##   <date>     <dbl> <dbl> <dbl> <dbl>
    ## 1 2023-10-25  71.3    95  60.3  82.3
    ## 2 2023-10-26  76.2    95  65.0  87.4
    ## 3 2023-10-27  81.0    95  69.3  92.8
    ## 4 2023-10-28  85.8    95  73.3  98.3
    ## 5 2023-10-29  90.4    95  76.8 104.

And display the training set accuracy measures.

``` r
result$ts_accuracy
```

    ## # A tibble: 1 × 10
    ##   .model                  .type    ME  RMSE   MAE   MPE  MAPE  MASE RMSSE   ACF1
    ##   <chr>                   <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
    ## 1 "fable::ETS(Cases ~ er… Trai…  1.16  5.35  2.86   NaN   Inf 0.357 0.406 0.0300
