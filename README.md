# F1 Strategy Analytics: Pit Stop & Lap Time Prediction

## O projekcie
Projekt zrealizowany w ramach przedmiotu Pracownia Analizy Danych. Analiza opiera się na rzeczywistych danych pomiarowych ze strategii wyścigowych Formuły 1 (sezony 2022-2025). Celem jest wykorzystanie metod uczenia maszynowego i modelowania matematycznego do przewidywania kluczowych decyzji i zjawisk na torze.

## Struktura Repozytorium

Rozważone zostały dwa główne scenariusze analityczne, podzielone na osobne skrypty:

### 1. Przewidywanie zjazdów do boksu (`pit_stop_prediction.R`)
* **Zmienna celu:** `PitNextLap` (Klasyfikacja binarna)
* **Opis:** Przewidywanie, czy kierowca zjedzie do alei serwisowej na następnym okrążeniu, biorąc pod uwagę m.in. wiek opony i jej zużycie.
* **Modele:** * Regresja Logistyczna (model bazowy), 
  * Kwadratowa Analiza Dyskryminacyjna (QDA - dopasowana do asymetrycznych klas), 
  * Naiwny Klasyfikator Bayesowski (z wykorzystaniem jądrowej estymacji gęstości KDE).

### 2. Analiza spadku tempa wyścigowego (`lap_time_prediction.R`)
* **Zmienna celu:** `LapTime_Delta` (Regresja)
* **Opis:** Szacowanie degradacji opon i jej wpływu na spadek tempa wyścigowego z pominięciem różnic sprzętowych między bolidami.
* **Modele:** * Wieloraka Regresja Liniowa (z interakcjami), 
  * Regresja na Składowych Głównych (PCR - jako rozwiązanie problemu współliniowości predyktorów), 
  * Ważony k-Najbliższych Sąsiadów (wkNN - do modelowania nieliniowych spadków przyczepności).

## Zbiór Danych
* **Plik:** `f1_strategy_dataset_v4.csv`
* **Zawartość:** Ponad 100 000 obserwacji zawierających m.in. informacje o mieszance opon (`Compound`), wieku opony (`TyreLife`), skumulowanej degradacji (`Cumulative_Degradation`) oraz pozycji na torze.

## Autor
Julia Estkowska i Maja Zontek | Wydział Matematyki, Fizyki i Informatyki UG
