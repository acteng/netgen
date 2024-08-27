# Generate origin-destination data for route network generation


The input of the network generation approaches demonstrated in this repo
is origin-destionation data. There are many sources of OD data, see
[odgen](odgen.qmd) for a way to generate synthetic OD data that we’ll
use in the reproducible code below.

# Setup

<div class="panel-tabset" group="language">

## R

<!---
 jn: I would suggest to use specific packages from tidyverse instead of attaching the whole tidyverse 
&#10;rl: Why? Tidyverse is popular and it makes life easy.
Also that's the approach in the teaching materials.
For the book and for software development that's another matter but for this blog post I think it's fine.
--->

## Python

    CompletedProcess(args=['gh', 'release', 'download', 'v0.1.0'], returncode=1)

</div>

# Data import and visualisation

It’s worth importing and visualising the OD datasets before routing and
network generation stages.

<div class="panel-tabset" group="language">

## R

    # A tibble: 6 × 3
      O              D trips_modelled
      <chr>      <dbl>          <dbl>
    1 E01013335 121266          6.37 
    2 E01013336 121266          3.26 
    3 E01013337 121266          4.57 
    4 E01013338 121266          6.46 
    5 E01013339 121266          2.95 
    6 E01013340 121266          0.124

![](README_files/figure-commonmark/desire-lines-r-1.png)

## Python

               O       D  trips_modelled
    0  E01013335  121266        6.372102
    1  E01013336  121266        3.264443
    2  E01013337  121266        4.566013
    3  E01013338  121266        6.463300
    4  E01013339  121266        2.953231

</div>

# Routing

There are many ways to calculate routes. The simplest in many cases will
be to calculate them with a routing engine. Let’s do that with
interfaces to the OSRM routing engine in the first instance.

## OSRM: basic

![](README_files/figure-commonmark/osrm-basic-1.png)
