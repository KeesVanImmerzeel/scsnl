#'  scsnl
#'
#' Schatting van piekafvoer in vrij afwaterende gebieden in Nederland met de SCS-methode (Grondwaterzakboekje 2016 p. 119-124).
#'
#' De berekening kan worden gedaan op puntniveau, resulterend in een tabel. Als raster-kaarten beschikbaar
#' zijn van alle invoer parameters dan kan de piekafvoer ook vlakdekkend worden berekend.
#'
#' Er is een tabel aanwezig voor de keuze van diverse neerslagstatistieken (zie hieronder).
#'
#' Functies:
#'
#' \code{\link{Bmax}} \cr
#' \code{\link{Qpiek_table_100jr}} \cr
#' \code{\link{afv}} \cr
#' \code{\link{rel_afv}} \cr
#' \code{\link{t_default}}
#'
#' Rasters:
#'
#' * \strong{r_ex}: Voorbeeld SpatRaster met layers met betrekking tot de bovenlopen van de Beerze (NL).
#'
#' Met layers:
#' - bofek: BOFEK-profiel (320, 302, 505, 406, 405,203 of 103) \cr
#' - gws: Grondwaterstand (m-mv) \cr
#' - tijdstip: 0=einde_winter of 1=einde_zomer. \cr
#' - buisdrainage: 0=nee of 1=ja. \cr
#' - gt: grondwatertrap (20, 30, 50, 60, 70). \cr
#' - landgebruik: 0=korte vegetatie, 1=braakliggende grond/onverharde weg, 2=verharde weg/bebouwing, 3=bos.\cr
#' - retentie: Berging in retentie gebieden.\cr
#' - L: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km). \cr
#'   Verdubbel deze lengte bij de invoer van de functie \code{\link{Qpiek_table_100jr}} \cr
#' - i: Gemiddelde terreinheilling van het stroomgebied (m/m).\cr
#'
#' Om deze dataset te gebruiken:
#'
#' * `r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()`
#'
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
#' Tabel voor de constructie van extreme buiten tabel (zoals \code{\link{Extreme_buien_table}}):
#'
#' * \strong{Extreme_buien.csv} Database (tabel) met neerslagstatistieken.
#'
#' Kolommen in deze tabel:
#' - FREQ: Frequentie: ... keer per jaar. (-)
#' - DUUR: Duur van de bui (TIJDSEENHEID)
#' - TIJDSEENHEID: minuut, uur of dag
#' - Q: Hoeveelheid neerslag in de bui. (mm)
#' - BRON: Referentie (-)
#' - PERIODE: Periode waar de statistiek betrekking op heeft (Jaar, Winter, Zomer)
#' - REF_JAAR: Indicatie van het jaar waarop de statistiek betrekking heeft (-)
#' - SCENARIO: Aanduiding van het scenario waarop de statistiek is gebaseerd (-).
#'
#' Hoe deze dataset te gebruiken? Voorbeeld":
#'
#'`fname <- file.path( find.package("scsnl"), "extdata", "Extreme_buien.csv")`\cr
#'`df <- fname |> read.csv(sep=";", dec = ",")`\cr
#'`df <- df[ , colSums(is.na(df))==0]`\cr
#'`df %<>% dplyr::filter(BRON=="Neerslagstatistiek KNMI23 tabel 8 p. 26")`\cr
#'`df%<>% dplyr::filter(FREQ==0.1)`\cr
#'`df %<>% dplyr::mutate(TN = dplyr::case_when(TIJDSEENHEID=="dag" ~ DUUR*24, TIJDSEENHEID=="min" ~ DUUR/60, TIJDSEENHEID=="uur" ~ DUUR))`\cr
#'`df %<>% dplyr::select(FREQ, TN, Q)`\cr
#'
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
#' @importFrom terra app
#' @importFrom terra rast
#' @importFrom terra 'values<-'
#'
#' @importFrom parallelly availableCores
#'
NULL

