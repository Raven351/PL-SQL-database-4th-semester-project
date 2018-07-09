--AUTOR: Bartosz Baum, nr albumu: 34951, WSB Gda?sk grupa INiS4_2

--Wyswietla zlecenie z najwieksza iloscia kosztow wsrod pracownikow
create or replace view highest_cost as 
select z.id as "Numer zlecenia", z.data_przyjecia,k.imie || ' ' || k.nazwisko as "Klient" ,sum(kz.wartosc) as "Suma kosztow zlecenia" from
klient k right join zlecenie z on k.id = z.klient_id
left join zlecenie_pracownika zp on z.id = zp.zlecenie_id
left join koszt_zlecenia kz on zp.id = kz.zlecenie_pracownika_id
group by kz.zlecenie_pracownika_id, z.id, z.data_przyjecia,k.imie, k.nazwisko
--having count (kz.suma) = (select top 1 with ties sum(wartosc) from 
having kz.ZLECENIE_PRACOWNIKA_ID in 
(select zlecenie_pracownika_id from (select zlecenie_pracownika_id ,  sum(wartosc) as "SUMA" from koszt_zlecenia group by zlecenie_pracownika_id order by sum(wartosc) desc) where ROWNUM = 1);

--Liczy i wyswietla ile zlecen podstawienia lub odbioru samochodu wykonal pracownik o danym ID w danym okresie
--Ponizsze zapytanie w przeksztalconej formie zostalo dodatkowo wykorzystane w jedenej z procedur.
create or replace view order_count_in_march as 
select count(*) as "Ilosc Zlecen" from ( --liczy ilosc rekordow w tabeli
select zp.pracownik_id,  zp.RODZAJ_Z_P_ID, rzp.tytul ,z.data_podstawienia, z.data_zwrotu from zlecenie_pracownika zp left join zlecenie z
on z.id = zp.zlecenie_id left join rodzaj_z_p rzp on zp.rodzaj_z_p_id = rzp.id
group by zp.pracownik_id, zp.rodzaj_z_p_id, rzp.tytul, z.data_podstawienia, z.data_zwrotu order by data_podstawienia asc) --select z laczeniami tabel celowo uzyty jako podzapytanie w celu mozliwosci uzycia funkcji count bez koniecznosci uzycia klauzuli having
where 
(rodzaj_z_p_id = 1 and data_podstawienia between TO_DATE('2018/03/01', 'yyyy/mm/dd') and TO_DATE('2018/03/31', 'yyyy/mm/dd') 
or rodzaj_z_p_id = 2 and  data_zwrotu between TO_DATE('2018/03/01', 'yyyy/mm/dd') and TO_DATE('2018/03/31', 'yyyy/mm/dd')) and pracownik_id = 1 ;

--Sumuje i wyswietla ilosc zlecen zrealizowanych przez pracownika w danym okresie
select count(*) from 
(select zp.pracownik_id, zp.rodzaj_z_p_id ,z.data_podstawienia, z.data_zwrotu from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
group by zp.pracownik_id, zp.rodzaj_z_p_id, z.data_podstawienia, z.data_zwrotu) 
where pracownik_id = 1 and ((data_podstawienia between TO_DATE('2018/01/01', 'yyyy/mm/dd') and TO_DATE('2018/12/31', 'yyyy/mm/dd') and rodzaj_z_p_id = 1) or  
(data_zwrotu between TO_DATE('2018/01/01', 'yyyy/mm/dd') and TO_DATE('2018/12/31', 'yyyy/mm/dd') and rodzaj_z_p_id = 2));


--========================================================================================================================
--|||||||||||||||||||||||||||||||||||||||||||BRUDNOPIS||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv+++++++++vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
having count(TO_DATE(z.data_podstawienia)) between TO_DATE('2018/03/01', 'yyyy/mm/dd') and TO_DATE('2018/03/31', 'yyyy/mm/dd') or
count(TO_DATE(z.data_zwrotu)) between TO_DATE('2018/03/01', 'yyyy/mm/dd') and TO_DATE('2018/03/31', 'yyyy/mm/dd')
order by zp.Rodzaj_z_p_id

having count(zp.RODZAJ_Z_P_ID) = 1 and TO_DATE(z.data_podstawienia) between TO_DATE('2018/03/01', 'yyyy/mm/dd') and TO_DATE('2018/03/31', 'yyyy/mm/dd') or
count(zp.RODZAJ_Z_P_ID) = 2 and TO_DATE(z.data_zwrotu) between TO_DATE('2018/03/01', 'yyyy/mm/dd') and TO_DATE('2018/03/31', 'yyyy/mm/dd')
order by zp.Rodzaj_z_p_id

insert into zaliczka (data_wplaty, pracownik_id, kwota) values (TO_DATE('2018/04/01', 'yyyy/mm/dd'), 2, 100);


select s.id_samochod, s.marka, s.model, s.nr_rej, s.nr_VIN, count (oz.id_pracownik) as 'Ilo?? wykonanych zlece?'
from samochod s left join samochody_pracownika sp on s.id_samochod=sp.id_samochod 
left join pracownik p on sp.id_pracownik = sp.id_samochod left join obsluga_zlecenia oz on p.id_pracownik = oz.id_pracownik
group by s.id_samochod, s.marka, s.model, s.nr_rej, s.nr_VIN having count(oz.id_pracownik)>1

select z.id_zlecenie, t.id_towar, t.nazwa , k.id_klient, k.imie as 'Imie zleceniodawcy',k.nazwisko as 'Nazwisko zleceniodawcy', z.data_odbioru from
zlecenie z right join klient k on z.id_klient = k.id_klient 
right join pozycja_zlecenia pz on z.id_zlecenie = pz.id_zlecenie 
right join towar t on pz.id_towar = t.id_towar
--where z.data_odbioru in (select data_odbioru from zlecenie where year(data_odbioru) = '2017')
group by z.id_zlecenie, t.id_towar, t.nazwa , k.id_klient, k.imie,k.nazwisko, z.data_odbioru 
having count(pz.id_towar) = (select top 1 with ties count(id_towar) from pozycja_zlecenia group by id_towar order by id_towar desc);


----------------------------------------------------
--5. Zapytania SELECT wykorzystuj?ce równocze?nie: z??czenia tabel DONE, funkcje agreguj?ce JEST  i podzapytania, nast?pnie utwórz z nich 2 widoki.
select p.imie || ' ' ||  p.nazwisko as "Pracownik", z.data_podstawienia as "Data Podstawienia", b.ulica ||' '|| b.numer ||' ' || b.miasto as "Adres", z.id from 
pracownik p left join zlecenie_pracownika zp on p.id = zp.pracownik_id 
left join zlecenie z on zp.zlecenie_id = z.id
left join adres b on z.adres_podstawienia_id = b.id 
group by p.imie, p.nazwisko,z.id, z.data_podstawienia, b.ulica, b.numer, b.miasto, z.id
having count (z.id) in (select id from zlecenie where extract(month from data_przyjecia) <> extract(month from data_podstawienia)) and count (zp.rodzaj_z_p_id) = 1;

select z.data_podstawienia as "Data Podstawienia", p.imie || ' ' ||  p.nazwisko as "Pracownik" , b.ulica ||' '|| b.numer ||' ' || b.miasto as "Adres", z.id from
zlecenie z left join zlecenie_pracownika zp on z.id = zp.zlecenie_id
left join pracownik p on p.id = zp.pracownik_id
left join adres b on z.adres_podstawienia_id = b.id
group by p.imie, p.nazwisko,z.id, z.data_podstawienia, b.ulica, b.numer, b.miasto, z.id, zp.rodzaj_z_p_id
having zp.rodzaj_z_p_id = 1 and count (extract(month from z.data_przyjecia)) not in  (select extract(month from data_podstawienia) from zlecenie);
select id from zlecenie_pracownika having count(pracownik_id) > 1 group by id, pracownik_id; 
select count(id) from zlecenie_pracownika where pracownik_id = 1;

--pokazuje pracownikow ktorzy wykonali mniej niz 2 zlecenia przed 1/04/2018
select p.imie || ' ' ||  p.nazwisko as "Pracownik", count(zp.pracownik_id) as "Ilosc wykonanych zlecen" 
from pracownik p left join zlecenie_pracownika zp on p.id = zp.pracownik_id
left join zlecenie z on z.id = zp.zlecenie_id
group by p.imie, p.nazwisko, zp.pracownik_id, z.data_podstawienia
having count (zp.pracownik_id) > 2 and extract(month from z.data_podstawienia) > 4 and count(extract(year from z.data_podstawienia)) <= 2018;

select p.imie || ' ' ||  p.nazwisko as "Pracownik" from pracownik p left join zlecenie_pracownika zp on p.id = zp.pracownik_id;

select imie from pracownik;

select max(SUMA) as "Najwyzszy koszt zlecenia" from (select zlecenie_pracownika_id ,  sum(wartosc) as "SUMA" from koszt_zlecenia group by zlecenie_pracownika_id order by sum(wartosc) desc);
select zlecenie_pracownika_id from (select zlecenie_pracownika_id ,  sum(wartosc) as "SUMA" from koszt_zlecenia group by zlecenie_pracownika_id order by sum(wartosc) desc) where ROWNUM = 1;