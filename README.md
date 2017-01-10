
<!-- README.md is generated from README.Rmd. Please edit that file -->
scdb
====

The goal of scdb is to provide a back-end for the sc project.

This is a general common-form data structure for complex hierarchical data.

Installation
------------

You can install scdb from github with:

``` r
# install.packages("devtools")
devtools::install_github("mdsumner/scdb")
```

Example
-------

This is a basic example which converts a simple features object to a database, then recreates that object in a very scaleable, flexible and extensible way.

``` r

library(scdb)
data(hpoly)
(pdb <- write_db(hpoly))
#> decomposing object
#> write tables to database C:\Users\mdsumner\AppData\Local\Temp\Rtmpi2OIqI\file39ec3c322a12.sqlite
#> src:  sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\Rtmpi2OIqI\file39ec3c322a12.sqlite]
#> tbls: branch, branch_vertex, object, sqlite_stat1, vertex
```

Now explore the objects available in the database.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
(obj <- tbl(pdb, "object"))
#> Source:   query [?? x 3]
#> Database: sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\Rtmpi2OIqI\file39ec3c322a12.sqlite]
#> 
#>   rownumber_ feature    object_
#>        <int>   <chr>      <chr>
#> 1          1    wall juLJdICtNx
#> 2          2    roof zRwPdLUmlu
#> 3          3    door QHiXzxc2p7
```

There are three objects, and each has a long ID `object_`, as well as other metadata.

Using joins we can access the other data in the decomposed tables.

``` r
big_tab <- (obj %>% inner_join(tbl(pdb, "branch")) %>% inner_join(tbl(pdb, "branch_vertex")) %>% inner_join(tbl(pdb, "vertex")))
#> Joining, by = "object_"
#> Joining, by = "branch_"
#> Joining, by = "vertex_"
big_tab %>% arrange(branch_, order_)
#> Source:   query [?? x 9]
#> Database: sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\Rtmpi2OIqI\file39ec3c322a12.sqlite]
#> 
#>    rownumber_ feature    object_ island_ branch_ order_    vertex_    x_
#>         <int>   <chr>      <chr>   <int>   <int>  <int>      <chr> <dbl>
#> 1           1    wall juLJdICtNx       1       1     16 oFOCWdGfrg    31
#> 2           1    wall juLJdICtNx       1       1     17 7DEPlYrLgR    37
#> 3           1    wall juLJdICtNx       1       1     18 yXtap7cNJw    37
#> 4           1    wall juLJdICtNx       1       1     19 rVd1aiUiX2    31
#> 5           1    wall juLJdICtNx       1       1     20 oFOCWdGfrg    31
#> 6           1    wall juLJdICtNx       1       2      1 HG5ZLPYxHF     0
#> 7           1    wall juLJdICtNx       2       2      1 HG5ZLPYxHF     0
#> 8           1    wall juLJdICtNx       3       2      1 HG5ZLPYxHF     0
#> 9           1    wall juLJdICtNx       1       2      2 R6VYSU5d0w     0
#> 10          1    wall juLJdICtNx       2       2      2 R6VYSU5d0w     0
#> # ... with more rows, and 1 more variables: y_ <dbl>
```

In a real case we would wrap the chained joins within a list-column in `obj` or similar trick, and use the database more cleverly to only expand out the data we need for each object. But also note there's no `collect` statement, `big_tab` is still a promise that the database will do the work only when we really need it to.

For demonstration, show that we can recompose the hierarchical object ...
