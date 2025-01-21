% Package 'scsnl'  

<!-- badges: start -->
<!-- badges: end -->

Schatting van piekafvoer in vrij afwaterende gebieden in Nederland met de SCS-methode (Grondwaterzakboekje 2016 p. 119-124). De berekening kan worden gedaan op puntniveau, resulterend in een tabel. 

Als raster-kaarten beschikbaar zijn van alle invoer parameters dan kan de piekafvoer
ook vlakdekkend worden berekend.

![](https://github.com/user-attachments/assets/f259c809-3570-4cf7-8064-565d0f4b1f0a)
![](https://github.com/user-attachments/assets/97c327f8-72b2-49b1-83f0-92528b7a1b56)

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
    * `Tc`: Concentratietijd (=maat voor de vertraging tussen de neerslag en afvoer) (uur).
    * `Tb`: Tijdbasis van de afvoergolf (uur).
    * `Q`: Hoeveelheid neerslag in de bui (mm).
    * `Qeff`: Afgevoerde hoeveelheid (mm).
    * `Ba`: Benutte berging tijdens afvoer (mm).
    * `Tb`: Tijdbasis van de afvoergolf (uur).
    * `Tpiek`: De tijd vanaf het begin van de bui tot aan het optreden van de piekafvoer (uur).
    * `Qpiek`: Qpiek: Hoogte van de piekafvoer (mm/uur).
* `Qpiek_100jr()`: Maak kaarten (SpatRasters) van Tpiek, Qpiek, TN en Q. Optioneel kan TN als input worden opgegeven. In dat geval worden piekafvoeren berekend bij een duur van de bui TN (uur).
  * Input:
    * Spatraster met layers bmax, L, i, TN (optioneel). Toelichting: zie hierboven.
  * Output:
    * Spatraster met layers Tpiek, Qpiek, TN, Tc, Tb en Q (zie hierboven).

* `Qfun()`: Maak een list van functies waarmee per rasterpunt de afvoer kan worden berekend (mm/u).
  * Input:
    * `x`: Spatraster met (named) layers Tpiek, Qpiek, Tb. Toelichting: zie hierboven.
  * Output:
    * List van functies waarmee per rasterpunt de afvoer (mm/u) kan worden berekend als functie van de tijd (uur).

    
## Datasets

* `r_ex`: Example input SpatRaster with layers of the Beerze region (Netherlands). Used as: `r_ex <- file.path( find.package("scsnl"), "extdata", "r_ex.tif") |> terra::rast()`
* `Bmax_table`: Eerste schatting van de maximale bodemberging (mm) met en zonder drainage.
* `Bbovengronds_table`: Globale schatting van de maximale berging in/op onbegroeide bodem.
* `Bmax_onbegroeid_table`: Globale schatting van de maximale berging in/op onbegroeide bodem.
* `Extreme_buien_table`: Frequentieverdeling van extreme buien.
* `Extreme_afvoer_table`: Globale relatie tussen de herhalingstijd en de *relatieve* extreme afvoer in Nederland (ten opzichte van de afvoer 1x per jaar).

## Constanten

* `clandgebruik`: Landgebruik codes.

## Voorbeelden

In Rstudio kan als volgt meer informatie over deze package worden verkregen:

``` r
library(scsnl)
?scsnl

```


[image](https://github.com/user-attachments/assets/35d2319c-ec2a-4768-a20a-f57d39a85d55)


