---
Title:    Package 'scsnl'  
Author:   C.H. van Immerzeel  
Date:     september 26, 20224
---

# scsnl

<!-- badges: start -->
<!-- badges: end -->

Schatting van piekafvoer in vrij afwaterende gebieden in Nederland met de SCS-methode (Grondwaterzakboekje 2016 p. 119-124). De berekening kan worden gedaan op puntniveau, resulterend in een tabel. 

Als raster-kaarten beschikbaar zijn van alle invoer parameters dan wordt de piekafvoer vlakdekkend berekend.

## Installatie

`install_github("KeesVanImmerzeel/scsnl")`

## Functies

* `Bmax()`: Maak kaart (SpatRaster) van de globale schatting van de totale maximale berging (mm). 
  * Input: spatraster met layers bofek-code, landgebruik, grondwaterstand, tijdstip (einde zomer of einde winter), buisdrainage (ja/nee), grondwatertrap, retentie.
* `Qpiek_table_100jr()`: Bereken tabel met piekafvoer parameters bij een herhalingstijd van 100 jaar. 
  * Input:
    * `bmax`: Globale schatting van de totale maximale berging (mm).
    * `L`: Afgelegde weg van een waterdeeltje, vanuit het verste punt van het stroomgebied tot aan het rekenpunt (km)
    * `i`: Gemiddelde terreinheilling van het stroomgebied (m/m).
  * Output: tabel met kolommen:
    * `FREQ`: Frequentie: ... keer per jaar (-).
    * `TN`: Duur van de bui (uur).
    * `Q`: Hoeveelheid neerslag in de bui (mm).
    * `Qeff`: Afgevoerde hoeveelheid (mm).
    * `Ba`: Benutte berging tijdens afvoer (mm).
    * `Tb`: Tijdbasis van de afvoergolf (uur).
    * `Tpiek`: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
    * `Qpiek`: Qpiek: Hoogte van de piekafvoer (mm/uur).
* `Qpiek_100jr()`: Maak kaarten (SpatRasters) vanTpiek, Qpiek, TN en Q.
  * Input:
    * Spatraster met layers bmax, L, i (zie hierboven).
  * Output:
    * Spatraster met layers Tpiek, Qpiek, TN en Q (zie hierboven).
    
## Datasets

* `r_ex`: Example input SpatRaster with layers of the Beerze region (Netherlands).
* `Bmax_table`: Eerste schatting van de maximale bodemberging (mm) met en zonder drainage.
* `Bbovengronds_table`: Globale schatting van de maximale berging in/op onbegroeide bodem.
* `Bmax_onbegroeid_table`: Globale schatting van de maximale berging in/op onbegroeide bodem.
* `Extreme_buien_table`: Frequentieverdeling van extreme buien.
* `Extreme_afvoer_table`: Globale relatie tussen de herhalingstijd en de *relatieve* extreme afvoer in Nederland (ten opzichte van de afvoer 1x per jaar).

## Constanten

* `clandgebruik`: Landgebruik codes.

## Voorbeelden

Voor meer informatie:

``` r
library(scsnl)
?scsnl

```

