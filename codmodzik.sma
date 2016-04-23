#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <csx>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <xs>
#include <nvault>
#include <fakemeta_util>
#include <ColorChat>
#include <ks>

#define STANDARDOWA_SZYBKOSC 230.0
#define ZADANIE_POKAZ_INFORMACJE 672
#define ZADANIE_WSKRZES 704
#define ZADANIE_WYSZKOLENIE_SANITARNE 736
#define ZADANIE_USTAW_SZYBKOSC 832
#define MAXEXP 782395

#define FL_WATERJUMP    (1<<11)
#define FL_ONGROUND     (1<<9)

new gmsgStatusText, sprite, czas, CzasBlokady, g_vault, blood, blood2, sprite_white, sprite_blast, SpadochronDetach, szClip, szAmmo
new g_msgHostageAdd, g_msgHostageDel, g_maxplayers, g_msg_screenfade, bool:freezetime = true;
new ilosc_blyskawic[33], poprzednia_blyskawica[33], queston[33], killquest[33], ile_nozy[33], g_hasZoom[33], oddaj_id[33];

new zoom[33], zoom1[33], zoom2[33], zoom3[33], zoom4[33], zoom5[33], zoom6[33], radar[33], ilosc_min_gracza[33];
new ilosc_dynamitow_gracza[33], ilosc_skokow_gracza[33], ilosc_spadochronow_gracza[33], para_ent[33];
new ranga_gracza[33], poziom_gracza[33] = 1, monety_gracza[33] = 1, modele_gracza[33] = 1;
new player_b_bank[33] = 0, player_b_bankdurability[33]= 0, player_b_bank2[33] = 0, player_b_bankdurability2[33]= 0;
new wytrzymalosc_przedmiotu[33], wytrzymalosc_itemu[33], bool:gracz_resetuje[33], ilosc_apteczek_gracza[33], ilosc_rakiet_gracza[33];
new klasa_gracza[33], doswiadczenie_gracza[33], weaponname[33], nowa_klasa_gracza[33], punkty_gracza[33], zdrowie_gracza[33];
new inteligencja_gracza[33], wytrzymalosc_gracza[33], kamizelka_gracza[33], kondycja_gracza[33], maksymalne_zdrowie_gracza[33], frakcja_gracza[33]
new informacje_przedmiotu_gracza[33][2], informacje_itemu_gracza[33][2], nazwa_gracza[33][64], grawitacja_gracza[33], opcja_wyboru[33];
new noc;
new Float:redukcja_obrazen_gracza[33], Float:szybkosc_gracza[33], Float:poprzednia_rakieta_gracza[33], Float:poprzednia_dynamit_gracza[33];

new const maxAmmo[31]={0,52,0,90,1,32,1,100,90,1,120,100,100,90,90,90,100,120,30,120,200,32,90,120,90,2,35,90,90,0,100};
new nagrodyquest[]={0,5000,5000,5000,5000,20000,20000,15000,8000,8000,8000,8000,32000,32000,15000};
new wymogquest[]={0,5,5,5,5,5,5,20,3,3,3,3,3,3,8}
new Ubrania_CT[4][]={"sas","gsg9","urban","gign"}, Ubrania_Terro[4][]={"arctic","leet","guerilla","terror"};

new const nazwy_rang[][] = {
	"[*] Zolnierz",
	"[**] Szeregowy",
	"[***] St. Szeregowy",
	"[****] Kapral",
	"[!] St. Kapral",
	"[!*] Plutonowy",
	"[!**] St. Plutonowy",
	"[!***] Sierzant",
	"[!****] St. Sierzant",
	"[@] Ml. Chorazy",
	"[@*] Chorazy",
	"[@**] St. Chorazy",
	"[@***] St. Chor. Sztab.",
	"[@****] Podporucznik",
	"[@!] Porucznik",
	"[@!*] Kapitan",
	"[@!**] Major",
	"[@!***] Podpulkownik",
	"[@!****] Pulkownik",
	"[@@] Gen. Brygady",
	"[@@*] Gen. Dywizji",
	"[@@**] Gen. Broni",
	"[@@***] Gen. Wojska",
	"[@@****] General",
	"[@@!] Marszalek",
	"[@@!*] Komandor Podpor.",
	"[@@!**] Komandor Porucz.",
	"[@@!***] Komandor",
	"[@@!****] Kontr-admiral",
	"[@@@] Admiral"	
};

new const nazwy_rang2[][] = {
	"[*]",
	"[**]",
	"[***]",
	"[****]",
	"[#]",
	"[#*]",
	"[#**]",
	"[#***]",
	"[#****]",
	"[@]",
	"[@*]",
	"[@**]",
	"[@***]",
	"[@****]",
	"[@#]",
	"[@#*]",
	"[@#**]",
	"[@#***]",
	"[@#****]",
	"[@@]",
	"[@@*]",
	"[@@**]",
	"[@@***]",
	"[@@****]",
	"[@@#]",
	"[@@#*]",
	"[@@#**]",
	"[@@#***]",
	"[@@#****]",
	"[@@@]"	
};

new const nazwy_przedmiotow[][] = {"Brak", 
	"Buty Szturmowego", //1
	"Podwojna Kamizelka", //2
	"Wzmocniona Kamizelka", //3
	"Weteran Noza", //4
	"Zaskoczenie Wroga", //5
	"Plaszcz Partyzanta", //6 
	"Morfina", //7
	"Noz Komandosa", //8
	"Podwojna kamizelka", //9
	"Oslepienie przeciwnika", //10
	"Notatki Ninji", //11
	"Tajemnica Wojskowa", //12
	"AWP Sniper",//13
	"Adrenalina",//14
	"Tajemnica Rambo",//15
	"Wyszkolenie Sanitarne",//16
	"Kamizelka NASA",//17
	"Wytrenowany Weteran",//18
	"Apteczka",//19
	"Eliminator Rozrzutu",//20
	"Tytanowe Naboje",//21
	"Naboje Pulkownika",//22
	"Ogranicznik Rozrzutu",//23
	"Tarcza SWAT",//24
	"Wytrenowany Rekrut",//25
	"Nanosuit",//26
	"Notatki Kapitana",//27
	"Modul odrzutowy",//28
	"Pas szczesliwca",//29
	"Kamizelka FBI",//30
	"Plastikowa kamizelka",//31
	"Metalowa kamizelka",//32
	"Stalowa kamizelka",//33
	"Rozowa kamizelka",//34
	"Mala paczka kasy",//35
	"Srednia paczka kasy",//36
	"Duza paczka kasy",//37
	"Ogromna paczka kasy",//38
	"Diamentowa paczka kasy",//39
	"Mala grawitacja",//40
	"Srednia grawitacja",//41
	"Duza grawitacja",//42
	"Top Kop",//43
	"Poligonowy wystrzal",//44
	"Urok admina",
	"Zaklecie admina",
	"Duch admina",
	"Rozowe okulary",
	"Oczy szatana",
	"Grosik",//50
	"Pens",
	"Frank",
	"Euro",
	"Dolar",
	"Kamizelka kuloodporna",
	"Worek expa",
	"Sredni worek expa",
	"Duzy worek expa",
	"Ogromny worek expa",
	"Scout Sniper",//60
	"Pomoc druzyny",
	"Tlumik farciarza",
	"Klejnot wroga",
	"Blogoslawienstwo",
	"Nawiedzenie wroga",
	"Opieka boska",
	"Rzeznia kowala",
	"Mocne klejnoty",
	"Sztuka dezorientacji",
	"Odpychajaca sila"//70
};

new const opisy_przedmiotow[][] = {"Zabij kogos aby dostac przedmiot", 
	"Cicho biegasz", 
	"Obniza uszkodzenia zadawane graczowi o LW",
	"Obniza uszkodzenia zadawane graczowi o LW", 
	"Zadajesz wieksze obrazenia nozem",
	"Gdy trafisz kogos od tylu, obrazenia sa 2 razy wieksze", 
	"Masz LW premii niewidocznosci",
	"1/LW szans do ponownego odrodzenia sie po smierci",
	"Natychmiastowe zabicie z Noza",
	"Dostajesz 2x kamizelki na poczatku rundy",//9
	"Dostajesz Flash",//10
	"Mozesz zrobic podwojny skok w powietrzu",
	"Twoje obrazenia sa zredukowane o 5. Masz 1/LW szans na oslepienie wroga",
	"Natychmiastowe zabicie z AWP",
	"Za kazdego Fraga dostajesz 50 zycia",
	"Za kazdego Fraga dostajesz pelen magazynek oraz +20 hp",
	"Dostajesz 10 HP co 5 sekund",
	"Masz 500 pancerza",
	"Dostajesz +100 HP co runde, wolniej biegasz",
	"Uzyj, aby uleczyc sie do maksymalnej ilosci HP",
	"Nie posiadasz rozrzutu broni",
	"Zadajesz 10 obrazen wiecej",
	"Zadajesz 20 obrazen wiecej",
	"Twoj rozrzut jest mniejszy",
	"Nie dzialaja na ciebie zadne przedmioty",
	"Dostajesz +50 HP co runde, wolniej biegasz",
	"Jesteœ niewidoczny, masz 1HP",
	"Jestes odporny na 3 pociski w kazdej rundzie",
	"Nacisnij CTRL i SPACE aby uzyc modulu, modul laduje sie co 4 sekundy",
	"Losuje Ci co runde dodatkowa bron",
	"Masz 300 pancerza",
	"Dostajesz +10 pancerza",
	"Dostajesz +20 pancerza",
	"Dostajesz +30 pancerza",
	"Dostajesz +40 pancerza",
	"Dostajesz +500$ co runde",
	"Dostajesz +100$ co runde",
	"Dostajesz +1500$ co runde",
	"Dostajesz +2000$ co runde",
	"Dostajesz +2500$ co runde",
	"Dostajesz 90% grawitacji",
	"Dostajesz 80% grawitacji",
	"Dostajesz 70% grawitacji",
	"Dostajesz 60% grawitacji",
	"Dostajesz 50% grawitacji",
	"Umierasz natychmiastowo",
	"Umierasz natychmiastowo",
	"Umierasz natychmiastowo",
	"Flash na ciebie niedziala",
	"Widzisz niewidzialnych",
	"Dostajesz co runde +1 PLN",
	"Dostajesz co runde +2 PLN",
	"Dostajesz co runde +3 PLN",
	"Dostajesz co runde +4 PLN",
	"Dostajesz co runde +5 PLN",
	"Masz 1/3 na unikniecie pocisku",
	"Dostajesz +100XP za HeadShot",
	"Dostajesz +200XP za HeadShot",
	"Dostajesz +300XP za HeadShot",
	"Dostajesz +500XP za HeadShot",
	"Natychmiastowe zabicie ze Scouta",
	"Zadajesz 1 procent wiecej obrazen",
	"Zadajesz 2 procent wiecej obrazen",
	"Zadajesz 3 procent wiecej obrazen",
	"Zadajesz 4 procent wiecej obrazen",
	"Zadajesz 5 procent wiecej obrazen",
	"Zadajesz 10 procent wiecej obrazen",
	"Zadajesz 15 procent wiecej obrazen",
	"Zadajesz 20 procent wiecej obrazen",
	"Masz 1/5 szans na zabranie celownika przeciwnikowi",
	"Mozesz odpychac sie od scian na nozu"
	
};

new const nazwy_itemow[][] = {"Brak", 
	"Zalosne obrazenia",//1
	"Srednie obrazenia",//2
	"Mocne obrazenia",//3
	"Ponadprzecietne obrazenia",//4
	"Hardcore damage",//5
	"Dynamit",//6
	"Mina",//7
	"Rakieta",//8
	"Mistrz USP",//9
	"Mistrz Glocka",//10
	"Mistrz M4A1",//11
	"Mistrz AK47",//12
	"Mistrz Deagle",//13
	"Mistrz elite",//14
	"Krolicza Lapka",
	"Apteczka",//16
	"Zalosny Bandaz",//17
	"Bawelniany bandaz",//18
	"Mocny Bandaz",//19
	"Boski Bandaz",//20
	"USP z nieba",//21
	"Deagle z nieba",//22
	"M4A1 z nieba",//23
	"AK47 z nieba",//24
	"M249 z nieba",//25
	"Galil z nieba",//26
	"Famas z nieba",//27
	"Pierscien expa",//28
	"Naszyjnik expa",//29
	"Paczka pirotechnika",//30
	"Drewniana tarcza",//31
	"Stalowa tarcza",//32
	"Metalowa tarcza",//33
	"Ebonitowa tarcza",//34
	"Spadochron",
	"Podwojny Spadochron",//36
	"Tri-Parachute",//37
	"Q-Para",//38
	"F-Spad",//39
	"Skarpetki expa",//40
	"Majtki expa",//41
	"Stringi expa",//42
	"Bombowy exp",//43
	"Wybuchowy exp",//44
	"Wyrzutowy exp",//45
	"Pijawkowy exp",//46
	"Koci exp",//47
	"Psi exp",//48
	"Bombowy exp",//49
	"Odrzutowy exp",//50
	"Odpychajacy exp",//51
	"Kijankowy exp",//52
	"PROfesjonalny exp",//53
	"Duzy exp",//54
	"Urok admina",
	"Zaklecie admina",
	"Duch admina",
	"Anty-Mistrz USP",//58
	"Anty-Mistrz Glocka",//59
	"Anty-Mistrz M4A1",//60
	"Anty-Mistrz AK47",//61
	"Anty-Mistrz Deagle",//62
	"Anty-Mistrz elite",
	"Anty-Zal",//64
	"Anty-Sredniak",//65
	"Anty-Mocny",//66
	"Anty-Ponad",//67
	"Anty-Hardcore",//68
	"Nozyczki",//69
	"Scyzoryk",//70
	"Noz wojskowy",//71
	"Komplet nozy"//72
};

new const opisy_itemow[][] = {"Zabij kogos aby dostac przedmiot", 
	"Zadajesz +3 obrazen",
	"Zadajesz +10 obrazen",
	"Zadajesz +20 obrazen",
	"Zadajesz +30 obrazen",
	"Zadajesz +50 obrazen",
	"Dostajesz co runde +1 dynamit",
	"Dostajesz co runde +1 mine",
	"Dostajesz co runde +1 rakiete",
	"Masz 1/3 szans na natychmiastowe zabicie z USP",
	"Masz 1/3 szans na natychmiastowe zabicie z glocka",
	"Masz 1/10 szans na natychmiastowe zabicie z M4A1",
	"Masz 1/10 szans na natychmiastowe zabicie z AK47",
	"Masz 1/3 szans na natychmiastowe zabicie z deagle",
	"Masz 1/3 szans na natychmiastowe zabicie z elites",
	"Posiadasz BunnyHop",
	"Dostajesz co runde +1 apteczke",
	"Dostajesz co runde +5 HP",
	"Dostajesz co runde +10 HP",
	"Dostajesz co runde +15 HP",
	"Dostajesz co runde +20 HP",
	"Dostajesz USP",
	"Dostajesz Deagle",
	"Dostajesz M4A1",
	"Dostajesz AK47",
	"Dostajesz M249",
	"Dostajesz galila",
	"Dostajesz famasa",
	"Dostajesz +200XP za HeadShot",
	"Dostajesz +100XP za zabojstwo",
	"Dostajesz co runde wszystkie granaty",
	"Dostajesz -3 obrazen",//31
	"Dostajesz -10 obrazen",//32
	"Dostajesz -15 obrazen",//33
	"Dostajesz -20 obrazen",//34
	"Dostajesz 1 uzycie spadochronu",//35
	"Dostajesz 2 uzycia spadochronu",//36
	"Dostajesz 3 uzycia spadochronu",//37
	"Dostajesz 4 uzycia spadochronu",//38
	"Dostajesz 5 uzycia spadochronu",//39
	"Dostajesz premie +10expa za zabojstwo",//40
	"Dostajesz premie +30expa za zabojstwo",//41
	"Dostajesz premie +50expa za zabojstwo",//42
	"Dostajesz premie +10expa za podlozenie bomby",//43
	"Dostajesz premie +30expa za podlozenie bomby",//44
	"Dostajesz premie +50expa za podlozenie bomby",//45
	"Dostajesz premie +10expa za podlozenie bomby przez twoj team",//46
	"Dostajesz premie +30expa za podlozenie bomby przez twoj team",//47
	"Dostajesz premie +50expa za podlozenie bomby przez twoj team",//48
	"Dostajesz premie +10expa za rozbrojenie bomby",//49
	"Dostajesz premie +30expa za rozbrojenie bomby",//50
	"Dostajesz premie +50expa za rozbrojenie bomby",//51
	"Dostajesz premie +10expa za rozbrojenie bomby przez twoj team",//52
	"Dostajesz premie +30expa za rozbrojenie bomby przez twoj team",//53
	"Dostajesz premie +50expa za rozbrojenie bomby przez twoj team",//54
	"Umierasz natychmiastowo",
	"Umierasz natychmiastowo",
	"Umierasz natychmiastowo",
	"Nie dziala na Ciebie przedmiot Mistrz USP",//58
	"Nie dziala na Ciebie przedmiot Mistrz Glocka",//59
	"Nie dziala na Ciebie przedmiot Mistrz M4A1",//60
	"Nie dziala na Ciebie przedmiot Mistrz AK47",//61
	"Nie dziala na Ciebie przedmiot Mistrz Deagle",//62
	"Nie dziala na Ciebie przedmiot Mistrz elite",
	"Nie dziala na Ciebie przedmiot Zalosne obrazenia",//64
	"Nie dziala na Ciebie przedmiot Srednie obrazenia",//65
	"Nie dziala na Ciebie przedmiot Mocne obrazenia",//66
	"Nie dziala na Ciebie przedmiot Ponadprzecietne obrazenia",//67
	"Nie dziala na Ciebie przedmiot Hardcore damage",//68
	"Dostajesz 2 noze do rzutu - Uzycie C (radio3)",//69
	"Dostajesz 3 noze do rzutu - Uzycie C (radio3)",//66
	"Dostajesz 4 noze do rzutu - Uzycie C (radio3)",//67
	"Dostajesz 5 noze do rzutu - Uzycie C (radio3)"//68
};

new const doswiadczenie_poziomu[] = {
	0,15,55,100,200,350,440,650,890,1070,
	1120,1230,1530,1920,2270,2420,2740,2995,3175,3365,
	3865,4285,4945,5175,5895,6520,7300,8110,8950,9820,
	9970,10745,11705,12035,12205,12380,12920,13845,14795,15380,
	15780,15985,16195,16625,17945,18395,19085,20260,21700,22435,
	22935,24210,25770,27095,28175,29825,30665,32090,32670,32965,
	34165,35080,36630,37890,39810,40785,42435,44445,46485,48555,
	48905,50325,52485,54310,55790,57290,57670,58055,60005,60795,
	61595,62000,63230,64060,64480,65755,67905,70080,72280,73615,
	75415,78145,79985,82775,85125,87500,87980,88465,91405,94375,
	97375,99900,100920,101950,102990,103515,105635,106705,108865,111590,
	114340,117670,118230,119360,121640,122790,123370,125710,126300,129870,
	131670,135300,135910,137140,140860,142735,143995,145900,148460,150395,
	153645,154955,156935,160260,163610,164285,164965,169075,169765,173240,
	175340,178865,180995,183855,188175,188900,191090,194765,199205,202930,
	205930,208195,212755,213520,214290,216615,218175,218960,221330,222125,
	226125,230955,232575,235020,239940,242415,243245,244080,249120,252500,
	253350,255915,260215,261945,264555,268930,269810,272465,274245,275140,
	278740,284170,288720,289635,292395,297945,301665,303535,307295,312020,
	315820,320595,325395,330220,334100,335075,336055,338025,342975,345960,
	349960,350965,353995,360085,363145,369295,370325,371360,374480,378660,
	381810,386030,387090,390285,394565,401015,404255,405340,406430,408620,
	413020,419650,425200,427430,429670,430795,437575,442115,447815,453540,
	456990,458145,462785,469775,473285,474460,481540,486280,492230,498205,
	499405,501815,504235,507880,510320,515220,521370,526310,528790,535015,
	540015,541270,543790,547585,550125,553950,561630,566770,569350,574530,
	579730,582340,587580,592840,599440,607390,612710,619385,620725,622070,
	630170,638300,646460,654650,656020,662895,664275,667045,669825,675405,
	679605,685225,690865,695110,697950,702225,710805,717980,722300,730970,
	739670,745490,746950,751345,760165,769015,771975,776430,780900,782395
};//300

enum { NONE = 0, Snajper, Komandos, Strzelec, Obronca, Medyk, Wsparcie, Saper, Demolitions, Rusher, Rambo,
	HGunner, Szturmowiec, Telegrafista, Pielegniarka, Partyzant, Szpieg, Szturmowiec2, StrzelecWsparcia, 
	LekkiZolnierz, Rebeliant, SGunner, Shooter, StrzelecGorski, ObroncaWsparcia, SnajperWyborowy,
	Profesjonalista, Oficer, Podporucznik, SWAT, Lekarz, Policjant, MlodszySzturmowy, Marynarz, 
	Sprinter, Terminator, Furiat, Oporowiec, USMC, Terrorysta, AntyTerrorysta, Samobojca, Uciekinier, 
	Uzurpator, Pulkownik, Aspirant, MlodszyChorazy, StarszyChorazy, ChorazySzturmowy, Assasin, 
	MlodszyKomandos, Pomocnik, Desantowiec, ZolnierzTaktyczny, Przemytnik, CichyZabojca, SeryjnyMorderca, 
	Nalotnik, GROM, LekkiSkoczek, Matrix, Wybuchowiec, Neo, Luq, Avatar, Zawodowiec, Radarowiec, Minowiec, 
	StarszySzturmowy, StarszyTerrorysta, StarszyOficer};
new const zdrowie_klasy[] = { 0, 120, 140, 110, 120, 110, 100, 100, 110, 100, 100, 100, 120, 
	100, 100, 100, 70, 140, 125, 100, 100, 100, 40, 40, 140, 50, 70, 130, 125, 120, 130, 120,
	115, 120, 70, 100, 90, 100, 70, 120, 120, 85, 95, 120, 100, 110, 100, 100, 100, 130, 80, 110, 
	80, 120, 80, 100, 80, 120, 120, 100, 110, 160, 160, 160, 160, 160, 160, 160, 100, 130, 150};
new const Float:szybkosc_klasy[] = {0.6, 1.2, 1.35, 0.8, 0.8, 1.0, 1.0, 1.0, 1.0, 1.3 , 1.15, 
	0.8, 1.1, 1.0, 1.0, 1.0, 1.0, 0.8, 1.0, 1.2, 1.0, 1.2, 1.1, 1.0, 1.1, 1.0, 1.1, 0.95, 0.95, 
	1.2, 1.1, 0.7, 0.95, 1.1, 1.4, 1.0, 1.1, 1.2, 1.0, 1.2, 1.2, 1.2, 1.3, 1.1, 1.2, 0.9, 1.2, 1.2, 
	1.25, 1.0, 1.0, 1.2, 1.1, 1.0, 1.0, 1.1, 1.1, 1.1, 0.9, 1.0, 1.0, 1.1, 1.2, 1.2, 1.1, 1.1, 1.1, 
	1.0, 1.2, 1.2, 1.2};
new const pancerz_klasy[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0};
new const nazwy_klas[][] = {"Brak || uSpiewaKa.eu",
	"Snajper",
	"Komandos",
	"Strzelec wyborowy",
	"Obronca",
	"Medyk",
	"Wsparcie ogniowe",
	"Saper",
	"Demolitions",
	"Rusher",
	"Rambo",//10
	"Hard Gunner",
	"Szturmowiec",
	"Telegrafista",
	"Pielegniarka",
	"Partyzant",//15
	"Szpieg",
	"Szturmowiec II",
	"Strzelec Wsparcia",
	"Lekki Zolnierz",
	"Rebeliant",//20
	"Shot Gunner",
	"Shooter",
	"Strzelec Gorski",
	"Obronca Wsparcia",
	"Snajper Wyborowy",//25
	"Profesjonalista",
	"Oficer",//27
	"Podporucznik",
	"SWAT",
	"Lekarz",//30
	"Policjant",
	"Mlodszy Szturmowy",
	"Marynarz",//33
	"Sprinter",
	"Terminator",
	"Furiat",
	"Oporowiec",
	"U.S.M.C",//38
	"Terrorysta",
	"Anty-Terrorysta",
	"Samobojca",//PP 41
	"Uciekinier",//PP 42
	"Uzurpator",//PP 43
	"Pulkownik",//PP 44
	"Aspirant",//45
	"Mlodszy Chorazy",//46
	"Starszy Chorazy",//47
	"Chorazy Szturmowy",//48
	"Assasin",//49
	"Mlodszy Komandos",
	"Pomocnik",
	"Desantowiec",
	"Zolnierz Taktyczny",
	"Przemytnik",
	"Cichy Zabojca",
	"Seryjny Morderca",
	"Nalotnik",
	"GROM",
	"Lekki Skoczek",
	"Armia Czerwona",//60
	"Wybuchowiec",
	"Czerwony Beret",
	"Czarny Beret",
	"Hitlerowiec",
	"Zawodowiec",
	"Radarowiec",
	"Minowiec",
	"Starszy Szturmowy",
	"Starszy Terrorysta",
	"Starszy Oficer"//70
};

new const frakcje[][]={
	"Brak",
	"Polacy",//Klasy normal
	"Rosjanie",//Klasy normal
	"Niemcy",//Klasy normal
	"Amerykanie",//Klasy normal
	"\wArabowie\r[*]",//Klasy pol premium
	"\wIranczycy\r[*]^n \r [*]\w Klasy premium^n \w Przeczytaj\r /regulamin ^n \w Kup\r /premium ^n \w Wpisz\r /menu ^n \w Wykonaj\r /misje ^n \w Wejdz na\y uSpiewaKa.eu ^n \w Kontakt: \y2228161 \r( \wSpiewaK \r)"
}

enum { NONE = 0,polacy,rosjanie,niemcy,amerykanie,arabowie,iranczycy}

new const nalezy_do[]={
	NONE,
	polacy,
	rosjanie,
	niemcy,
	polacy,
	rosjanie,
	niemcy,
	polacy,
	rosjanie,
	niemcy,
	amerykanie,//10
	polacy,
	rosjanie,
	niemcy,
	polacy,
	rosjanie,
	niemcy,
	polacy,
	rosjanie,
	niemcy,
	polacy,
	rosjanie,
	amerykanie,//22
	amerykanie,//23
	niemcy,//24
	polacy,//25
	amerykanie,//26
	rosjanie,//27
	niemcy,//28
	polacy,//29
	rosjanie,//30
	niemcy,
	polacy,
	rosjanie,
	niemcy,
	amerykanie,//35
	polacy,
	amerykanie,//37
	rosjanie,//38
	niemcy,//39
	polacy,//40
	arabowie,//41
	arabowie,//42
	arabowie,//43
	arabowie,//44
	polacy,//45
	polacy,//46
	rosjanie,//47
	niemcy,//48
	rosjanie,//49
	niemcy,//50
	rosjanie,
	niemcy,
	amerykanie,
	amerykanie,
	amerykanie,
	amerykanie,
	amerykanie,
	amerykanie,
	amerykanie,
	amerykanie,
	iranczycy,
	iranczycy,
	iranczycy,
	iranczycy,
	iranczycy,
	iranczycy,
	iranczycy,
	arabowie,
	arabowie,
	arabowie
}

new const opisy_klas[][] = {"Brak",
	"Dostaje AWP, scout i deagle, 120hp bazowe, 1/3 szansy natychmiastowego zabicia noza, 110% biegu, 100 pancerza",
	"Dostaje Deagle, 140hp bazowe, Natychmiastowe zabicie z noza (prawy przycisk myszy), 135% biegu, 100 pancerza",
	"Dostaje AK i M4A1, 110hp bazowe, 80 % biegu, 100 pancerza",
	"Dostaje M249 (Krowa), 120hp bazowe, 80% biegu, jest odporny na miny, ma wszystkie granaty, 150 pancerza",
	"Dostaje UMP45, 110hp bazowe, posiada apteczke, 100 pancerza",
	"Dostaje MP5, 100 hp bazowe, Ma dwie rakiety,ktore po trafieniu przeciwnika zadaja du¿o obrazen",
	"Dostaje P90, 100hp bazowe, 100 pancerza, posiada 3 miny",
	"Dostaje AUG, 110 hp bazowe, 100 pancerza, Ma wszystkie granaty, posiada dynamit",
	"Dostaje szotgana M3, 100 hp bazowe, 130% biegu",
	"Dostaje Famasa, 100 hp bazowe, 120% biegu",//10
	"Dostaje M249 (Krowa) + 1 HE, 100hp, 120 pancerza, biega wolno",
	"Dostaje Ak47, 120hp na Start, 110% biegu i 100 pancerza",
	"Dostaje AUG i deagle, 100hp na Start, 150 pancerza, posiada 2 miny",
	"Dostaje MP5, 100 hp, 250 pancerza, posiada 5 apteczek",
	"Dostaje P90 + FLASH, 100 hp bazowe + mniej widzialny",//15
	"Dostaje deagla, 70 hp bazowe, ma ubranie wroga",
	"Dostaje M4 + deagle + he, 140 hp bazowe + 150 kamizelki, wolniej biega",
	"Dostaje G3/SG-1, 125 hp bazowe, ma 1 rakiete",
	"Dostaje galil + p228, 100 hp bazowe, szybciej biega",
	"Dostaje sg552 + 1 mine + 1 HE, 100 hp bazowe",//20
	"Dostaje oba shotguny oraz 1HE, 100HP, 100kamizelki, szybciej biega",
	"Dostaje M4A1,Famas,Ak47, 40HP, 110% Biegu, 100 kamizelki",
	"Dostaje 2 AutoKampy, 40Hp Bazowe, 100% biegu",
	"Dostaje Tarcze oraz deagle, 140HP, 110% biegu, 200 kamizelki",
	"Dostaje AWP, 50hp bazowe, 1/2 na zabicie z AWP, 100% biegu, 100 pancerza",//25
	"Dostaje M4A1, AK47 oraz Defuse Kit, 70hp bazowe, 100 kamizelki, 110% biegu",
	"Dostaje Galil, 130HP, 95% biegu, 70 pancerza",
	"Dostaje AK47 oraz elites, 125HP, 50 pancerza, 95% biegu, ma dynamit",
	"Dostaje MP5, 120HP, 100 pancerza, 120% biegu",
	"Dostaje galila, 130HP, 250 pancerza, 110% biegu, posiada 3 apteczki",//30
	"Dostaje Famasa, 120HP, 100 pancerza, 70% biegu, ciche chodzenie",
	"Dostaje AK47, 115HP, 0 pancerza, 95% biegu, posiada mine",
	"Dostaje MAC10 oraz deagle, 120HP, 50 kamizelki, 110% biegu, zadaje +5 obrazen",
	"Dostaje MAC10, UMP45, 70HP, 50 kamizelki, 140% biegu",
	"Dostaje M4A1, SCOUT oraz deagle, 100 kamizelki, 100% biegu, 100HP",
	"Dostaje AK47, 90HP, 100 kamizelki, 110% biegu",
	"Dostaje Famasa oraz deagle, 100HP, 50 kamizelki, 120% biegu",
	"Dostaje MP5 oraz deagle, 70HP, 0 kamizelki, posiada Auto BH i mine",
	"Dostaje AK47, deagle, 120HP, 120% biegu, posiada mine",
	"Dostaje M4A1, deagle, 120HP, 120% biegu, posiada mine",
	"Dostaje AK45, 85HP, 100 pancerza, 120% biegu, posiada 2 dynamity, wymagany 100 poziom",
	"Dostaje P90, deagle, 95HP, 100 pancerza, 130% biegu, wymagany 200 poziom",
	"Dostaje M4A1 i AUG, 120HP, 100 pancerza, 110% biegu, wymagany 300 poziom",
	"Dostaje Famasa i deagle, 100HP, 100 pancerza, 120% biegu, 1/20 na zabicie z deagle, wymagany 400 poziom",
	"Dostaje UMP45 i fiveseven, 110HP, 100 kamizelki, 90% biegu, dostaje defuse kit",
	"Dostaje Famasa+Deagla , 100 HP, 50 pancerza, 120% biegu, 1/6 natychmiastowe zabicie z deagla",
	"Dostaje M4A1+Deagla, 100HP, 50 pancerza, 120% biegu, posiada 1/9 natychmiastowe zabicie z Deagla",
	"Dostaje Deagla ,100HP ,200 pancerza, 125% biegu , posiada 1/5 natychmiastowe zabicie z Deagla, posiada 1 rakiete",
	"Dostaje Deagle oraz smoke, 130HP, 50 pancerza, moze podskoczyc w locie",
	"Dostaje Famasa, 80HP, 100pancerza, 100% biegu, 1/2 na zabicie z noza",
	"Dostaje XM1014 oraz deagle, 110HP, 100 kamizelki, 120% biegu",
	"Dostaje Scout, 80HP, 110% biegu, 20% niewidzialnosci",
	"Dostaje deagle oraz USP/Glock, 120HP, 200 kamizelki, 100% biegu, odporny na miny",
	"Dostaje losowa bron, 80HP, 100 kamizelki, 100% biegu, posiada ubranie wroga",
	"Dostaje M4A1, 100HP, 100 kamizelki, 110% biegu, cicho biega",
	"Dostaje M4A1 oraz smoke, 80HP, 110% biegu, cicho biega",
	"Dostaje deagle, 120hp, 100 pancerza, 110% biegu, mniejsza grawitacja, posiada mine",
	"Dostaje M4A1, 120HP, 200 pancerza, 90% biegu",
	"Dostaje elitki, 100hp bazowe, brak pancerza, auto BH",
	"Dostaje elites, deagle oraz USP/Glock, 110HP, 100 kamizelki",
	"Dostaje M4A1 + 1 HE, 160hp, 200 pancerza, biego szyciej, wybucha po smierci, odporny na rakiety, miny, dynamity",
	"Dostaje Famasa, 160 hp bazowe, 120% biegu, za kazde zabojstwo +20 hp oraz pelen magazynek, podwojny skok, odporny na rakiety, miny, dynamity",
	"Dostaje Famasa, 160 hp bazowe, 120% biegu, za kazde zabojstwo +20 hp oraz pelen magazynek, AutoBH, odporny na rakiety, miny, dynamity",
	"Dostaje MP5 oraz USP/Glock, 160HP, 200 pancerza, 110 % biegu, posiada podwojny skok oraz AutoBH, odporny na rakiety, miny, dynamity",
	"Dostaje Famasa oraz deagle, 160HP, 200 pancerza, 110 % biegu, 1/5 na zabicie z deagle, AutoBH, odporny na rakiety, miny, dynamity",
	"Dostaje M4A1 oraz deagle, 160HP, 200 pancerza, 120 % biegu, widzi wrogow na radarze, AutoBH, odporny na rakiety, miny, dynamity",
	"Dostaje galila, 160hp bazowe, 100 pancerza, Dostaje 5 min, odporny na rakiety, miny, dynamity",
	"Dostaje M4A1, 100HP, 100 pancerza, 120% biegu, wymagany 500 poziom",
	"Dostaje AK47, 130HP, 200 pancerza, 120% biegu, wymagany 700 poziom",
	"Dostaje M4A1 oraz AK47, 150HP, 400 pancerza, 120% biegu, wymagany 900 poziom"
};

new const nazwy_misji[][] = {"Brak",
	"Zabij 5 Polakow",
	"Zabij 5 Rosjanow",
	"Zabij 5 Niemcow",
	"Zabij 5 Amerykanow",
	"Zabij 5 Arabow",
	"Zabij 5 Iranczykow",
	"Zabij 20 zolnierzy",
	"Zabij 3 Polakow bez zginiecia",
	"Zabij 3 Rosjanow bez zginiecia",
	"Zabij 3 Niemcow bez zginiecia",
	"Zabij 3 Amerykanow bez zginiecia",
	"Zabij 3 Arabow bez zginiecia",
	"Zabij 3 Iranczykow bez zginiecia",
	"Zabij 8 zolnierzy bez zginiecia"
};
new x_bankmenu[][]={"say /bank","say bank","say /schowek","say schowek","say_team /bank","say_team bank","say_team /schowek","say_team schowek"}
new x_bank[][]={"say /bank1","say bank1","say /schowek1","say schowek1","say_team /bank1","say_team bank1","say_team /schowek1","say_team schowek1"}
new x_bank2[][]={"say /bank2","say bank2","say /schowek2","say schowek2","say_team /bank2","say_team bank2","say_team /schowek2","say_team schowek2"}
new x_questycomm[][]={"say /questy","say questy","say /misje","say misje", "say /misja", "say misja", "say /quest","say quest","say_team /questy","say_team questy","say_team /misje","say_team misje", "say_team /misja", "say_team misja", "say_team /quest","say_team quest"}
new x_wybierzklase[][]={"say /klasa","say /frakcja","say frakcja","say klasa","say_team /klasa","say_team /frakcja","say_team frakcja","say_team klasa"}
new x_opisklasy[][]={"say /klasy", "say klasy","say_team /klasy", "say_team klasy"}
new x_opismenu[][]={"say /przedmiot", "say /item", "say item", "say przedmiot","say_team /przedmiot", "say_team /item", "say_team item", "say_team przedmiot", "say /perk", "say perk"}
new x_opisprzedmiotu[][]={"say /przedmiot1","say /item1","say przedmiot1","say item1","say_team /przedmiot1","say_team /item1","say_team przedmiot1","say_team item1","say perk1","say /perk1"}
new x_opisitemu[][]={"say przedmiot2","say item2","say /przedmiot2","say /item2","say_team przedmiot2","say_team item2","say_team /przedmiot2","say_team /item2","say perk2","say /perk2"}
new x_dropmenu[][]={"say /drop","say /wyrzuc","say drop","say wyrzuc","say_team /drop","say_team /wyrzuc","say_team drop","say_team wyrzuc"}
new x_wyrzucprzedmiot[][]={"say /drop1","say /wyrzuc1","say drop1","say wyrzuc1","say_team /drop1","say_team /wyrzuc1","say_team drop1","say_team wyrzuc1"}
new x_wyrzucitem[][]={"say /drop2","say /wyrzuc2","say drop2","say wyrzuc2","say_team /drop2","say_team /wyrzuc2","say_team drop2","say_team wyrzuc2"}
new x_resetuj[][]={"say /reset","say reset","say_team /reset","say_team reset"}
new x_block[][]={"fullupdate","cl_autobuy","cl_rebuy","cl_setautobuy"}
new x_wymiana[][]={"say /wymien","say wymien","say_team /wymien","say_team wymien"}
new x_sklepmenu[][]={"say /sklep","say sklep","say /shop","say shop","say_team /sklep","say_team sklep","say_team /shop","say_team shop"}
new x_sklep1[][]={"say /sklep1","say sklep1","say /shop1","say shop1","say_team /sklep1","say_team sklep1","say_team /shop1","say_team shop1"}
new x_sklep2[][]={"say /sklep2","say sklep2","say /shop2","say shop2","say_team /sklep2","say_team sklep2","say_team /shop2","say_team shop2"}
new x_dajmenu[][]={"say /daj","say daj","say /oddaj","say oddaj","say_team /daj","say_team daj","say_team /oddaj","say_team oddaj"}
new x_oddajprzedmiot[][]={"say /daj1","say daj1","say /oddaj1","say oddaj1","say_team /daj1","say_team daj1","say_team /oddaj1","say_team oddaj1"}
new x_oddajitem[][]={"say /daj2","say daj2","say /oddaj2","say oddaj2","say_team /daj2","say_team daj2","say_team /oddaj2","say_team oddaj2"}
new x_menu[][]={"say /menu","say menu","say /menucod","say menucod","say_team /menu","say_team menu","say_team /menucod","say_team menucod"}
new x_reg[][]={"say regulamin","say zasady", "say reg","say /regulamin","say /zasady","say_team regulamin","say_team zasady", "say_team reg","say_team /regulamin","say_team /zasady", "say /reg", "say_team /reg"}
new x_rangi[][]={"say /rangi", "say rangi","say_team /rangi", "say_team rangi"}
new x_pre[][]={"say premium","say pre","say vip","say /vip","say /pre","say /premium","say_team premium","say_team pre","say_team vip","say_team /vip","say_team /pre","say_team /premium"}
new x_sprzedajmenu[][]={"say /sprzedaj","say sprzedaj","say /sell","say sell","say_team /sprzedaj","say_team sprzedaj","say_team /sell","say_team sell"}
new x_zamienmenu[][]={"say /zamien","say zamien","say zamiana","say /zamiana","say_team /zamien","say_team zamien","say_team zamiana","say_team /zamiana"}
new x_zamienperk[][]={"say /zamien1","say zamien1","say zamiana1","say /zamiana1","say_team /zamien1","say_team zamien1","say_team zamiana1","say_team /zamiana1"}
new x_zamienperka[][]={"say /zamien2","say zamien2","say zamiana2","say /zamiana2","say_team /zamien2","say_team zamien2","say_team zamiana2","say_team /zamiana2"}
new x_opisyprzedmiotu[][]={"say /przedmioty1","say /itemy1","say przedmioty1","say /perki1","say perki1","say itemy1","say_team /przedmioty1","say_team /itemy1","say_team przedmioty1","say_team /perki1","say_team perki1","say_team itemy1"}
new x_opisyitemu[][]={"say /przedmioty2","say /itemy2","say przedmioty2","say /perki2","say perki2","say itemy2","say_team /przedmioty2","say_team /itemy2","say_team przedmioty2","say_team /perki2","say_team perki2","say_team itemy2"}
new x_opisymenu[][]={"say /przedmioty","say /itemy","say przedmioty","say /perki","say perki","say itemy","say_team /przedmioty","say_team /itemy","say_team przedmioty","say_team /perki","say_team perki","say_team itemy"}

public plugin_init() 
{
	if(is_allowed_server()) register_plugin("CoD:MW", "1.0", "QTM_Peyote & SpiewaK");
	
	g_vault = nvault_open("CodMod");

	register_think("Apteczka","ApteczkaThink");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
	RegisterHam(Ham_Touch, "armoury_entity", "DotykBroni");
	RegisterHam(Ham_Touch, "weapon_shield", "DotykBroni");
	RegisterHam(Ham_Touch, "weaponbox", "DotykBroni");
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack")
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	register_forward(FM_CmdStart, "CmdStart");
	register_forward(FM_EmitSound, "EmitSound");
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
	register_event("DeathMsg", "Death", "ade");
	register_event("Damage", "Damage", "b", "2!=0");
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_event("ResetHUD", "ResetHUD", "abe");
	register_message(get_user_msgid("ScreenFade"), "msgScreenFade");
	register_message(get_user_msgid("Health"),"message_health");
	register_touch("Rocket", "*" , "DotykRakiety");
	register_touch("Mine", "player",  "DotykMiny");
	register_touch("throw_knife", "player", "knife_touch")
	register_touch("throw_knife", "worldspawn", "touchWorld")
	register_touch("throw_knife", "func_wall", "touchWorld")
	register_touch("throw_knife", "func_wall_toggle", "touchWorld")
	for(new i=0 ;i<sizeof(x_bankmenu);i++) register_clcmd(x_bankmenu[i],"BankMenu")
	for(new i=0 ;i<sizeof(x_bank);i++) register_clcmd(x_bank[i],"bank")
	for(new i=0 ;i<sizeof(x_bank2);i++) register_clcmd(x_bank2[i],"bank2")
	for(new i=0 ;i<sizeof(x_questycomm);i++) register_clcmd(x_questycomm[i],"QuestyComm")
	for(new i=0 ;i<sizeof(x_wybierzklase);i++) register_clcmd(x_wybierzklase[i],"WybierzKlase")
	for(new i=0 ;i<sizeof(x_opisklasy);i++) register_clcmd(x_opisklasy[i],"OpisKlasy")
	for(new i=0 ;i<sizeof(x_opismenu);i++) register_clcmd(x_opismenu[i],"OpisMenu")
	for(new i=0 ;i<sizeof(x_opisprzedmiotu);i++) register_clcmd(x_opisprzedmiotu[i],"OpisPrzedmiotu")
	for(new i=0 ;i<sizeof(x_opisitemu);i++) register_clcmd(x_opisitemu[i],"OpisItemu")
	for(new i=0 ;i<sizeof(x_dropmenu);i++) register_clcmd(x_dropmenu[i],"DropMenu")
	for(new i=0 ;i<sizeof(x_wyrzucprzedmiot);i++) register_clcmd(x_wyrzucprzedmiot[i],"WyrzucPrzedmiot")
	for(new i=0 ;i<sizeof(x_wyrzucitem);i++) register_clcmd(x_wyrzucitem[i],"WyrzucItem")
	for(new i=0 ;i<sizeof(x_resetuj);i++) register_clcmd(x_resetuj[i],"KomendaResetujPunkty")
	for(new i=0 ;i<sizeof(x_wymiana);i++) register_clcmd(x_wymiana[i],"Wymiana")
	for(new i=0 ;i<sizeof(x_sklepmenu);i++) register_clcmd(x_sklepmenu[i],"SklepMenu")
	for(new i=0 ;i<sizeof(x_sklep1);i++) register_clcmd(x_sklep1[i],"Sklep1")
	for(new i=0 ;i<sizeof(x_sklep2);i++) register_clcmd(x_sklep2[i],"Sklep2")
	for(new i=0 ;i<sizeof(x_dajmenu);i++) register_clcmd(x_dajmenu[i],"DajMenu")
	for(new i=0 ;i<sizeof(x_oddajprzedmiot);i++) register_clcmd(x_oddajprzedmiot[i],"OddajPrzedmiot")
	for(new i=0 ;i<sizeof(x_oddajitem);i++) register_clcmd(x_oddajitem[i],"OddajItem")
	for(new i=0 ;i<sizeof(x_menu);i++) register_clcmd(x_menu[i],"MenuCoD")
	for(new i=0 ;i<sizeof(x_reg);i++) register_clcmd(x_reg[i],"regulamin_motd")
	for(new i=0 ;i<sizeof(x_rangi);i++) register_clcmd(x_rangi[i],"ranga_motd")
	for(new i=0 ;i<sizeof(x_pre);i++) register_clcmd(x_pre[i],"premium_motd")
	for(new i=0 ;i<sizeof(x_sprzedajmenu);i++) register_clcmd(x_sprzedajmenu[i],"SprzedajMenu")
	for(new i=0 ;i<sizeof(x_zamienmenu);i++) register_clcmd(x_zamienmenu[i],"ZamienMenu")
	for(new i=0 ;i<sizeof(x_zamienperk);i++) register_clcmd(x_zamienperk[i],"ZamienPerk")
	for(new i=0 ;i<sizeof(x_zamienperka);i++) register_clcmd(x_zamienperka[i],"ZamienPerka")
	for(new i=0 ;i<sizeof(x_opisyprzedmiotu);i++) register_clcmd(x_opisyprzedmiotu[i],"OpisyPrzedmiotu")
	for(new i=0 ;i<sizeof(x_opisyitemu);i++) register_clcmd(x_opisyitemu[i],"OpisyItemu")
	for(new i=0 ;i<sizeof(x_opisymenu);i++) register_clcmd(x_opisymenu[i],"OpisyMenu")
	for(new i=0 ;i<sizeof(x_block);i++) register_clcmd(x_block[i],"BlokujKomende")
	register_clcmd("radio3", "UzyjItemu");
	register_clcmd("cod_iditem", "itemid", ADMIN_IMMUNITY);
	register_clcmd("cod_iditem2", "item2id", ADMIN_IMMUNITY);
	register_clcmd("cod_idklas", "klasyid", ADMIN_IMMUNITY);
	

	register_clcmd("cod_iditem", "itemid", ADMIN_IMMUNITY);
	register_clcmd("cod_iditem2", "item2id", ADMIN_IMMUNITY);
	register_clcmd("cod_idklas", "klasyid", ADMIN_IMMUNITY);
	register_concmd("cod_giveitem", "KomendaDajPrzedmiot", ADMIN_IMMUNITY, "<nick> <item>");
	register_concmd("cod_giveitem2", "KomendaDajPrzedmiot2", ADMIN_IMMUNITY, "<nick> <item>");
	register_concmd("cod_removeitem", "KomendaUsunPrzedmiot", ADMIN_IMMUNITY, "<nick>");
	register_concmd("cod_removeitem2", "KomendaUsunPrzedmiot2", ADMIN_IMMUNITY, "<nick>");
	register_concmd("cod_addexp", "cmd_addexp", ADMIN_IMMUNITY, "<nick> <dodawany exp>");
	register_concmd("cod_remexp", "cmd_remexp", ADMIN_IMMUNITY, "<nick> <usuwany exp>");
	register_concmd("cod_addranga", "cmd_addranga", ADMIN_IMMUNITY, "<nick> <dodawane rangi>");
	register_concmd("cod_remranga", "cmd_remranga", ADMIN_IMMUNITY, "<nick> <usuwane rangi>");
	register_concmd("cod_addpln", "cmd_addpln", ADMIN_IMMUNITY, "<nick> <dodawane pln>");
	register_concmd("cod_rempln", "cmd_rempln", ADMIN_IMMUNITY, "<nick> <usuwane pln>");
	register_concmd("cod_addwytrz", "cmd_addwytrz", ADMIN_IMMUNITY, "<nick> <usuwana wytrzymalosc 1>");
	register_concmd("cod_addwytrz2", "cmd_addwytrz2", ADMIN_IMMUNITY, "<nick> <usuwana wytrzymalosc 2>");
	register_concmd("cod_remwytrz", "cmd_remwytrz", ADMIN_IMMUNITY, "<nick> <usuwana wytrzymalosc 1>");
	register_concmd("cod_remwytrz2", "cmd_remwytrz2", ADMIN_IMMUNITY, "<nick> <usuwana wytrzymalosc 2>");
	register_concmd("cod_przenies", "KomendaPrzeniesPoziom", ADMIN_IMMUNITY, "<nick> <id klasy 1> <id klasy 2>");
	set_task(0.5,"bestplayersexp",666,_,_,"d")
	register_cvar("amx_knifedamage_mw2","100")
	register_cvar("amx_knifespeed_mw2","600")
	register_cvar("amx_knifegravity_mw2","0.3")
	SpadochronDetach = register_cvar("cod_spadochron_detach", "1");
	g_msg_screenfade= get_user_msgid("ScreenFade")
	g_msgHostageAdd = get_user_msgid("HostagePos");
	g_msgHostageDel = get_user_msgid("HostageK");
	g_maxplayers = get_maxplayers();
	gmsgStatusText = get_user_msgid("StatusText")
	for (new i = 1; i<=g_maxplayers;i++) radar[i] = false;	
	set_task (2.0,"radar_scan",_,_,_,"b");
	set_task(30.0, "Pomoc");
	register_message(get_user_msgid("SayText"),"handleSayText");
	SprawdzCzas();
}
public handleSayText(msgId,msgDest,msgEnt){
	new id = get_msg_arg_int(1);
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	new szTmp[256],szTmp2[256]
	
	get_msg_arg_string(2,szTmp, charsmax( szTmp ) )
	new szPrefix[64]
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)) formatex(szPrefix,charsmax( szPrefix ),"^x03[%s]%s",nazwy_klas[klasa_gracza[id]], nazwy_rang2[ranga_gracza[id]]);
	else formatex(szPrefix,charsmax( szPrefix ),"^x04[%s]%s",nazwy_klas[klasa_gracza[id]], nazwy_rang2[ranga_gracza[id]]);
	
	if(!equal(szTmp,"#Cstrike_Chat_All")){
		add(szTmp2,charsmax(szTmp2),szPrefix);
		add(szTmp2,charsmax(szTmp2)," ");
		add(szTmp2,charsmax(szTmp2),szTmp);
	}
	else{
		add(szTmp2,charsmax(szTmp2),szPrefix);
		add(szTmp2,charsmax(szTmp2),"^x03 %s1^x01 :  %s2");
	}

	set_msg_arg_string(2,szTmp2);
	return PLUGIN_CONTINUE;
}
public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr") ;
	sprite_blast = precache_model("sprites/dexplo.spr");
	
	precache_sound("QTM_CodMod/select.wav");
	precache_sound("QTM_CodMod/start.wav");
	precache_sound("QTM_CodMod/start2.wav");
	precache_sound("QTM_CodMod/levelup.wav");
	
	precache_model("models/w_medkit.mdl");
	precache_model("models/rpgrocket.mdl");
	precache_model("models/mine.mdl");
	precache_model("models/parachute.mdl");
	
	precache_sound("uSpiewaKa_CoD/witajsklep.wav");
	precache_sound("uSpiewaKa_CoD/niemoge.wav");	
	precache_sound("uSpiewaKa_CoD/pieniadze.wav");
	precache_sound("uSpiewaKa_CoD/pieniadze2.wav");
	precache_sound("uSpiewaKa_CoD/uleczaniesklep.wav");
	precache_sound("uSpiewaKa_CoD/awans.wav");
	
	precache_model("models/w_throw.mdl");
	blood = precache_model("sprites/blood.spr")
	blood2 = precache_model("sprites/bloodspray.spr")
	precache_sound("player/headshot1.wav")
	precache_sound("player/die1.wav")

	precache_sound("weapons/rocketfire1.wav");

	precache_sound("radar.wav");

}
public plugin_cfg() 
	server_cmd("sv_maxspeed 1600");
	
public UstawSzybkosc(id)
{
	id -= id>32? ZADANIE_USTAW_SZYBKOSC: 0;
	
	if(is_user_alive(id)){
		new grav = grawitacja_gracza[id] / 230;
		set_user_gravity(id, get_user_gravity(id)-float(grav));
		set_user_maxspeed(id, szybkosc_gracza[id]-0.4);
	}
}
public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	new button = get_uc(uc_handle, UC_Buttons);
	new oldbutton = get_user_oldbutton(id);
	new flags = get_entity_flags(id);
	
	if(informacje_przedmiotu_gracza[id][0] == 11 || klasa_gracza[id] == Assasin || klasa_gracza[id] == Neo || klasa_gracza[id] == Luq || klasa_gracza[id] == Avatar){
		if((button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldbutton & IN_JUMP) && ilosc_skokow_gracza[id] > 0){
			ilosc_skokow_gracza[id]--;
			new Float:velocity[3];
			entity_get_vector(id,EV_VEC_velocity,velocity);
			velocity[2] = random_float(265.0,285.0);
			entity_set_vector(id,EV_VEC_velocity,velocity);
		}
		else if(flags & FL_ONGROUND){	
			ilosc_skokow_gracza[id] = 0;
			if(informacje_przedmiotu_gracza[id][0] == 11 || klasa_gracza[id] == Assasin || klasa_gracza[id] == Neo || klasa_gracza[id] == Luq || klasa_gracza[id] == Luq) ilosc_skokow_gracza[id]++;
		}
	}
	
	if(button & IN_ATTACK){
		new Float:punchangle[3];
		
		if(informacje_przedmiotu_gracza[id][0] == 20) entity_set_vector(id, EV_VEC_punchangle, punchangle);
		if(informacje_przedmiotu_gracza[id][0] == 23){
			entity_get_vector(id, EV_VEC_punchangle, punchangle);
			for(new i=0; i<3;i++) punchangle[i]*=0.9;
			entity_set_vector(id, EV_VEC_punchangle, punchangle);
		}
	}
	
	if(informacje_przedmiotu_gracza[id][0] == 28 && button & IN_JUMP && button & IN_DUCK && flags & FL_ONGROUND && get_gametime() > informacje_przedmiotu_gracza[id][1]+4.0){
		informacje_przedmiotu_gracza[id][1] = floatround(get_gametime());
		new Float:velocity[3];
		VelocityByAim(id, 700, velocity);
		velocity[2] = random_float(265.0,285.0);
		entity_set_vector(id, EV_VEC_velocity, velocity);
	}
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) ){
		new szWeapID = get_user_weapon( id, szClip, szAmmo )

		if( (szWeapID == CSW_DEAGLE && !zoom[id] || szWeapID == CSW_USP && !zoom1[id] ||
		szWeapID == CSW_GLOCK18 && !zoom2[id] || szWeapID == CSW_AK47 && !zoom3[id] || 
		szWeapID == CSW_MP5NAVY && !zoom4[id] || szWeapID == CSW_P90 && !zoom5[id] || 
		szWeapID == CSW_GALIL && !zoom6[id]) && !g_hasZoom[ id ] ){
			g_hasZoom[ id ] = true
			cs_set_user_zoom( id, CS_SET_FIRST_ZOOM, 1 )
			emit_sound( id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 )
		}
		else {
			if( g_hasZoom[ id ] ){
				g_hasZoom[ id ] = false
				cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
			}
		}
		return PLUGIN_HANDLED	
	}
	UstawSzybkosc(id)
	return FMRES_IGNORED;
}

public Odrodzenie(id)
{
	if(!is_user_alive(id) || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	radar[id] = false;
	
	zoom[id] = true;
	zoom1[id] = true;
	zoom2[id] = true;
	zoom3[id] = true;
	zoom4[id] = true;
	zoom5[id] = true;
	zoom6[id] = true;
	
	ilosc_blyskawic[id] = 0;
	ilosc_rakiet_gracza[id] = 0;
	ilosc_apteczek_gracza[id] = 0;
	ilosc_min_gracza[id] = 0;
	ilosc_dynamitow_gracza[id] = 0;
	ilosc_skokow_gracza[id] = 0;
	ilosc_spadochronow_gracza[id] = 0;
	
	if(para_ent[id] > 0) {
		remove_entity(para_ent[id])
		set_user_gravity(id, 1.0)
		para_ent[id] = 0
	}
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
	if(nowa_klasa_gracza[id]){
		klasa_gracza[id] = nowa_klasa_gracza[id];
		nowa_klasa_gracza[id] = 0;
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
		switch(get_user_team(id))
		{
			case 1: give_item(id, "weapon_glock18");
			case 2: give_item(id, "weapon_usp");
		}
		WczytajDane(id, klasa_gracza[id]);
	}
	
	if(!klasa_gracza[id]){
		WybierzKlase(id);
		return PLUGIN_CONTINUE;
	}
	
	switch(klasa_gracza[id]){
		case Snajper:{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_scout");
			give_item(id, "weapon_deagle");
		}
		case Strzelec, StarszyOficer:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_ak47");
		}
		case Obronca:{
			give_item(id, "weapon_m249");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");				
			give_item(id, "weapon_smokegrenade");
		}
		case Medyk:{
			give_item(id, "weapon_ump45");
			ilosc_apteczek_gracza[id] = 2;
		}	
		case Wsparcie:{
			give_item(id, "weapon_mp5navy");
			ilosc_rakiet_gracza[id] = 2;
		}
		case Saper:{
			give_item(id, "weapon_p90");
			ilosc_min_gracza[id] = 3;
		}
		case Demolitions:{
			give_item(id, "weapon_aug");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
			ilosc_dynamitow_gracza[id] = 1;
		}
		case Rusher: give_item(id, "weapon_m3");
		case HGunner:{
			give_item(id, "weapon_m249");	
			give_item(id, "weapon_hegrenade");
		}
		case Telegrafista:{
			give_item(id, "weapon_aug");
			give_item(id, "weapon_deagle");
			ilosc_min_gracza[id] = 2;
		}
		case Pielegniarka:{
			give_item(id, "weapon_mp5navy");
			ilosc_apteczek_gracza[id] = 5;
		}
		case Partyzant:{
			give_item(id, "weapon_p90");
			give_item(id, "weapon_flashbang");
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 70);
		}
		case Szpieg:{
			give_item(id, "weapon_deagle");
			ZmienUbranie(id, 0);
		}
		case Szturmowiec2:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
		}
		case StrzelecWsparcia:{
			give_item(id, "weapon_g3sg1");
			ilosc_rakiet_gracza[id] = 1 ;
		}
		case LekkiZolnierz:{
			give_item(id, "weapon_galil");
			give_item(id, "weapon_p228");
		}
		case Rebeliant:{
			give_item(id, "weapon_sg552");
			give_item(id, "weapon_hegrenade");
			ilosc_min_gracza[id] = 1 ;
		}
		case SGunner:{
			give_item(id,"weapon_m3")
			give_item(id,"weapon_xm1014")
			give_item(id, "weapon_hegrenade");
		}
		case Shooter:{
			give_item(id,"weapon_m4a1")
			give_item(id,"weapon_ak47")
			give_item(id,"weapon_famas");
		}
		case StrzelecGorski:{
			give_item(id, "weapon_sg550");
			give_item(id, "weapon_sg552");
		}
		case ObroncaWsparcia:{
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_shield");
		}
		case SnajperWyborowy: give_item(id, "weapon_awp");
		case Profesjonalista:{
			give_item(id,"weapon_m4a1")
			give_item(id,"weapon_ak47")
			give_item(id,"item_thighpack");
		}
		case Oficer: give_item(id, "weapon_galil");
		case Podporucznik:{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_elite");
			ilosc_dynamitow_gracza[id] = 1;
		}
		case Lekarz:{
			give_item(id, "weapon_galil");
			ilosc_apteczek_gracza[id] = 5;
		}
		case Policjant:{
			give_item(id, "weapon_famas");
			set_user_footsteps(id, 1);
		}
		case MlodszySzturmowy:{
			give_item(id, "weapon_ak47");
			ilosc_min_gracza[id] = 1 ;
		}
		case Marynarz:{
			give_item(id, "weapon_mac10");
			give_item(id, "weapon_deagle");
		}
		case Sprinter:{
			give_item(id, "weapon_mac10");
			give_item(id, "weapon_ump45");
		}
		case Terminator:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_scout");
			give_item(id, "weapon_deagle");
		}
		case USMC:{
			give_item(id, "weapon_mp5navy");
			give_item(id, "weapon_deagle");
			ilosc_min_gracza[id] = 1 ;
		}
		case Terrorysta:{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_deagle");
			ilosc_min_gracza[id] = 1 ;
		}
		case AntyTerrorysta:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_deagle");
			ilosc_min_gracza[id] = 1 ;
		}
		case Samobojca:{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_deagle");
			ilosc_dynamitow_gracza[id] = 2 ;
		}
		case Uciekinier:{
			give_item(id, "weapon_p90");
			give_item(id, "weapon_deagle");
		}
		case Uzurpator:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_aug");
		}
		case Aspirant:{
			give_item(id, "weapon_ump45");
			give_item(id, "weapon_fiveseven");
		}
		case StarszyChorazy:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_deagle");
		}
		case ChorazySzturmowy:{
			give_item(id, "weapon_deagle");
			ilosc_rakiet_gracza[id] = 1 ;
		}
		case Assasin:{
			give_item(id, "weapon_smokegrenade");
			give_item(id, "weapon_deagle");
		}
		case Pomocnik:{
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_xm1014");
		}
		case Desantowiec:{
			give_item(id, "weapon_scout");
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 204);
		}
		case Przemytnik:{
			get_weaponname(random_num(1, 31), weaponname, 31);
			give_item(id, weaponname);
			ZmienUbranie(id, 0);		
		}
		case CichyZabojca:{
			give_item(id, "weapon_m4a1");
			set_user_footsteps(id, 1);
		}
		case Nalotnik:{
			give_item(id, "weapon_elite");
			set_user_gravity(id, 0.5);
			ilosc_min_gracza[id] = 1;
		}
		case LekkiSkoczek:{
			give_item(id, "weapon_galil");
			give_item(id, "weapon_p228");
		}
		case Matrix:{
			give_item(id, "weapon_elite");
			give_item(id, "weapon_deagle");
		}
		case Wybuchowiec:{
			give_item(id, "weapon_m4a1");	
			give_item(id, "weapon_hegrenade");
		}
		case Radarowiec:{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_deagle");
			radar[id] = true;
		}
		case Minowiec:{
			give_item(id, "weapon_galil");
			ilosc_min_gracza[id] = 5;
		}
		case Avatar, SWAT: give_item(id, "weapon_mp5navy");
		case Komandos, ZolnierzTaktyczny: give_item(id, "weapon_deagle");
		case Pulkownik, MlodszyChorazy:{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_deagle");
		}
		case Neo, Luq, Rambo, MlodszyKomandos:
		{
			give_item(id, "weapon_famas");
		}
		case Zawodowiec, Oporowiec:{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_deagle");
		}
		case StarszySzturmowy, GROM: give_item(id, "weapon_m4a1");
		case StarszyTerrorysta, Furiat, Szturmowiec: give_item(id, "weapon_ak47");
	}
	if(gracz_resetuje[id]){
		ResetujPunkty(id);
		gracz_resetuje[id] = false;
	}
	
	if(punkty_gracza[id]>0) PrzydzielPunkty(id);
	
	if(informacje_przedmiotu_gracza[id][0] == 1)set_user_footsteps(id, 1);
	if(informacje_przedmiotu_gracza[id][0] == 13)give_item(id, "weapon_awp");
	if(informacje_przedmiotu_gracza[id][0] == 60)give_item(id, "weapon_scout");
	if(informacje_przedmiotu_gracza[id][0] == 19)informacje_przedmiotu_gracza[id][1] = 1;
	if(informacje_przedmiotu_gracza[id][0] == 27)informacje_przedmiotu_gracza[id][1] = 3;
	if(informacje_itemu_gracza[id][0] == 35) ilosc_spadochronow_gracza[id] = 1;
	if(informacje_itemu_gracza[id][0] == 36) ilosc_spadochronow_gracza[id] = 2;
	if(informacje_itemu_gracza[id][0] == 37) ilosc_spadochronow_gracza[id] = 3;
	if(informacje_itemu_gracza[id][0] == 38) ilosc_spadochronow_gracza[id] = 4;
	if(informacje_itemu_gracza[id][0] == 39) ilosc_spadochronow_gracza[id] = 5;
	if(informacje_przedmiotu_gracza[id][0] == 35) cs_set_user_money(id, cs_get_user_money(id)+500);	
	if(informacje_przedmiotu_gracza[id][0] == 36) cs_set_user_money(id, cs_get_user_money(id)+1000);	
	if(informacje_przedmiotu_gracza[id][0] == 37) cs_set_user_money(id, cs_get_user_money(id)+1500);	
	if(informacje_przedmiotu_gracza[id][0] == 38) cs_set_user_money(id, cs_get_user_money(id)+2000);	
	if(informacje_przedmiotu_gracza[id][0] == 39) cs_set_user_money(id, cs_get_user_money(id)+2500);	
	if(informacje_przedmiotu_gracza[id][0] == 50) monety_gracza[id] += 1
	if(informacje_przedmiotu_gracza[id][0] == 51) monety_gracza[id] += 2
	if(informacje_przedmiotu_gracza[id][0] == 52) monety_gracza[id] += 3
	if(informacje_przedmiotu_gracza[id][0] == 53) monety_gracza[id] += 4
	if(informacje_przedmiotu_gracza[id][0] == 54) monety_gracza[id] += 5
	if(cs_get_user_money(id) > 16000) cs_set_user_money(id, 16000);

	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(is_user_alive(id))
		if(maxAmmo[weapons[i]] > 0)
		cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
	
	redukcja_obrazen_gracza[id] = (47.3057*(1.0-floatpower( 2.7182, -0.06798*float(wytrzymalosc_gracza[id])))/100);
	maksymalne_zdrowie_gracza[id] = zdrowie_klasy[klasa_gracza[id]]+zdrowie_gracza[id]*1;
	szybkosc_gracza[id] = STANDARDOWA_SZYBKOSC*szybkosc_klasy[klasa_gracza[id]]+floatround(kondycja_gracza[id]*1.3);
	
	if(informacje_przedmiotu_gracza[id][0] == 18){
		maksymalne_zdrowie_gracza[id] += 100;
		szybkosc_gracza[id] -= 0.4;
	}
	
	if(informacje_przedmiotu_gracza[id][0] == 25){
		maksymalne_zdrowie_gracza[id] += 50;
		szybkosc_gracza[id] -= 0.3;
	}
	
	if(informacje_itemu_gracza[id][0] == 6) ilosc_dynamitow_gracza[id] += 1;
	if(informacje_itemu_gracza[id][0] == 7) ilosc_min_gracza[id] += 1;
	if(informacje_itemu_gracza[id][0] == 8) ilosc_rakiet_gracza[id] += 1;
	if(informacje_itemu_gracza[id][0] == 15) ilosc_apteczek_gracza[id] += 1;
	if(informacje_itemu_gracza[id][0] == 9 || informacje_itemu_gracza[id][0] == 21) give_item(id, "weapon_usp");
	if(informacje_itemu_gracza[id][0] == 10) give_item(id, "weapon_glock18");
	if(informacje_itemu_gracza[id][0] == 11 || informacje_itemu_gracza[id][0] == 23) give_item(id, "weapon_m4a1");
	if(informacje_itemu_gracza[id][0] == 12 || informacje_itemu_gracza[id][0] == 24) give_item(id, "weapon_ak47");
	if(informacje_itemu_gracza[id][0] == 13 || informacje_itemu_gracza[id][0] == 22) give_item(id, "weapon_deagle");
	if(informacje_itemu_gracza[id][0] == 14) give_item(id, "weapon_elite");
	if(informacje_itemu_gracza[id][0] == 17) maksymalne_zdrowie_gracza[id] += 5;
	if(informacje_itemu_gracza[id][0] == 18) maksymalne_zdrowie_gracza[id] += 10;
	if(informacje_itemu_gracza[id][0] == 19) maksymalne_zdrowie_gracza[id] += 15;
	if(informacje_itemu_gracza[id][0] == 20) maksymalne_zdrowie_gracza[id] += 20;
	if(informacje_itemu_gracza[id][0] == 25) give_item(id, "weapon_m249");
	if(informacje_itemu_gracza[id][0] == 26) give_item(id, "weapon_galil");
	if(informacje_itemu_gracza[id][0] == 27) give_item(id, "weapon_famas");
	
	if(informacje_itemu_gracza[id][0] == 30){
		give_item(id, "weapon_hegrenade");
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_smokegrenade");
	}
	
	if(informacje_przedmiotu_gracza[id][0] == 29){
		get_weaponname(random_num(1, 31), weaponname, 31);
		give_item(id, weaponname);
	}
	
	
	set_user_armor(id, pancerz_klasy[klasa_gracza[id]]+kamizelka_gracza[id]);
	set_user_health(id, maksymalne_zdrowie_gracza[id]);
	set_user_gravity(id, 1.0);
	if(informacje_przedmiotu_gracza[id][0] == 26){
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 40);
		set_user_health(id, 1)
	}

	if(informacje_przedmiotu_gracza[id][0] == 9) set_user_armor(id, get_user_armor(id) * 2)	
	if(informacje_itemu_gracza[id][0] == 10)give_item(id, "weapon_flashbang");
	if(informacje_przedmiotu_gracza[id][0] == 40) set_user_gravity(id, 0.9);
	if(informacje_przedmiotu_gracza[id][0] == 41) set_user_gravity(id, 0.8);
	if(informacje_przedmiotu_gracza[id][0] == 42) set_user_gravity(id, 0.7);
	if(informacje_przedmiotu_gracza[id][0] == 43) set_user_gravity(id, 0.6);
	if(informacje_przedmiotu_gracza[id][0] == 44) set_user_gravity(id, 0.5);
	if(informacje_przedmiotu_gracza[id][0] == 17) set_user_armor(id, 500);
	if(informacje_przedmiotu_gracza[id][0] == 30) set_user_armor(id, 300);
	if(informacje_przedmiotu_gracza[id][0] == 31) set_user_armor(id, get_user_armor(id) + 10)
	if(informacje_przedmiotu_gracza[id][0] == 32) set_user_armor(id, get_user_armor(id) + 20)
	if(informacje_przedmiotu_gracza[id][0] == 33) set_user_armor(id, get_user_armor(id) + 30)
	if(informacje_przedmiotu_gracza[id][0] == 34) set_user_armor(id, get_user_armor(id) + 40)	
	if(informacje_itemu_gracza[id][0] == 69) ile_nozy[id] = 2
	if(informacje_itemu_gracza[id][0] == 70) ile_nozy[id] = 3	
	if(informacje_itemu_gracza[id][0] == 71) ile_nozy[id] = 4	
	if(informacje_itemu_gracza[id][0] == 72) ile_nozy[id] = 5
	if(informacje_przedmiotu_gracza[id][0] == 71) ilosc_blyskawic[id] = 1;		
	if(informacje_przedmiotu_gracza[id][0] == 72) ilosc_blyskawic[id] = 2;			
	if(informacje_przedmiotu_gracza[id][0] == 73) ilosc_blyskawic[id] = 3;
	
	return PLUGIN_CONTINUE;
}

public PoczatekRundy()	
{
	if(get_playersnum()>g_maxplayers-1 && halflife_time()-czas >= 25){
		set_task(5.0, "dajpodarunek")
		czas=floatround(halflife_time())
	}
	freezetime = false;
	for(new id=0;id<=g_maxplayers;id++){
		if(!is_user_alive(id)) continue;
		set_task(0.1, "UstawSzybkosc", id+ZADANIE_USTAW_SZYBKOSC);
	
		/*
		switch(get_user_team(id))
		{
			case 1: client_cmd(id, "spk QTM_CodMod/start");
				case 2: client_cmd(id, "spk QTM_CodMod/start2");
			}*/
	}
	set_task(1.0, "Odblokuj", -44, _, _, "a", CzasBlokady = 15);
}
public dajpodarunek()
{
	new nowe = 100
	if(noc) nowe = nowe*2
	for (new i=1; i<g_maxplayers; i++) doswiadczenie_gracza[i] += nowe
	ColorChat(0, GREEN, "[uSpiewaKa.eu]^x01 Premia za pelny serwer - %i EXP", nowe)
}
public NowaRunda(id)
{
	freezetime = true;
	new iEnt = find_ent_by_class(-1, "Mine");
	new ent = find_ent_by_class(-1, "dynamite");
	while(iEnt > 0) {
		remove_entity(iEnt);
		iEnt = find_ent_by_class(iEnt, "Mine");	
	}
	while(ent > 0) {
		remove_entity(ent);
		ent = find_ent_by_class(ent, "dynamite");	
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(this) || !is_user_connected(this) || informacje_przedmiotu_gracza[this][0] == 24 || !is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker) || !klasa_gracza[idattacker]) return HAM_IGNORED;
	
	new health = get_user_health(this);
	new weapon = get_user_weapon(idattacker);
	
	if(health < 2) return HAM_IGNORED;
	
	if(informacje_przedmiotu_gracza[this][0] == 27 && informacje_przedmiotu_gracza[this][1]>0){
		informacje_przedmiotu_gracza[this][1]--;
		return HAM_SUPERCEDE;
	}
	
	if(wytrzymalosc_gracza[this]>0) damage -= redukcja_obrazen_gracza[this]*damage;
	if(informacje_przedmiotu_gracza[this][0] == 2 || informacje_przedmiotu_gracza[this][0] == 3) damage-=(float(informacje_przedmiotu_gracza[this][1])<damage)? float(informacje_przedmiotu_gracza[this][1]): damage;
	if(informacje_przedmiotu_gracza[idattacker][0] == 5 && !UTIL_In_FOV(this, idattacker) && UTIL_In_FOV(idattacker, this)) damage*=2.0;
	if(informacje_przedmiotu_gracza[idattacker][0] == 10) damage+=informacje_przedmiotu_gracza[idattacker][1];
	if(informacje_przedmiotu_gracza[this][0] == 12) damage-=(5.0<damage)? 5.0: damage;
	if(informacje_przedmiotu_gracza[idattacker][0] == 21 || !(informacje_itemu_gracza[this][0] == 65) && informacje_itemu_gracza[idattacker][0] == 2)damage+=10;
	if(informacje_przedmiotu_gracza[idattacker][0] == 22 || !(informacje_itemu_gracza[this][0] == 66) && informacje_itemu_gracza[idattacker][0] == 3)damage+=20;
	if(!(informacje_itemu_gracza[this][0] == 64) && informacje_itemu_gracza[idattacker][0] == 1) damage+=3;
	if(!(informacje_itemu_gracza[this][0] == 67) && informacje_itemu_gracza[idattacker][0] == 4) damage+=30;
	if(!(informacje_itemu_gracza[this][0] == 68) && informacje_itemu_gracza[idattacker][0] == 5) damage+=50;
	if(informacje_przedmiotu_gracza[this][0] == 4 && weapon == CSW_KNIFE) damage=damage*1.4+inteligencja_gracza[idattacker];
	if(klasa_gracza[idattacker] == Marynarz) damage+=5;
	if(informacje_przedmiotu_gracza[this][0] == 55 && random(3) == 1) damage == 0	
	if(informacje_itemu_gracza[this][0] == 31) damage-=3;
	if(informacje_itemu_gracza[this][0] == 32) damage-=10;
	if(informacje_itemu_gracza[this][0] == 33) damage-=15;
	if(informacje_itemu_gracza[this][0] == 34)damage-=20;
	if(klasa_gracza[idattacker] == SnajperWyborowy && weapon == CSW_AWP && random(2) == 1 
	|| klasa_gracza[idattacker] == MlodszyKomandos && weapon == CSW_KNIFE && random(2) == 1 
	|| klasa_gracza[idattacker] == Zawodowiec && weapon == CSW_DEAGLE && random(5) == 1 
	|| klasa_gracza[idattacker] == ChorazySzturmowy && weapon == CSW_DEAGLE && random(5) == 1 
	|| klasa_gracza[idattacker] == StarszyChorazy && weapon == CSW_DEAGLE && random(9) == 1 
	|| klasa_gracza[idattacker] == MlodszyChorazy && weapon == CSW_DEAGLE && random(6) == 1 
	|| klasa_gracza[idattacker] == Pulkownik && weapon == CSW_DEAGLE && random(20) == 1
	|| !(informacje_itemu_gracza[this][0] == 63) && informacje_itemu_gracza[idattacker][0] == 14 && weapon == CSW_ELITE && random(3) == 1
	|| !(informacje_itemu_gracza[this][0] == 62) && informacje_itemu_gracza[idattacker][0] == 13 && weapon == CSW_DEAGLE && random(3) == 1
	|| !(informacje_itemu_gracza[this][0] == 61) && informacje_itemu_gracza[idattacker][0] == 12 && weapon == CSW_AK47 && random(10) == 1
	|| !(informacje_itemu_gracza[this][0] == 60) && informacje_itemu_gracza[idattacker][0] == 11 && weapon == CSW_M4A1 && random(10) == 1
	|| !(informacje_itemu_gracza[this][0] == 59) && informacje_itemu_gracza[idattacker][0] == 10 && weapon == CSW_GLOCK18 && random(3) == 1
	|| !(informacje_itemu_gracza[this][0] == 58) && informacje_itemu_gracza[idattacker][0] == 9 && weapon == CSW_USP && random(3) == 1
	|| weapon == CSW_SCOUT && informacje_przedmiotu_gracza[idattacker][0] == 60 || weapon == CSW_AWP && informacje_przedmiotu_gracza[idattacker][0] == 13
	|| informacje_przedmiotu_gracza[idattacker][0] == 8 && weapon == CSW_KNIFE || (klasa_gracza[idattacker] == Snajper && random(2) == 2) && weapon == CSW_KNIFE 
	|| klasa_gracza[idattacker] == Komandos && !(get_user_button(idattacker) & IN_ATTACK) && weapon == CSW_KNIFE)
		damage = float(health);
	if(damage <= 20) damage == random_num(10, 30)	
	if(informacje_przedmiotu_gracza[idattacker][0] == 61) damage=damage*1.01	
	if(informacje_przedmiotu_gracza[idattacker][0] == 62) damage=damage*1.02	
	if(informacje_przedmiotu_gracza[idattacker][0] == 63) damage=damage*1.03	
	if(informacje_przedmiotu_gracza[idattacker][0] == 64)damage=damage*1.04	
	if(informacje_przedmiotu_gracza[idattacker][0] == 65) damage=damage*1.05	
	if(informacje_przedmiotu_gracza[idattacker][0] == 66) damage=damage*1.10	
	if(informacje_przedmiotu_gracza[idattacker][0] == 67) damage=damage*1.15	
	if(informacje_przedmiotu_gracza[idattacker][0] == 68) damage=damage*1.20	
		
	SetHamParamFloat(4, damage);
	return HAM_IGNORED;
}

public Damage(id)
{
	new attacker = get_user_attacker(id);
	new damage = read_data(2);
	if(!is_user_alive(attacker) || !is_user_connected(attacker) || id == attacker || !klasa_gracza[attacker]  || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	if(informacje_przedmiotu_gracza[attacker][0] == 12 && (random_num(1, informacje_przedmiotu_gracza[id][1]) == 1)) Display_Fade(id,1<<14,1<<14 ,1<<16,255,155,50,230);
		
	if(get_user_team(id) != get_user_team(attacker)){
		while(damage>20){
			damage-=20;
			doswiadczenie_gracza[attacker]++;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public Death()
{
	new id = read_data(2);
	new attacker = read_data(1);
	parachute_reset(id); 
	
	if(!is_user_alive(attacker) || !is_user_connected(attacker) || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	new zdrowie = get_user_health(attacker);
	
	if(!informacje_przedmiotu_gracza[attacker][0]) DajPrzedmiot(attacker, random_num(1, sizeof nazwy_przedmiotow-1));
	if(!informacje_itemu_gracza[attacker][0]) DajItem(attacker, random_num(1, sizeof nazwy_przedmiotow-1));

	if(informacje_przedmiotu_gracza[id][0]) {
		if(wytrzymalosc_przedmiotu[id] > 0) wytrzymalosc_przedmiotu[id]-=10;
		if(wytrzymalosc_przedmiotu[id] > 0) ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Zniszczenia przedmiotu 1: %i/100", wytrzymalosc_przedmiotu[id]);
		else {
			ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Przedmiot 1 %s zostal calkowicie zniszczony.", nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]]);
			UsunPrzedmiot(id);
		}
	}
	if(informacje_itemu_gracza[id][0]) {
		if(wytrzymalosc_itemu[id] > 0) wytrzymalosc_itemu[id]-=10;
		if(wytrzymalosc_itemu[id] > 0)  ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Zniszczenia przedmiotu 2: %i/100", wytrzymalosc_itemu[id]);
		else {
			ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Przedmiot 2 %s zostal calkowicie zniszczony.", nazwy_itemow[informacje_itemu_gracza[id][0]]);
			UsunItem(id);
		}
	}
	if(get_user_team(id) != get_user_team(attacker) && klasa_gracza[attacker]){
		new Players[32], zablokuj;
		get_players(Players, zablokuj, "ch");
		if(zablokuj < 3) return PLUGIN_CONTINUE;
		new nowe_doswiadczenie = 300;
		monety_gracza[attacker] += 1;
		
		if (informacje_itemu_gracza[attacker][0] == 39) nowe_doswiadczenie += 10
		if (informacje_itemu_gracza[attacker][0] == 40) nowe_doswiadczenie += 30
		if (informacje_itemu_gracza[attacker][0] == 41) nowe_doswiadczenie += 50
		if (informacje_itemu_gracza[attacker][0] == 29) nowe_doswiadczenie += 100;
		if (poziom_gracza[id] > poziom_gracza[attacker]) nowe_doswiadczenie += poziom_gracza[id] - poziom_gracza[attacker];
		
		if (informacje_przedmiotu_gracza[attacker][0] == 14 || klasa_gracza[attacker] == Neo || klasa_gracza[attacker] == Luq){
			new nowe_zdrowie = (zdrowie+50<maksymalne_zdrowie_gracza[attacker])? zdrowie+50: maksymalne_zdrowie_gracza[attacker];
			set_user_health(attacker, nowe_zdrowie);
		}
		if(noc) nowe_doswiadczenie = nowe_doswiadczenie * 2
		set_hudmessage (255, 212, 0, 0.5, 0.33, 0, 6.0, 4.0, 0.1, 0.2, 3);
		show_hudmessage(attacker, "+%i", nowe_doswiadczenie);
		doswiadczenie_gracza[attacker] += nowe_doswiadczenie;
	}
	if(klasa_gracza[id] == Wybuchowiec)
	{
		new Float:fOrigin[3], iOrigin[3];
		entity_get_vector(id, EV_VEC_origin, fOrigin);
                
		iOrigin[0] = floatround(fOrigin[0]);
		iOrigin[1] = floatround(fOrigin[1]);
		iOrigin[2] = floatround(fOrigin[2]);
                
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast);
		write_byte(32); // scale
		write_byte(20); // framerate
		write_byte(0);// flags
		message_end();
                
		static victim
		victim = -1;
                
		while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, fOrigin, 90.0)) != 0){  // 90 = obszar wybuchu{               
			if (!is_user_alive(victim)) continue;
                
			ExecuteHam(Ham_TakeDamage, victim, 0, id, 100.0, 1);  // 100.0 zabrane dmg
		}
		new Players[32], zablokuj;
		get_players(Players, zablokuj, "ch");
		if(zablokuj < 3) return PLUGIN_CONTINUE;
		doswiadczenie_gracza[id] += 50
		SprawdzPoziom(id);
	}
	radar[id] = false;
	zoom[id] = true;
	zoom1[id] = true;
	zoom2[id] = true;
	zoom3[id] = true;
	zoom4[id] = true;
	zoom5[id] = true;
	zoom6[id] = true;
	SprawdzPoziom(attacker);
	
	if(informacje_przedmiotu_gracza[id][0] == 7 && (random_num(1, informacje_przedmiotu_gracza[id][1]) == 1)) set_task(0.1, "Wskrzes", id+ZADANIE_WSKRZES);
	if(queston[id] == 8 || queston[id] == 9 || queston[id] == 10 || queston[id] == 11 || queston[id] == 12 || queston[id] == 13 || queston[id] == 14 || queston[id] == 22 || queston[id] == 23 || queston[id] == 24 || queston[id] == 25 || queston[id] == 26 || queston[id] == 27 || queston[id] == 28){
		killquest[id] = 0
		queston[id] = 0
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 0.1, 0.2, 3)
		show_hudmessage(id, "Nie udalo Ci sie wykonac misji")
		ColorChat(id,RED,"[uSpiewaKa.eu]^x01 Nie udalo Ci sie wykonac misji");
	}
	if(queston[attacker] == 1 && frakcja_gracza[id] == 1 || queston[attacker] == 2 && frakcja_gracza[id] == 2 || queston[attacker] == 3 && frakcja_gracza[id] == 3|| queston[attacker] == 4 && frakcja_gracza[id] == 4 ||
	queston[attacker] == 5 && frakcja_gracza[id] == 5 || queston[attacker] == 6 && frakcja_gracza[id] == 6 || queston[attacker] == 7 || queston[attacker] == 8  && frakcja_gracza[id] == 1 ||
	queston[attacker] == 9  && frakcja_gracza[id] == 2 || queston[attacker] == 10  && frakcja_gracza[id] == 3 || queston[attacker] == 11 && frakcja_gracza[id] == 4 || queston[attacker] == 12  && frakcja_gracza[id] == 5 ||
	queston[attacker] == 13  && frakcja_gracza[id] == 6 || queston[attacker] == 14){
		killquest[attacker] += 1
		if(killquest[attacker] == wymogquest[queston[attacker]]){
			new Players[32], zablokuj;
			get_players(Players, zablokuj, "ch");
			if(zablokuj < 3) return PLUGIN_CONTINUE;
			doswiadczenie_gracza[attacker] += nagrodyquest[queston[attacker]]
			ColorChat(attacker,BLUE,"[uSpiewaKa.eu]^x01 Wykonales misje '%s'", nazwy_misji[queston[attacker]]);
			/*new name[32]
			get_user_name(attacker, name, 31) 
			set_hudmessage(0, 127, 255, -1.0, 0.20, 0, 6.0, 5.0, 0.1, 0.2, 3)
			show_hudmessage(0, "Gratulacje!^n%s wykonal misje '%s'", name, nazwy_misji[queston[attacker]])*/
			killquest[attacker] = 0
			queston[attacker] = 0
		}
	}

	return PLUGIN_CONTINUE;
}

public client_connect(id)
{
	klasa_gracza[id] = 0;
	poziom_gracza[id] = 0;
	monety_gracza[id] = 0;
	doswiadczenie_gracza[id] = 0;
	punkty_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	inteligencja_gracza[id] = 0;
	grawitacja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	maksymalne_zdrowie_gracza[id] = 0;
	szybkosc_gracza[id] = 0.0;
	wytrzymalosc_przedmiotu[id] = 0;
	wytrzymalosc_itemu[id] = 0;
	radar[id] = false;
	player_b_bank[id]= 0;
	player_b_bankdurability[id]= 0
	player_b_bank2[id]= 0
	player_b_bankdurability2[id]=0
	queston[id]=0
	killquest[id]=0
	zoom[id] = true;
	zoom1[id] = true;
	zoom2[id] = true;
	zoom3[id] = true;
	zoom4[id] = true;
	zoom5[id] = true;
	zoom6[id] = true;
	ranga_gracza[id] = 0
	opcja_wyboru[id] = 0
	
	get_user_name(id, nazwa_gracza[id], 63);
	
	remove_task(id+ZADANIE_POKAZ_INFORMACJE);
	remove_task(id+ZADANIE_WSKRZES);
	remove_task(id+ZADANIE_WYSZKOLENIE_SANITARNE);
	remove_task(id+ZADANIE_USTAW_SZYBKOSC);
	set_task(3.0, "PokazInformacje", id+ZADANIE_POKAZ_INFORMACJE);
	client_cmd(id, "bind ^"c^" ^"radio3^"")
	UsunPrzedmiot(id);
	UsunItem(id);
	ResetujPunkty(id);
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	remove_task(id+ZADANIE_POKAZ_INFORMACJE);
	remove_task(id+ZADANIE_WSKRZES);
	remove_task(id+ZADANIE_WYSZKOLENIE_SANITARNE);
	remove_task(id+ZADANIE_USTAW_SZYBKOSC);
	ZapiszDane(id);
	UsunPrzedmiot(id);
	UsunItem(id);
	parachute_reset(id);
	new ent = find_ent_by_class(0, "dynamite");
	while(ent > 0) {
		if(entity_get_edict(id, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "dynamite");
	}
	new ent1	    
	while((ent1 = fm_find_ent_by_owner(ent1, "fake_corpse", id)) != 0) fm_remove_entity(ent1)
	return PLUGIN_CONTINUE;
}

public OpisKlasy(id)
{
	new menu = menu_create("Wybierz frakcje:", "OpisKlasy_Handle");
	for(new i = 1;i<sizeof(frakcje);i++) menu_additem(menu, frakcje[i]);
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public OpisKlasy_Handle(id, menu2, item)
{       
	if(item == MENU_EXIT){
		menu_destroy(menu2);
		return PLUGIN_CONTINUE;
	}       
	
	item++;
	frakcja_gracza[id] = item;
	new menu = menu_create("Wybierz klase:", "OpisKlasy2_Handle");
	new klasa[50];
	for(new i=1; i<sizeof nazwy_klas; i++){
		if(nalezy_do[i] == item){
			format(klasa, 49, "%s", nazwy_klas[i]);
			menu_additem(menu, klasa);
		}
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_display(id, menu);
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	return PLUGIN_CONTINUE;
}

public OpisKlasy2_Handle(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}       
	
	item++;
	new ile = 0;
	for(new i=1; i<sizeof nazwy_klas; i++){
		if(nalezy_do[i] == frakcja_gracza[id]) ile++;
		if(ile == item){
			item = i;
			break;
		}
	}
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 %s : %s", nazwy_klas[item], opisy_klas[item]);
		
	return PLUGIN_CONTINUE;
}
public OpisyMenu(id)
{
	new menu = menu_create("Opisy \rprzedmiotow:", "OpisyMenu_Handle");
	menu_additem(menu, "Przedmioty 1");
	menu_additem(menu, "Przedmioty 2");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public OpisyMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: OpisyPrzedmiotu(id)
		case 1: OpisyItemu(id)
	}
	return PLUGIN_CONTINUE;
}
public OpisyPrzedmiotu(id)
{
	new menu = menu_create("Wybierz przedmiot 1:", "OpisPrzedmiotu_Handle");
	for(new i=1; i<sizeof nazwy_przedmiotow; i++) menu_additem(menu, nazwy_przedmiotow[i]);
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_display(id, menu);
	client_cmd(id, "spk QTM_CodMod/select");
	return PLUGIN_HANDLED;
}

public OpisPrzedmiotu_Handle(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 %s : %s", nazwy_przedmiotow[item+1], opisy_przedmiotow[item+1]);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}
public OpisyItemu(id)
{
	new menu = menu_create("Wybierz przedmiot 2:", "OpisItemu_Handle");
	for(new i=1; i<sizeof nazwy_itemow; i++) menu_additem(menu, nazwy_itemow[i]);
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_display(id, menu);
	client_cmd(id, "spk QTM_CodMod/select");
	return PLUGIN_HANDLED;
}

public OpisItemu_Handle(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 %s : %s", nazwy_itemow[item+1], opisy_itemow[item+1]);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}
public WybierzKlase(id)
{
	new menu2 = menu_create("Wybierz frakcje:", "Wybierzfrakcje_Handle");
	for(new i = 1;i<sizeof(frakcje);i++) menu_additem(menu2, frakcje[i]);
	menu_display(id, menu2);
	return PLUGIN_HANDLED;
}

public Wybierzfrakcje_Handle(id, menu2, item)
{       
	if(item == MENU_EXIT){
		menu_destroy(menu2);
		return PLUGIN_CONTINUE;
	}       
	
	item++;
	frakcja_gracza[id] = item;
	new menu2 = menu_create("Wybierz klase:", "WybierzKlase_Handle");
	new klasa[50];
	for(new i=1; i<sizeof nazwy_klas; i++){
		if(nalezy_do[i] == item){
			WczytajDane(id, i);
			format(klasa, 49, "%s %s \yPoziom: %i", nazwy_rang2[ranga_gracza[id]], nazwy_klas[i], poziom_gracza[id]);
			menu_additem(menu2, klasa);
		}
	}
	WczytajDane(id, klasa_gracza[id]);
	menu_setprop(menu2, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu2, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu2, MPROP_NEXTNAME, "Nastepna strona");
	menu_display(id, menu2);
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	return PLUGIN_CONTINUE;
}

public WybierzKlase_Handle(id, menu2, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu2);
		return PLUGIN_CONTINUE;
	}       
	
	item++;
	
	new ile = 0;
	for(new i=1; i<sizeof nazwy_klas; i++){
		if(nalezy_do[i] == frakcja_gracza[id]) ile++;
		if(ile == item){
			item = i;
			break;
		}
	}
	
	
	if(item == klasa_gracza[id]) return PLUGIN_CONTINUE;
		
	if((item == Samobojca && ranga_gracza[id] < 1 || item == Uzurpator && ranga_gracza[id] < 2 || item == Uciekinier && ranga_gracza[id] < 3 || item == Pulkownik && ranga_gracza[id] < 4 || item == StarszyTerrorysta && ranga_gracza[id] < 7 || item == StarszyOficer && ranga_gracza[id] < 9 || ((item == Neo || item == Luq || item == Avatar || item == Zawodowiec || item == Radarowiec || item == Minowiec || item == Wybuchowiec) && ranga_gracza[id] < 15)) && !(get_user_flags(id) & ADMIN_LEVEL_H)){
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Kup premium do tej klasy.");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		WybierzKlase(id);
		return PLUGIN_CONTINUE;
	}
	if(klasa_gracza[id]){
		nowa_klasa_gracza[id] = item;
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Klasa zostanie zmieniona w nastepnej rundzie.");
	}
	else{
		klasa_gracza[id] = item;
		WczytajDane(id, klasa_gracza[id]);
		Odrodzenie(id);
	}
	return PLUGIN_CONTINUE;
}
public PrzydzielPunkty(id)
{
	new inteligencja[65];
	new zdrowie[60];
	new wytrzymalosc[60];
	new kondycja[60];
	new kamizelka[60];
	new grawitacja[60];
	new tytul[25];
	format(inteligencja, 64, "Inteligencja: \r(%i/200) \y(Zwieksza obrazenia zadawane przedmiotami)", inteligencja_gracza[id]);
	format(zdrowie, 59, "Zdrowie: \r(%i/100) \y(Zwieksza zycie)", zdrowie_gracza[id]);
	format(wytrzymalosc, 59, "Wytrzymalosc: \r(%i/50) \y(Zmniejsza obrazenia)", wytrzymalosc_gracza[id]);
	format(kondycja, 59, "Kondycja: \r(%i/100) \y(Zwieksza tempo chodu)", kondycja_gracza[id]);
	format(kamizelka, 60, "Kamizelka: \r(%i/200) \y(Zwieksza kamizelke)", kamizelka_gracza[id]);
	format(grawitacja, 60, "Grawitacja: \r(%i/100) \y(Zmniejsza grawitacje)", grawitacja_gracza[id]);
	format(tytul, 24, "Przydziel Punkty(%i):", punkty_gracza[id]);
	new menu = menu_create(tytul, "PrzydzielPunkty_Handler");
	menu_additem(menu, inteligencja);
	menu_additem(menu, zdrowie);
	menu_additem(menu, wytrzymalosc);
	menu_additem(menu, kondycja);
	menu_additem(menu, kamizelka);
	menu_additem(menu, grawitacja);
	menu_additem(menu, "Przydziel losowo \r1 punkt");
	menu_additem(menu, "Dodaj wszystko w \rinteligencje");
	menu_additem(menu, "Dodaj wszystko w \rzdrowie");
	menu_additem(menu, "Dodaj wszystko w \rwytrzymalosc");
	menu_additem(menu, "Dodaj wszystko w \rkondycje");
	menu_additem(menu, "Dodaj wszystko w \rkamizelke");
	menu_additem(menu, "Dodaj wszystko w \rgrawitacje");
	menu_additem(menu, "Dodaj wszystko \rlosowo");
	menu_display(id, menu);

}
public PrzydzielPunkty_Handler(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item) 
	{ 
		case 0: {	
			if(inteligencja_gracza[id]<100){
				inteligencja_gracza[id]++;
				client_print(id, print_center, "Dodano punkt inteligencji!");
			}
			else {
				client_print(id, print_center, "Maksymalny poziom inteligencji osiagniety!");
				punkty_gracza[id]++;
			}
			
		}
		case 1: {	
			if(zdrowie_gracza[id]<100){
				zdrowie_gracza[id]++;
				client_print(id, print_center, "Dodano punkt zdrowia!");
			}
			else {
				client_print(id, print_center, "Maksymalny poziom zdrowia osiagniety!");
				punkty_gracza[id]++;
			}
		}
		case 2: {	
			if(wytrzymalosc_gracza[id]<50){
				wytrzymalosc_gracza[id]++;
				client_print(id, print_center, "Dodano punkt wytrzymalosci!");
			}
			else {
				client_print(id, print_center, "Maksymalny poziom wytrzymalosci osiagniety!");
				punkty_gracza[id]++;
			}
			
		}
		case 3: {	
			if(kondycja_gracza[id]<100){
				kondycja_gracza[id]++;
				client_print(id, print_center, "Dodano punkt kondycji!");
			}
			else {
				client_print(id, print_center, "Maksymalny poziom kondycji osiagniety!");
				punkty_gracza[id]++;
			}
		}
		case 4: {	
			if(kamizelka_gracza[id]<200){
				kamizelka_gracza[id]++;
				client_print(id, print_center, "Dodano punkt kamizelki!");
			}
			else {
				client_print(id, print_center, "Maksymalny poziom kamizelki osiagniety!");
				punkty_gracza[id]++;
			}
		}
		case 5: {	
			if(grawitacja_gracza[id]<100){
				grawitacja_gracza[id]++;
				client_print(id, print_center, "Dodano punkt grawitacji!");
			}
			else {
				client_print(id, print_center, "Maksymalny poziom grawitacji osiagniety.!");
				punkty_gracza[id]++;
			}
		}
		case 6: {
			PrzydzielPunkty_Handler(id, menu, random_num(0,5))
			punkty_gracza[id]++;
		}
		case 7: {       
			if (punkty_gracza[id]+inteligencja_gracza[id] <= 200){
				inteligencja_gracza[id]+=punkty_gracza[id]
				punkty_gracza[id]=0
				client_print(id, print_center, "Dodano wszystko w inteligencje!");
			}
			else{
				punkty_gracza[id]-=200-inteligencja_gracza[id]
				inteligencja_gracza[id]=200
				client_print(id, print_center, "Maksymalny poziom inteligencji osiagniety!");
			}
		}
		case 8: {       
			if (punkty_gracza[id]+zdrowie_gracza[id] <= 100){
				zdrowie_gracza[id]+=punkty_gracza[id]
				punkty_gracza[id]=0
				client_print(id, print_center, "Dodano wszystko w zdrowie!");
			}
			else{
				punkty_gracza[id]-=100-zdrowie_gracza[id]
				zdrowie_gracza[id]=100
				client_print(id, print_center, "Maksymalny poziom zdrowia osiagniety!");
			}
		}
		case 9: {       
			if (punkty_gracza[id]+wytrzymalosc_gracza[id] <= 50){
				wytrzymalosc_gracza[id]+=punkty_gracza[id]
				punkty_gracza[id]=0
				client_print(id, print_center, "Dodano wszystko w wytrzymalosc!");
			}
			else{
				punkty_gracza[id]-=50-wytrzymalosc_gracza[id]
				wytrzymalosc_gracza[id]=50
				client_print(id, print_center, "Maksymalny poziom wytrzymalosci osiagniety!");
			}
		}
		case 10: {       
			if (punkty_gracza[id]+kondycja_gracza[id] <= 100){
				kondycja_gracza[id]+=punkty_gracza[id]
				punkty_gracza[id]=0
				client_print(id, print_center, "Dodano wszystko w kondycje!");
			}
			else{
				punkty_gracza[id]-=100-kondycja_gracza[id]
				kondycja_gracza[id]=100
				client_print(id, print_center, "Maksymalny poziom kondycji osiagniety!");
			}
		}
		case 11: {       
			if (punkty_gracza[id]+kamizelka_gracza[id] <= 200){
				kamizelka_gracza[id]+=punkty_gracza[id]
				punkty_gracza[id]=0
				client_print(id, print_center, "Dodano wszystko w kamizelke!");
			}
			else{
				punkty_gracza[id]-=200-kamizelka_gracza[id]
				kamizelka_gracza[id]=200
				client_print(id, print_center, "Maksymalny poziom kamizelki osiagniety!");
			}
		}
		case 12: {       
			if (punkty_gracza[id]+grawitacja_gracza[id] <= 100){
				grawitacja_gracza[id]+=punkty_gracza[id]
				punkty_gracza[id]=0
				client_print(id, print_center, "Dodano wszystko w grawitacje!");
			}
			else{
				punkty_gracza[id]-=100-grawitacja_gracza[id]
				grawitacja_gracza[id]=100
				client_print(id, print_center, "Maksymalny poziom grawitacji osiagniety!");
			}
		}
		case 13: {
			PrzydzielPunkty_Handler(id, menu, random_num(7,12))
			punkty_gracza[id]++;
		}
	}
	punkty_gracza[id]--;
	
	if(punkty_gracza[id]>0) PrzydzielPunkty(id);
	
	return PLUGIN_CONTINUE;
}

public ResetujPunkty(id)
{	
	punkty_gracza[id] = poziom_gracza[id]+(ranga_gracza[id]*5);
	inteligencja_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	kamizelka_gracza[id] = 0;
	grawitacja_gracza[id] = 0;
}


public KomendaResetujPunkty(id)
{	
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Umiejetnosci zostana zresetowane w nastepnej rundzie.");
	client_cmd(id, "spk QTM_CodMod/select");
	gracz_resetuje[id] = true;
	return PLUGIN_HANDLED;
}

public WyszkolenieSanitarne(id)
{
	id -= ZADANIE_WYSZKOLENIE_SANITARNE;
	if(informacje_przedmiotu_gracza[id][0] != 16 || informacje_itemu_gracza[id][0] != 16) return PLUGIN_CONTINUE;
	set_task(5.0, "WyszkolenieSanitarne", id+ZADANIE_WYSZKOLENIE_SANITARNE);
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;
	new health = get_user_health(id);
	new new_health = (health+10<maksymalne_zdrowie_gracza[id])?health+10:maksymalne_zdrowie_gracza[id];
	set_user_health(id, new_health);
	return PLUGIN_CONTINUE;
}

public StworzApteczke(id)
{
	if (!ilosc_apteczek_gracza[id]){
		client_print(id, print_center, "Masz tylko 2 apteczki na runde!");
		return PLUGIN_CONTINUE;
	}
	
	if(inteligencja_gracza[id] < 1) client_print(id, print_center, "Aby wzmocnic apteczke, zwieksz inteligencje!");
	
	ilosc_apteczek_gracza[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "Apteczka");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);
	
	entity_set_model(ent, "models/w_medkit.mdl");
	set_rendering ( ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255 ) 	;
	drop_to_floor(ent);
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	
	return PLUGIN_CONTINUE;
}

public ApteczkaThink(ent)
{
	new id = entity_get_edict(ent, EV_ENT_owner);
	new totem_dist = 300;
	new totem_heal = 5+floatround(inteligencja_gracza[id]*0.5);
	if (entity_get_edict(ent, EV_ENT_euser2) == 1){		
		new Float:forigin[3], origin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);
		FVecIVec(forigin,origin);
		
		new entlist[33];
		new numfound = find_sphere_class(0,"player",totem_dist+0.0,entlist, 32,forigin);
		
		for (new i=0; i < numfound; i++){		
			new pid = entlist[i];
			
			if (get_user_team(pid) != get_user_team(id)) continue;
			
			new zdrowie = get_user_health(pid);
			new nowe_zdrowie = (zdrowie+totem_heal<maksymalne_zdrowie_gracza[pid])?zdrowie+totem_heal:maksymalne_zdrowie_gracza[pid];
			if (is_user_alive(pid)) set_user_health(pid, nowe_zdrowie);		
		}
		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id)){
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time()) set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 ) ;
	
	new Float:forigin[3], origin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);
	FVecIVec(forigin,origin);
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, origin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( origin[0] );
	write_coord( origin[1] );
	write_coord( origin[2] );
	write_coord( origin[0] );
	write_coord( origin[1] + totem_dist );
	write_coord( origin[2] + totem_dist );
	write_short( sprite_white );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 10 );
	write_byte( 10 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 100 );
	write_byte( 100 );
	write_byte( 128 );
	write_byte( 5 );
	message_end();
	
	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);
	
	
	return PLUGIN_CONTINUE;
	
}

public StworzRakiete(id)
{
	if (!ilosc_rakiet_gracza[id]){
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
		return PLUGIN_CONTINUE;
	}
	
	if(poprzednia_rakieta_gracza[id] + 5.0 > get_gametime()){
		client_print(id, print_center, "Rakiet mozesz uzywac co 5 sekund!");
		return PLUGIN_CONTINUE;
	}
	
	if (is_user_alive(id)){	
		if(inteligencja_gracza[id] < 1) client_print(id, print_center, "Aby wzmocnic rakiete, zwieksz inteligencje!");
		
		poprzednia_rakieta_gracza[id] = get_gametime();
		ilosc_rakiet_gracza[id]--;
		
		new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];
		
		entity_get_vector(id, EV_VEC_v_angle, vAngle);
		entity_get_vector(id, EV_VEC_origin , Origin);
		
		new Ent = create_entity("info_target");
		
		entity_set_string(Ent, EV_SZ_classname, "Rocket");
		entity_set_model(Ent, "models/rpgrocket.mdl");
		
		vAngle[0] *= -1.0;
		
		entity_set_origin(Ent, Origin);
		entity_set_vector(Ent, EV_VEC_angles, vAngle);
		
		entity_set_int(Ent, EV_INT_effects, 2);
		entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
		entity_set_edict(Ent, EV_ENT_owner, id);
		
		VelocityByAim(id, 1000 , Velocity);
		entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
	}	
	return PLUGIN_CONTINUE;
}

public PolozDynamit(id)
{
	if(!ilosc_dynamitow_gracza[id]){
		client_print(id, print_center, "Wykorzystales juz caly dynamit!");
		return PLUGIN_CONTINUE;
	}
	
	if(poprzednia_dynamit_gracza[id] + 5.0 > get_gametime()){
		client_print(id, print_center, "Rakiet mozesz uzywac co 5 sekund!");
		return PLUGIN_CONTINUE;
	}
	
	if(inteligencja_gracza[id] < 1) client_print(id, print_center, "Aby wzmocnic dynamit, zwieksz inteligencje!");
	
	poprzednia_dynamit_gracza[id] = get_gametime();
	ilosc_dynamitow_gracza[id]--;
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 10 );
	write_byte( 10 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 100 );
	write_byte( 100 );
	write_byte( 128 );
	write_byte( 8 );
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 300.0 , entlist, 32);
	
	for (new i=0; i < numfound; i++){		
		new pid = entlist[i];
		if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid) || informacje_przedmiotu_gracza[pid][0] == 24 || klasa_gracza[pid] == Wybuchowiec || klasa_gracza[pid] == Neo || klasa_gracza[pid] == Luq || klasa_gracza[pid] == Avatar || klasa_gracza[pid] == Zawodowiec || klasa_gracza[pid] == Radarowiec || klasa_gracza[pid] == Minowiec) continue;
		ExecuteHam(Ham_TakeDamage, pid, 0, id, 90.0+float(inteligencja_gracza[id]) , 1);
	}
	return PLUGIN_CONTINUE;
}

public PostawMine(id)
{
	if (!ilosc_min_gracza[id]){
		client_print(id, print_center, "Wykorzystales juz wszystkie miny!");
		return PLUGIN_CONTINUE;
	}
	
	if(inteligencja_gracza[id] < 1) client_print(id, print_center, "Aby wzmocnic miny, zwieksz inteligencje!");
	
	ilosc_min_gracza[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent ,EV_SZ_classname, "Mine");
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, "models/mine.mdl");
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	
	drop_to_floor(ent);
	
	entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01) ;
	
	set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50)	;
	
	
	return PLUGIN_CONTINUE;
}

public DotykMiny(ent, id)
{
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id)){
		new Float:fOrigin[3], iOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);
		iOrigin[0] = floatround(fOrigin[0]);
		iOrigin[1] = floatround(fOrigin[1]);
		iOrigin[2] = floatround(fOrigin[2]);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast);
		write_byte(32); // scale
		write_byte(20); // framerate
		write_byte(0);// flags
		message_end();
		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);
		
		for (new i=0; i < numfound; i++){		
			new pid = entlist[i];
			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid) || informacje_przedmiotu_gracza[pid][0] == 24 || klasa_gracza[pid] == Obronca || klasa_gracza[pid] == ZolnierzTaktyczny  || klasa_gracza[pid] == Wybuchowiec || klasa_gracza[pid] == Neo || klasa_gracza[pid] == Luq || klasa_gracza[pid] == Avatar || klasa_gracza[pid] == Zawodowiec || klasa_gracza[pid] == Radarowiec || klasa_gracza[pid] == Minowiec) continue;
			ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 90.0+float(inteligencja_gracza[attacker]) , 1);
		}
		remove_entity(ent);
	}
}

public DotykRakiety(ent)
{
	if ( !is_valid_ent(ent)) return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fOrigin);	
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32); // scale
	write_byte(20); // framerate
	write_byte(0);// flags
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 230.0, entlist, 32);
	
	for (new i=0; i < numfound; i++){		
		new pid = entlist[i];
		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid) || informacje_przedmiotu_gracza[pid][0] == 24  || klasa_gracza[pid] == Wybuchowiec || klasa_gracza[pid] == Neo || klasa_gracza[pid] == Luq || klasa_gracza[pid] == Avatar || klasa_gracza[pid] == Zawodowiec || klasa_gracza[pid] == Radarowiec || klasa_gracza[pid] == Minowiec) continue;
		ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 55.0+float(inteligencja_gracza[attacker]) , 1);
	}
	remove_entity(ent);
}	

public CurWeapon(id)
{
	if(freezetime || !klasa_gracza[id]) return PLUGIN_CONTINUE;
	
	if(task_exists(-44) && is_user_alive(id)){
		new ammo, clip, weapon = get_user_weapon(id, ammo, clip)
		if(weapon==CSW_HEGRENADE){
			client_cmd(id, "lastinv") 
			client_print(id, print_center, "Z granatu HE korzystamy od 2:45");
		}
	}
	UstawSzybkosc(id)
	return PLUGIN_CONTINUE;
}

public EmitSound(id, iChannel, szSound[], Float:fVol, Float:fAttn, iFlags, iPitch ) 
{
	if(equal(szSound, "common/wpn_denyselect.wav")){
		UzyjPrzedmiotu(id);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public UzyjPrzedmiotu(id)
{
	if(informacje_przedmiotu_gracza[id][0] == 19 && informacje_przedmiotu_gracza[id][1]>0) {
		set_user_health(id, maksymalne_zdrowie_gracza[id]);
		informacje_przedmiotu_gracza[id][1]--;
	}
	
	if(ilosc_apteczek_gracza[id]>0) StworzApteczke(id);
	if(ilosc_min_gracza[id]>0) PostawMine(id);
	
	if(task_exists(-44) && (ilosc_rakiet_gracza[id]>0 || ilosc_dynamitow_gracza[id]>0) && is_user_alive(id)){
		client_print(id, print_center, "Rakiety i dynamity za %i sekund.", CzasBlokady);
		set_pdata_float(id, 83, 0.1 , 5);
	}
	else{	
		if(ilosc_rakiet_gracza[id]>0) StworzRakiete(id);	
		if(ilosc_dynamitow_gracza[id]>0) PolozDynamit(id);
	}
	return PLUGIN_HANDLED;
}
public UzyjItemu(id)
{
	if(ile_nozy[id]>0) paint_fire(id);
	if(ilosc_blyskawic[id]){
		new ofiara, body;
		get_user_aiming(id, ofiara, body);
	
		if(is_user_alive(ofiara)){
			if(get_user_team(ofiara) == get_user_team(id)) return PLUGIN_HANDLED;
			
			if(poprzednia_blyskawica[id]+5.0>get_gametime()){
				client_print(id,print_center,"Blyskawicy mozesz uzyc raz na 5 sek.");
				return PLUGIN_HANDLED;
			}
			poprzednia_blyskawica[id] = floatround(get_gametime());
			ilosc_blyskawic[id]--;
			puscBlyskawice(id, ofiara, 0.5);
		}
	}
	return PLUGIN_HANDLED;
}

stock Create_TE_BEAMENTS(startEntity, endEntity, iSprite, startFrame, frameRate, life, width, noise, red, green, blue, alpha, speed) {
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMENTS )
	write_short( startEntity )
	write_short( endEntity )
	write_short( iSprite )
	write_byte( startFrame )
	write_byte( frameRate )
	write_byte( life )
	write_byte( width )
	write_byte( noise )
	write_byte( red )
	write_byte( green )
	write_byte( blue )
	write_byte( alpha )
	write_byte( speed )
	message_end()
}
puscBlyskawice(id, ofiara, Float:fCzas = 1.0){
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "blyskawica");
	ExecuteHam(Ham_TakeDamage, ofiara, 0, id, 40.0+float(inteligencja_gracza[id]) , 1);
	
	remove_entity(ent);

	Create_TE_BEAMENTS(id, ofiara, sprite, 0, 10, floatround(fCzas*10), 150, 5, 200, 200, 200, 200, 10);

	emit_sound(id, CHAN_WEAPON, "ambience/thunder_clap.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(ofiara, CHAN_WEAPON, "ambience/thunder_clap.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}


public ResetHUD(id)
{
	if(informacje_przedmiotu_gracza[id][0] == 71) ilosc_blyskawic[id] = 1;
	if(informacje_przedmiotu_gracza[id][0] == 72) ilosc_blyskawic[id] = 2;
	if(informacje_przedmiotu_gracza[id][0] == 73) ilosc_blyskawic[id] = 3;
}
public WyrzucPrzedmiot(id)
{
	if(informacje_przedmiotu_gracza[id][0]){
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Wyrzuciles %s ze slotu pierwszego.", nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]]);
		UsunPrzedmiot(id);
	}
	else ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Nie masz zadnego przedmiotu.");
		
	return PLUGIN_HANDLED;
}

public WyrzucItem(id)
{
	if(informacje_itemu_gracza[id][0]){
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Wyrzuciles %s ze slotu pierwszego.", nazwy_itemow[informacje_itemu_gracza[id][0]]);
		UsunItem(id);
	}
	else ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Nie masz zadnego przedmiotu.");
		
	return PLUGIN_HANDLED;
}


public UsunPrzedmiot(id)
{
	informacje_przedmiotu_gracza[id][0] = 0;
	informacje_przedmiotu_gracza[id][1] = 0;
	wytrzymalosc_przedmiotu[id] = 0
	ilosc_blyskawic[id] = 0;
}

public UsunItem(id)
{
	informacje_itemu_gracza[id][0] = 0;
	informacje_itemu_gracza[id][1] = 0;
	if(is_user_alive(id)){
		set_user_footsteps(id, 0);
		set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
	}
	ZmienUbranie(id, 1);
	wytrzymalosc_itemu[id] = 0
}

public DajPrzedmiot(id, przedmiot)
{
	UsunPrzedmiot(id);
	informacje_przedmiotu_gracza[id][0] = przedmiot;
	wytrzymalosc_przedmiotu[id] = 100;
	switch(przedmiot){
		case 1: set_user_footsteps(id, 1);
		case 2: informacje_przedmiotu_gracza[id][1] = random_num(3,6);
		case 3: informacje_przedmiotu_gracza[id][1] = random_num(6, 11);
		case 5: informacje_przedmiotu_gracza[id][1] = random_num(6, 9);
		case 6: {
			informacje_przedmiotu_gracza[id][1] = random_num(100, 150);
			set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, informacje_przedmiotu_gracza[id][1]);
		}
		case 7: informacje_przedmiotu_gracza[id][1] = random_num(2, 4);
		case 8: if(klasa_gracza[id] == Komandos) DajPrzedmiot(id, random_num(1, sizeof nazwy_przedmiotow-1));
		case 10: give_item(id, "weapon_flashbang");
		case 12: informacje_przedmiotu_gracza[id][1] = random_num(1, 4);
		case 13: give_item(id, "weapon_awp");
		case 16: set_task(5.0, "WyszkolenieSanitarne", id+ZADANIE_WYSZKOLENIE_SANITARNE);
		case 19: informacje_przedmiotu_gracza[id][1] = 1;
		case 26:{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 40);
			set_user_health(id, 1)
		}
		case 27: informacje_przedmiotu_gracza[id][1] = 3;
		case 40: set_user_gravity(id, 0.9);
		case 41: set_user_gravity(id, 0.8);
		case 42: set_user_gravity(id, 0.7);
		case 43: set_user_gravity(id, 0.6);
		case 44: set_user_gravity(id, 0.5);
		case 45 .. 47:{
			if(!(get_user_flags(id) & ADMIN_LEVEL_H)){
				user_kill(id)
				client_print(id, print_center, "Zostales zabity przez zlosliwy przedmiot!");
				ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Zostales zabity przez zly item");	
				WyrzucPrzedmiot(id);
			}
			else DajPrzedmiot(id, random_num(1, sizeof nazwy_przedmiotow-1));
		}
		case 60: give_item(id, "weapon_scout");
		case 71: ilosc_blyskawic[id] = 1;
		case 72: ilosc_blyskawic[id] = 2;
		case 73: ilosc_blyskawic[id] = 3;
	}
}

public DajItem(id, item)
{
	UsunItem(id);
	informacje_itemu_gracza[id][0] = item;
	wytrzymalosc_itemu[id] = 100;
	switch(item){
		case 6: ilosc_dynamitow_gracza[id] += 1;
		case 7: ilosc_min_gracza[id] += 1;
		case 8: ilosc_rakiet_gracza[id] += 1;
		case 9, 21: give_item(id, "weapon_usp");
		case 10: give_item(id, "weapon_glock18");
		case 11, 23: give_item(id, "weapon_m4a1");
		case 12, 24: give_item(id, "weapon_ak47");
		case 13, 22: give_item(id, "weapon_deagle");
		case 14: give_item(id, "weapon_elite");
		case 15: ilosc_apteczek_gracza[id] += 1;
		case 25: give_item(id, "weapon_m249");
		case 26: give_item(id, "weapon_galil");
		case 27: give_item(id, "weapon_famas");
		case 30:{
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
		}
		case 35: ilosc_spadochronow_gracza[id] = 1;
		case 36: ilosc_spadochronow_gracza[id] = 2;
		case 37: ilosc_spadochronow_gracza[id] = 3;
		case 38: ilosc_spadochronow_gracza[id] = 4;
		case 39: ilosc_spadochronow_gracza[id] = 5;
		case 55 .. 57:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_H)){
				user_kill(id)
				client_print(id, print_center, "Zostales zabity przez zlosliwy przedmiot!");
				ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Zostales zabity przez zly item");	
				WyrzucItem(id);
			}
			else DajItem(id, random_num(1, sizeof nazwy_itemow-1));
		}
		case 69: ile_nozy[id] = 2
		case 70: ile_nozy[id] = 3
		case 71: ile_nozy[id] = 4
		case 72: ile_nozy[id] = 5
	}
}	
public OpisPrzedmiotu(id)
{
	new opis_przedmiotu[128];
	new losowa_wartosc[3];
	num_to_str(informacje_przedmiotu_gracza[id][1], losowa_wartosc, 2);
	format(opis_przedmiotu, 127, opisy_przedmiotow[informacje_przedmiotu_gracza[id][0]]);
	replace_all(opis_przedmiotu, 127, "LW", losowa_wartosc);
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Przedmiot 1: %s (%i / 100)", nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]], wytrzymalosc_przedmiotu[id]);	
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Opis: %s", opis_przedmiotu);
	return PLUGIN_HANDLED;
}
public OpisItemu(id)
{
	new opis_itemu[128];
	new losowa_wartosc[3];
	num_to_str(informacje_itemu_gracza[id][1], losowa_wartosc, 2);
	format(opis_itemu, 127, opisy_itemow[informacje_itemu_gracza[id][0]]);
	replace_all(opis_itemu, 127, "LW", losowa_wartosc);
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Przedmiot 2: %s (%i / 100)", nazwy_itemow[informacje_itemu_gracza[id][0]], wytrzymalosc_itemu[id]);	
	ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Opis: %s", opis_itemu);	
	return PLUGIN_HANDLED;
}
public Wskrzes(id)
{
	id-=ZADANIE_WSKRZES;
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public SprawdzPoziom(id)
{	
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	if(poziom_gracza[id] < 300){
		while(doswiadczenie_gracza[id] >= doswiadczenie_poziomu[poziom_gracza[id]]){
			poziom_gracza[id]++;
			client_cmd(id, "spk QTM_CodMod/levelup");
			if(poziom_gracza[id] >= 300 && ranga_gracza[id] < 29){
				new orgazm = doswiadczenie_gracza[id]-MAXEXP
				if(orgazm < 0) orgazm = 0
				ranga_gracza[id]++;
				client_cmd(id, "spk uSpiewaKa_CoD/awans"); 
				poziom_gracza[id] = 1
				doswiadczenie_gracza[id] = orgazm
				inteligencja_gracza[id] = 0
				zdrowie_gracza[id] = 0
				wytrzymalosc_gracza[id] = 0
				kondycja_gracza[id] = 0
				kamizelka_gracza[id] = 0
				KomendaResetujPunkty(id) 
				monety_gracza[id] += 10
				set_hudmessage(0, 127, 255, -1.0, 0.20, 0, 6.0, 5.0, 0.1, 0.2, 3)
				show_hudmessage(0, "Gratulacje!^n%s awansowal do rangi %s", nazwa_gracza[id], nazwy_rang[ranga_gracza[id]])
			}
		}
		while(doswiadczenie_gracza[id] <= doswiadczenie_poziomu[poziom_gracza[id]-5]){
			poziom_gracza[id]--;
			KomendaResetujPunkty(id)
		}
		punkty_gracza[id] = (poziom_gracza[id]-1)+(ranga_gracza[id]*5)-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-kamizelka_gracza[id]-grawitacja_gracza[id];
	}
	ZapiszDane(id);
	return PLUGIN_HANDLED;
}
public ZapiszDane(id)
{
	new vaultkey[64],vaultdata[256];
	format(vaultkey,63,"%s-%i-cod", nazwa_gracza[id], klasa_gracza[id]);
	format(vaultdata,255,"%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i", doswiadczenie_gracza[id], poziom_gracza[id], inteligencja_gracza[id], zdrowie_gracza[id], wytrzymalosc_gracza[id], kondycja_gracza[id], kamizelka_gracza[id], grawitacja_gracza[id], monety_gracza[id], player_b_bank[id], player_b_bankdurability[id], player_b_bank2[id], player_b_bankdurability2[id], ranga_gracza[id], modele_gracza[id]);
	nvault_set(g_vault,vaultkey,vaultdata);
}

public WczytajDane(id, klasa)
{
	new vaultkey[64],vaultdata[256];
	format(vaultkey,63,"%s-%i-cod", nazwa_gracza[id], klasa);
	format(vaultdata,255,"%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i", doswiadczenie_gracza[id], poziom_gracza[id], inteligencja_gracza[id], zdrowie_gracza[id], wytrzymalosc_gracza[id], kondycja_gracza[id], kamizelka_gracza[id], grawitacja_gracza[id], monety_gracza[id], player_b_bank[id], player_b_bankdurability[id], player_b_bank2[id], player_b_bankdurability2[id], ranga_gracza[id], modele_gracza[id]);
	nvault_get(g_vault,vaultkey,vaultdata,255);
	
	replace_all(vaultdata, 255, "#", " ");
	
	new doswiadczeniegracza[32], poziomgracza[32], inteligencjagracza[32], zdrowiegracza[32], wytrzymaloscgracza[32], kondycjagracza[32], kamizelkagracza[32], grawitacjagracza[32], monetygracza[32], playerbbank[32], playerbbankdurability[32], playerbbank2[32], playerbbankdurability2[32], rangagracza[32], modelegracza[32];
	
	parse(vaultdata, doswiadczeniegracza, 31, poziomgracza, 31, inteligencjagracza, 31, zdrowiegracza, 31, wytrzymaloscgracza, 31, kondycjagracza, 31, kamizelkagracza, 31, grawitacjagracza, 31, monetygracza, 31, playerbbank, 31, playerbbankdurability, 31, playerbbank2, 31, playerbbankdurability2, 31, rangagracza, 31, modelegracza, 31);
	
	doswiadczenie_gracza[id] = str_to_num(doswiadczeniegracza);
	poziom_gracza[id] = str_to_num(poziomgracza)>0?str_to_num(poziomgracza):1;
	inteligencja_gracza[id] = str_to_num(inteligencjagracza);
	zdrowie_gracza[id] = str_to_num(zdrowiegracza);
	wytrzymalosc_gracza[id] = str_to_num(wytrzymaloscgracza);
	kondycja_gracza[id] = str_to_num(kondycjagracza);
	kamizelka_gracza[id] = str_to_num(kamizelkagracza);
	grawitacja_gracza[id] = str_to_num(grawitacjagracza);
	monety_gracza[id] = str_to_num(monetygracza);
	player_b_bank[id] = str_to_num(playerbbank);
	player_b_bankdurability[id] = str_to_num(playerbbankdurability);
	player_b_bank2[id] = str_to_num(playerbbank2);
	player_b_bankdurability2[id] = str_to_num(playerbbankdurability2);
	ranga_gracza[id] = str_to_num(rangagracza);
	modele_gracza[id] = str_to_num(modelegracza);
	punkty_gracza[id] = (poziom_gracza[id]-1)+(ranga_gracza[id]*5)-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-kamizelka_gracza[id]-grawitacja_gracza[id];

} 
public PokazInformacje(id) 
{		
	id -= ZADANIE_POKAZ_INFORMACJE;	
	set_task(0.1, "PokazInformacje", id+ZADANIE_POKAZ_INFORMACJE);
	if(is_user_connected(id) && !is_user_alive(id)){
		if(!is_valid_ent(id)) return PLUGIN_CONTINUE;
		
		new target = entity_get_int(id, EV_INT_iuser2);
		
		if(target <= 0) return PLUGIN_CONTINUE;
		set_hudmessage(0, 170, 255, 0.02, 0.23, 0, 0.0, 0.3, 0.0, 0.0);
		show_hudmessage(id, "[Klasa : %s] (%i)^n[Exp : %i / %i]^n[Ranga : %s]^n[Przedmiot 1 : %s] (%i%s)^n[Przedmiot 2 : %s] (%i%s)^n[HP : %i | AP : %i | PLN : %i | KS : %i]^n[Misja : %s] (Wyk: %i)", 
		nazwy_klas[klasa_gracza[target]], poziom_gracza[target], doswiadczenie_gracza[target], doswiadczenie_poziomu[poziom_gracza[target]], nazwy_rang[ranga_gracza[target]], nazwy_przedmiotow[informacje_przedmiotu_gracza[target][0]], wytrzymalosc_przedmiotu[target], "%",nazwy_itemow[informacje_itemu_gracza[target][0]], wytrzymalosc_itemu[target], "%",get_user_health(target), get_user_armor(target), monety_gracza[target], ks_get_user_ks(target), nazwy_misji[queston[target]], killquest[target]);
		return PLUGIN_CONTINUE;
	}
	if(is_user_connected(id) && is_user_alive(id)){
		
		new tpstring[1024]
		format(tpstring,1023,"Rak : %i / Min : %i / Dyn : %i / Apt : %i / Noz : %i", ilosc_rakiet_gracza[id], ilosc_min_gracza[id], ilosc_dynamitow_gracza[id], ilosc_apteczek_gracza[id], ile_nozy[id])
		message_begin(MSG_ONE,gmsgStatusText,{0,0,0}, id) 
		write_byte(0) 
		write_string(tpstring) 
		message_end()
		set_hudmessage(0, 170, 255, 0.02, 0.23, 0, 0.0, 0.3, 0.0, 0.0);
		show_hudmessage(id, "[Klasa : %s] (%i)^n[Exp : %i / %i]^n[Ranga : %s]^n[Przedmiot 1 : %s] (%i%s)^n[Przedmiot 2 : %s] (%i%s)^n[HP : %i | AP : %i | PLN : %i | KS : %i]^n[Misja : %s] (Wyk: %i)", 
		nazwy_klas[klasa_gracza[id]], poziom_gracza[id], doswiadczenie_gracza[id], doswiadczenie_poziomu[poziom_gracza[id]], nazwy_rang[ranga_gracza[id]], nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]], wytrzymalosc_przedmiotu[id], "%",nazwy_itemow[informacje_itemu_gracza[id][0]], wytrzymalosc_itemu[id], "%",get_user_health(id), get_user_armor(id), monety_gracza[id], ks_get_user_ks(id), nazwy_misji[queston[id]], killquest[id]);
	}
	return PLUGIN_CONTINUE;
}

public ZmienUbranie(id,reset)
{
	if (id<1 || id>32 || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	if (reset) cs_reset_user_model(id);
	else{
		new num = random_num(0,3);
		switch(get_user_team(id))
		{
			case 1: cs_set_user_model(id, Ubrania_CT[num]);
				case 2:cs_set_user_model(id, Ubrania_Terro[num]);
			}
	}
	
	return PLUGIN_CONTINUE;
}

public Pomoc(id)
{
	switch(random(16))
	{
		case 0: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby zresetowac umiejetnosci napisz /reset");
			case 1: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby zmienic klase napisz /klasa");
			case 2: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby uzyc przedmiotu/mocy nacisnij E");
			case 3: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby wyrzucic przedmiot napisz /wyrzuc");
			case 4: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby zobaczyc opis przedmiotu napisz /item");
			case 5: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby zobaczyc opis klas napisz /klasy");
			case 6: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby dac komus przedmiot 1 napisz /daj");
			case 7: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Aby kupic ulepszenia napisz /sklep");
			case 8: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Wszystkie komendy -  /menu");
			case 9: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Zapoznaj sie z regulaminem -  /reg");
			case 10: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Kup PREMIUM -  /zakup");
			case 11: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Co daje PREMIUM -  /pre");
			case 12: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Sprzedaj przedmioty - /sprzedaj");
			case 13: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Zapraszamy na facebook.com/uspiewaka");
			case 14: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 Nasze IP: 89.231.6.7:27025");
			case 15: ColorChat(0 ,BLUE,"[uSpiewaKa.eu]^x01 O co chodzi z rangami - /rangi");
		}
	set_task(36.0, "Pomoc");
}

public DotykBroni(weapon,id)
{
	new model[23];
	entity_get_string(weapon, EV_SZ_model, model, 22);
	if (!is_user_connected(id) || entity_get_edict(weapon, EV_ENT_owner) == id || equal(model, "models/w_backpack.mdl")) return HAM_IGNORED;
	return HAM_SUPERCEDE;
}

public BlokujKomende()
	return PLUGIN_HANDLED;
	
stock bool:UTIL_In_FOV(id,target)
{
	if (Find_Angle(id,target,9999.9) > 0.0) return true;	
	return false;
}

stock Float:Find_Angle(Core,Target,Float:dist)
{
	new Float:vec2LOS[2];
	new Float:flDot;
	new Float:CoreOrigin[3];
	new Float:TargetOrigin[3];
	new Float:CoreAngles[3];
	
	pev(Core,pev_origin,CoreOrigin);
	pev(Target,pev_origin,TargetOrigin);
	
	if (get_distance_f(CoreOrigin,TargetOrigin) > dist) return 0.0;
	
	pev(Core,pev_angles, CoreAngles);
	
	for ( new i = 0; i < 2; i++ ) vec2LOS[i] = TargetOrigin[i] - CoreOrigin[i];
	
	new Float:veclength = Vec2DLength(vec2LOS);

	if (veclength <= 0.0){
		vec2LOS[0] = 0.0;
		vec2LOS[1] = 0.0;
	}
	else{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}

	engfunc(EngFunc_MakeVectors,CoreAngles);
	
	new Float:v_forward[3];
	new Float:v_forward2D[2];
	get_global_vector(GL_v_forward, v_forward);
	
	v_forward2D[0] = v_forward[0];
	v_forward2D[1] = v_forward[1];
	
	flDot = vec2LOS[0]*v_forward2D[0]+vec2LOS[1]*v_forward2D[1];
	
	if ( flDot > 0.5 ){
		return flDot;
	}
	
	return 0.0;
}

stock Float:Vec2DLength( Float:Vec[2] )  
{ 
	return floatsqroot(Vec[0]*Vec[0] + Vec[1]*Vec[1] );
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, g_msg_screenfade,{0,0,0},id );
	write_short( duration );
	write_short( holdtime );
	write_short( fadetype );
	write_byte ( red );
	write_byte ( green );
	write_byte ( blue );
	write_byte ( alpha );
	message_end();
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = find_ent_by_class(weaponid, weaponname)) != 0)
		if(entity_get_edict(weaponid, EV_ENT_owner) == id) 
	{
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}

public client_death(killer,victim,weapon,hitplace,TK)
{	
	if(!killer || !victim || TK || !(hitplace == HIT_HEAD)) return PLUGIN_CONTINUE;
	
	new Players[32], zablokuj;
	get_players(Players, zablokuj, "ch");
	if(zablokuj < 3) return PLUGIN_CONTINUE;	
	
	if(informacje_itemu_gracza[killer][0] == 28){
		new nowe = 200
		if(noc) nowe = nowe*2
		doswiadczenie_gracza[killer] += nowe;
		ColorChat(killer, BLUE, "[uSpiewaKa.eu]^x01 Dostales %i doswiadczenia za trafienie w glowe.", nowe);
	}
	
	if(!informacje_przedmiotu_gracza[killer][0]) return  PLUGIN_CONTINUE;
	
	if(informacje_przedmiotu_gracza[killer][0] == 56){
		new nowe = 100
		if(noc) nowe = nowe*2
		doswiadczenie_gracza[killer] += nowe;
		ColorChat(killer, BLUE, "[uSpiewaKa.eu]^x01 Dostales %i doswiadczenia za trafienie w glowe.", nowe);
	}
	
	if(informacje_przedmiotu_gracza[killer][0] == 57){
		new nowe = 200
		if(noc) nowe = nowe*2
		doswiadczenie_gracza[killer] += nowe;
		ColorChat(killer, BLUE, "[uSpiewaKa.eu]^x01 Dostales %i doswiadczenia za trafienie w glowe.", nowe);
	}
	
	if(informacje_przedmiotu_gracza[killer][0] == 58){
		new nowe = 300
		if(noc) nowe = nowe*2
		doswiadczenie_gracza[killer] += nowe;
		ColorChat(killer, BLUE, "[uSpiewaKa.eu]^x01 Dostales %i doswiadczenia za trafienie w glowe.", nowe);
	}
	
	if(informacje_przedmiotu_gracza[killer][0] == 59){
		new nowe = 500
		if(noc) nowe = nowe*2
		doswiadczenie_gracza[killer] += nowe;
		ColorChat(killer, BLUE, "[uSpiewaKa.eu]^x01 Dostales %i doswiadczenia za trafienie w glowe.", nowe);
	}
	return PLUGIN_CONTINUE;	
	
}
parachute_reset(id)
{
	if(para_ent[id] > 0 && is_valid_ent(para_ent[id])) remove_entity(para_ent[id])
	if (is_user_alive(id)) set_user_gravity(id, 1.0)

	ilosc_spadochronow_gracza[id] = 0;
	para_ent[id] = 0;
}

public client_PreThink(id)
{
        if (!is_user_alive(id)) return

        new Float:fallspeed = 100 * -1.0
        new Float:frame

        new button = get_user_button(id)
        new oldbutton = get_user_oldbutton(id)
        new flags = get_entity_flags(id)
        
        if (para_ent[id] > 0 && (flags & FL_ONGROUND)) {

                if (get_pcvar_num(SpadochronDetach)){
                        if (get_user_gravity(id) == 0.1) set_user_gravity(id, 1.0)

                        if (entity_get_int(para_ent[id],EV_INT_sequence) != 2) {
                                entity_set_int(para_ent[id], EV_INT_sequence, 2)
                                entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
                                entity_set_float(para_ent[id], EV_FL_frame, 0.0)
                                entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
                                entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
                                entity_set_float(para_ent[id], EV_FL_framerate, 0.0)
                                return
                        }

                        frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 2.0
                        entity_set_float(para_ent[id],EV_FL_fuser1,frame)
                        entity_set_float(para_ent[id],EV_FL_frame,frame)

                        if (frame > 254.0) {
                                remove_entity(para_ent[id])
                                para_ent[id] = 0
                        }
                }
                else {
                        remove_entity(para_ent[id])
                        set_user_gravity(id, 1.0)
                        para_ent[id] = 0
                }

                return
        }

        if ((button & IN_USE) && ilosc_spadochronow_gracza[id] > 0){
                new Float:velocity[3]
                entity_get_vector(id, EV_VEC_velocity, velocity)

                if (velocity[2] < 0.0) {

                        if(para_ent[id] <= 0) {
                                para_ent[id] = create_entity("info_target")
                                if(para_ent[id] > 0) {
                                        entity_set_string(para_ent[id],EV_SZ_classname,"parachute")
                                        entity_set_edict(para_ent[id], EV_ENT_aiment, id)
                                        entity_set_edict(para_ent[id], EV_ENT_owner, id)
                                        entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
                                        entity_set_model(para_ent[id], "models/parachute.mdl")
                                        entity_set_int(para_ent[id], EV_INT_sequence, 0)
                                        entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
                                        entity_set_float(para_ent[id], EV_FL_frame, 0.0)
                                        entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
                                }
                                
                        }

                        if (para_ent[id] > 0) {
                                entity_set_int(id, EV_INT_sequence, 3)
                                entity_set_int(id, EV_INT_gaitsequence, 1)
                                entity_set_float(id, EV_FL_frame, 1.0)
                                entity_set_float(id, EV_FL_framerate, 1.0)
                                set_user_gravity(id, 0.1)

                                velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
                                entity_set_vector(id, EV_VEC_velocity, velocity)

                                if (entity_get_int(para_ent[id],EV_INT_sequence) == 0) {

                                        frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0
                                        entity_set_float(para_ent[id],EV_FL_fuser1,frame)
                                        entity_set_float(para_ent[id],EV_FL_frame,frame)

                                        if (frame > 100.0) {
                                                entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
                                                entity_set_float(para_ent[id], EV_FL_framerate, 0.4)
                                                entity_set_int(para_ent[id], EV_INT_sequence, 1)
                                                entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
                                                entity_set_float(para_ent[id], EV_FL_frame, 0.0)
                                                entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
                                        }
                                }
                        }
                }
                else if (para_ent[id] > 0) {
                        remove_entity(para_ent[id])
                        set_user_gravity(id, 1.0)
                        para_ent[id] = 0
                        ilosc_spadochronow_gracza[id]--;
                }
        }
        else if ((oldbutton & IN_USE) && para_ent[id] > 0) {
                remove_entity(para_ent[id])
                set_user_gravity(id, 1.0)
                para_ent[id] = 0;
                ilosc_spadochronow_gracza[id]--;
        }
        
        if (entity_get_int(id, EV_INT_button) & 2 && (informacje_itemu_gracza[id][0] == 15 || klasa_gracza[id] == USMC || klasa_gracza[id] == LekkiSkoczek || klasa_gracza[id] == Avatar || klasa_gracza[id] == Zawodowiec || klasa_gracza[id] == Radarowiec || klasa_gracza[id] == Luq || klasa_gracza[id] == Neo)) {// tam gdzie Klasa_auto_BH dajemy nasz¹ klase z BH
                new flags = entity_get_int(id, EV_INT_flags)
                if (flags & FL_WATERJUMP)
                return
                if (entity_get_int(id, EV_INT_waterlevel) >= 2)
                return
                if (!(flags & FL_ONGROUND))
                return
                
                new Float:velocity[3]
                entity_get_vector(id, EV_VEC_velocity, velocity)
                velocity[2] += 250.0
                entity_set_vector(id, EV_VEC_velocity, velocity)
                entity_set_int(id, EV_INT_gaitsequence, 6)
        }
}
public KomendaDajPrzedmiot(id, level, cid)
{
	if(!cmd_access(id,level,cid,3)) return PLUGIN_HANDLED;

	new arg1[33];
	new arg2[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	new gracz  = cmd_target(id, arg1, 0);
	new przedmiot = str_to_num(arg2)-1;

	if(przedmiot < 1 || przedmiot > sizeof nazwy_przedmiotow-1){
		client_print(id, print_console, "[uSpiewaKa.eu] Podales nieprawidlowy numer przedmiotu.")
		return PLUGIN_HANDLED;
	}
	DajPrzedmiot(gracz, przedmiot);
	return PLUGIN_HANDLED;
}
public KomendaDajPrzedmiot2(id, level, cid)
{
	if(!cmd_access(id,level,cid,3)) return PLUGIN_HANDLED;
	
	new arg1[33];
	new arg2[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	new gracz  = cmd_target(id, arg1, 0);
	new item = str_to_num(arg2)-1;
	
	if(item < 1 || item > sizeof nazwy_itemow-1){
		client_print(id, print_console, "[uSpiewaKa.eu] Podales nieprawidlowy numer przedmiotu.")
		return PLUGIN_HANDLED;
	}
	
	DajItem(gracz, item);
	return PLUGIN_HANDLED;
}
public KomendaUsunPrzedmiot(id, level, cid)
{
	if(!cmd_access(id,level,cid,3)) return PLUGIN_HANDLED;
	
	new arg1[33];
	new arg2[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	new gracz  = cmd_target(id, arg1, 0);
	
	UsunPrzedmiot(gracz);
	return PLUGIN_HANDLED;
}
public KomendaUsunPrzedmiot2(id, level, cid)
{
	if(!cmd_access(id,level,cid,3)) return PLUGIN_HANDLED;
	
	new arg1[33];
	new arg2[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	new gracz  = cmd_target(id, arg1, 0);
	
	UsunItem(gracz);
	return PLUGIN_HANDLED;
}
public cmd_addexp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	if(doswiadczenie_gracza[player] + exp > MAXEXP) {
		client_print(id, print_console, "[uSpiewaKa.eu] Chciales dodac za duzo expa (expgracza + wartosc < %i)", MAXEXP)
		} else {
		doswiadczenie_gracza[player] += exp;
		SprawdzPoziom(player);
	}
	return PLUGIN_HANDLED;
}

public cmd_remexp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	if(doswiadczenie_gracza[player] - exp < 1) {
		client_print(id, print_console, "[uSpiewaKa.eu] Chciales odjac za duzo expa (expgracza - wartosc > 1)")
		} else {
		doswiadczenie_gracza[player] -= exp;
		SprawdzPoziom(player);
	}
	return PLUGIN_HANDLED;
}
public cmd_addranga(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	if(ranga_gracza[player] + exp > 29) {
		client_print(id, print_console, "[uSpiewaKa.eu] Chciales dodac za duzo rang (29 max)", MAXEXP)
		} else {
		ranga_gracza[player] += exp;
		SprawdzPoziom(player);
		KomendaResetujPunkty(player);
	}
	return PLUGIN_HANDLED;
}

public cmd_remranga(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	if(ranga_gracza[player] - exp < 0) {
		client_print(id, print_console, "[uSpiewaKa.eu] Chciales odjac za duzo expa (0 min)")
		} else {
		ranga_gracza[player] -= exp;
		SprawdzPoziom(player);
		KomendaResetujPunkty(player);
	}
	return PLUGIN_HANDLED;
}
public cmd_addpln(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	monety_gracza[player] += exp;
	return PLUGIN_HANDLED;
}

public cmd_rempln(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new exp = str_to_num(arg2);
	monety_gracza[player] -= exp;
	return PLUGIN_HANDLED;
}
public cmd_addwytrz(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new dod = str_to_num(arg2);
	if(wytrzymalosc_przedmiotu[player] + dod > 100) {
		client_print(id, print_console, "[uSpiewaKa.eu] Chciales dodac za duzo wytrzymalosci (powyzej 100%)")
		} else {
		wytrzymalosc_przedmiotu[player] += dod;
	}
	return PLUGIN_HANDLED;
}
public cmd_addwytrz2(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new dod = str_to_num(arg2);
	if(wytrzymalosc_itemu[player] + dod > 100) {
		client_print(id, print_console, "[uSpiewaKa.eu] Chciales dodac za duzo wytrzymalosci (powyzej 100%)")
		} else {
		wytrzymalosc_itemu[player] += dod;
	}
	return PLUGIN_HANDLED;
}
public cmd_remwytrz(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new dod = str_to_num(arg2);
	if(wytrzymalosc_przedmiotu[player] - dod < 0) {
		client_print(id, print_console, "[uSpiewaKa.eu] Przedmiot usuniety graczowi")
		UsunPrzedmiot(player)
		} else {
		wytrzymalosc_przedmiotu[player] -= dod;
	}
	return PLUGIN_HANDLED;
}
public cmd_remwytrz2(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3)) return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new dod = str_to_num(arg2);
	if(wytrzymalosc_itemu[player] - dod < 0) {
		client_print(id, print_console, "[uSpiewaKa.eu] Przedmiot usuniety graczowi")
		} else {
		wytrzymalosc_itemu[player] -= dod;
	}
	return PLUGIN_HANDLED;
}
public OddajPrzedmiot(id)
{
	new menu = menu_create("Oddaj przedmiot 1", "OddajPrzedmiot_Handle");
	new cb = menu_makecallback("OddajPrzedmiot_Callback");
	new numer_przedmiotu;
	for(new i=0; i<=32; i++){
		if(!is_user_connected(i)) continue;
		oddaj_id[numer_przedmiotu++] = i;
		menu_additem(menu, nazwa_gracza[i], "0", 0, cb);
	}
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public OddajPrzedmiot_Handle(id, menu, item)
{
	if(!is_user_connected(oddaj_id[item])){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nieodnaleziono gracza!")
		return PLUGIN_CONTINUE;
	}
	if(!informacje_przedmiotu_gracza[id][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz zadnego przedmiotu!")
		return PLUGIN_CONTINUE;
	}
	if(informacje_przedmiotu_gracza[oddaj_id[item]][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Gracz ma juz przedmiot!")
		return PLUGIN_CONTINUE;
	}
	DajPrzedmiot(oddaj_id[item], informacje_przedmiotu_gracza[id][0]);
	informacje_przedmiotu_gracza[oddaj_id[item]][1] = informacje_przedmiotu_gracza[id][1];
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Przekazales %s graczowi %s!",nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]] , nazwa_gracza[oddaj_id[item]])
	ColorChat(oddaj_id[item],BLUE,"[uSpiewaKa.eu]^x01 Dostales %s od gracza %s!",nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]] , nazwa_gracza[id]);
	UsunPrzedmiot(id);
	return PLUGIN_CONTINUE;
}

public OddajPrzedmiot_Callback(id, menu, item)
{
	if(oddaj_id[item] == id) return ITEM_DISABLED;
	return ITEM_ENABLED;
}
public OddajItem(id)
{
	new menu = menu_create("Oddaj przedmiot 2", "OddajItem_Handle");
	new cb = menu_makecallback("OddajItem_Callback");
	new numer_itemu;
	for(new i=0; i<=32; i++){
		if(!is_user_connected(i)) continue;
		oddaj_id[numer_itemu++] = i;
		menu_additem(menu, nazwa_gracza[i], "0", 0, cb);
	}
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}
public OddajItem_Handle(id, menu, item)
{
	if(!is_user_connected(oddaj_id[item])){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nieodnaleziono gracza!")
		return PLUGIN_CONTINUE;
	}
	if(!informacje_itemu_gracza[id][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz zadnego przedmiotu!")
		return PLUGIN_CONTINUE;
	}
	if(informacje_itemu_gracza[oddaj_id[item]][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Gracz ma juz przedmiot!")
		return PLUGIN_CONTINUE;
	}
	DajItem(oddaj_id[item], informacje_itemu_gracza[id][0]);
	informacje_itemu_gracza[oddaj_id[item]][1] = informacje_itemu_gracza[id][1];
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Przekazales %s graczowi %s!",nazwy_itemow[informacje_itemu_gracza[id][0]] , nazwa_gracza[oddaj_id[item]])
	ColorChat(oddaj_id[item],BLUE,"[uSpiewaKa.eu]^x01 Dostales %s od gracza %s!",nazwy_itemow[informacje_itemu_gracza[id][0]] , nazwa_gracza[id]);
	UsunItem(id);
	return PLUGIN_CONTINUE;
}

public OddajItem_Callback(id, menu, item)
{
	if(oddaj_id[item] == id) return ITEM_DISABLED;
	return ITEM_ENABLED;
}
public MenuCoD(id)
{
	new menu = menu_create("\ruSpiewaKa.eu\y [Call of Duty]:", "MenuCoD_Handle");
	menu_additem(menu, "Sklep");
	menu_additem(menu, "Wykonaj misje");
	menu_additem(menu, "Zmien klase");
	menu_additem(menu, "Info o klasach");
	menu_additem(menu, "Info o twoich przedmiotach");
	menu_additem(menu, "Info o przedmiotach na serwerze");
	menu_additem(menu, "Wyrzuc przedmioty");
	menu_additem(menu, "Daj przedmioty");
	menu_additem(menu, "Sprzedaj przedmioty");
	menu_additem(menu, "Zamien sie przedmiotem");
	menu_additem(menu, "Zresetuj punkty");
	menu_additem(menu, "Regulamin serwera");
	menu_additem(menu, "Informacje o rangach");
	menu_additem(menu, "\r[~] \wKup dodatki za SMS");
	menu_additem(menu, "\r[~] \wWymien $ na PLN");
	menu_additem(menu, "\r[~] \wSchowaj przedmioty");
	menu_additem(menu, "\r[~] \wCo daje premium");
	menu_additem(menu, "\yNasze forum:");
	menu_additem(menu, "\ywww.uSpiewaKa.eu");
	menu_additem(menu, "\ySpiewaK\w 2228161");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public MenuCoD_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item)
	{
		case 0: SklepMenu(id)
		case 1: QuestyComm(id)
		case 2: WybierzKlase(id)
		case 3: OpisKlasy(id)
		case 4: OpisMenu(id)
		case 5: OpisyMenu(id)
		case 6: DropMenu(id)
		case 7: DajMenu(id)
		case 8: SprzedajMenu(id)
		case 9: ZamienMenu(id)
		case 10: KomendaResetujPunkty(id)
		case 11: regulamin_motd(id)
		case 12: ranga_motd(id)
		case 13: client_cmd(id,"say /zakup")
		case 14: Wymiana(id)
		case 15: BankMenu(id)
		case 16: premium_motd(id)
	}
	return PLUGIN_HANDLED;
}
public radar_scan()
{
	new PlayerCoords[3];
	new id;
	new Players[32];
	new i;
	new playerCount = 0;

	for (id=1; id<=g_maxplayers; id++){
		if((!is_user_alive(id))||(!radar[id])) continue;
		
		if(get_players(Players, playerCount, "a") &&is_user_alive(id)) playerCount++; 
		
		for (i=1;i<=playerCount;i++){	
			get_user_origin(i, PlayerCoords)
		
			message_begin(MSG_ONE_UNRELIABLE, g_msgHostageAdd, {0,0,0}, id)
			write_byte(id)
			write_byte(i)		
			write_coord(PlayerCoords[0])
			write_coord(PlayerCoords[1])
			write_coord(PlayerCoords[2])
			message_end()
		
			message_begin(MSG_ONE_UNRELIABLE, g_msgHostageDel, {0,0,0}, id)
			write_byte(i)
			message_end()
		}
		emit_sound(id, CHAN_ITEM, "radar.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
}
public msgScreenFade(msgId, msgType, id)
{
	if(informacje_przedmiotu_gracza[id][0]  != 48) return PLUGIN_CONTINUE;	
	if(get_msg_arg_int(4) == 255 && get_msg_arg_int(5) == 255 && get_msg_arg_int(6) == 255 && get_msg_arg_int(7) > 199) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}
public regulamin_motd(id)
{	
	show_motd(id,"addons/amxmodx/configs/regulamin.txt","Regulamin serwera")
	return PLUGIN_HANDLED;
}
public premium_motd(id)
{	
	show_motd(id,"addons/amxmodx/configs/premium.txt","Premium")
	return PLUGIN_HANDLED;
}
public ranga_motd(id)
{	
	show_motd(id,"addons/amxmodx/configs/rangi.txt","Rangi")
	return PLUGIN_HANDLED;
}
public Wymiana(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)){
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Kup premium do tej komendy.");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	else{
		new menu = menu_create("Kantor \r[CoD]:", "Wymiana_Handle");
		menu_additem(menu, "1 PLN \yKoszt: \r1000$");
		menu_additem(menu, "2 PLN \yKoszt: \r2000$");
		menu_additem(menu, "3 PLN \yKoszt: \r3000$");
		menu_additem(menu, "4 PLN \yKoszt: \r4000$");
		menu_additem(menu, "5 PLN \yKoszt: \r5000$");
		menu_additem(menu, "6 PLN \yKoszt: \r6000$");
		menu_additem(menu, "7 PLN \yKoszt: \r7000$");
		menu_display(id, menu);
	}
	return PLUGIN_HANDLED;
}

public Wymiana_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new kasa_gracza = cs_get_user_money(id);
	new koszt = (item*1000)+1000;
	if (kasa_gracza<koszt){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci PLN!");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	cs_set_user_money(id, kasa_gracza-koszt);
	monety_gracza[id] += (item*1)+1;
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wymieniono $ na PLN!");
	ZapiszDane(id)
	return PLUGIN_CONTINUE
}

public bank(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)){
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Kup premium do tej komendy.");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	else{
		if (informacje_przedmiotu_gracza[id][0] > 0){
			new menu = menu_create("Schowac item 1 do banku?:", "bank_Handle");
			menu_additem(menu, "Tak \r[400PLN]");
			menu_additem(menu, "Nie");
			menu_display(id, menu);
		}
		else{
			if(player_b_bank[id]>0){
				new menu = menu_create("Wyjac przedmiot 1 z banku?:", "bankmenu1a_Handle");
				menu_additem(menu, "Tak");
				menu_additem(menu, "Nie");
				menu_display(id, menu);
			}
			else{
				ColorChat(id, BLUE, "[uSpiewaKa.eu]^x01 Jeszcze nic nie wlozyles do banku")
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
			}
		}
	}
	return PLUGIN_HANDLED;
}
public bank_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) { 
		case 0:{
			if (monety_gracza[id]<400){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci PLN.");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_CONTINUE;
			}
			monety_gracza[id] -= 400
			player_b_bank[id]=informacje_przedmiotu_gracza[id][0]
			player_b_bankdurability[id]=wytrzymalosc_przedmiotu[id]
			ColorChat(id, BLUE, "[uSpiewaKa.eu]^x01 Wlozyles %s do banku", nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]])
			UsunPrzedmiot(id)
			menu_destroy(menu);
		}
		case 1:{
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Anulowano wymiane!");
			menu_destroy(menu);
		}
	}
	return PLUGIN_CONTINUE
}
public bankmenu1a_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) { 
		case 0:{
			informacje_przedmiotu_gracza[id][0] = player_b_bank[id]
			wytrzymalosc_przedmiotu[id] = player_b_bankdurability[id]-20
			player_b_bank[id]=0
			player_b_bankdurability[id]=0
			ColorChat(id, BLUE, "[uSpiewaKa.eu]^x01 Wyjales %s ze schowka",  nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]])
			menu_destroy(menu);
		}
		case 1:{
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Anulowano wymiane!");
			menu_destroy(menu);
		}
	}
	return PLUGIN_CONTINUE
}
public bank2(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H)){
		ColorChat(id, BLUE,"[uSpiewaKa.eu]^x01 Kup premium do tej komendy.");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	else{
		if (informacje_itemu_gracza[id][0] > 0){
			new menu = menu_create("Schowac item 2 do banku?:", "bankmenu2_Handle");
			menu_additem(menu, "Tak \r [400PLN]");
			menu_additem(menu, "Nie");
			menu_display(id, menu);
		}
		else{
			if(player_b_bank2[id]>0)
			{
				new menu = menu_create("Wyjac przedmiot 2 z banku?:", "bankmenu2a_Handle");
				menu_additem(menu, "Tak");
				menu_additem(menu, "Nie");
				menu_display(id, menu);
			}
			else{
				ColorChat(id, BLUE, "[uSpiewaKa.eu]^x01 Jeszcze nic nie wlozyles do banku")
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
			}
		}
	}
	return PLUGIN_HANDLED;
}
public bankmenu2_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) 
	{ 
		case 0:{
			if (monety_gracza[id]<400){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci PLN.");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_CONTINUE;
			}
			monety_gracza[id] -= 400
			player_b_bank2[id]=informacje_itemu_gracza[id][0]
			player_b_bankdurability2[id]=wytrzymalosc_itemu[id]
			ColorChat(id, BLUE, "[uSpiewaKa.eu]^x01 Wlozyles %s do banku", nazwy_itemow[informacje_itemu_gracza[id][0]])
			UsunItem(id)
			menu_destroy(menu);
		}
		case 1:{
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Anulowano wymiane!");
			menu_destroy(menu);
		}
	}
	return PLUGIN_CONTINUE
}
public bankmenu2a_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) { 
		case 0:
		{
			informacje_itemu_gracza[id][0] = player_b_bank2[id]
			wytrzymalosc_itemu[id] = player_b_bankdurability2[id]-20
			player_b_bank2[id]=0
			player_b_bankdurability2[id]=0
			ColorChat(id, BLUE, "[uSpiewaKa.eu]^x01 Wyjales %s ze schowka",  nazwy_itemow[informacje_itemu_gracza[id][0]])
			menu_destroy(menu);
		}
		case 1:{
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Anulowano wymiane!");
			menu_destroy(menu);
		}
	}
	return PLUGIN_CONTINUE
}
public message_health(msg_id, msg_dest,msg_entity)
        if(get_msg_arg_int(1) == 256) set_msg_arg_int(1, ARG_BYTE, 255);

public Sklep(id)
{
	new menu = menu_create("Wybierz kategorie:", "Sklep_Handle");
	menu_additem(menu, "Zdrowie");
	menu_additem(menu, "Losowania");
	menu_additem(menu, "Wytrzymalosc przedmiotow");
	menu_additem(menu, "Doswiadczenie");
	menu_additem(menu, "Napoje");
	menu_additem(menu, "Zoom do broni");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}
public Sklep1(id)
{
	opcja_wyboru[id] = 1
	Sklep(id)
}
public Sklep2(id)
{
	opcja_wyboru[id] = 2
	Sklep(id)
}
public Sklep_Handle(id, menu, item) 
{
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) { 
		case 0: ZdrowieSklep(id)
		case 1: LosowaniaSklep(id)
		case 2: PrzedmiotySklep(id)
		case 3: DoswiadczenieSklep(id)
		case 4: NapojeSklep(id)
		case 5: ZoomSklep(id)
	}
	return PLUGIN_CONTINUE;
}
public ZoomSklep(id)
{
	new menu = menu_create("Sklep\r [Powiekszenia]:", "ZoomSklep_Handle");
	menu_additem(menu, "Zoom deagle \yKoszt: \r3000$/3PLN");
	menu_additem(menu, "Zoom USP \yKoszt: \r3000$/3PLN");
	menu_additem(menu, "Zoom Glock \yKoszt: \r3000$/3PLN");
	menu_additem(menu, "Zoom AK47 \yKoszt: \r3000$/3PLN");
	menu_additem(menu, "Zoom MP5 \yKoszt: \r3000$/3PLN");
	menu_additem(menu, "Zoom P90 \yKoszt: \r3000$/3PLN");
	menu_additem(menu, "Zoom Galil \yKoszt: \r3000$/3PLN");
	menu_display(id, menu);
}

public ZoomSklep_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new koszt
	new kasa_gracza
	if(opcja_wyboru[id] == 1){
		kasa_gracza = cs_get_user_money(id);
		koszt = 3000
	}
	if(opcja_wyboru[id] == 2){
		kasa_gracza = monety_gracza[id]
		koszt = 3
	}
	if (kasa_gracza<koszt){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
		return PLUGIN_HANDLED;
	}
	if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
	if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles powiekszenei do broni!");
	if(item == 0) zoom[id] = false;
	if(item == 1) zoom1[id] = false;
	if(item == 2) zoom2[id] = false;
	if(item == 3) zoom3[id] = false;
	if(item == 4) zoom4[id] = false;
	if(item == 5) zoom5[id] = false;
	if(item == 6) zoom6[id] = false;
	ZapiszDane(id)
	return PLUGIN_CONTINUE;
}
public ZdrowieSklep(id)
{
	new menu = menu_create("Sklep\r [Zdrowie]:", "ZdrowieSklep_Handle");
	menu_additem(menu, "Zastrzyk \r[Leczy 10 HP] \yKoszt: \r1000$/2PLN");
	menu_additem(menu, "Opatrunek \r[Leczy 20 HP] \yKoszt: \r2000$/4PLN");
	menu_additem(menu, "Bandaz \r[Leczy 30 HP] \yKoszt: \r4000$/6PLN");
	menu_additem(menu, "Witamina C \r[Leczy 40 HP] \yKoszt: \r5000$/8PLN");
	menu_additem(menu, "Rutinoscorbin \r[Leczy 50 HP] \yKoszt: \r6000$/10PLN");
	menu_additem(menu, "Wegielek \r[Leczy 60 HP] \yKoszt: \r7000$/12PLN");
	menu_additem(menu, "Flegamina \r[Leczy 70 HP] \yKoszt: \r8000$/14PLN");
	menu_additem(menu, "Syrop \r[Leczy 80 HP] \yKoszt: \r9000$/16PLN");
	menu_additem(menu, "Aspirina \r[Leczy 90 HP] \yKoszt: \r10000$/18PLN");
	menu_additem(menu, "Antybiotyk \r[Leczy 100 HP] \yKoszt: \r11000$/20PLN");
	menu_display(id, menu);
}

public ZdrowieSklep_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new koszt = 0;
	new kasa_gracza
	new hp = get_user_health(id);
	if(opcja_wyboru[id] == 1){
		kasa_gracza = cs_get_user_money(id);
		koszt = (item*1000)+1000;
	}
	if(opcja_wyboru[id] == 2){
		kasa_gracza = monety_gracza[id]
		koszt = (item*2)+2;
	}
	if (kasa_gracza<koszt){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	if(hp >= maksymalne_zdrowie_gracza[id]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Jestes w pelni uleczony.");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
	if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
	new ammount=item*10+10;
	new nowe_zdrowie = (hp+ammount<maksymalne_zdrowie_gracza[id])? hp+ammount: maksymalne_zdrowie_gracza[id];
	set_user_health(id, nowe_zdrowie);
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles uleczenie!");
	client_cmd(id, "spk uSpiewaKa_CoD/uleczaniesklep");
	ZapiszDane(id)
	return PLUGIN_CONTINUE;
}
public PrzedmiotySklep(id)
{
	new menu = menu_create("Sklep\r [Wytrzymalosc]:", "PrzedmiotySklep_Handle");
	menu_additem(menu, "+20 wytrzymalosci \r[Przedmiot 1] \yKoszt: \r2000$/4PLN");
	menu_additem(menu, "+40 wytrzymalosci \r[Przedmiot 1] \yKoszt: \r4000$/8PLN");
	menu_additem(menu, "+60 wytrzymalosci \r[Przedmiot 1] \yKoszt: \r6000$/12PLN");
	menu_additem(menu, "+20 wytrzymalosci \r[Przedmiot 2] \yKoszt: \r2000$/4PLN");
	menu_additem(menu, "+40 wytrzymalosci \r[Przedmiot 2] \yKoszt: \r4000$/8PLN");
	menu_additem(menu, "+60 wytrzymalosci \r[Przedmiot 2] \yKoszt: \r6000$/12PLN");
	menu_display(id, menu);
}

public PrzedmiotySklep_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	switch(item) 
	{ 
		case 0 .. 2:
		{
			new koszt
			new kasa_gracza
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = (item*2000)+2000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = (item*4)+4;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_CONTINUE;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			wytrzymalosc_przedmiotu[id]+=(item*20)+20;
			if(wytrzymalosc_przedmiotu[id] > 100) wytrzymalosc_przedmiotu[id] = 100
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles wytrzymalosc przedmiotu 1");
		}
		case 3 .. 5:
		{
			new pifo = item-3;
			new koszt
			new kasa_gracza
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = (pifo*2000)+2000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = (pifo*4)+4;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_CONTINUE;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			wytrzymalosc_itemu[id]+=(pifo*20)+20;
			if(wytrzymalosc_itemu[id] > 100) wytrzymalosc_itemu[id] = 100
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles wytrzymalosc przedmiotu 2");
		}
	}
	ZapiszDane(id)
	return PLUGIN_CONTINUE;
}
public DoswiadczenieSklep(id)
{
	new menu = menu_create("Sklep\r [Doswiadczenie]:", "DoswiadczenieSklep_Handle");
	menu_additem(menu, "Mala paczka \r[+1000] \yKoszt: \r2000$/4PLN");
	menu_additem(menu, "Srednia paczka \r[+2000] \yKoszt: \r4000$/8PLN");
	menu_additem(menu, "Duza paczka \r[+3000] \yKoszt: \r6000$/12PLN");
	menu_additem(menu, "Ogromna paczka \r[+4000] \yKoszt: \r8000$/16PLN");
	menu_additem(menu, "Stalowa paczka \r[+5000] \yKoszt: \r10000$/20PLN");
	menu_additem(menu, "Diamentowa paczka \r[+6000] \yKoszt: \r12000$/24PLN");
	menu_display(id, menu);
}

public DoswiadczenieSklep_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new koszt
	new kasa_gracza
	if(opcja_wyboru[id] == 1){
		kasa_gracza = cs_get_user_money(id);
		koszt = (item*2000)+2000;
	}
	if(opcja_wyboru[id] == 2){
		kasa_gracza = monety_gracza[id]
		koszt = (item*4)+4;
	}
	if (kasa_gracza<koszt){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_HANDLED;
	}
	if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
	if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
	new nowe = (item*1000)+1000;
	if(noc) nowe = nowe*2
	doswiadczenie_gracza[id] += nowe
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles doswiadczenie!");
	SprawdzPoziom(id);
	ZapiszDane(id)
	return PLUGIN_CONTINUE;
}

public LosowaniaSklep(id)
{
	new menu = menu_create("Sklep\r [Losowania]:", "LosowaniaSklep_Handle");
	menu_additem(menu, "Losowanie \yKoszt: \r1000$/5PLN");
	menu_additem(menu, "Losowanie \yKoszt: \r2000$/10PLN");
	menu_additem(menu, "Losowanie \yKoszt: \r2000$/10PLN");
	menu_additem(menu, "Losowanie \yKoszt: \r7000$/13PLN");
	menu_additem(menu, "Losowanie przedmiotu 1 \yKoszt: \r5000$/20PLN");
	menu_additem(menu, "Losowanie przedmiotu 2 \yKoszt: \r5000$/20PLN");
	menu_display(id, menu);
}
public LosowaniaSklep_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new koszt
	new kasa_gracza
	switch(item) { 
		case 0:{
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = 1000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = 5;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_HANDLED;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles los!");
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Trwa losowanie!");
			new explos = random_num(0,1);
			switch(explos){
				case 0:{
					new explos2 = random_num(100,1000);
					ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wygrales %i doswiadczenia!", explos2)
					doswiadczenie_gracza[id] += explos2;
				}
				case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nic nie wygrales!")
			}
			SprawdzPoziom(id);
		}
		case 1:{
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = 2000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = 10;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_HANDLED;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles los!");
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Trwa losowanie!");
			new explos = random_num(0,1);
			switch(explos){
				case 0:{
					new explos2 = random_num(200,1400);
					ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wygrales %i doswiadczenia!", explos2)
					doswiadczenie_gracza[id] += explos2;
				}
				case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nic nie wygrales!")
			}
			SprawdzPoziom(id);
		}
		case 2:
		{
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = 2000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = 10;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_HANDLED;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles los!");
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Trwa losowanie!");
			new explos = random_num(0,1);
			switch(explos){
				case 0:{
					new explos2 = random_num(5000,16000);
					ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wygrales %i dolarow!", explos2)
					cs_set_user_money(id, kasa_gracza+explos2);
				}
				case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nic nie wygrales!")
			}
			ZapiszDane(id)
			SprawdzPoziom(id);
		}
		case 3:
		{
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = 7000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = 13;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_HANDLED;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles los!");
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Trwa losowanie!");
			new explos = random_num(0,1);
			switch(explos){
				case 0:{
					new explos2 = random_num(1000,7000);
					ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wygrales %i doswiadczenia!", explos2)
					doswiadczenie_gracza[id] += explos2;
				}
				case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nic nie wygrales!")
			}
			ZapiszDane(id)
			SprawdzPoziom(id);
		}
		case 4:
		{
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = 5000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = 20;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_HANDLED;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wylosowano przedmiot 1!");
			DajPrzedmiot(id, random_num(1, sizeof nazwy_przedmiotow-1)); 
		}
		case 5:
		{
			if(opcja_wyboru[id] == 1){
				kasa_gracza = cs_get_user_money(id);
				koszt = 5000;
			}
			if(opcja_wyboru[id] == 2){
				kasa_gracza = monety_gracza[id]
				koszt = 20;
			}
			if (kasa_gracza<koszt){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_HANDLED;
			}
			if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
			if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wylosowano przedmiot 2!");
			DajItem(id, random_num(1, sizeof nazwy_przedmiotow-1)); 
		}
	}
	ZapiszDane(id)
	return PLUGIN_CONTINUE;
}
public NapojeSklep(id)
{
	new menu = menu_create("Sklep\r [Napoje]:", "NapojeSklep_Handle");
	menu_additem(menu, "RedBull \yKoszt: \r1000$/2PLN");
	menu_additem(menu, "Tiger \yKoszt: \r2000$/4PLN");
	menu_additem(menu, "R20+ \yKoszt: \r3000$/6PLN");
	menu_additem(menu, "Burn \yKoszt: \r4000$/8PLN");
	menu_additem(menu, "Bullit \yKoszt: \r5000$/10PLN");
	menu_additem(menu, "Max Force \yKoszt: \r6000$/12PLN");
	menu_additem(menu, "Dominator \yKoszt: \r7000$/14PLN");
	menu_display(id, menu);
}
public NapojeSklep_Handle(id, menu, item) 
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new koszt
	new kasa_gracza
	if(opcja_wyboru[id] == 1){
		kasa_gracza = cs_get_user_money(id);
		koszt = (item*1000)+1000;
	}
	if(opcja_wyboru[id] == 2){
		kasa_gracza = monety_gracza[id]
		koszt = (item*2)+2;
	}
	if (kasa_gracza<koszt){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz wystarczajacej ilosci srodkow na koncie!");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	if (get_user_gravity(id) <= 0.4){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie kupisz bo masz za duzo grawitacji!");
		client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
		return PLUGIN_CONTINUE;
	}
	new piwo = (item+1) / 10
	new piwo2 = (item+4)
	if(opcja_wyboru[id] == 1) cs_set_user_money(id, kasa_gracza-koszt);
	if(opcja_wyboru[id] == 2) monety_gracza[id] -= koszt
	set_user_gravity(id,get_user_gravity(id) - piwo);
	set_user_maxspeed(id,get_user_maxspeed(id) + piwo2);
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Kupiles napoj!");
	ZapiszDane(id)
	return PLUGIN_CONTINUE;
}
public SklepMenu(id)
{
	client_cmd(id, "spk uSpiewaKa_CoD/witajsklep");
	new menu = menu_create("Witaj w \rsklepie:", "SklepMenu_Handle");
	menu_additem(menu, "Place $");
	menu_additem(menu, "Place PLN'ami");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public SklepMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: opcja_wyboru[id] = 1;
		case 1: opcja_wyboru[id] = 2;
	}
	Sklep(id)
	return PLUGIN_CONTINUE;
}
public QuestyComm(id)
{
	if(queston[id] > 0){
		new menu = menu_create("Anulowac \rmisje:", "QuestyDelete_Handle");
		menu_additem(menu, "Tak");
		menu_additem(menu, "Nie");
		menu_display(id, menu);
	}
	else{
		new misja1[65], misja2[65], misja3[65], misja4[65], misja5[65], misja6[65], misja7[256], misja8[65], misja9[65], misja10[65], misja11[65], misja12[65], misja13[65], misja14[256];
		
		new nowe1 = 8000
		if(noc) nowe1 = nowe1*2	
		new nowe2 = 20000
		if(noc) nowe2 = nowe2*2
		new nowe3 = 15000
		if(noc) nowe3 = nowe3*2
		new nowe4 = 8000
		if(noc) nowe4 = nowe4*2
		new nowe5 = 32000
		if(noc) nowe5 = nowe5*2
		new nowe6 = 15000
		if(noc) nowe6 = nowe6*2
		format(misja1, 64, "Zabij 5 Polakow\r (%i XP)", nowe1);
		format(misja2, 64, "Zabij 5 Niemcow\r (%i XP)", nowe1);
		format(misja3, 64, "Zabij 5 Rosjanow\r (%i XP)", nowe1);
		format(misja4, 64, "Zabij 5 Amerykanow\r (%i XP)", nowe1);
		format(misja5, 64, "Zabij 5 Arabow\r (%i XP)", nowe2);
		format(misja6, 64, "Zabij 5 Iranczykow\r (%i XP)", nowe2);
		format(misja7, 255, "Zabij 20 zolnierzy\r (%i XP)\w^n Czas na wykonanie masz do konca mapy!", nowe3);
		format(misja8, 64, "Zabij 3 Polakow bez zginiecia\r (%i XP)", nowe4);
		format(misja9, 64, "Zabij 3 Rosjanow bez zginiecia\r (%i XP)", nowe4);
		format(misja10, 64, "Zabij 3 Niemcow bez zginiecia\r (%i XP)", nowe4);
		format(misja11, 64, "Zabij 3 Amerykanow bez zginiecia\r (%i XP)", nowe4);
		format(misja12, 64, "Zabij 3 Arabow bez zginiecia\r (%i XP)", nowe5);
		format(misja13, 64, "Zabij 3 Iranczykow bez zginiecia\r (%i XP)", nowe5);
		format(misja14, 255, "Zabij 8 zolnierzy bez zginiecia\r (%i XP)\w^n Czas na wykonanie masz do konca mapy!", nowe6);
		new menu = menu_create("Wybierz \rmisje:", "QuestyComm_Handle")
		menu_additem(menu, misja1);
		menu_additem(menu, misja2);
		menu_additem(menu, misja3);
		menu_additem(menu, misja4);
		menu_additem(menu, misja5);
		menu_additem(menu, misja6);
		menu_additem(menu, misja7);
		menu_additem(menu, misja8);
		menu_additem(menu, misja9);
		menu_additem(menu, misja10);
		menu_additem(menu, misja11);
		menu_additem(menu, misja12);
		menu_additem(menu, misja13);
		menu_additem(menu, misja14);

		menu_display(id, menu);
	}
	return PLUGIN_HANDLED;
}

public QuestyComm_Handle(id, menu, item)
{
	if(item == MENU_EXIT) return PLUGIN_CONTINUE;
	menu_destroy(menu);
	queston[id] = item+1
	killquest[id] = 0
	ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wykonujesz misje '%s'", nazwy_misji[queston[id]]);
	return PLUGIN_CONTINUE;
}
public QuestyDelete_Handle(id, menu, item)
{
	if(item == MENU_EXIT) return PLUGIN_CONTINUE;
	menu_destroy(menu);
	switch(item){
		case 0:{
			queston[id] = 0
			killquest[id] = 0
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Anulowales misje");
		}
		case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Grasz misje nadal");
	}
	return PLUGIN_CONTINUE;
}
public DropMenu(id)
{
	new menu = menu_create("Wyrzuc \rprzedmiot:", "DropMenu_Handle");
	menu_additem(menu, "Przedmiot 1");
	menu_additem(menu, "Przedmiot 2");
	menu_additem(menu, "Oba przedmioty");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public DropMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: WyrzucPrzedmiot(id)
		case 1: WyrzucItem(id)
		case 2:{
			WyrzucPrzedmiot(id)
			WyrzucItem(id)
		}
	}
	return PLUGIN_CONTINUE;
}
public OpisMenu(id)
{
	new menu = menu_create("Opis \rprzedmiotu:", "OpisMenu_Handle");
	menu_additem(menu, "Przedmiot 1");
	menu_additem(menu, "Przedmiot 2");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public OpisMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: OpisPrzedmiotu(id)
		case 1: OpisItemu(id)
	}
	return PLUGIN_CONTINUE;
}
public DajMenu(id)
{
	new menu = menu_create("Daj \rprzedmiot:", "DajMenu_Handle");
	menu_additem(menu, "Przedmiot 1");
	menu_additem(menu, "Przedmiot 2");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public DajMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: OddajPrzedmiot(id)
		case 1: OddajItem(id)
	}
	return PLUGIN_CONTINUE;
}
public BankMenu(id)
{
	new menu = menu_create("Schowaj \rprzedmiot:", "BankMenu_Handle");
	menu_additem(menu, "Przedmiot 1");
	menu_additem(menu, "Przedmiot 2");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public BankMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: bank(id)
		case 1: bank2(id)
	}
	return PLUGIN_CONTINUE;
}
public ZamienMenu(id)
{
	new menu = menu_create("Zamien sie \rprzedmiotem:", "ZamienMenu_Handle");
	menu_additem(menu, "Przedmiot 1");
	menu_additem(menu, "Przedmiot 2");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public ZamienMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0: ZamienPerk(id)
		case 1: ZamienPerka(id)
	}
	return PLUGIN_CONTINUE;
}
public Odblokuj()
	CzasBlokady--;

public KomendaPrzeniesPoziom(id, level, cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;

	new arg1[33];
	new arg2[6];
	new arg3[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	read_argv(3, arg3, 5);
	new gracz  = cmd_target(id, arg1, 0);
	new klasa1 = str_to_num(arg2);
	new klasa2 = str_to_num(arg3);

	WczytajDane(id, klasa1)
	klasa_gracza[gracz]=klasa1
	new temp = doswiadczenie_gracza[gracz];
	new temp1 = poziom_gracza[gracz]
	new temp2 = inteligencja_gracza[gracz]
	new temp3 = zdrowie_gracza[gracz]
	new temp4 = wytrzymalosc_gracza[gracz]
	new temp5 = kondycja_gracza[gracz]
	new temp6 = kamizelka_gracza[gracz]
	new temp7 = ranga_gracza[gracz]
	new temp8 = monety_gracza[gracz]
	new temp9 = player_b_bank[gracz]
	new temp10 = player_b_bankdurability[gracz]
	new temp11 = player_b_bank2[gracz]
	new temp12 = player_b_bankdurability2[gracz]
	new temp13 = punkty_gracza[gracz]
	
	doswiadczenie_gracza[gracz] = 0
	poziom_gracza[gracz] = 0
	inteligencja_gracza[gracz] = 0
	zdrowie_gracza[gracz] = 0
	wytrzymalosc_gracza[gracz] = 0
	kondycja_gracza[gracz] = 0
	kamizelka_gracza[gracz] = 0
	monety_gracza[gracz] = 0
	player_b_bank[gracz] = 0
	player_b_bankdurability[gracz] = 0
	player_b_bank2[gracz] = 0
	player_b_bankdurability2[gracz] = 0
	punkty_gracza[id] = 0
	ranga_gracza[id] = 0
	ZapiszDane(gracz);
	klasa_gracza[gracz]=klasa2
	doswiadczenie_gracza[gracz] = temp
	poziom_gracza[gracz] = temp1
	inteligencja_gracza[gracz] = temp2
	zdrowie_gracza[gracz] = temp3
	wytrzymalosc_gracza[gracz] = temp4
	kondycja_gracza[gracz] = temp5
	kamizelka_gracza[gracz] = temp6
	monety_gracza[gracz] = temp8
	player_b_bank[gracz] = temp9
	player_b_bankdurability[gracz] = temp10
	player_b_bank2[gracz] = temp11
	player_b_bankdurability2[gracz] = temp12
	punkty_gracza[gracz] = temp13
	ranga_gracza[gracz] = temp7
	ZapiszDane(gracz);
	return PLUGIN_HANDLED;
}
public klasyid(id)
{
	client_print(id, print_console, "===============================================");
	for(new i = 1; i < sizeof(nazwy_klas); i++) client_print(id, print_console, "ID: %d | Nazwa: %s", i, nazwy_klas[i]);
	client_print(id, print_console, "===============================================");	
}
public itemid(id)
{
	client_print(id, print_console, "===============================================");
	for(new i = 1; i < sizeof(nazwy_przedmiotow); i++) client_print(id, print_console, "ID: %d | Nazwa: %s", i, nazwy_przedmiotow[i]);
	client_print(id, print_console, "===============================================");	
}
public item2id(id)
{
	client_print(id, print_console, "===============================================");
	for(new i = 1; i < sizeof(nazwy_itemow); i++) client_print(id, print_console, "ID: %d | Nazwa: %s", i, nazwy_itemow[i]);
	client_print(id, print_console, "===============================================");	
}
public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!is_user_connected(host) || !is_user_connected(ent)) return;	
	if(informacje_przedmiotu_gracza[host][0] == 49) set_es(es_handle, ES_RenderAmt, 255.0);
}
stock is_allowed_server(){
        
        new server_ip[22];
        get_user_ip(0, server_ip, charsmax(server_ip));
        
        if(!equal("89.231.6.7:27025", server_ip)){
                set_fail_state("Nie kradnij pluginow :) - uSpiewaKa.eu");
                return false;
        }
        return true;
}
public knife_touch(Toucher, Touched){
	new kid = entity_get_edict(Toucher, EV_ENT_owner)
	new vic = entity_get_edict(Toucher, EV_ENT_enemy)
	if(is_user_alive(Touched)) {
		new bool:zyje = true;
		if(kid == Touched || vic == Touched) return ;
		new Float:Random_Float[3]
		for(new i = 0; i < 3; i++) Random_Float[i] = random_float(-50.0, 50.0)
		Punch_View(Touched, Random_Float)
		
		if(get_cvar_num("amx_knifedamage_mw2") >= get_user_health(Touched)) zyje = false;
		new origin[3];
		get_user_origin(Touched,origin)
		origin[2] += 25
		if(zyje == true){
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_short(blood2)
			write_short(blood)
			write_byte(229)
			write_byte(25)
			message_end()
			set_user_health(Touched,get_user_health(Touched) - get_cvar_num("amx_knifedamage_mw2"));
			emit_sound(Touched, CHAN_ITEM, "player/headshot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		
		else{
			set_user_frags(kid, get_user_frags(kid) + 1)
			
			new gmsgScoreInfo = get_user_msgid("ScoreInfo")
			new gmsgDeathMsg = get_user_msgid("DeathMsg")
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_short(blood2)
			write_short(blood)
			write_byte(229)
			write_byte(25)
			message_end()
			
			set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
			set_msg_block(gmsgScoreInfo,BLOCK_ONCE)
			user_kill(Touched,1)
			
			message_begin(MSG_ALL,gmsgScoreInfo)
			write_byte(kid)
			write_short(get_user_frags(kid))
			write_short(get_user_deaths(kid))
			write_short(0)
			write_short(get_user_team(kid))
			message_end()
			
			message_begin(MSG_ALL,gmsgScoreInfo)
			write_byte(Touched)
			write_short(get_user_frags(Touched))
			write_short(get_user_deaths(Touched))
			write_short(0)
			write_short(get_user_team(Touched))
			message_end()
			
			message_begin(MSG_ALL,gmsgDeathMsg,{0,0,0},0)
			write_byte(kid)
			write_byte(Touched)
			write_byte(0)
			write_string("knife")
			message_end()
			emit_sound(Touched, CHAN_ITEM, "player/die1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		remove_entity(Toucher)
	}
}
public paint_fire(id)
{
	new ent = create_entity("info_target")
	if (pev_valid(ent) && is_user_alive(id)){
		if(ile_nozy[id]-- < 1){
			client_print(id, print_center, "Nie masz wiecej nozy!");
			return 0;
		}
			
		new Float:vangles[3], Float:nvelocity[3], Float:voriginf[3], vorigin[3];
		
		set_pev(ent, pev_owner, id);
		set_pev(ent, pev_classname, "throw_knife");
		engfunc(EngFunc_SetModel, ent, "models/w_throw.mdl");
		set_pev(ent, pev_gravity, get_cvar_float("amx_knifegravity_mw2"));	
		get_user_origin(id, vorigin, 1);
		
		IVecFVec(vorigin, voriginf);
		set_pev(ent,pev_origin,voriginf)
		
		static Float:player_angles[3]
		pev(id, pev_angles, player_angles)
		player_angles[2] = 0.0
		set_pev(ent, pev_angles, player_angles);
		
		pev(id, pev_v_angle, vangles);
		set_pev(ent, pev_v_angle, vangles);
		pev(id, pev_view_ofs, vangles);
		set_pev(ent, pev_view_ofs, vangles);
		
		new veloc = get_cvar_num("amx_knifespeed_mw2")
		
		set_pev(ent, pev_movetype, MOVETYPE_TOSS);
		set_pev(ent, pev_solid, 2);
		velocity_by_aim(id, veloc, nvelocity);	
		
		set_pev(ent, pev_velocity, nvelocity);
		set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);
		set_pev(ent,pev_sequence,0)
		set_pev(ent,pev_framerate,1.0)
		
		entity_set_edict(ent, EV_ENT_owner, id)
	}
	return ent;
}

public Punch_View(id, Float:ViewAngle[3])
	set_pev(id, pev_punchangle, ViewAngle)

public SprzedajMenu(id)
{
	new menu = menu_create("Sprzedaj \rprzedmiot:", "SprzedajMenu_Handle");
	menu_additem(menu, "Przedmiot 1 \r[+1PLN]");
	menu_additem(menu, "Przedmiot 2 \r[+1PLN]");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public SprzedajMenu_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_destroy(menu);
	switch(item){
		case 0:{
			if (informacje_przedmiotu_gracza[id][0] == 0){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz przedmiotu 1 na sprzedaz!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_CONTINUE;
			}
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Sprzedano przedmiot 1!");
			WyrzucPrzedmiot(id)
			monety_gracza[id] += 1
		}
		case 1:{
			if (informacje_itemu_gracza[id][0] == 0){
				ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz przedmiotu 2 na sprzedaz!");
				client_cmd(id, "spk uSpiewaKa_CoD/niemoge");
				return PLUGIN_CONTINUE;
			}
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Sprzedano przedmiot 2!");
			WyrzucItem(id)
			monety_gracza[id] += 1
		}
	}
	return PLUGIN_CONTINUE;
}
stock Blast_ExplodeDamage( entid, Float:damage, Float:range ) 
{
        new Float:flOrigin1[ 3 ];
        entity_get_vector( entid, EV_VEC_origin, flOrigin1 );

        new Float:flDistance;
        new Float:flTmpDmg;
        new Float:flOrigin2[ 3 ];

        for( new i = 1; i <= g_maxplayers; i++ ) 
        {
                if( is_user_alive( i ) && get_user_team( entid ) != get_user_team( i ) ){
                        entity_get_vector( i, EV_VEC_origin, flOrigin2 );
                        flDistance = get_distance_f( flOrigin1, flOrigin2 );
                        
                        static const szWeaponName[] = "Blast Explosion";
                
                        if( flDistance <= range ) {
                                flTmpDmg = damage - ( damage / range ) * flDistance;
                                fakedamage( i, szWeaponName, flTmpDmg, DMG_BLAST );
                        
                                message_begin( MSG_BROADCAST, gMessageDeathMsg );
                                write_byte( entid );
                                write_byte( i );
                                write_byte( 0 );
                                write_string( szWeaponName );
                                message_end();
                        }
                }
        }
}
stock Create_BeamCylinder( origin[ 3 ], addrad, sprite, startfrate, framerate, life, width, amplitude, red, green, blue, brightness, speed )
{
        message_begin( MSG_PVS, SVC_TEMPENTITY, origin ); 
        write_byte( TE_BEAMCYLINDER );
        write_coord( origin[ 0 ] );
        write_coord( origin[ 1 ] );
        write_coord( origin[ 2 ] );
        write_coord( origin[ 0 ] );
        write_coord( origin[ 1 ] );
        write_coord( origin[ 2 ] + addrad );
        write_short( sprite );
        write_byte( startfrate );
        write_byte( framerate );
        write_byte(life );
        write_byte( width );
        write_byte( amplitude );
        write_byte( red );
        write_byte( green );
        write_byte( blue );
        write_byte( brightness );
        write_byte( speed );
        message_end();
}
public ZamienPerk(id)
{
	new menu = menu_create("Zamien sie perkiem", "ZamienPerk_Handle");
	new cb = menu_makecallback("OddajPerk_Callback");
	for(new i=0, n=0; i<=32; i++){
		if(!is_user_connected(i))
			continue;
		oddaj_id[n++] = i;
		new nazwa_gracza[64];
		get_user_name(i, nazwa_gracza, 63)
		menu_additem(menu, nazwa_gracza, "0", 0, cb);
	}
	menu_display(id, menu);
}

public ZamienPerk_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(oddaj_id[item])){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie odnaleziono rzadanego gracza.");
		return PLUGIN_HANDLED;
	}
	
	if(!informacje_przedmiotu_gracza[oddaj_id[item]][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wybrany gracz nie mam zadnego przedmiotu 1.");
		return PLUGIN_HANDLED;
	}
	
	if(!informacje_przedmiotu_gracza[id][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz zadnego przedmiotu 1.");
		return PLUGIN_HANDLED;
	}

	new nazwa_menu[128], nick[64];
	
	get_user_name(id, nick, charsmax(nick))
	formatex(nazwa_menu, charsmax(nazwa_menu), "Chcesz wymienic sie itemem1 z \y%s^n\wJego Item:\y %s", nick,nazwy_przedmiotow[informacje_przedmiotu_gracza[id][0]])
	
	new menu2 = menu_create(nazwa_menu, "menu_wymien");

	menu_additem(menu2, "Tak", nick);
	menu_addblank(menu2, 0)
	menu_additem(menu2, "Nie", nick);
	menu_setprop(menu2, MPROP_EXITNAME, "Wyjdz");
	menu_display(oddaj_id[item], menu2);
	return PLUGIN_HANDLED;
}

public menu_wymien(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new access, callback, data[64];
	menu_item_getinfo(menu, item, access, data, charsmax(data), _, _, callback);
	new id2 = get_user_index(data) 
	
	switch(item){
		case 0: { 
			new perk_oddajacego = informacje_przedmiotu_gracza[id2][0]
			new perk_dajacego = informacje_przedmiotu_gracza[id][0]
			new trim_oddajacego = wytrzymalosc_przedmiotu[id2]
			new trim_dajacego = wytrzymalosc_przedmiotu[id]
			
			DajPrzedmiot(id2, perk_dajacego)
			DajPrzedmiot(id, perk_oddajacego)
			wytrzymalosc_przedmiotu[id2] = trim_dajacego
			wytrzymalosc_przedmiotu[id] = trim_oddajacego
					
			new nazwa_dajacego[64];
			
			get_user_name(id, nazwa_dajacego, charsmax(nazwa_dajacego))
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wymieniles sie przedmiotem 1 z %s", data);
			ColorChat(id2,BLUE,"[uSpiewaKa.eu]^x01 Wymieniles sie przedmiotem 1 z %s", nazwa_dajacego);
		}
		case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wybrany gracz nie zgodzil sie na wymiane przedmiotu 1.");
	}
	return PLUGIN_CONTINUE;
}

public OddajPerk_Callback(id, menu, item)
{
	if(oddaj_id[item] == id || !klasa_gracza[oddaj_id[item]] || !informacje_przedmiotu_gracza[oddaj_id[item]][0]) return ITEM_DISABLED;
	return ITEM_ENABLED;
}
public ZamienPerka(id)
{
	new menu = menu_create("Zamien sie perkiem", "ZamienPerka_Handle");
	new cb = menu_makecallback("OddajPerka_Callback");
	for(new i=0, n=0; i<=32; i++){
		if(!is_user_connected(i)) continue;
		oddaj_id[n++] = i;
		new nazwa_gracza[64];
		get_user_name(i, nazwa_gracza, 63)
		menu_additem(menu, nazwa_gracza, "0", 0, cb);
	}
	menu_display(id, menu);
}

public ZamienPerka_Handle(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_connected(oddaj_id[item])){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie odnaleziono rzadanego gracza.");
		return PLUGIN_HANDLED;
	}
	
	if(!informacje_itemu_gracza[oddaj_id[item]][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wybrany gracz nie mam zadnego przedmiotu 2.");
		return PLUGIN_HANDLED;
	}
	
	if(!informacje_itemu_gracza[id][0]){
		ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Nie masz zadnego przedmiotu 2.");
		return PLUGIN_HANDLED;
	}

	new nazwa_menu[128], nick[64];
	
	get_user_name(id, nick, charsmax(nick))
	formatex(nazwa_menu, charsmax(nazwa_menu), "Chcesz wymienic sie itemem2 z\y %s ^n\wJego Item:\y %s", nick,nazwy_itemow[informacje_itemu_gracza[id][0]])
	
	new menu2 = menu_create(nazwa_menu, "menu_wymiena");

	menu_additem(menu2, "Tak", nick);
	menu_addblank(menu2, 0)
	menu_additem(menu2, "Nie", nick);
	menu_setprop(menu2, MPROP_EXITNAME, "Wyjdz");
	menu_display(oddaj_id[item], menu2);
	return PLUGIN_HANDLED;
}

public menu_wymiena(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new access, callback, data[64];
	menu_item_getinfo(menu, item, access, data, charsmax(data), _, _, callback);
	new id2 = get_user_index(data) 
	
	switch(item){
		case 0: { 
			new perk_oddajacego = informacje_itemu_gracza[id2][0]
			new perk_dajacego = informacje_itemu_gracza[id][0]
			new trim_oddajacego = wytrzymalosc_itemu[id2]
			new trim_dajacego = wytrzymalosc_itemu[id]
			
			DajItem(id2, perk_dajacego)
			DajItem(id, perk_oddajacego)
			wytrzymalosc_itemu[id2] = trim_dajacego
			wytrzymalosc_itemu[id] = trim_oddajacego
					
			new nazwa_dajacego[64];
			
			get_user_name(id, nazwa_dajacego, charsmax(nazwa_dajacego))
			ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wymieniles sie przedmiotem 2 z %s", data);
			ColorChat(id2,BLUE,"[uSpiewaKa.eu]^x01 Wymieniles sie przedmiotem 2 z %s", nazwa_dajacego);
		}
		case 1: ColorChat(id,BLUE,"[uSpiewaKa.eu]^x01 Wybrany gracz nie zgodzil sie na wymiane przedmiotu 2.");
	}
	return PLUGIN_CONTINUE;
}

public OddajPerka_Callback(id, menu, item)
{
	if(oddaj_id[item] == id || !klasa_gracza[oddaj_id[item]] || !informacje_itemu_gracza[oddaj_id[item]][0]) return ITEM_DISABLED;
	return ITEM_ENABLED;
}
public bestplayersexp(){
	new exp[3]={20000, 10000, 5000}
	new fragi;
	new omijamy[3];
	for(new j=0;j<3;j++){
		for(new i=1;i<g_maxplayers;i++){
			if(!is_user_connected(i) || i == omijamy[0] || i == omijamy[1]) continue;
			if(fragi < get_user_frags(i)){
				fragi = get_user_frags(i);
				omijamy[j] = i;
			}
		}
		fragi = 0;
		new name[64];
		get_user_name(omijamy[j],name,63);
		ColorChat(0,RED,"[uSpiewaKa.eu]^x03 %s ^x01zajal^x03 %d ^x01miejsce i zdobyl^x03 %d^x01 doswiadczenia",name,j+1,exp[j]);
		new Players[32], zablokuj;
		get_players(Players, zablokuj, "ch");
		if(zablokuj < 3) return PLUGIN_CONTINUE;
		doswiadczenie_gracza[omijamy[j]] += exp[j];
	}
	return PLUGIN_CONTINUE;
}
stock get_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
    new Float:fEntOrigin[3];
    entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

    new Float:fDistance[3];
    fDistance[0] = fEntOrigin[0] - fOrigin[0];
    fDistance[1] = fEntOrigin[1] - fOrigin[1];
    fDistance[2] = fEntOrigin[2] - fOrigin[2];

    new Float:fTime = ( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

    fVelocity[0] = fDistance[0] / fTime;
    fVelocity[1] = fDistance[1] / fTime;
    fVelocity[2] = fDistance[2] / fTime;

    return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}
stock set_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
    new Float:fVelocity[3];
    get_velocity_from_origin( ent, fOrigin, fSpeed, fVelocity )

    entity_set_vector( ent, EV_VEC_velocity, fVelocity );

    return ( 1 );
}
public fw_TraceAttack(id, enemy, Float:damage, Float:direction[3], tracehandle, damagetype){
	if (!is_user_alive(enemy) || informacje_przedmiotu_gracza[enemy][0] != 70 || get_user_weapon(enemy) != CSW_KNIFE) return HAM_IGNORED
	get_tr2(tracehandle,TR_vecEndPos,direction);
	set_velocity_from_origin(enemy,direction,500.0);
	return HAM_IGNORED
}
SprawdzCzas()
{
	new timestr[3];
	get_time("%H", timestr, 2);
	new godzina = str_to_num(timestr);  
	if(godzina >= 22 || godzina <= 06){
		noc = 1
		server_cmd("hostname ^"uSpiewaKa.eu [ CoD ][ EXPx2 22h-6h ][ FAST EXP ][ 300 LVL ][ Call of Duty ] @NetShoot.pl^"");
	}
	else server_cmd("hostname ^"uSpiewaKa.eu [ CoD ][ FAST EXP ][ 300 LVL ][ Call of Duty ] @NetShoot.pl^"");
}
