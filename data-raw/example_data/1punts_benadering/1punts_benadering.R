library(scsnl)
r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()
bmax <- r_ex |> scsnl::Bmax() 
projectgebied <- "projectgebied.tif" |> terra::rast()
bmax <- bmax * projectgebied
x <- terra::values(bmax) |> stats::quantile(probs=c(0.05, 0.95), na.rm=TRUE)
bmax_min <- as.numeric(x[1])
bmax_max <- as.numeric(x[2])
L <- 14.8 
i <- (39-24.5)/(L*1000)

df <- Qpiek_table_100jr(bmax=bmax_min, L=L, i=i)
df_kritiek_max <- df |> dplyr::slice_max(Qpiek)

df <- Qpiek_table_100jr(bmax=bmax_max, L=L, i=i)
df_kritiek_min <- df |> dplyr::slice_max(Qpiek)


