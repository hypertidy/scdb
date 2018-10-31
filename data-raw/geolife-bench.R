pdf <- "https://github.com/hypertidy/scdb/files/2533604/A02_2115_FP_Graser.pdf"
dir.create("inst/geolife-bench", recursive = TRUE, showWarnings = FALSE)
file <- file.path("inst/geolife-bench", basename(pdf))
if (!file.exists(file)) {
  curl::curl_download(pdf, file)
}
geolife <- "https://download.microsoft.com/download/F/4/8/F4894AA5-FDBC-481E-9285-D5F8C4C4F039/Geolife%20Trajectories%201.3.zip"
## sub spaces Geolife Trajectories 1.3.zip
gfile <- file.path("inst/geolife-bench", "Geolife_Trajectories_1.3.zip")
curl::curl_download(geolife, gfile)
unzip(gfile, exdir = "inst/geolife-bench")

gfiles <- tibble::tibble(fullname = fs::dir_ls("inst/geolife-bench/Geolife Trajectories 1.3", recursive = TRUE, type = "file"))

usethis::use_data(gfiles, internal = TRUE)
