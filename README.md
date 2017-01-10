
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
data(pholy)
#> Warning in data(pholy): data set 'pholy' not found
(pdb <- write_db(hpoly))
#> decomposing object
#> write tables to database C:\Users\mdsumner\AppData\Local\Temp\RtmpE7CkT9\file14b8199842a2.sqlite
#> src:  sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\RtmpE7CkT9\file14b8199842a2.sqlite]
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
#> Database: sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\RtmpE7CkT9\file14b8199842a2.sqlite]
#> 
#>   rownumber_ feature    object_
#>        <int>   <chr>      <chr>
#> 1          1    wall lTfMCMoosC
#> 2          2    roof CbNzDsznEy
#> 3          3    door l2rMYAyCaP
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
#> Database: sqlite 3.11.1 [C:\Users\mdsumner\AppData\Local\Temp\RtmpE7CkT9\file14b8199842a2.sqlite]
#> 
#>    rownumber_ feature    object_ island_ branch_ order_    vertex_    x_
#>         <int>   <chr>      <chr>   <int>   <int>  <int>      <chr> <dbl>
#> 1           1    wall lTfMCMoosC       1       1      6 BnuPwFHI7k     7
#> 2           1    wall lTfMCMoosC       1       1      7 oLwfFZnIJi    13
#> 3           1    wall lTfMCMoosC       1       1      8 ap5ur2Mlen    13
#> 4           1    wall lTfMCMoosC       1       1      9 eg408jEPuu     7
#> 5           1    wall lTfMCMoosC       1       1     10 BnuPwFHI7k     7
#> 6           1    wall lTfMCMoosC       1       2     11 Mo2iYwcFCF    18
#> 7           1    wall lTfMCMoosC       1       2     12 6xBBITbpve    24
#> 8           1    wall lTfMCMoosC       1       2     13 XoiyHF6sFo    24
#> 9           1    wall lTfMCMoosC       1       2     14 YwBPD5KbcS    18
#> 10          1    wall lTfMCMoosC       1       2     15 Mo2iYwcFCF    18
#> # ... with more rows, and 1 more variables: y_ <dbl>
```

In a real case we would wrap the chained joins within a list-column in `obj` or similar trick, and use the database more cleverly to only expand out the data we need for each object. But also note there's no `collect` statement, `big_tab` is still a promise that the database will do the work only when we really need it to.

For demonstration, show that we can recompose the hierarchical object ...
