--AUTOR: Bartosz Baum, nr albumu: 34951, WSB Gda?sk grupa INiS4_2


create or replace package CarRentalPackage is
function countEmployeeMoney(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_stanowisko_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_includeOrders BOOLEAN,
    v_includeBonuses BOOLEAN,
    v_includeCosts BOOLEAN

)
RETURN WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
function countTaxes(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
function countOrderIncome(
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
function employeeAdvance(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
function countNetto(
    kwota_brutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE,
    procent_podatku NUMBER)
RETURN WYPLATA.SUMA_WYPLATY_NETTO%TYPE;
procedure wyplac_pieniadze(
    v_data WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_stanowisko_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_przepracowane_godziny INT
    );
procedure employeeReport(
    v_pracownikID int ,
    v_rok int
    );
procedure countCars(
    v_carID int

);
procedure serwisRaport;
function countNetto(
    kwota_brutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE,
    procent_podatku NUMBER,
    kwotaDoPomniejszenia WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE)
    RETURN WYPLATA.SUMA_WYPLATY_NETTO%TYPE;
procedure employeeReport(
    v_pracownikID int ,
    v_rok int,
    v_miesiac int
    );
end;
--------------------------------------------------------------------------------
/
create or replace package body CarRentalPackage is
function countEmployeeMoney(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_stanowisko_id WYPLATA.S_P_PRACOWNIK_ID%TYPE,
    v_includeOrders BOOLEAN,
    v_includeBonuses BOOLEAN,
    v_includeCosts BOOLEAN
)
RETURN WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE IS
    v_countedMoney WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE := 0 ;
    v_iloscZlecen WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
    v_stawka WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE;
begin
    if v_includeOrders = true then
        select count(*) into v_iloscZlecen from ( 
        select zp.pracownik_id,  zp.RODZAJ_Z_P_ID, rzp.tytul ,z.data_podstawienia, z.data_zwrotu from zlecenie_pracownika zp left join zlecenie z
        on z.id = zp.zlecenie_id left join rodzaj_z_p rzp on zp.rodzaj_z_p_id = rzp.id
        group by zp.pracownik_id, zp.rodzaj_z_p_id, rzp.tytul, z.data_podstawienia, z.data_zwrotu order by data_podstawienia asc) 
        where 
        (rodzaj_z_p_id = 1 and data_podstawienia between v_okres_poczatek and v_okres_koniec 
        or rodzaj_z_p_id = 2 and  data_zwrotu between v_okres_poczatek and v_okres_koniec) and pracownik_id = v_pracownik_id;
        select stawka into v_stawka from stanowisko_pracownika where pracownik_id = v_pracownik_id and stanowisko_id = v_stanowisko_id;
        v_countedMoney := v_countedMoney + (v_iloscZlecen * v_stawka);     
    end if; --55
    if v_includeBonuses = true then
        select sum(Wynagrodzenie) into v_stawka from (
        select zp.PRACOWNIK_ID , b.wynagrodzenie, rzp.id as "RODZAJ_ID",  z.DATA_PODSTAWIENIA, z.DATA_ZWROTU from 
        bonus b left join bonus_zlecenia bz on b.id = bz.bonus_id 
        left join zlecenie_pracownika zp on bz.ZLECENIE_PRACOWNIKA_ID = zp.ID 
        left join zlecenie z on zp.ZLECENIE_ID = z.ID
        left join rodzaj_z_p rzp on zp.RODZAJ_Z_P_ID = rzp.id
        group by zp.pracownik_id,rzp.id, b.WYNAGRODZENIE, z.DATA_PODSTAWIENIA, z.DATA_ZWROTU ) where
        (RODZAJ_ID = 1 and data_podstawienia between v_okres_poczatek and v_okres_koniec 
        or RODZAJ_ID = 2 and  data_zwrotu between v_okres_poczatek and v_okres_koniec) and pracownik_id = v_pracownik_id ;
        v_countedMoney := v_countedMoney + v_stawka;
        v_stawka:= 0;
    end if; --23
    if v_includeCosts = true then
        select sum(Wartosc) into v_stawka from (
        select kz.wartosc, zp.pracownik_id, rzp.id as "RODZAJ_ID", z.data_podstawienia, z.data_zwrotu from KOSZT_ZLECENIA kz left join ZLECENIE_PRACOWNIKA zp on kz.ZLECENIE_PRACOWNIKA_ID = zp.ID
        left join zlecenie z on zp.zlecenie_id = z.id
        left join rodzaj_z_p rzp on zp.RODZAJ_Z_P_ID = rzp.id
        group by kz.wartosc, rzp.id , zp.pracownik_id, z.data_podstawienia, z.data_zwrotu)
        where 
        (RODZAJ_ID = 1 and data_podstawienia between v_okres_poczatek and v_okres_koniec 
        or RODZAJ_ID = 2 and  data_zwrotu between v_okres_poczatek and v_okres_koniec) and pracownik_id = v_pracownik_id ;
        v_countedMoney := v_countedMoney + v_stawka;
        v_stawka:= 0;
    end if;
return v_countedMoney;
end countEmployeeMoney;
function countTaxes(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE IS
    v_sumaPodatkow WYPLATA.SUMA_WYPLATY_NETTO%TYPE := 0;
    v_temp WYPLATA.SUMA_WYPLATY_NETTO%TYPE := 1;
    v_i int := 1;
begin
--    select SUMA_WYPLATY_BRUTTO - SUMA_WYPLATY_NETTO as "Podatek" from  (select SUMA_WYPLATY_BRUTTO, SUMA_WYPLATY_NETTO, ROW_NUMBER() Over (order by id) as RowNumber  
--    from wyplata where s_p_pracownik_id = 1 and okres_poczatek between TO_DATE('2018/03/01', 'yyyy/mm/dd') and  TO_DATE('2018/03/30', 'yyyy/mm/dd')) where RowNumber = 1;
    while ( v_temp<>null or v_temp<>0) loop
--        dbms_output.put_line('Petla aktywna');
            begin
            select SUMA_WYPLATY_NETTO as "Netto" into v_temp from  (select SUMA_WYPLATY_BRUTTO, SUMA_WYPLATY_NETTO, ROW_NUMBER() Over (order by id) as RowNumber  
            from wyplata where s_p_pracownik_id = v_pracownik_id and okres_poczatek between v_okres_poczatek and  v_okres_koniec) where RowNumber = v_i;
            if (v_temp != 0) then 
                select SUMA_WYPLATY_BRUTTO - SUMA_WYPLATY_NETTO as "Podatek" into v_temp from  (select SUMA_WYPLATY_BRUTTO, SUMA_WYPLATY_NETTO, ROW_NUMBER() Over (order by id) as RowNumber  
                from wyplata where s_p_pracownik_id = v_pracownik_id and okres_poczatek between v_okres_poczatek and  v_okres_koniec) where RowNumber = v_i;
                else v_temp :=1;
            end if;
            exception WHEN NO_DATA_FOUND THEN v_temp := 0;
            end;
        v_sumaPodatkow := v_sumaPodatkow + v_temp;
        v_i := v_i + 1;
    end loop;
    return v_sumaPodatkow;
end countTaxes;
function countOrderIncome(
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE IS
    v_przychodZeZlecen WYPLATA.SUMA_WYPLATY_NETTO%TYPE := 0;
    v_stawka WYPLATA.SUMA_WYPLATY_NETTO%TYPE := 0;
begin
    begin
        select count (*) into v_przychodZeZlecen from zlecenie_pracownika where pracownik_id = v_pracownik_id group by pracownik_id ;
        select stawka into v_stawka from stanowisko_pracownika where pracownik_id = v_pracownik_id and stanowisko_id = 2;
    exception
        WHEN NO_DATA_FOUND THEN return 0;
    end;
    v_przychodZeZlecen := v_przychodZeZlecen * v_stawka;
    return v_przychodZeZlecen;
end countOrderIncome; 
function employeeAdvance(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE IS
    v_sumaZaliczek WYPLATA.SUMA_WYPLATY_NETTO%TYPE := 0;
begin
     select sum(kwota) into v_sumaZaliczek from zaliczka where data_wplaty between v_okres_poczatek and v_okres_koniec and pracownik_id = v_pracownik_id ;
     return v_sumaZaliczek;
end employeeAdvance;
function countNetto(
    kwota_brutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE,
    procent_podatku NUMBER)
RETURN WYPLATA.SUMA_WYPLATY_NETTO%TYPE IS
    v_kwota_netto WYPLATA.SUMA_WYPLATY_NETTO%TYPE;
BEGIN
    v_kwota_netto := (kwota_brutto - (kwota_brutto*(procent_podatku/100)));
    RETURN v_kwota_netto;
END countNetto;
procedure wyplac_pieniadze(
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
end wyplac_pieniadze;
procedure employeeReport(
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
end employeeReport;
procedure countCars(
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
end countCars;
procedure serwisRaport as
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
end serwisRaport;
function countNetto(
    kwota_brutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE,
    procent_podatku NUMBER,
    kwotaDoPomniejszenia WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE)
RETURN WYPLATA.SUMA_WYPLATY_NETTO%TYPE IS
    v_kwota_netto WYPLATA.SUMA_WYPLATY_NETTO%TYPE;
BEGIN
    v_kwota_netto := (kwota_brutto - (kwota_brutto*(procent_podatku/100)));
    RETURN v_kwota_netto - kwotaDoPomniejszenia;
END countNetto;
procedure employeeReport(
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
end employeeReport;
end;


--TEST F5 Overload z pakietu
set serveroutput on
/
begin
    dbms_output.put_line(CARRENTALPACKAGE.COUNTNETTO(1000, 10, 100));
end;
/


begin
CARRENTALPACKAGE.WYPLAC_PIENIADZE(TO_DATE('2018/04/04', 'yyyy/mm/dd'), TO_DATE('2018/03/01', 'yyyy/mm/dd'), TO_DATE('2018/03/31', 'yyyy/mm/dd'), 1, 1, 30);
end;
/

--TEST P4 OVERLOAD z pakietu
begin
CarRentalPackage.employeeReport(1,2018);
end;



