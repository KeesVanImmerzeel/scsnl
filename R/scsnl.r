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
#' Tabellen:
#'
#' \code{\link{r_ex}} \cr
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
#' @docType package
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

