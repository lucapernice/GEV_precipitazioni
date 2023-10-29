
## Panoramica

Questo file README fornisce un'illustrazione del codice R utilizzato per l'analisi esplorativa e fit dei modelli sui dati nel dataset Gemona. Il codice si concentra sull'analisi e la modellazione di quattro serie temporali meteorologiche: precipitazioni massime orarie, temperature medie mensili, umidità relativa media mensile e velocità media del vento mensile. Questi dati sono stati ottenuti dalla piattaforma del Sistema nazionale per l’elaborazione e diffusione di dati climatici disponibile su [scia.isprambiente.it](http://www.scia.isprambiente.it). Le osservazioni coprono il periodo dal 01/2000 al 12/2018 e sono state registrate presso la stazione meteorologica di Gemona del Friuli (Udine).

## Librerie Richieste

Il codice utilizza diverse librerie di R per eseguire analisi e modellazione avanzate:
- `ggplot2`: Per la visualizzazione dei dati.
- `ggfortify`: Per arricchire le funzionalità di ggplot2.
- `tseries`: Per l'analisi delle serie temporali.
- `evd`: Per le distribuzioni dei valori estremi.
- `extRemes`: Per la modellazione dei valori estremi.

Assicurarsi di installare queste librerie prima di eseguire il codice.

## Importazione dei Dati

Il codice inizia importando i dati meteorologici dalla piattaforma del Sistema nazionale per l’elaborazione e diffusione di dati climatici. I dati sono costituiti da quattro serie temporali: precipitazioni massime orarie, temperature medie mensili, umidità relativa media mensile e velocità media del vento mensile. Vengono estratte le osservazioni dal 01/2000 al 12/2018 dalla stazione meteorologica di Gemona del Friuli.

## Esplorazione dei Dati

Il codice esegue una serie di analisi esplorative dei dati, compresi controllo dei valori mancanti, visualizzazioni e analisi delle serie temporali. Vengono presentati grafici di box plot, funzioni di autocorrelazione e altri grafici descrittivi per comprendere meglio la natura dei dati.

## Preparazione dei Dati di Allenamento e Test

Il codice prepara i dati per l'allenamento e il test, separando i dati precedenti al 2018 per l'allenamento e i dati del 2018 per il test. Vengono anche calcolate variabili aggiuntive legate al giorno dell'anno e alle trasformazioni seno/coseno delle variabili temporali.

## Modelli e Calcolo delle Verosimiglianze

Il codice definisce e adatta diversi modelli ai dati di allenamento, inclusi modelli con parametri mensili, trasformazioni seno/coseno delle variabili temporali e variabili meteorologiche aggiuntive. Vengono calcolate le verosimiglianze dei dati osservati dati i parametri stimati dai modelli.

## Grafici dei Livelli di Ritorno

Infine, il codice genera grafici dei livelli di ritorno e grafici quantile-quantile per visualizzare la distribuzione dei valori estremi e confrontare i diversi modelli.

Si tenga presente che il codice è stato sviluppato specificamente come supporto per una presentazione e può essere utilizzato come punto di partenza per ulteriori analisi o modellazioni. Tutte le analisi si basano sui dati meteorologici affidabili dalla stazione meteorologica di Gemona del Friuli registrati nel periodo specificato.
