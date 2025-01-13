library(terra)
q <- "r_Qpiek_100jr.tif" |> terra::rast()
q <- q$Qpiek
projectgebied <- "projectgebied.tif" |> terra::rast()
q <- q * projectgebied
n <- sum(as.vector(projectgebied), na.rm=TRUE)
area <- n * 25 * 25
qmean <- mean(as.vector(q), na.rm=TRUE) # mm/u
Q <- qmean * area / (1000*3600) # m3/s mm/u * m2 / (1000 * 3600)


