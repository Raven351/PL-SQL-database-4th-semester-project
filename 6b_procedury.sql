--AUTOR: Bartosz Baum, nr albumu: 34951, WSB Gda?sk grupa INiS4_2

--6. Oprogramuj baz? danych. 
--Napisz co najmniej 5 nietrywialnych, u?ytecznych funkcji, 5 nietrywialnych, u?ytecznych procedur i 5 nietrywialnych, u?ytecznych wyzwalaczy (nie licz autoinkrementacji) 
--oraz udowodnij, ?e dzia?aj? (napisz instrukcj?, która wykorzystuje lub inicjuje implementowany obiekt). Nie zapomnij napisa? w komentarzu co robi? implementowane obiekty. 


--P1 Procedura wstawia rekord do tabeli 'wyplata' w zaleznosci od podanych wartosci oraz wartosci z innych tabel 
--(dodaje wszystkie bonusy i wynagrodzenia z pojedyncze zlecenia oraz odejmuje zaliczke z danego miesiaca)
create or replace procedure wyplac_pieniadze(
    v_data WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_stanowisko_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_przepracowane_godziny INT
    )
is
v_suma_brutto wyplata.suma_wyplaty_brutto%type :=0 ;
v_suma_netto wyplata.suma_wyplaty_brutto%type :=0;
v_n int;
v_procent wyplata.suma_wyplaty_brutto%type;


begin
    --mozna by dodac EXCEPTION
    if v_stanowisko_id = 1 then
        select stawka into v_suma_brutto from stanowisko_pracownika where pracownik_id = v_pracownik_id and stanowisko_id = v_stanowisko_id;
    end if;
    if v_stanowisko_id = 2 then
        v_suma_brutto := countEmployeeMoney(v_okres_poczatek, v_okres_koniec, v_pracownik_id  , v_stanowisko_id, true, true, true);
        v_suma_brutto := v_suma_brutto - employeeAdvance(v_okres_poczatek, v_okres_koniec, v_pracownik_id);
    end if;
    if v_stanowisko_id = 3 then
        select stawka into v_suma_brutto from stanowisko_pracownika where pracownik_id = v_pracownik_id and stanowisko_id = v_stanowisko_id;
        v_suma_brutto := v_suma_brutto * v_przepracowane_godziny;
    end if;
    v_suma_netto := v_suma_brutto;
    select count(*) into v_n from podatki_pracownika where stanowisko_pracownika_p_id = v_pracownik_id and stanowisko_pracownika_s_id = v_stanowisko_id;
    if v_n > 0 then
        for v_i in 1..v_n loop
            select procent into v_procent from podatki where id = 
            (select podatki_id from (select PODATKI_ID, ROW_NUMBER() OVER(ORDER BY podatki_id) AS RowNumber from podatki_pracownika where 
            stanowisko_pracownika_p_id = v_pracownik_id and stanowisko_pracownika_s_id = v_stanowisko_id)where RowNumber = v_i); 
            v_procent := v_procent / 10000;
            v_suma_netto := v_suma_netto - (v_suma_netto * v_procent);
        end loop;
    end if;
    insert into wyplata (data, suma_wyplaty_brutto, suma_wyplaty_netto, okres_poczatek, okres_koniec, s_p_pracownik_id, s_p_stanowisko_id, przepracowane_godziny) values 
    (v_data, v_suma_brutto, v_suma_netto, v_okres_poczatek, v_okres_koniec, v_pracownik_id, v_stanowisko_id, v_przepracowane_godziny);
end;


--P2 Wyswietla raport roczny o pracowniku (ile zlecen w roku, ile zarobkow srednio miesiecznie, ile lacznie, ile wykonal podstawien/odbiorow, ile przepracowal godzin itd) 
--jako argument podaje procedury podaje sie rok za ktory ma zostac wyswietlony raport oraz id pracownika

create or replace procedure employeeReport(
    v_pracownikID int ,
    v_rok int
    )
is
v_iloscZlecen int;
v_iloscPodstawien int;
v_iloscZwrotow int;
v_iloscGodzin int;
v_srednieZarobkiBrutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_srednieZarobkiNetto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_sumaZarobkiBrutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_sumaZarobkiNetto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_stanowiskoPracownika int :=0;


begin
    select count (*) into v_stanowiskoPracownika from stanowisko_pracownika where pracownik_id = v_pracownikID and stanowisko_id = 2; --sprawdza czy pracownik zajmuje sie zleceniami
    
    begin
    select count(*) into v_iloscZlecen from 
    (select zp.pracownik_id, zp.rodzaj_z_p_id ,EXTRACT(YEAR from z.data_podstawienia) as "P", EXTRACT(YEAR FROM z.data_zwrotu) as "Z" from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
    group by zp.pracownik_id, zp.rodzaj_z_p_id,  z.data_podstawienia, z.data_zwrotu) 
    where pracownik_id = v_pracownikID and ((P = v_rok and rodzaj_z_p_id = 1) or  
    (Z = v_rok and rodzaj_z_p_id = 2));
    exception when no_data_found then v_iloscZlecen:= 0;
    end;
    
    begin select avg(suma_wyplaty_brutto) into v_srednieZarobkiBrutto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok;
    exception WHEN NO_DATA_FOUND THEN v_srednieZarobkiBrutto:= 0;
    end;
    
    begin select avg(suma_wyplaty_netto) into v_srednieZarobkiNetto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok;
    exception when NO_DATA_FOUND then v_srednieZarobkiNetto := 0;
    end;
    
    begin select sum(suma_wyplaty_brutto) into v_sumaZarobkiBrutto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok;
    exception when NO_DATA_FOUND then v_sumaZarobkiBrutto :=0;
    end;
    
    select sum(suma_wyplaty_netto) into v_sumaZarobkiNetto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok;
    
    if (v_stanowiskoPracownika != 0) then
        begin
        select count(*) into v_iloscPodstawien from 
        (select zp.pracownik_id, zp.rodzaj_z_p_id ,EXTRACT(YEAR from z.data_podstawienia) as "P", EXTRACT(YEAR FROM z.data_zwrotu) as "Z" from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
        group by zp.pracownik_id, zp.rodzaj_z_p_id,  z.data_podstawienia, z.data_zwrotu) 
        where rodzaj_z_p_id = 1 and pracownik_id = v_pracownikID and ((P = v_rok and rodzaj_z_p_id = 1) or  
        (Z = v_rok and rodzaj_z_p_id = 2));
        exception when NO_DATA_FOUND then v_iloscPodstawien :=0;
        end;
        
        begin
        select count(*) into v_iloscZwrotow from 
        (select zp.pracownik_id, zp.rodzaj_z_p_id ,EXTRACT(YEAR from z.data_podstawienia) as "P", EXTRACT(YEAR FROM z.data_zwrotu) as "Z" from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
        group by zp.pracownik_id, zp.rodzaj_z_p_id,  z.data_podstawienia, z.data_zwrotu) 
        where rodzaj_z_p_id = 2 and pracownik_id = v_pracownikID and ((P = v_rok and rodzaj_z_p_id = 1) or  
        (Z = v_rok and rodzaj_z_p_id = 2));
        exception when NO_DATA_FOUND then v_iloscZwrotow :=0;
        end;
        
    end if;
    begin
        select sum(przepracowane_godziny) into v_iloscGodzin from wyplata where s_p_pracownik_id = v_pracownikID and EXTRACT(YEAR from data) = v_rok; 
    exception WHEN NO_DATA_FOUND THEN v_iloscGodzin:= 0;
    end;

dbms_output.put_line('W roku '|| v_rok  || ' pracownik przepracowal ' || v_iloscGodzin || ' godzin. Miesiecznie zarobil srednio ' || v_srednieZarobkiBrutto || ' brutto, oraz ' || v_srednieZarobkiNetto || ' netto.');
dbms_output.put_line('W sumie w danym roku pracownik zarobil ' || v_sumaZarobkiBrutto || ' brutto, oraz ' || v_sumaZarobkiNetto || ' netto.');
if v_stanowiskoPracownika != 0 then
    dbms_output.put_line('W danym roku pracownik wykonal ' || v_iloscZlecen || ' zlecen, w tym: ' || v_iloscPodstawien || ' podstawien i ' || v_iloscZwrotow || ' zwrotow samochodow. ');  
end if;
end;

--P2 Overload To samo co P3 tylko dla danego miesiaca ktory podaje sie jako argument. 

create or replace procedure employeeReport(
    v_pracownikID int ,
    v_rok int,
    v_miesiac int
    )
is
v_iloscZlecen int;
v_iloscPodstawien int;
v_iloscZwrotow int;
v_iloscGodzin int;
v_srednieZarobkiBrutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_srednieZarobkiNetto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_sumaZarobkiBrutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_sumaZarobkiNetto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
v_stanowiskoPracownika int :=0;

begin
    select count (*) into v_stanowiskoPracownika from stanowisko_pracownika where pracownik_id = v_pracownikID and stanowisko_id = 2; --sprawdza czy pracownik zajmuje sie zleceniami
    
    begin
    select count(*) into v_iloscZlecen from 
    (select zp.pracownik_id, zp.rodzaj_z_p_id ,EXTRACT(YEAR from z.data_podstawienia) as "P", EXTRACT(YEAR FROM z.data_zwrotu) as "Z", 
    EXTRACT(MONTH from z.data_podstawienia) as "PM", EXTRACT(MONTH FROM z.data_zwrotu) as "ZM"
    from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
    group by zp.pracownik_id, zp.rodzaj_z_p_id,  z.data_podstawienia, z.data_zwrotu) 
    where pracownik_id = v_pracownikID and ((P = v_rok and rodzaj_z_p_id = 1 and PM = v_miesiac) or  
    (Z = v_rok and rodzaj_z_p_id = 2 and ZM = v_miesiac));
    exception when no_data_found then v_iloscZlecen:= 0;
    end;
    
    begin select avg(suma_wyplaty_brutto) into v_srednieZarobkiBrutto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok and extract(month from data) = v_miesiac;
    exception WHEN NO_DATA_FOUND THEN v_srednieZarobkiBrutto:= 0;
    end;
    
    begin select avg(suma_wyplaty_netto) into v_srednieZarobkiNetto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok and extract(month from data) = v_miesiac;
    exception when NO_DATA_FOUND then v_srednieZarobkiNetto := 0;
    end;
    
    begin select sum(suma_wyplaty_brutto) into v_sumaZarobkiBrutto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok and extract(month from data) = v_miesiac;
    exception when NO_DATA_FOUND then v_sumaZarobkiBrutto :=0;
    end;
    
    select sum(suma_wyplaty_netto) into v_sumaZarobkiNetto from wyplata where s_p_pracownik_id = v_pracownikID and extract(year from data) = v_rok and extract(month from data) = v_miesiac;
    
    if (v_stanowiskoPracownika != 0) then
        begin
        select count(*) into v_iloscPodstawien from 
        (select zp.pracownik_id, zp.rodzaj_z_p_id ,EXTRACT(YEAR from z.data_podstawienia) as "P", EXTRACT(YEAR FROM z.data_zwrotu) as "Z", 
        EXTRACT(MONTH from z.data_podstawienia) as "PM", EXTRACT(MONTH FROM z.data_zwrotu) as "ZM"
        from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
        group by zp.pracownik_id, zp.rodzaj_z_p_id,  z.data_podstawienia, z.data_zwrotu) 
        where rodzaj_z_p_id = 1 and pracownik_id = v_pracownikID and ((P = v_rok and rodzaj_z_p_id = 1 and PM = v_miesiac) or  
        (Z = v_rok and rodzaj_z_p_id = 2 and ZM = v_miesiac));
        exception when NO_DATA_FOUND then v_iloscPodstawien :=0;
        end;
        
        begin
        select count(*) into v_iloscZwrotow from 
        (select zp.pracownik_id, zp.rodzaj_z_p_id ,EXTRACT(YEAR from z.data_podstawienia) as "P", EXTRACT(YEAR FROM z.data_zwrotu) as "Z", 
        EXTRACT(MONTH from z.data_podstawienia) as "PM", EXTRACT(MONTH FROM z.data_zwrotu) as "ZM"
        from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id 
        group by zp.pracownik_id, zp.rodzaj_z_p_id,  z.data_podstawienia, z.data_zwrotu) 
        where rodzaj_z_p_id = 2 and pracownik_id = v_pracownikID and ((P = v_rok and rodzaj_z_p_id = 1 and PM = v_miesiac) or  
        (Z = v_rok and rodzaj_z_p_id = 2 and ZM = v_miesiac));
        exception when NO_DATA_FOUND then v_iloscZwrotow :=0;
        end;
        
    end if;
    begin
        select sum(przepracowane_godziny) into v_iloscGodzin from wyplata where s_p_pracownik_id = v_pracownikID and EXTRACT(YEAR from data) = v_rok and EXTRACT(MONTH from data) = v_miesiac; 
    exception WHEN NO_DATA_FOUND THEN v_iloscGodzin:= 0;
    end;

dbms_output.put_line('W roku '|| v_rok  || ' pracownik przepracowal ' || v_iloscGodzin || ' godzin. Miesiecznie zarobil srednio ' || v_srednieZarobkiBrutto || ' brutto, oraz ' || v_srednieZarobkiNetto || ' netto.');
dbms_output.put_line('W sumie w danym miesiacu pracownik zarobil ' || v_sumaZarobkiBrutto || ' brutto, oraz ' || v_sumaZarobkiNetto || ' netto.');
if v_stanowiskoPracownika != 0 then
    dbms_output.put_line('W danym roku pracownik wykonal ' || v_iloscZlecen || ' zlecen, w tym: ' || v_iloscPodstawien || ' podstawien i ' || v_iloscZwrotow || ' zwrotow samochodow. ');  
end if;
end;

--P3 --Wypisuje ile razy dany samochodow zostal wypozyczony (lub przez jaki czas lacznie)
create or replace procedure countCars(
    v_carID int

)
is
    v_liczbaDni int;
    v_samochodMarka varchar(100 char) := 'Blad';
    v_iloscWypozyczen int := 0;
    v_iloscDni int :=0;
begin
    select marka || ' ' ||  model as Samochod into v_samochodMarka from (select s.id, mm.marka, mm.model from samochod s left join marka_model_samochodu mm on mm.id = s.MARKA_MODEL_SAMOCHODU_ID) where id = v_carID;
    select count(*) into v_iloscWypozyczen from zlecenie where samochod_id = v_carID;
    select sum(data_zwrotu - data_podstawienia)as "L" into v_iloscDni from zlecenie where samochod_id = v_carID;
dbms_output.put_line('Samochod ' || v_samochodMarka || ' zostal wypozyczony ' || v_iloscWypozyczen || ' razy i lacznie byl wypozyczony przez ' || v_iloscDni || ' dni.');    
end;


--P4 --Wypisuje raport dotyczacy serwisow samochodu. Laczny koszt, sredni koszty serwisu ,najczesciej wybierany warsztat, samochod ktory ma najwiecej serwisow
create or replace procedure serwisRaport as
v_avgKoszt int;
v_sumKoszt int;
v_warsztatID int;
v_samochodID int;
v_warsztat varchar(100 char);
v_samochod varchar(100 char);
begin
    select avg(koszt) into v_avgKoszt from serwis;
    select sum(koszt) into v_sumKoszt from serwis;
    select warsztat_id into v_warsztatID from  (select warsztat_id, count(id) as "L" from serwis group by warsztat_id order by L desc) where ROWNUM =1 ;
    select samochod_id into v_samochodID from  (select samochod_id, count(id) as "L" from serwis group by samochod_id order by L desc) where ROWNUM =1 ;
    select nazwa into v_warsztat from warsztat where id = v_warsztatID;
    select "Samochod" into v_samochod from (select mm.marka || ' ' || mm.model as "Samochod", s.id from marka_model_samochodu mm right join samochod s on s.MARKA_MODEL_SAMOCHODU_ID = mm.id) where id = v_samochodID;
    dbms_output.put_line('Firma na serwis samochodow przeznaczyla lacznie ' || v_sumKoszt || ' zl. Srednio jeden serwis kosztowal firme '|| v_avgKoszt || ' zl. 
    Samochody byly najszczesciej serwisowane w warsztacie "' || v_warsztat || '". Najczesciej serwisowanym samochodem byl '|| v_samochod || '.');
end;

--TODO P5 Wyswietla ranking adresow w ktorych auta sa wypozyczane lub oddawane w kolejnosci zadanej jako argument procedury (true - od najwiekszej do najmniejszej, false - na odwrot)
create or replace procedure rankingAdresow(
    ascending boolean
)
is
    v_ascdesc varchar2 (4 char);
begin --podwojne laczenie z tabelami z dwoma laczeniami
    select z.id, adr.id, adr2.id from zlecenie z left join adres adr on z.adres_podstawienia_id = adr.id left join adres adr2 on z.adres_odbioru_id = adr2.id;
    select z.id, adr.id, adr2.id from zlecenie z left join adres adr on z.adres_podstawienia_id = adr.id left join adres adr2 on z.adres_odbioru_id = adr2.id; 
    
    select z.adres_podstawienia_id, z.adres_odbioru_id, adr.nazwa, adr.ulica, adr.numer, adr.miasto, adr.kod_pocztowy from 
    zlecenie z inner join adres adr on z.adres_podstawienia_id = adr.id
    
end;

--TESTY:
--P1
set serveroutput on
/
begin
wyplac_pieniadze(TO_DATE('2018/04/04', 'yyyy/mm/dd'), TO_DATE('2018/03/01', 'yyyy/mm/dd'), TO_DATE('2018/03/31', 'yyyy/mm/dd'), 1, 1, 30);
end;
/
--P2
SET SERVEROUTPUT ON
/
begin
EMPLOYEEREPORT(1,2018);
end;
/

--P3
SET SERVEROUTPUT ON
/
begin
countCars(1);
end;
/

--P4 
SET SERVEROUTPUT ON
/
begin
serwisRaport();
end;
/