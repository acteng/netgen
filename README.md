# Generate origin-destination data and route networks


The code in this results demonstrates how to generate origin-destination
(OD) data for a given set of zones and destinations. OD data is a key
input into spatial interaction models (SIMs) for generating route
networks. (See [An introduction to spatial interaction models: from
first
principles](https://robinlovelace.github.io/simodels/articles/sims-first-principles.html)
introduction to SIMs for more information.) The code is fully
reproducible, although requires a validation dataset that is not in the
public domain to generate goodness-of-fit statistics shown in this
README.

Install the package as follows (you can also clone the repo and run
`devtools::load_all()`):

``` r
if (!require("devtools")) install.packages("devtools")
devtools::install_github("acteng/netgen")
```

The package uses the [`{simodels}` R
package](https://robinlovelace.github.io/simodels/) to pre-process the
input datasets and generate the OD data used as the basis of the
interaction prediction model. The input datasets are illustrated in the
figure below (these are `zones_york` and `destinations_york` that are
provided with the pacage):

![](README_files/figure-commonmark/inputs-1.png)

Before we run any models let’s compare the total number of pupils in the
zones dataset and the destinations dataset (they should be the same):

``` r
zone_overestimate_factor = 
  (sum(zones_york$f0_to_15) + sum(zones_york$m0_to_15)) /
    sum(destinations_york$n_pupils)
zone_overestimate_factor
```

    [1] 1.194998

As one would expect, the total number of pupils in the zones dataset is
a bit bigger than the total number of pupils in the destinations
dataset: not all people aged 0 to 15 go to school, especially those
under school age. To tackle this issue we’ll create a new variables
called `pupils_estimated` in the zones dataset, which is the sum of the
number of pupils in the zones dataset and the number of pupils in the
destinations dataset.

``` r
zones_york = zones_york |>
  dplyr::mutate(
    pupils_estimated = (f0_to_15 + m0_to_15) / zone_overestimate_factor
  )
```

After the adjustment shown above, the totals in the origin and
destination columns should be the same:

``` r
sum(zones_york$pupils_estimated)
```

    [1] 25631

``` r
sum(destinations_york$n_pupils)
```

    [1] 25631

Based on these inputs the `si_to_od()` function generates the OD data,
as shown below (note: 2 versions are created, one with a maximum
distance constraint for speed of processing, important when working with
large datasets).

``` r
max_dist = 5000 # meters
od_from_si_full = simodels::si_to_od(zones_york, destinations_york)
od_from_si = simodels::si_to_od(zones_york, destinations_york, max_dist = max_dist)
```

    4338 OD pairs remaining after removing those with a distance greater than 5000 meters:
    57% of all possible OD pairs

![](README_files/figure-commonmark/plot-od-all-1.png)

![](README_files/figure-commonmark/plot-od-all-2.png)

The output OD dataset has column names taken from both the origin and
destination datasets, with the following column names:

     [1] "O"                                 "D"                                
     [3] "distance_euclidean"                "origin_LSOA21NM"                  
     [5] "origin_total"                      "origin_f0_to_15"                  
     [7] "origin_f16_to_29"                  "origin_f30_to_44"                 
     [9] "origin_f45_to_64"                  "origin_f65_and_over"              
    [11] "origin_m0_to_15"                   "origin_m16_to_29"                 
    [13] "origin_m30_to_44"                  "origin_m45_to_64"                 
    [15] "origin_m65_and_over"               "origin_pupils_estimated"          
    [17] "destination_n_pupils"              "destination_phase"                
    [19] "destination_type_of_establishment" "geometry"                         

Let’s run a simple model:

``` r
gravity_model = function(beta, d, m, n) {
  m * n * exp(-beta * d / 1000)
} 
# perform SIM
od_res = simodels::si_calculate(
  od_from_si,
  fun = gravity_model,
  d = distance_euclidean,
  m = origin_pupils_estimated,
  n = destination_n_pupils,
#   constraint_production = origin_all,
  beta = 0.9
  )
```

We can assess the model fit at thre levels: the origin level (number of
students departing from each zone), the destination level (the number
arriving at each school in the input dataset) and the origin-destination
level.

    `geom_smooth()` using formula = 'y ~ x'

![](README_files/figure-commonmark/r-squared-1.png)

The R-squared value is 0.401.

Let’s see if making the model production constrained can help:

``` r
od_res_constrained = simodels::si_calculate(
  od_from_si,
  fun = gravity_model,
  d = distance_euclidean,
  m = origin_pupils_estimated,
  n = destination_n_pupils,
  constraint_production = origin_pupils_estimated,
  beta = 0.9
  )
```

The R-squared value is 0.57.
