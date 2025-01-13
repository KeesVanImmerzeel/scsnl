#'  scsnl
#'
#' Schatting van piekafvoer in vrij afwaterende gebieden in Nederland met de SCS-methode (Grondwaterzakboekje 2016 p. 119-124).
#'
#' De berekening kan worden gedaan op puntniveau, resulterend in een tabel. Als raster-kaarten beschikbaar
#' zijn van alle invoer parameters dan wordt de piekafvoer vlakdekkend berekend.
#'
#' Functies:
#'
#' \code{\link{Bmax}} \cr
#' \code{\link{Qpiek_table_100jr}}
#'
#' Rasters:
#'
#' * \strong{r_ex}: HELP map of the Netherlands based on the Bofek2020 map.
#'
#' Voorbeeld SpatRaster met layers met betrekking tot de bovenlopen van de Beerze (NL).
#'
#' Om deze dataset te gebruiken:
#'
#' * `r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()`
#'
#' Layers:
#' - bofek: BOFEK-profiel (320, 302, 505, 406, 405,203 of 103) \cr
#' - gws: Grondwaterstand (m-mv) \cr
#' - tijdstip: 0=einde_winter of 1=einde_zomer. \cr
#' - buisdrainage: 0=nee of 1=ja. \cr
#' - grondwatertrap: 20, 30, 50, 60, 70. \cr
#' - landgebruik: 0=korte vegetatie, 1=braakliggende grond/onverharde weg, 2=verharde weg/bebouwing, 3=bos.\cr
#' - retentie: Berging in retentie gebieden.\cr
#' - L: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km). \cr
#' - i: Gemiddelde terreinheilling van het stroomgebied (m/m).
#'
#' @source <http://www.grondwaterzakboekje.nl/> {grondwaterzakboekje}
#'
#' Tabellen:
#'
#' \code{\link{Bmax_table}} \cr
#' \code{\link{Bbovengronds_table}} \cr
#' \code{\link{Bmax_onbegroeid_table}} \cr
#' \code{\link{Extreme_buien_table}} \cr
#' \code{\link{Extreme_afvoer_table}}
#'
#' Constants:
#'
#' \code{\link{clandgebruik}}
#'
#' @name scsnl
#'
#' @importFrom stats approx
#'
#' @importFrom magrittr %>%
#' @importFrom magrittr %<>%
#'
# @importFrom akima interp
#'
#' @importFrom terra app
#' @importFrom terra rast
#' @importFrom terra 'values<-'
#'
#' @importFrom parallelly availableCores
#'
NULL

