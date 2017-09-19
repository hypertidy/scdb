context("write_db")

library(silicate)
test_that("write to db works", {
  write_db(hpoly) %>% expect_s3_class("src") %>% 
    dplyr::tbl("vertex") %>% expect_s3_class("tbl_sql")
  
})
