There are two datasets in the data_clean/ directory called regready_sa.csv and regready_nsa.csv. These are the seasonally and non-seasonally adjusted versions of the data.

Each dataset is a state X year-month panel. The data runs from 2019m1 through 2021m3. Here is what the seasonally adjusted data looks like:

``` r
# A tibble: 2,700 x 14
   seasonal state_fips  year month month_date emp_H25 emp_L25 emp_M50 rr_H25 rr_L25 rr_M50 emp_priv emp_rest emp_2019_priv
   <chr>         <dbl> <dbl> <dbl> <date>       <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl>    <dbl>    <dbl>         <dbl>
 1 S                 1  2019     1 2019-01-01    374.    440.    862.  0.388  0.500  0.423    1676.     187.         1683.
 2 S                 1  2019     2 2019-02-01    375.    440.    863   0.388  0.500  0.423    1677.     187.         1683.
 3 S                 1  2019     3 2019-03-01    374.    439.    865.  0.388  0.500  0.423    1678.     187.         1683.
 4 S                 1  2019     4 2019-04-01    375.    440.    865.  0.388  0.500  0.423    1680.     188.         1683.
 5 S                 1  2019     5 2019-05-01    376.    439.    867   0.388  0.500  0.423    1682.     187          1683.
 6 S                 1  2019     6 2019-06-01    376.    438.    868.  0.388  0.500  0.423    1682      187.         1683.
 7 S                 1  2019     7 2019-07-01    377.    438.    870.  0.388  0.500  0.423    1685      186.         1683.
 8 S                 1  2019     8 2019-08-01    376.    438.    870.  0.388  0.500  0.423    1685.     187.         1683.
 9 S                 1  2019     9 2019-09-01    376.    438.    868.  0.388  0.500  0.423    1683.     186.         1683.
10 S                 1  2019    10 2019-10-01    376.    440     870.  0.388  0.500  0.423    1686.     188.         1683.
# … with 2,690 more rows
```

The first few columns tell you what data set you're using (SA or NSA), and which state and month the row refers to. The emp_L25 column is the total employment in that state X month in roughly the bottom 25% of major industries in the CES, ranked by median wage level. This turns out to be Accommodation and Food Services; and Retail Trade; and Arts, Entertainment, and Recreation. Similarly there are employment levels for the top 25% and middle 50%.

The rr_L25 variable is the bottom 25% industries, state-specific median replacement rate, as estimated using the Ganong Noel Vavras data from their paper here. This value changes over time to reflect the different FPUC amounts we've had.

There are also variables for private sector employment (emp_priv), accommodation/food services employment (emp_rest), and average private sector employment in 2019 (emp_2019_priv).

Even though they're not shown above, there are also employment and replacement rate columns reflecting a different industry grouping, where we consider the bottom, middle, and top 33%. Same idea, just somewhat different industries. They have names like emp_L33, rr_L33, etc.

The non-seasonally adjusted data has the same layout, but it includes a few more states, as some low-population states in the CES didn't have seasonally adjusted series for a few industries. There are 40 states in the seasonally adjusted data with emp_L25 values, compared to 45 states in the non-seasonally adjusted data. DC is not included in either dataset because for some reason there were no values of replacement rates for that state in the Ganong Noel Vavras data.

I have not yet added COVID caseloads or rates to the data, but I'll do that later.
