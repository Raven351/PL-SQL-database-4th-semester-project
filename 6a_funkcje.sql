--AUTOR: Bartosz Baum, nr albumu: 34951, WSB Gda?sk grupa INiS4_2

--6. Oprogramuj baz? danych. 
--Napisz co najmniej 5 nietrywialnych, u?ytecznych funkcji, 5 nietrywialnych, u?ytecznych procedur i 5 nietrywialnych, u?ytecznych wyzwalaczy (nie licz autoinkrementacji) 
--oraz udowodnij, ?e dzia?aj? (napisz instrukcj?, która wykorzystuje lub inicjuje implementowany obiekt). Nie zapomnij napisa? w komentarzu co robi? implementowane obiekty.

--F1 Sumuje i zwraca wartosc wszystkich dochodow ze zlecen lub dochodow z bonusow lub poniesionych kosztow pracownika o podanym id
create or replace function countEmployeeMoney(
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
end;

--F2 Oblicza ile pieniedzy pracownika zostalo przeznaczone na podatki w danym okresie
create or replace function countTaxes(
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
end;
    
--F3 Oblicza sume przychodow pracownika pochadzaca jedynie z wykonywanych zlecen
create or replace function countOrderIncome(
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
end; 


--F4 Oblicza sume wszystkich zaliczek ktore pracownik otrzymal w danym okresie
create or replace function employeeAdvance(
    v_okres_poczatek WYPLATA.OKRES_POCZATEK%TYPE,
    v_okres_koniec WYPLATA.OKRES_KONIEC%TYPE,
    v_pracownik_id WYPLATA.S_P_PRACOWNIK_ID%TYPE
)
return WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE IS
    v_sumaZaliczek WYPLATA.SUMA_WYPLATY_NETTO%TYPE := 0;
begin
     select sum(kwota) into v_sumaZaliczek from zaliczka where data_wplaty between v_okres_poczatek and v_okres_koniec and pracownik_id = v_pracownik_id ;
     return v_sumaZaliczek;
end;

--F5 Oblicza kwote netto na podstawie podanej kwoty brutto i procenta
create or replace function countNetto(
    kwota_brutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE,
    procent_podatku NUMBER)
RETURN WYPLATA.SUMA_WYPLATY_NETTO%TYPE IS
    v_kwota_netto WYPLATA.SUMA_WYPLATY_NETTO%TYPE;
BEGIN
    v_kwota_netto := (kwota_brutto - (kwota_brutto*(procent_podatku/100)));
    RETURN v_kwota_netto;
END;

--F5 Overload ...dodatkowo odejmuje dana kwote od obliczonej kwoty
create or replace function countNetto(
    kwota_brutto WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE,
    procent_podatku NUMBER,
    kwotaDoPomniejszenia WYPLATA.SUMA_WYPLATY_BRUTTO%TYPE)
RETURN WYPLATA.SUMA_WYPLATY_NETTO%TYPE IS
    v_kwota_netto WYPLATA.SUMA_WYPLATY_NETTO%TYPE;
BEGIN
    v_kwota_netto := (kwota_brutto - (kwota_brutto*(procent_podatku/100)));
    RETURN v_kwota_netto - kwotaDoPomniejszenia;
END;

--TESTY 
--F1
set serveroutput on
/
begin
    dbms_output.put_line(countEmployeeMoney(TO_DATE('2018/03/01', 'yyyy/mm/dd'), TO_DATE('2018/03/30', 'yyyy/mm/dd'), 1 , 2, true, true, true));
end;
/

--F2
set serveroutput on
/
begin
    dbms_output.put_line(countTaxes(TO_DATE('2018/03/01', 'yyyy/mm/dd'),  TO_DATE('2018/03/31', 'yyyy/mm/dd'), 1));
end;
/
select * from wyplata;

--F3
set serveroutput on
/
begin
    dbms_output.put_line(countOrderIncome(3));
end;
/

--F4
set serveroutput on
/
begin
    dbms_output.put_line(employeeAdvance(TO_DATE('2018/03/01', 'yyyy/mm/dd'),TO_DATE('2018/03/31', 'yyyy/mm/dd'), 2));
end;
/

--F5
set serveroutput on
/
begin
    dbms_output.put_line(countNetto(1000, 10));
end;
/
