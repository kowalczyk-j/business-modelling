set PRODUCENCI;
set MAGAZYNY;
set WARZYWA;
set SKLEPY;

param koszt_tona_km >= 0;
param t 			>= 0;	# liczba tygodni w roku
param max_roczna_prod 		{PRODUCENCI, WARZYWA} 	>= 0;
param max_pojemnosc_mag 	{MAGAZYNY} 				>= 0;
param max_pojemnosc_sklep 	{SKLEPY} 				>= 0;
param odleglosc_mag_prod 	{MAGAZYNY, PRODUCENCI} 	>= 0;
param odleglosc_mag_sklep 	{MAGAZYNY, SKLEPY} 		>= 0;
param tygodniowa_sprzedaz 	{WARZYWA, SKLEPY, 1..t} >= 0;

var roczny_transport_prod_mag {PRODUCENCI, MAGAZYNY, WARZYWA} 		 >= 0;
var tygodniowy_transport_mag_sklep {MAGAZYNY, WARZYWA, SKLEPY, 1..t} >= 0;
var tygodniowy_magazyn_sklepow {WARZYWA, SKLEPY, 1..t} 				 >= 0;


# Funkcja kosztu - ³¹czny koszt transportu od producentów poprzez magazyny do sklepów

minimize koszt_transportu:	
	sum {p in PRODUCENCI, m in MAGAZYNY, w in WARZYWA}
   		odleglosc_mag_prod[m,p] * koszt_tona_km * roczny_transport_prod_mag[p,m,w]
	+ sum {m in MAGAZYNY, w in WARZYWA, s in SKLEPY, n in 1..t}
   		odleglosc_mag_sklep[m,s] * koszt_tona_km *  tygodniowy_transport_mag_sklep[m, w, s, n];
   		
   		
# Ograniczenia odnoœnie transportu warzyw od Producentów do Magazynów

subject to Transport_prod_mag_niewiekszy_niz_max_pojemnosc_magazynow {m in MAGAZYNY}:
	sum {p in PRODUCENCI, w in WARZYWA} roczny_transport_prod_mag[p, m, w] <= max_pojemnosc_mag[m];

subject to Transport_prod_mag_niemniejszy_niz_zapotrzebowanie_sklepow {m in MAGAZYNY, w in WARZYWA}:
	sum {p in PRODUCENCI} roczny_transport_prod_mag[p, m, w] >= sum {s in SKLEPY, n in 1..t}
																tygodniowy_transport_mag_sklep[m, w, s, n];

subject to Tranpsort_prod_mag_niewiekszy_niz_produkcja_producentow {p in PRODUCENCI, w in WARZYWA}:
	sum {m in MAGAZYNY} roczny_transport_prod_mag[p, m, w] <= max_roczna_prod[p, w];

    
# Ograniczenia odnoœnie magazynów przysklepowych

subject to Transport_niewiekszy_niz_pojemnosc_magazynow_sklepow {s in SKLEPY, n in 1..t}:
	sum {m in MAGAZYNY, w in WARZYWA} tygodniowy_transport_mag_sklep[m, w, s, n] <= max_pojemnosc_sklep[s];
 
subject to Ilosc_warzyw_w_magazynach_sklepow_w_1wszym_tyg {s in SKLEPY, w in WARZYWA}:
	tygodniowy_magazyn_sklepow[w, s, 1] = sum {m in MAGAZYNY} tygodniowy_transport_mag_sklep[m, w, s, 1]
	-tygodniowa_sprzedaz[w, s, 1];

subject to Ilosc_warzyw_w_magazynach_sklepow {w in WARZYWA, s in SKLEPY, n in 2..t}:
	tygodniowy_magazyn_sklepow[w, s, n] = tygodniowy_magazyn_sklepow[w, s, n-1] - tygodniowa_sprzedaz[w, s, n]
	+ sum {m in MAGAZYNY} tygodniowy_transport_mag_sklep[m, w, s, n];

subject to Ograniczona_pojemnosc_magazynow_sklepow {s in SKLEPY, n in 1..t}:
	sum {w in WARZYWA} tygodniowy_magazyn_sklepow[w, s, n] <= max_pojemnosc_sklep[s];
	
subject to Minimalny_10procentowy_zapas_warzyw_w_sklepach {w in WARZYWA, s in SKLEPY, n in 1..t}:
	tygodniowy_magazyn_sklepow[w, s, n] >= 0.1 * tygodniowa_sprzedaz[w, s, n];