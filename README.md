
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
#> write tables to database C:\Users\mdsumner\AppData\Local\Temp\RtmpwNASr6\fileb601b0797.sqlite
#> src:  sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\RtmpwNASr6\fileb601b0797.sqlite]
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
#> Database: sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\RtmpwNASr6\fileb601b0797.sqlite]
#> 
#>   rownumber_ feature    object_
#>        <int>   <chr>      <chr>
#> 1          1    wall lYiqMmNowd
#> 2          2    roof 3NPAJ1qXX5
#> 3          3    door kVRn2odXIO
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
#> Database: sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\RtmpwNASr6\fileb601b0797.sqlite]
#> 
#>    rownumber_ feature    object_ island_ branch_ order_    vertex_    x_
#>         <int>   <chr>      <chr>   <int>   <int>  <int>      <chr> <dbl>
#> 1           1    wall lYiqMmNowd       1       1      6 N0faXkjTx7   7.0
#> 2           1    wall lYiqMmNowd       1       1      7 jEH7AuGK8y  13.0
#> 3           1    wall lYiqMmNowd       1       1      8 oybjnjolu1  13.0
#> 4           1    wall lYiqMmNowd       1       1      9 dQUu8AxbGk   7.0
#> 5           1    wall lYiqMmNowd       1       1     10 N0faXkjTx7   7.0
#> 6           3    door kVRn2odXIO       1       2     44 3D9eBxTBuX  18.4
#> 7           3    door kVRn2odXIO       1       2     45 oY15sfoCci  18.6
#> 8           3    door kVRn2odXIO       1       2     46 EnhsiM4Ms5  18.8
#> 9           3    door kVRn2odXIO       1       2     47 V8pVJeZujK  18.8
#> 10          3    door kVRn2odXIO       1       2     48 YpVaixHEZU  18.6
#> # ... with more rows, and 1 more variables: y_ <dbl>
```

In a real case we would wrap the chained joins within a list-column in `obj` or similar trick, and use the database more cleverly to only expand out the data we need for each object. But also note there's no `collect` statement, `big_tab` is still a promise that the database will do the work only when we really need it to.

For demonstration, show that we can recompose the hierarchical object ...
