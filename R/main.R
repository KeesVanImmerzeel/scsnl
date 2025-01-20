# Internal functions ###########################################################

# Bepaal het aantal cores dat gebruikt gaat worden voor parallelle berekeningen
#
# @param max_ncores Maximum  aantal gebruikte cores [numeric]
# @return Aantal cores dat gebruikt gaat worden voor parallelle berekeningen [-]
ncores <- function(max_ncores = 8) {
  n <- parallel::detectCores()
  n <- max(min(n - 1, max_ncores), 1)
  print(paste("Cores used:", n))
  return(n)
}

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
  df <- data.frame(Qeff = NA, Ba = NA)
  if (any(is.na(Q), is.na(bmax))) {
    return(df)
  }
  Bi <- 0.2 * bmax # Initele benutte berging zonder afvoer (mm)
  if (Q > Bi) {
    res <- (Q - Bi) ^ 2 / (Q + 0.8 * bmax)
    Ba <- bmax * (Q - Bi) / (Q + 0.8 * bmax) # Benutte berging tijdens afvoer (mm)
    Ba <- min(Ba, bmax)
  } else {
    res <- 0
  }
  df <- data.frame(Qeff = res, Ba = Ba)
  return(df)
}

# @param L Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
# @param bmax: zie hierboven [numeric]
# @param i Gemiddelde terreinheilling van het stroomgebied (m/m). [numeric]
# @return Concentratietijd (=maat voor de vertraging tussen de neerslag en afvoer) (uur) [numeric]
# @example get_Tc(L=5.25, bmax=65, i=1.2/1000)
get_Tc <- function(L, bmax, i) {
  res <- L^0.8 * (bmax+25)^0.7 / (150*sqrt(i))
  return(res)
}

# @param tn Duur van de bui (uur) [numeric]
# @param tc concentratietijd (uur), zie functie get_Tc() [numeric]
# @return Tijdbasis van de afvoergolf (uur) [numeric]
# @example get_Tb(tn=6, tc=16.9)
get_Tb <- function(tn, tc) {
  return(1.33*tn + 1.6*tc)
}

# @param qeff afgevoerde hoeveelheid (mm), zie functie Qeff() [numeric]
# @param tb tijdbasis van de afvoergolf (uur), zie functie Tb() [numeric]
# @return Hoogte van de piekafvoer (mm/uur) [numeric]
# @example Qpiek(qeff <- 13.4, tb=35.0)
Qpiek <- function(qeff, tb) {
  return(2*qeff/tb)
}

#' Bereken Tpiek, Qpiek, Q en (optioneel) TN behorende bij een bui met een herhalingstijd van 1/100 jaar.
#'
#' @param x named vector with (bmax, L, i en optioneel TN)
#' @param df \code{\link{Extreme_buien_table}}
#' @details * bmax: Globale schatting van de totale maximale berging (mm)
#' @details * L: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
#' @details * i: Gemiddelde terreinheilling van het stroomgebied (m/m).
#' @details * TN: (optioneel) Duur van de bui (uur). Als gebruikt als invoer, moet TN voorkomen in de tabel 'Extreme_buien_table'.
#' @details *     Als TN niet is gespecificeerd, dan wordt de tijdsduur TN opgezocht die leidt tot de grootste piekafvoer (Qpiek).
#' @return Tpiek, Qpiek, TN en Q (named vector)
#' @details * Tpiek: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
#' @details * Qpiek: Hoogte van de maximale piekafvoer (mm/uur).
#' @details * Tc: Concentratietijd (=maat voor de vertraging tussen de neerslag en afvoer) (uur)
#' @details * Tb: Tijdbasis van de afvoergolf (uur)
#' @details * Q: Hoeveelheid neerslag gedurende een bui met de duur TN (uur), (mm).
# @export
.Qpiek_100jr <- function(x, df = Extreme_buien_table) {
  res <- c(
    Tpiek = NA,
    Qpiek = NA,
    TN = NA,
    Tc = NA,
    Tb = NA,
    Q = NA
  )
  if (is.na(x['TN'])) {
    #TN not specified so TN with max Qpiek is selected.
    if (all(!is.na(x))) {
      res <- Qpiek_table_100jr(df, x['bmax'], x['L'], x['i']) |> dplyr::slice(which.max(Qpiek))
      res <- c(
        Tpiek = res[1, ]$Tpiek,
        Qpiek = res[1, ]$Qpiek,
        TN = res[1, ]$TN,
        Tc = res[1, ]$Tc,
        Tb = res[1, ]$Tb,
        Q = res[1, ]$Q
      )
    }
  } else {
    #TN is specified. Corresponding Qpiek is selected.
    if (all(!is.na(x))) {
      res <- Qpiek_table_100jr(df, x['bmax'], x['L'], x['i']) |> dplyr::filter(TN ==
                                                                                 x['TN'])
      if (nrow(res) == 1) {
        res <- c(
          Tpiek = res[1, ]$Tpiek,
          Qpiek = res[1, ]$Qpiek,
          TN = res[1, ]$TN,
          Tc = res[1, ]$Tc,
          Tb = res[1, ]$Tb,
          Q = res[1, ]$Q
        )
      }
    }
  }
  #print(names(res))
  return(res)
}

# @param tb Tijdbasis van de afvoergolf (uur) [numeric]
# @return De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer [uur]
Tpiek <- function(tb) {
  return(3/8*tb)
}

#' Afvoer (mm/u) op tijdstip t (uur).
#'
#' @param x Named vector with Tpiek, Qpiek, Tb
#' @param t Tijd (uur)
#' @details * Tpiek: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
#' @details * Qpiek: Hoogte van de maximale piekafvoer (mm/uur).
#' @details * Tb: Tijdbasis van de afvoergolf (uur)
#' @return Afvoer (mm/uur) op tijdstip t (uur)
#' @examples
#' \dontrun{
#' x <- c(Tpiek=2.5, Qpiek=2, Tb=5)
#' t <- seq(0,5,0.5)
#' .afv(x, t)
#' }
#'
.afv <- function(x, t) {
  if (any(is.na(x['Tpiek']), is.na(x['Qpiek']), is.na(x['Tb']))) {
    return(NA)
  }
  res <- stats::approx(x=c(0, x['Tpiek'], x['Tb']), y=c(0, x['Qpiek'], 0 ), xout=t, method="linear", rule=2:2)
  return(res$y)
}

# Exported functions ***********************************************************

#' Relatieve extreme afvoer (-) bij herhalingstijd van T (x per jaar)
#'
#' t.o.v. de extreme afvoer bij een herhalingstijd van eens per 100 jaar (T=0.01).
#' @param T Herhalingstijd T (x per jaar)
#' @return Relatieve afvoer (-) bij herhalingstijd van T (x per jaar).
#' @examples
#' T <- 10    # 14 keer per jaar
#' rel_afv(T) # Afvoer t.o.v. de afvoer van eens per 100 jaar (T=0.01)
#' @source <GWZ tabel 10.6 p. 118> {grondwaterzakboekje}
#' @export
rel_afv <- function(T) {
  x <- log(Extreme_afvoer_table$FREQ)
  y <- Extreme_afvoer_table$REAFV
  stats::approx(x, y, xout=log(T), rule=1:1)$y / stats::approx(x, y, xout=log(0.01), rule=1:1)$y
}

#' Maak kaart (SpatRaster) van de globale schatting van de totale maximale berging (mm).
#'
#' @param r Spatraster met layers bofek, landgebruik, gws, tijdstip, buisdrainage, gt, retentie
#' @param df1 Bmax_table
#' @param df2 Bbovengronds_table
#' @param df3 Bmax_onbegroeid_table
#' @return Kaart (SpatRaster) van de globale schatting van de totale maximale berging (mm).
#' @examples
#' \dontrun{
#' r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()
#' bmax <- r_ex |> Bmax()}
#' @export
Bmax <- function(r, df1 = Bmax_table,
                 df2 = Bbovengronds_table,
                 df3 = Bmax_onbegroeid_table) {
  n <- parallel::detectCores()
  n <- max(min(n - 1, 8), 1)
  print(paste("Cores used:", n))
  res <- terra::app(x=r, fun=.Bmax, df1=df1, df2=df2, df3=df3, cores = n)
  names(res) <- "bmax"
  return(res)
}

#' Bereken tabel met piekafvoer parameters bij een herhalingstijd van 1/100 jaar.
#'
#' @param df Extreme_buien_table
#' @param bmax Globale schatting van de totale maximale berging (mm, SpatRaster). Zie functie Bmax().
#' @param L Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
#' @param i Gemiddelde terreinheilling van het stroomgebied (m/m).
#' @returns data.frame met kolommen: FREQ, TN, Q, Qeff, Ba, Tb, Tpiek, Qpiek.
#' @details * FREQ: Frequentie: ... keer per jaar (-).
#' @details * TN: Duur van de bui (uur).
#' @details * Q: Hoeveelheid neerslag in de bui (mm).
#' @details * Qeff: Afgevoerde hoeveelheid (mm).
#' @details * Ba: Benutte berging tijdens afvoer (mm).
#' @details * Tb: Tijdbasis van de afvoergolf (uur).
#' @details * Tc: Concentratietijd (=maat voor de vertraging tussen de neerslag en afvoer) (uur)
#' @details * Tpiek: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
#' @details * Qpiek: Hoogte van de piekafvoer (mm/uur).
#' @examples
#' Qpiek_table_100jr(bmax=30, L=1, i=1/2000)
#' @export
Qpiek_table_100jr <- function(df=Extreme_buien_table, bmax, L, i) {
  df %<>% dplyr::filter(FREQ==0.01)
  df <-cbind( df, do.call("rbind", apply(as.array(df$Q), MARGIN=1, FUN=Qeff, bmax=bmax)) )
  df$Tc <- unlist(Map(f=get_Tc, L, bmax, i))
  df$Tb <- unlist(Map(f=get_Tb, df$TN, df$Tc))
  df$Tpiek <- unlist(Map(f=Tpiek, df$Tb))
  df$Qpiek <- unlist(Map(f=Qpiek, df$Qeff, df$Tb))
  return(df)
}

#' Bereken Tpiek, Qpiek, TN Tc, Tb en Q (Spatrasters) behorende bij een bui met een herhalingstijd van 1/100 jaar.
#'
#' @param r Spatraster met layers bmax, L, i
#' @param TN Duur van de bui (uur). Optionele input. [numeric]
#' @param df \code{\link{Extreme_buien_table}}
#' @details Optioneel kan TN als input worden opgegeven. In dat geval worden piekafvoeren berekend bij een duur van de bui TN (uur).
#' @details De opgegeven waarde van TN moet voorkomen in de kolom 'TN' van de tabel 'Extreme_buien_table'.
#' @details * bmax: Globale schatting van de totale maximale berging (mm)
#' @details * L: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
#' @details * i: Gemiddelde terreinheilling van het stroomgebied (m/m).
#' @details * TN: (optioneel) Duur van de bui (uur). Als gebruikt als invoer, moet TN voorkomen in de tabel 'Extreme_buien_table'.
#' @details *     Als TN niet is gespecificeerd, dan wordt de tijdsduur TN opgezocht die leidt tot de grootste piekafvoer (Qpiek).
#' @details * Tc: Concentratietijd (=maat voor de vertraging tussen de neerslag en afvoer) (uur)
#' @details * Tb: Tijdbasis van de afvoergolf (uur)
#' @details * Q: Hoeveelheid neerslag gedurende een bui met de duur TN (uur), (mm).
#' @return Spatraster met layers Tpiek, Qpiek, TN, Tc, Tb en Q
#' @examples
#' \dontrun{
#' r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()
#' bmax <- r_ex |> Bmax()
#'
#' of direct:
#' bmax <- file.path(find.package("scsnl"), "extdata", "bmax.tif") |> terra::rast()
#'
#' r_Qpiek_100jr <- c(bmax, r_ex$L, r_ex$i) |> Qpiek_100jr()
#'
#' of
#'
#' r_Qpiek_100jr <- c(bmax, r_ex$L, r_ex$i) |> Qpiek_100jr(TN=2)}
#' @export
Qpiek_100jr <- function(r, TN = NULL, df = Extreme_buien_table) {
  if (!is.null(TN)) {
    x <- r$L
    values(x) <- TN
    names(x) <- "TN"
    r <- c(r, x)
  }
  res <- terra::app(
    x = r,
    fun = .Qpiek_100jr,
    df = df,
    cores = ncores()
  )
  return(res)
}

#' Maak spatraster(s) van de afvoer (mm/u) op tijdstip t (uur).
#'
#' @param r Spatraster met layers Tpiek, Qpiek, Tb (bij herhalingstijd van 1/100 jaar)
#' @param t Tijd (uur) [numeric]
#' @details * Tpiek: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
#' @details * Qpiek: Hoogte van de maximale piekafvoer (mm/uur).
#' @details * Tb: Tijdbasis van de afvoergolf (uur)
#' @return Spatraster met de afvoer (mm/u) op tijdstip t (uur).
#' @examples
#' \dontrun{
#' r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()
#' bmax <- r_ex |> Bmax()
#'
#' of direct:
#' bmax <- file.path(find.package("scsnl"), "extdata", "bmax.tif") |> terra::rast()
#'
#' Bereken Spatraster met layers Tpiek, Qpiek, TN, Tc, Tb en Q waarbij:
#'   herhalingstijd 1/100 jaar, duur van de bui TN=2 uur.
#' r_ex$i <- mean(terra::values(r_ex$i), na.rm=TRUE)
#' r <- c(bmax, r_ex$L, r_ex$i)
#' r100 <- r |> Qpiek_100jr(TN=2)
#'
#' of direct:
#' r100 <-  file.path(find.package("scsnl"), "extdata", "Qpiek_100jrTN2uur.tif") |> terra::rast()
#'
#' Bereken de afvoer na t=5 uur van een bui met een duur van TN=2 uur en een
#' Herhalingstijd van 1/100 jaar.
#' afv_T100_5uur <- afv(r=c(r100$Tpiek, r100$Qpiek, r100$Tb), t=5)
#'
#' Idem, bij een herhalingstijd van 1/10 jaar (i.p.v. 1/100 jaar)
#' afv_T10_5uur <- afv_T100_5uur * rel_afv(T=1/10)
#'
#' Bereken afvoer voor een aantal tijdstippen en bewaar het resultaat in 1 Spatraster.
#' Herhalingstijd van 1/100 jaar, bui met een duur van TN=2 uur.
#' times <- t_default(r100$Tpiek)
#' Qafv_100jrTN2uur <- lapply(as.array(times), FUN=afv, r=r100) |> terra::rast()
#' fnames <- paste0(names(Qafv_100jrTN2uur),".tif")
#' r_mask <- file.path(find.package("scsnl"), "extdata", "projectgebied.tif") |> terra::rast()
#' Qafv_100jrTN2uur <- r_mask * Qafv_100jrTN2uur
#' names(Qafv_100jrTN2uur) <-paste0("Qafv_100jrTN2uur_t=", times)
#' Qafv_100jrTN2uur |> terra::writeRaster(fnames)
#'   }
#' @export
afv <- function(t, r) {
  cat("Bereken afvoeren t=", t, "uur.")
  terra::app(r,
             fun = .afv,
             t = t,
             cores = ncores())
}

#' Suggestie voor uitvoertijden (u)
#'
#' @param r Spatraster met het tijdtip van de piekafvoeren Tpiek (u).
#' @param prc Percentiel waarde van piekafvoeren; prc% van de piekafvoeren is kleiner (-)
#' @return Gesuggereerde uitvoertijden (u) (numeric vector)
#' @examples
#' \dontrun{
#' r100 <-  file.path(find.package("scsnl"), "extdata", "Qpiek_100jrTN2uur.tif") |> terra::rast()
#' t <- t_default(r100$Tpiek)
#' }
#' @export
t_default <- function(r, prc=0.95) {
  x <- graphics::hist(terra::values(r), plot=FALSE)
  i <- which(cumsum(x$density)< prc)
  sort(c(x$breaks[i], x$mids[i]))
}
# x <- hist(terra::values(r100$Tpiek), plot=FALSE)
# i <- which(cumsum(x$density)<0.95)
# c(x$breaks[i], x$mids[i])
