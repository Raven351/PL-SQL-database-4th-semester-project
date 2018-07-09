--AUTOR: Bartosz Baum, nr albumu: 34951, WSB Gda?sk grupa INiS4_2


insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Grunwaldzka', '421', 'Gdañsk', '80-312');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Nidzicka', '41', 'Sopot', '80-323');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Krakowska', '25', 'Gdañsk', '80-674');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Malopolska', '87', 'Gdynia', '80-674');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Wielkopolska', '56', 'Gdynia', '80-452');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Lubelska', '45', 'Gdansk', '80-684');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Podkarpacka', '33', 'Gdynia', '80-236');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Mazurska', '57', 'Gdansk', '80-564');
insert into adres(ulica, numer, miasto, kod_pocztowy) values ('Zachodnia', '86', 'Sopot', '80-345');
insert into adres(nazwa, ulica, numer, miasto, kod_pocztowy) values ('Lotnisko', 'Juliusza Slowackiego', '200', 'Gda?sk', '80-289');
insert into adres(nazwa, ulica, numer, miasto, kod_pocztowy) values ('Dworzec PKP Gda?sk', 'Podwale Grodzkie', '1', 'Gda?sk', '80-001');

insert into bonus (id, tytul, wynagrodzenie) values (0, 'Sprzedaz ubezpieczenia - podstawowe', 8);
insert into bonus (id, tytul, wynagrodzenie) values (1, 'Sprzedaz ubezpieczenia - rozszerzone', 15);
insert into bonus (id, tytul, wynagrodzenie) values (2, 'Sprzedaz ubezpieczenia - pelne', 30);
insert into bonus (id, tytul, wynagrodzenie) values (3, 'Wykrycie szkody w pojezdzie', 20);

insert into klient (imie, nazwisko, nr_telefonu, email, adres_id, pesel, nr_dokumentu, nr_prawa_jazdy) values ('Michal','Stachowicz', '512741462', 'ms@mail.com', 6, '25121253753', 'aws352246', 'N/S/2641236');
insert into klient (imie, nazwisko, nr_telefonu, email, adres_id, pesel, nr_dokumentu, nr_prawa_jazdy) values ('Zdzislaw','Kowalski', '514767182', 'zk@mail.com', 1, '93092575314', 'aws156786', 'N/S/7545636' );
insert into klient (imie, nazwisko, nr_telefonu, email, adres_id, pesel, nr_dokumentu, nr_prawa_jazdy) values ('Stanislaw','Nowak', '225778921', 'sn@mail.com', 2, '85041234113', 'aws827944', 'N/S/7654613');

insert into pracownik(imie,nazwisko,nr_telefonu_prywatny, email_firmowy, adres_id) values ('Szymon', 'Laskowski', '664702730' ,'sl@car.com', 3);
insert into pracownik(imie,nazwisko,nr_telefonu_prywatny, email_firmowy, adres_id) values ('Natalia', 'Grzybowska', '737040181' ,'ng@car.com', 4);
insert into pracownik(imie,nazwisko,nr_telefonu_prywatny, email_firmowy, adres_id) values ('Jakub', 'Sikora', '739362497' ,'js@car.com', 5);

insert into sposob_rozliczania(nazwa, opis) values ('Okres miesieczny', 'Stale okreslona stawka miesieczna');
insert into sposob_rozliczania(nazwa, opis) values ('Okres godzinowy', 'Stale okreslona stawka godzinowa');
insert into sposob_rozliczania(nazwa, opis) values ('Jednostkowy zleceniowy', 'Stale okreslona stawka za jedno wykonane zlecenie');

insert into stanowisko(nazwa, opis) values ('Kierownik Oddzialu', 'Odpowiada za oddzial firmy na danym terenie lub w danej miejscowsci');
insert into stanowisko(nazwa, opis) values ('Podstawienia i odbiory', 'Odpowiada za podstawienia i odbiory auta w miejscu wyznaczonym przez klienta');
insert into stanowisko(nazwa, opis) values ('Infolinia', 'Odpowiada za kontakt z klientem poprzez infolinie');

insert into stanowisko_pracownika(data_poczatku_zatrudnienia, stawka, pracownik_id, stanowisko_id, sposob_rozliczania_id) values (TO_DATE('2018/02/17', 'yyyy/mm/dd'), 4500, 1,1,1);
insert into stanowisko_pracownika(data_poczatku_zatrudnienia, stawka, pracownik_id, stanowisko_id, sposob_rozliczania_id) values (TO_DATE('2018/02/17', 'yyyy/mm/dd'), 20, 1,2,3);
insert into stanowisko_pracownika(data_poczatku_zatrudnienia, stawka, pracownik_id, stanowisko_id, sposob_rozliczania_id) values (TO_DATE('2018/02/17', 'yyyy/mm/dd'), 20, 3,2,3);
insert into stanowisko_pracownika(data_poczatku_zatrudnienia, stawka, pracownik_id, stanowisko_id, sposob_rozliczania_id) values (TO_DATE('2018/02/17', 'yyyy/mm/dd'), 15, 2,3,2); --22-04-2018

insert into wersja_nadwozia(nazwa) values ('Hatchback'); 
insert into wersja_nadwozia(nazwa) values ('Sedan'); 
insert into wersja_nadwozia(nazwa) values ('SUV'); 

insert into segment_samochodu(nazwa) values ('B');
insert into segment_samochodu(nazwa) values ('C');
insert into segment_samochodu(nazwa) values ('SUV');

insert into marka_model_samochodu(marka, model, wersja_nadwozia_id,segment_samochodu_id) values ('Nissan', 'Micra', '1', '1');
insert into marka_model_samochodu(marka, model, wersja_nadwozia_id,segment_samochodu_id) values ('Opel', 'Astra', '2', '2');
insert into marka_model_samochodu(marka, model, wersja_nadwozia_id,segment_samochodu_id) values ('Nissan', 'Qashqai', '3', '3');


insert into samochod(nr_rejestracyjny, nr_polisy, data_waznosci_polisy, data_waznosci_przegladu, marka_model_samochodu_id) values ('GD 2516W', 'P/18/25653', 
TO_DATE('2018/05/03', 'yyyy/mm/dd'), TO_DATE('2018/06/07', 'yyyy/mm/dd'), 1);
insert into samochod(nr_rejestracyjny, nr_polisy, data_waznosci_polisy, data_waznosci_przegladu, marka_model_samochodu_id) values ('GD 2533W', 'P/18/21523', 
TO_DATE('2018/05/23', 'yyyy/mm/dd'), TO_DATE('2018/09/27', 'yyyy/mm/dd'), 2);
insert into samochod(nr_rejestracyjny, nr_polisy, data_waznosci_polisy, data_waznosci_przegladu, marka_model_samochodu_id) values ('GD 2251W', 'P/18/56523', 
TO_DATE('2018/08/15', 'yyyy/mm/dd'), TO_DATE('2018/12/17', 'yyyy/mm/dd'), 3);

insert into warsztat (nazwa, telefon, EMAIL, adres_id) values ('Multiserwis', 512621252, 'ms@email.com', 7);
insert into warsztat (nazwa, telefon, EMAIL, adres_id) values ('Wulkanizacja', 641321252, 'ms@email.com', 8);
insert into warsztat (nazwa, telefon, EMAIL, adres_id) values ('Nissan ASO', 675126652, 'ms@email.com', 9);

insert into szkoda(samochod_id, data_powstania, opis) values (1, (TO_DATE('2018/03/17', 'yyyy/mm/dd')), 'Wgniecenie na drzwiach LP');
insert into szkoda(samochod_id, data_powstania, opis) values (2, (TO_DATE('2018/04/10', 'yyyy/mm/dd')), 'Zarysowanie na tylnym zderzaku, strona lewa');
insert into szkoda(samochod_id, data_powstania, opis) values (1, (TO_DATE('2018/04/04', 'yyyy/mm/dd')), 'Zarysowanie na przednim zderzaku strona prawa');

insert into serwis (data, samochod_id, opis, koszt, warsztat_id, szkoda_id) values ((TO_DATE('2018/03/23', 'yyyy/mm/dd')), 1,'Naprawa drzwi przednich lewych', 342.25,3,1);
insert into serwis (data, samochod_id, opis, koszt, warsztat_id, szkoda_id) values ((TO_DATE('2018/03/20', 'yyyy/mm/dd')), 2,'Naprawa tylnego zderzaka' ,152.74,1,2);
insert into serwis (data, samochod_id, opis, koszt, warsztat_id, szkoda_id) values ((TO_DATE('2018/03/20', 'yyyy/mm/dd')), 1,'Wymiana przedniego zderzaka' ,234.12,3,3);

insert into zlecenie(data_przyjecia, data_podstawienia, data_zwrotu, segment_samochodu_id, samochod_id, adres_podstawienia_id, adres_odbioru_id, klient_id)
values (TO_DATE('2018/02/20 08:02:44', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/02/23 08:00:00', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/01 21:00:00', 'yyyy/mm/dd hh24:mi:ss'),
1, 1, 10, 11, 1);

insert into zlecenie(data_przyjecia, data_podstawienia, data_zwrotu, segment_samochodu_id, samochod_id, adres_podstawienia_id, adres_odbioru_id, klient_id)
values (TO_DATE('2018/02/22 23:43:12', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/02/25 11:00:00', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/06 19:00:00', 'yyyy/mm/dd hh24:mi:ss'),
3, 3, 10, 10, 2);

insert into zlecenie(data_przyjecia, data_podstawienia, data_zwrotu, segment_samochodu_id, samochod_id, adres_podstawienia_id, adres_odbioru_id, klient_id)
values (TO_DATE('2018/02/26 18:04:22', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/01 08:30:00', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/09 15:00:00', 'yyyy/mm/dd hh24:mi:ss'),
2, 2, 11, 11, 3);
--
insert into zlecenie(data_przyjecia, data_podstawienia, data_zwrotu, segment_samochodu_id, samochod_id, adres_podstawienia_id, adres_odbioru_id, klient_id)
values (TO_DATE('2018/03/09 22:42:09', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/10 09:00:00', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/17 17:00:00', 'yyyy/mm/dd hh24:mi:ss'),
1, 1, 10, 10, 1);

insert into zlecenie(data_przyjecia, data_podstawienia, data_zwrotu, segment_samochodu_id, samochod_id, adres_podstawienia_id, adres_odbioru_id, klient_id)
values (TO_DATE('2018/04/02 10:23:42', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/30 14:00:00', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/04/10 14:00:00', 'yyyy/mm/dd hh24:mi:ss'),
2, 2, 10, 10, 2);

insert into zlecenie(data_przyjecia, data_podstawienia, data_zwrotu, segment_samochodu_id, samochod_id, adres_podstawienia_id, adres_odbioru_id, klient_id)
values (TO_DATE('2018/03/19 09:12:04', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/03/26 11:00:00', 'yyyy/mm/dd hh24:mi:ss'), TO_DATE('2018/04/04 11:00:00', 'yyyy/mm/dd hh24:mi:ss'),
1, 1, 11, 10, 1);

insert into zaliczka (data_wplaty, pracownik_id, kwota) values (TO_DATE('2018/02/18', 'yyyy/mm/dd'), 2, 40);
insert into zaliczka (data_wplaty, pracownik_id, kwota) values (TO_DATE('2018/03/01', 'yyyy/mm/dd'), 2, 100);
insert into zaliczka (data_wplaty, pracownik_id, kwota) values (TO_DATE('2018/04/01', 'yyyy/mm/dd'), 2, 100);

insert into rodzaj_z_p(tytul) values ('Podstawienie');
insert into rodzaj_z_p(tytul) values ('Zwrot');
insert into rodzaj_z_p(tytul) values ('Transfer');

insert into poniesione_koszty_pracownika (tytul) values ('Parking');
insert into poniesione_koszty_pracownika (tytul) values ('Komunikacja miejska');
insert into poniesione_koszty_pracownika (tytul) values ('Komunikacja krajowa');
insert into poniesione_koszty_pracownika (tytul) values ('Przygotowanie auta');

--zrobic trigger on insert dla bonus_zlecenia by sam zwiekszal wartosc wynagrodzenia w tabeli zlecenie_pracownika
--zrobic CHECK constraints z datami, np data zwrotu wczesniejsza niz data wypozyczenia, albo sprawdzenie czy samochod nie jest juz zarezerwowany
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (1, 1, 1);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (1, 1, 2);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 2, 1);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 2, 2);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 3, 1);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 3, 2);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 4, 1);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (1, 4, 2);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (1, 5, 1);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 5, 2);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (3, 6, 1);
insert into zlecenie_pracownika (pracownik_id, zlecenie_id, rodzaj_z_p_id) values (1, 6, 2);

insert into bonus_zlecenia (zlecenie_pracownika_id, bonus_id) values (1,0);
insert into bonus_zlecenia (zlecenie_pracownika_id, bonus_id) values (2,2);
insert into bonus_zlecenia (zlecenie_pracownika_id, bonus_id) values (3,1);
insert into bonus_zlecenia (zlecenie_pracownika_id, bonus_id) values (4,3);
insert into bonus_zlecenia (zlecenie_pracownika_id, bonus_id) values (5,1);
insert into bonus_zlecenia (zlecenie_pracownika_id, bonus_id) values (6,3);

insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (1, 4, 9);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (1, 8, 7);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (1, 10, 12);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (1, 12, 7);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (2, 5, 7);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (2, 11, 7);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (4, 1, 10);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (4, 3, 10);
insert into koszt_zlecenia (poniesione_koszty_p_id, zlecenie_pracownika_id, wartosc) values (4, 5, 15);

insert into podatki (tytul, procent) values ('emerytalna', 976);
insert into podatki (tytul, procent) values ('rentowa', 15);
insert into podatki (tytul, procent) values ('chorobowa', 245);

insert into podatki_pracownika (stanowisko_pracownika_p_id, stanowisko_pracownika_s_id, podatki_id) values (1,1,1);
insert into podatki_pracownika (stanowisko_pracownika_p_id, stanowisko_pracownika_s_id, podatki_id) values (1,1,2);
insert into podatki_pracownika (stanowisko_pracownika_p_id, stanowisko_pracownika_s_id, podatki_id) values (1,1,3);
insert into podatki_pracownika (stanowisko_pracownika_p_id, stanowisko_pracownika_s_id, podatki_id) values (2,3,1);
insert into podatki_pracownika (stanowisko_pracownika_p_id, stanowisko_pracownika_s_id, podatki_id) values (2,3,2);