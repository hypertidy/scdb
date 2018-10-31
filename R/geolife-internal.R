
# This GPS trajectory dataset was collected in (Microsoft Research Asia) Geolife
# project by 182 users in a period of over three years (from April 2007 to
# August 2012). A GPS trajectory of this dataset is represented by a sequence of
# time-stamped points, each of which contains the information of latitude,
# longitude and altitude. This dataset contains 17,621 trajectories with a total
# distance of about 1.2 million kilometers and a total duration of 48,000+
# hours. These trajectories were recorded by different GPS loggers and
# GPS-phones, and have a variety of sampling rates. 91 percent of the
# trajectories are logged in a dense representation, e.g. every 1~5 seconds or
# every 5~10 meters per point. This dataset recoded a broad range of users’
# outdoor movements, including not only life routines like go home and go to
# work but also some entertainments and sports activities, such as shopping,
# sightseeing, dining, hiking, and cycling. This trajectory dataset can be used
# in many research fields, such as mobility pattern mining, user activity
# recognition, location-based social networks, location privacy, and location
# recommendation. Please cite the following papers when using this GPS dataset.
# [1] Yu Zheng, Lizhu Zhang, Xing Xie, Wei-Ying Ma. Mining interesting locations
# and travel sequences from GPS trajectories. In Proceedings of International
# conference on World Wild Web (WWW 2009), Madrid Spain. ACM Press: 791-800. [2]
# Yu Zheng, Quannan Li, Yukun Chen, Xing Xie, Wei-Ying Ma. Understanding
# Mobility Based on GPS Data. In Proceedings of ACM conference on Ubiquitous
# Computing (UbiComp 2008), Seoul, Korea. ACM Press: 312-321. [3] Yu Zheng, Xing
# Xie, Wei-Ying Ma, GeoLife: A Collaborative Social Networking Service among
# User, location and trajectory. Invited paper, in IEEE Data Engineering
# Bulletin. 33, 2, 2010, pp. 32-40.


# PLT format:
#   Line 1…6 are useless in this dataset, and can be ignored. Points are described in following lines, 
# one for each line.
# Field 1: Latitude in decimal degrees.
# Field 2: Longitude in decimal degrees.
# Field 3: All set to 0 for this dataset.
# Field 4: Altitude in feet (-777 if not valid).
# Field 5: Date - number of days (with fractional part) that have passed since 12/30/1899.
# Field 6: Date as a string.
# Field 7: Time as a string.
# Note that field 5 and field 6&7 represent the same date/time in this dataset. You may use either of them.
# Example:
# 39.906631,116.385564,0,492,40097.5864583333,2009-10-11,14:04:30
# 39.906554,116.385625,0,492,40097.5865162037,2009-10-11,14:04:35
#' @importFrom readr col_double col_integer col_character
#' @examples 
#' tr <- read_geofile(gfiles$fullname[1]) %>% as_trip()
#' wm <- which.max(gfiles$size)
#' 
#' ## 4 seconds
#' system.time(tr <- read_geofile(gfiles$fullname[wm]) %>% as_trip())
#' system.time(total_length(tr))
#' system.time(total_duration(tr))
#' ## fast
#' system.time(extract_position(tr, mean(c(time_end(tr), time_start(tr)))))
read_geofile <- function(x, ...) {
  readr::read_csv(x, col_names = c("lat", "lon", "allzero", "altitude_ft", "ms_date", "date", "time"), 
                  col_types = list(col_double(), col_double(), col_integer(), col_double(), col_double(), 
                                   col_character(), col_character()), 
                  skip = 6) %>% 
    dplyr::transmute(lon, lat, utc = as.POSIXct(strptime(paste(date, time), "%Y-%m-%d %H:%M:%S"), tz = "UTC"), 
                     z = altitude_ft * 0.3048, id = gsub("\\.plt$", "", basename(x)))
}
project_extent <- function(x, family = "laea") {
  UseMethod("project_extent")
}
project_extent.Spatial <- function(x, family = "laea") {
  project_extent(coordinates(x))
}
project_extent.default <- function(x, family = "laea") {
  mxy <- c(mean(x[,1]), mean(x[,2]))
  proj <- sprintf("+proj=%s +lon_0=%f +lat_0=%f +datum=WGS84", family, mxy[1], mxy[2])
  raster::projectExtent(raster::raster(raster::extent(x), crs = "+init=epsg:4326"), proj)
}
as_trip <- function(x) {
  if (!requireNamespace("trip")) stop("as_trip needs the trip package installed, use 'install.packages(\"trip\")'")
  trip::trip(sp::SpatialPointsDataFrame(sp::SpatialPoints(cbind(x$lon, x$lat), proj4string = sp::CRS("+init=epsg:4326")),
                                        data.frame(utc = x$utc, z = x$z, id = x$id, stringsAsFactors = FALSE)), 
             c("utc", "id"))
}

stop_not_trip <- function(x) {
  if (!inherits(x, "trip")) stop("not a trip")
  invisible(NULL)
}
## 1. Computing total trajectory duration and length per tracker
## in hours
total_duration <- function(x) {
  stop_not_trip(x)
  dif <- diff(range(x[[trip::getTORnames(x)[1]]]))
  units(dif) <- "hours"
  dif
}
time_start <- function(x) {
  stop_not_trip(x)
  min(x[[trip::getTORnames(x)[1]]])
}
time_end <- function(x) {
  stop_not_trip(x)
  max(x[[trip::getTORnames(x)[1]]])
}

## in km
total_length <- function(x) {
  stop_not_trip(x)
  sum(trip::trackDistance(x))
}

#### this is where we need the full db backended

## 2. Finding trajectories that occurred during a certain time frame (temporal filter)

## 3. Finding trajectories that originated in a certain spatial region (spatial filter)


## 4. Extracting positions at a certain point in time
## if longlat ok
extract_position <- function(x, utc) {
  if (!inherits(utc, "POSIXct")) utc <- as.POSIXct(utc, tz = "UTC")
  xy <- coordinates(x)
  dt <- x[[trip::getTORnames(x)[1]]]
  ax <- approxfun(dt, xy[,1])
  ay <- approxfun(dt, xy[,2])
  cbind(ax(utc), ay(utc))
}

# 5. Visualizing trajectories in desktop GIS
## tcltck, mapview, etc. 

# ## here a bit of fun to produce a globe of envelopes
# read <- function(.x) read_geofile(.x)[c("lon", "lat")] %>% as.matrix() %>% project_extent()
# system.time(l <- purrr::map(gfiles$fullname, purrr::safely(read)))
# o <- vector("list", length(l))
# ok <- logical(length(l))
# for (i in seq_along(l)) {
#    isok <- !is.null(l[[i]]$result)
#    ok[i] <- isok
#    o[[i]] <- anglr::globe(silicate::SC(spex::spex(l[[i]]$result)))
# }
# 
# library(anglr)
# for (i in seq_along(o)) plot3d(o[[i]], add = i > 1)
# rgl::rglwidget()
