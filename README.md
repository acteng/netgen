# Generate origin-destination data and route networks


``` r
devtools::load_all()
```

    ℹ Loading netgen

``` r
library(tidyverse)
```

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ✔ purrr     1.0.2     
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ purrr::%||%()   masks base::%||%()
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
# Set theme to void:
theme_set(theme_void())
```

``` r
max_dist = 5000 # meters
od_from_si_full = simodels::si_to_od(zones_york, destinations_york)
od_from_si = simodels::si_to_od(zones_york, destinations_york, max_dist = max_dist)
```

    4511 OD pairs remaining after removing those with a distance greater than 5000 meters:
    57% of all possible OD pairs

``` r
m1 = od_from_si_full |>
  ggplot() +
  geom_sf(alpha = 0.1)
m2 = od_from_si |>
  ggplot() +
  geom_sf(alpha = 0.1)
m1
```

![](README_files/figure-commonmark/plot-od-all-1.png)

``` r
m2
```

![](README_files/figure-commonmark/plot-od-all-2.png)

``` r
# gravity_model = function(beta, d, m, n) {
#   m * n * exp(-beta * d / 1000)
# } 
# # perform SIM
# od_res = si_calculate(
#   od_from_si,
#   fun = gravity_model,
#   d = distance_euclidean,
#   m = destination_n_pupils,
#   n = destination_n_pupils,
#   constraint_production = origin_all,
#   beta = 0.9
#   )
```
