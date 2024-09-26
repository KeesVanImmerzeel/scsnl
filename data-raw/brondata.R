## code to prepare internal tables (data.frames).
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(raster))

# Constanten
clandgebruik <- data.frame(code=0:3)
rownames(clandgebruik) <- c("gras", "braak", "bebouwing", "bos")

# Read internal tables (data.frames).
csearchpath <- file.path("data-raw", "xlsx")
Bmax_table <-  file.path(csearchpath, "Bmax_table.xlsx") |> readxl::read_excel()                          # GWZ tabel 10.9 p. 120
Bbovengronds_table <- file.path(csearchpath, "Berging_bovengronds.xlsx") |> readxl::read_excel()          # GWZ tabel 10.11 p. 121
Bmax_onbegroeid_table <- file.path(csearchpath, "Berging_onbegroeide_bodem.xlsx") |> readxl::read_excel() # GWZ tabel 10.12 p. 121
Extreme_buien_table <- file.path(csearchpath, "Extreme_buien.xlsx") |> readxl::read_excel()               # GWZ tabel 1.5 p. 4
Extreme_afvoer_table <- file.path(csearchpath, "Extreme_afvoer.xlsx") |> readxl::read_excel()             # GWZ tabel 10.6 p. 118

# Create  package data
usethis::use_data(Bmax_table, overwrite = TRUE, internal = FALSE)
usethis::use_data(Bbovengronds_table,
                  overwrite = TRUE,
                  internal = FALSE)
usethis::use_data(Bmax_onbegroeid_table,
                  overwrite = TRUE,
                  internal = FALSE)
usethis::use_data(Extreme_buien_table,
                  overwrite = TRUE,
                  internal = FALSE)
usethis::use_data(Extreme_afvoer_table,
                  overwrite = TRUE,
                  internal = FALSE)
usethis::use_data(clandgebruik,
                  overwrite = TRUE,
                  internal = TRUE)

# Create package (example dataset).
csearchpath <- file.path("data-raw", "example_data", "rasters")
# bofek BOFEK-profiel (320, 302, 505, 406, 405,203 of 103). [integer]
# gws grondwaterstand (m-mv) [numeric]
# tijdstip (0="einde_winter" of 1="einde_zomer"). [integer]
# buisdrainage (0=nee of 1=ja). [integer]
# gt grondwatertrap (20, 30, 50, 60, 70). [integer]
# landgebruik (0=korte vegetatie of 3=bos). [integer]
# retentie berging in retentie gebieden (optioneel) [numeric]
# L afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
# i gemiddelde terreinheilling van het stroomgebied (m/m). [numeric]
bofek <- file.path(csearchpath, "scs_bofek.tif") |> terra::rast()
gws   <- file.path(csearchpath, "scs_ghg.tif") |> terra::rast()
tijdstip <- file.path(csearchpath, "scs_tijdstip.tif") |> terra::rast()
buisdrainage <- file.path(csearchpath, "scs_buisdrainage.tif") |> terra::rast()
gt <- file.path(csearchpath, "scs_gt.tif") |> terra::rast()
landgebruik <- file.path(csearchpath, "scs_landgebruik.tif") |> terra::rast()
retentie <- file.path(csearchpath, "scs_retentie.tif") |> terra::rast()
L <- file.path(csearchpath, "scs_L.tif") |> terra::rast()
i <- file.path(csearchpath, "scs_i.tiff") |> terra::rast()
r_ex <- c(bofek,
          gws,
          tijdstip,
          buisdrainage,
          gt,
          landgebruik,
          retentie,
          L,
          i)
names(r_ex) <- c("bofek",
                 "gws",
                 "tijdstip",
                 "buisdrainage",
                 "gt",
                 "landgebruik",
                 "retentie",
                 "L",
                 "i")
r_ex <- raster::brick(r_ex)
r_ex |> usethis::use_data( overwrite = TRUE,
                  internal = FALSE)


