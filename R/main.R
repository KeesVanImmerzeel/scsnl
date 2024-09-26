# Internal functions ###########################################################

# Eerste schatting van de maximale bodemberging (mm) NA if invalid input.
#
# @param bofek BOFEK-profiel (320, 302, 505, 406, 405,203 of 103). [integer]
# @param gws   grondwaterstand (m-mv) [numeric]
# @param tijdstip (0="einde_winter" of 1="einde_zomer"). [integer]
# @param buisdrainage (0 of NA=nee of 1=ja). [integer]
# @return Eerste schatting van de maximale bodemberging (mm) NA if invalid input. [numeric]
# @example Bmax_bodem(df = Bmax_table, bofek=320L, gws=1.0, tijdstip=0L, buisdrainage=0L)
Bmax_bodem <- function(df = Bmax_table,
                       bofek = 320L,
                       gws = 1.0,
                       tijdstip = 0L,
                       buisdrainage = 0L) {

  if (is.na(buisdrainage)) {
    buisdrainage <- 0
  }
  df %<>% dplyr::filter(BOFEK == bofek,
                        TIJDSTIP == tijdstip,
                        BUISDRAINAGE == buisdrainage)
  if (nrow(df) > 0) {
    res <- stats::approx(
      x = df$GWS,
      y = df$BMAX,
      xout = gws,
      rule = 2
    )
    return(res$y)
  } else {
    return(NA)
  }
}

# Globale schatting van de bergingsmogelijkheid bovengronds (interceptie aan maaiveld + afvoerende watergangen + retentie (optioneel) (mm)
#
# @param gt grondwatertrap (20, 30, 50, 60, 70). [integer]
# @param landgebruik (0=korte vegetatie of 3=bos). [integer]
# @param retentie berging in retentie gebieden [numeric]
# @return Globale schatting van de bergingsmogelijkheid bovengronds (interceptie aan maaiveld + afvoerende watergangen + retentie (mm). 0 if invalid input.[numeric]
# @example Bbovengronds(df = Bbovengronds_table, gt=20, landgebruik=0)
Bbovengronds <- function(df = Bbovengronds_table,
                         gt = 20L,
                         landgebruik = 0L,
                         retentie=0) {
  GT <- NULL
  LANDGEBRUIK <- NULL
  MAAIVELDBERGING <- NULL
  df %<>% dplyr::filter(GT == gt, LANDGEBRUIK == landgebruik)
  if (nrow(df) == 1) {
    return(df$WATERGANGEN + df$MAAIVELDBERGING + retentie)
  } else {
    return(0)
  }
}

# Globale schatting van de maximale berging in/op onbegroeide bodem (mm).
#
# @param bofek BOFEK-profiel (320, 302, 505, 406, 405,203 of 103). [integer]
# @param landgebruik (1=braakliggende grond/onverharde weg, 2=verharde weg/bebouwing). [integer]
# @return Globale schatting van de maximale berging in/op onbegroeide bodem (mm). 0 if invalid input. [numeric]
# @example Bmax_onbegroeid(df = Bmax_onbegroeid_table, bofek=320, landgebruik=1)
Bmax_onbegroeid <- function(df = Bmax_onbegroeid_table,
                            bofek = 320L,
                            landgebruik = 1L) {
  BOFEK <- NULL
  LANDGEBRUIK <- NULL
  df %<>% dplyr::filter(BOFEK == bofek, LANDGEBRUIK == landgebruik)
  if (nrow(df) == 1) {
    return(df$MAXBERGING)
  } else {
    return(0)
  }
}

# @param x named vector with (bofek, landgebruik, gws, tijdstip, buisdrainage, gt, retentie)
# @param df1 Bmax_table
# @param df2 Bbovengronds_table
# @param df3 Bmax_onbegroeid_table
# @param landgebruik Nummers van landgebruik (named vector)
# @return Globale schatting van de totale maximale berging (mm). NA if invalid input. [numeric]
.Bmax <- function(x,
                 df1 = Bmax_table,
                 df2 = Bbovengronds_table,
                 df3 = Bmax_onbegroeid_table,
                 landgebruik=clandgebruik) {

  #clandgebruik <- data.frame(code=0:3)
  #rownames(clandgebruik) <- c("gras", "braak", "bebouwing", "bos")

  if ((x['landgebruik'] == landgebruik["braak",]) || (x['landgebruik'] == landgebruik["bebouwing",])) {  #Onbegroeide bodem
    res <- Bmax_onbegroeid(df3, x['bofek'], x['landgebruik']) + x['retentie']
  } else if ((x['landgebruik'] == landgebruik["gras",]) || (x['landgebruik'] == landgebruik["bos",]) || (x['landgebruik'] == landgebruik["braak",])) {
    res <- Bmax_bodem(df1, x['bofek'], x['gws'], x['tijdstip'], x['buisdrainage'])
    res <- res + Bbovengronds(df2, x['gt'], x['landgebruik'], x['retentie'])
  } else {
    res <- NA # invalid landgebruik
  }
  #if ((!is.na(res)) && ((res > 250) || (res < 15))) { # Beperking ivm toepassingsgebied SCS-methode
  #  res <- NA
  #}
  return(res)
}


# @param Q Hoeveelheid neerslag in de bui (=Intensiteit (mm/u) x Tn (uur)) (mm) [numeric]
# @param bmax Globale schatting van de totale maximale berging (mm). Zie functie Bmax().
# @return data.frame met kolommen Qeff=afgevoerde hoeveelheid (mm) en Ba=Benutte berging tijdens afvoer (mm) [numeric]
# @example Qeff(bmax=65, Q=50)
Qeff <- function(Q, bmax) {
  Bi <- 0.2*bmax # Initele benutte berging zonder afvoer (mm)
  if (Q > Bi) {
    res <- (Q-Bi)^2 / (Q+0.8*bmax)
    Ba <- bmax * (Q-Bi) / (Q+0.8*bmax) # Benutte berging tijdens afvoer (mm)
    Ba <- min(Ba, bmax)
  } else {
    res <- 0
  }
  df <- data.frame(Qeff=res, Ba=Ba)
  return(df)
}

# @param L Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
# @param bmax: zie hierboven [numeric]
# @param i Gemiddelde terreinheilling van het stroomgebied (m/m). [numeric]
# @return Concentratietijd (=maat voor de vertraging tussen de neerslag en afvoer) (uur) [numeric]
# @example Tc(L=5.25, bmax=65, i=1.2/1000)
Tc <- function(L, bmax, i) {
  res <- L^0.8 * (bmax+25)^0.7 / (150*sqrt(i))
  return(res)
}

# @param tn Duur van de bui (uur) [numeric]
# @param tc concentratietijd (uur), zie functie Tc() [numeric]
# @return Tijdbasis van de afvoergolf (uur) [numeric]
# @example Tb(tn=6, tc=16.9)
Tb <- function(tn, tc) {
  return(1.33*tn + 1.6*tc)
}

# @param tb Tijdbasis van de afvoergolf (uur) [numeric]
# @return De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer [uur]
Tpiek <- function(tb) {
  return(3/8*tb)
}

# @param qeff afgevoerde hoeveelheid (mm), zie functie Qeff() [numeric]
# @param tb tijdbasis van de afvoergolf (uur), zie functie Tb() [numeric]
# @return Hoogte van de piekafvoer (mm/uur) [numeric]
# @example Qpiek(qeff <- 13.4, tb=35.0)
Qpiek <- function(qeff, tb) {
  return(2*qeff/tb)
}

#' Bereken Tpiek, Qpiek, TN en Q
#'
#' @param x named vector with (bmax, L, i)
#' @param df \code{\link{Extreme_buien_table}}
#' @details * bmax: Globale schatting van de totale maximale berging (mm)
#' @details * L: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
#' @details * i: Gemiddelde terreinheilling van het stroomgebied (m/m).
#' @return Tpiek, Qpiek, TN en Q (named vector)
#' @details * Tpiek: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
#' @details * Qpiek: Hoogte van de maximale piekafvoer (mm/uur).
#' @details * TN: Duur van de bui (uur).
#' @details * Q: Hoeveelheid neerslag in de bui (mm).
# @export
.Qpiek_100jr <- function(x, df = Extreme_buien_table) {
  if (any(is.na(x))) {
    res <- c(Tpiek = NA, Qpiek = NA, TN=NA, Q=NA)
  } else {
    res <- Qpiek_table_100jr(df, x['bmax'], x['L'], x['i']) |> dplyr::slice(which.max(Qpiek))
    res <- c(Tpiek = res[1, ]$Tpiek, Qpiek = res[1, ]$Qpiek, TN=res[1, ]$TN, Q=res[1, ]$Q)
  }
  #res <- res[1,]$Tpiek
  return(res)
}

# Exported functions ***********************************************************

#' Maak kaart (SpatRaster) van de globale schatting van de totale maximale berging (mm).
#'
#' @param r Spatraster met layers bofek, landgebruik, gws, tijdstip, buisdrainage, gt, retentie
#' @param df1 Bmax_table
#' @param df2 Bbovengronds_table
#' @param df3 Bmax_onbegroeid_table
#' @return Kaart (SpatRaster) van de globale schatting van de totale maximale berging (mm).
#' @details \code{\link{r_ex}}
#' @examples
#' \dontrun{ terra::rast(r_ex) |> Bmax()}
#' @export
Bmax <- function(r, df1 = Bmax_table,
                 df2 = Bbovengronds_table,
                 df3 = Bmax_onbegroeid_table) {
  n <- parallelly::availableCores()
  print(paste(n, 'cores detected. Using', n - 1))
  res <- terra::app(x=r, fun=.Bmax, df1=df1, df2=df2, df3=df3, cores = n-1)
  return(res)
}

#' Bereken tabel met piekafvoer parameters bij een herhalingstijd van 100 jaar.
#'
#' @param df Extreme_buien_table
#' @param bmax Globale schatting van de totale maximale berging (mm). Zie functie Bmax().
#' @param L Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
#' @param i Gemiddelde terreinheilling van het stroomgebied (m/m).
#' @returns data.frame met kolommen: FREQ, TN, Q, Qeff, Ba, Tb, Tpiek, Qpiek.
#' @details * FREQ: Frequentie: ... keer per jaar (-).
#' @details * TN: Duur van de bui (uur).
#' @details * Q: Hoeveelheid neerslag in de bui (mm).
#' @details * Qeff: Afgevoerde hoeveelheid (mm).
#' @details * Ba: Benutte berging tijdens afvoer (mm).
#' @details * Tb: Tijdbasis van de afvoergolf (uur).
#' @details * Tpiek: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
#' @details * Qpiek: Hoogte van de piekafvoer (mm/uur).
#' @examples
#' Qpiek_table_100jr(bmax=30, L=1, i=1/2000)
#' @export
Qpiek_table_100jr <- function(df=Extreme_buien_table, bmax, L, i) {
  df %<>% dplyr::filter(FREQ==0.01)
  df <-cbind( df, do.call("rbind", apply(as.array(df$Q), MARGIN=1, FUN=Qeff, bmax=bmax)) )
  tc <- Tc(L, bmax, i)
  df$Tb <- unlist(Map(Tb, df$TN, tc))
  df$Tpiek <- unlist(Map(f=Tpiek, df$Tb))
  df$Qpiek <- unlist(Map(f=Qpiek, df$Qeff, df$Tb))
  return(df)
}

#' Bereken Tpiek, Qpiek, TN en Q (Spatrasters).
#'
#' @param r Spatraster met layers bmax, L, i
#' @param df \code{\link{Extreme_buien_table}}
#' @details * bmax: Globale schatting van de totale maximale berging (mm)
#' @details * L: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
#' @details * i: Gemiddelde terreinheilling van het stroomgebied (m/m).
#' @details * TN: Duur van de bui (uur).
#' @details * Q: Hoeveelheid neerslag in de bui (mm).
#' @return Spatraster met layers Tpiek, Qpiek, TN en Q
#' @examples
#' \dontrun{
#' bmax <- terra::rast(r_ex) |> Bmax()
#' of: bmax <- file.path("data-raw", "example_data", "rasters", "bmax.tif") |> terra::rast()
#' names(bmax) <- "bmax"
#' r <- c(terra::rast(r_ex), bmax)
#' r_Qpiek_100jr <- r |> Qpiek_100jr() }
#' @export
Qpiek_100jr <- function(r, df = Extreme_buien_table) {
  n <- parallelly::availableCores()
  print(paste(n, 'cores detected. Using', n - 1))
  res <- terra::app(x=r, fun=.Qpiek_100jr, df=df, cores = n-1)
  return(res)
}




