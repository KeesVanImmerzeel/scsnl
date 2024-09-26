#' r_ex
#'
#' Voorbeeld SpatRaster met layers met betrekking tot de bovenlopen van de Beerze (NL).
#'
#' Convert r_ex-object to terra-raster first before usage in scsnl package: terra::rast(r_ex) \cr \cr
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
"r_ex"

#' Bmax_table
#'
#' Eerste schatting van de maximale bodemberging (mm) met en zonder drainage.
#'
#' - BOFEK:	       BOFEK-profiel (320, 302, 505, 406, 405,203 of 103).\cr
#' - GWS:           Grondwaterstand (m-mv).\cr
#' - TIJDSTIP:	     0="einde_winter" of 1="einde_zomer".\cr
#' - BUISDRAINAGE:	 0 of NA=nee of 1=ja.\cr
#' - BMAX:          Eerste schatting van de maximale bodemberging. (mm).

#' @source <GWZ tabel 10.9 en 10.10 p. 120 en p. 121> {grondwaterzakboekje}
#'
"Bmax_table"

#' Bbovengronds_table
#'
#' Globale schatting van de bergingsmogelijkheid bovengronds (interceptie aan maaiveld + afvoerende watergangen + retentie).
#'
#' - GT:              Grondwatertrap (20, 30, 50, 60, 70).  \cr
#' - WATERGANGEN:     bergingsmogelijkheid in watergangen (mm).  \cr
#' - LANDGEBRUIK:     0=korte vegetatie of 3=bos.  \cr
#' - MAAIVELDBERGING: Interceptie aan maaiveld. (mm)
#'
#' @source <GWZ tabel 10.11 p. 121> {grondwaterzakboekje}
#'
"Bbovengronds_table"

#' Bmax_onbegroeid_table
#'
#' Globale schatting van de maximale berging in/op onbegroeide bodem.
#'
#' - BOFEK:	       BOFEK-profiel (320, 302, 505, 406, 405,203 of 103). \cr
#' - LANDGEBRUIK:   1=braakliggende grond/onverharde weg, 2=verharde weg/bebouwing.  \cr
#' - MAXBERGING:    Globale schatting van de maximale berging in/op onbegroeide bodem. (mm).
#'
#' @source <GWZ tabel 10.12 p. 121> {grondwaterzakboekje}
#'
"Bmax_onbegroeid_table"

#' Extreme_buien_table
#'
#' Frequentieverdeling van extreme buien.
#'
#' - FREQ:	      Frequentie: ... keer per jaar. (-) \cr
#' - TN:          Duur van de bui (uur).  \cr
#' - Q:           Hoeveelheid neerslag in de bui. (mm)
#'
#' @source <GWZ tabel 1.5 p. 4> {grondwaterzakboekje}
#'
"Extreme_buien_table"

#' Extreme_afvoer_table
#'
#' Globale relatie tussen de herhalingstijd en de *relatieve* extreme afvoer in Nederland (ten opzichte van de afvoer 1x per jaar).
#'
#' - FREQ:	       Frequentie: ... keer per jaar. (-) \cr
#' - REAFV:	     Relatieve extreme afvoer (-).
#'
#' @source <GWZ tabel 10.6 p. 118> {grondwaterzakboekje}
#'
"Extreme_afvoer_table"

#' clandgebruik
#'
#' Landgebruik codes. "Verharde weg" = "bebouwing
#'
#' @source <GWZ p. 120-121> {grondwaterzakboekje}
#'
"clandgebruik"
