--AUTOR: Bartosz Baum, nr albumu: 34951, WSB Gda?sk grupa INiS4_2

--W1 OnInsert - Automatycznie przypisuje pracownika z najmniejsza iloscia zlecen do wprowadzonego zlecenia, chyba ze ma on juz przydzielone zlecenie o podobnej porze.
CREATE OR REPLACE TRIGGER przypiszPracownika BEFORE
    INSERT ON zlecenie_pracownika
    --REFERENCING OLD AS o NEW AS n
    FOR EACH ROW
    WHEN (
        new.pracownik_id IS NULL
    )
DECLARE 
v_pracownikID int;
v_data DATE;
v_czyWolny int :=0 ;
BEGIN
    select pracownik_id into v_pracownikID from (select pracownik_id, count(id) as "I" from  zlecenie_pracownika group by pracownik_id order by I asc) where ROWNUM = 1;
    if (new.rodzaj_z_p_id = 1) then
    select count(*) into v_czyWolny from (select zp.pracownik_id, z.data_podstawienia, zp.rodzaj_z_p_id from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id) 
    where pracownik_id = v_pracownikID and rodzaj_z_p_id = 1 and (data_podstawienia between new.data_podstawienia - 
    interval '1' hour and new.data_podstawienia + interval '1' hour);
        if (v_czyWolny = 0) then 
            select count(*) into v_czyWolny from (select zp.pracownik_id, z.data_odbioru, zp.rodzaj_z_p_id from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id) 
            where pracownik_id = v_pracownikID and rodzaj_z_p_id = 1 and (data_odbioru between new.data_podstawienia - 
            interval '1' hour and new.data_podstawienia + interval '1' hour);
        end if;
    else if (new.rodzaj_z_p_id = 2) then
        select count(*) into v_czyWolny from (select zp.pracownik_id, z.data_podstawienia, zp.rodzaj_z_p_id from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id) 
        where pracownik_id = v_pracownikID and rodzaj_z_p_id = 1 and (data_podstawienia between new.data_odbioru - 
        interval '1' hour and new.data_odbioru + interval '1' hour);
        if (v_czyWolny = 0) then 
            select count(*) into v_czyWolny from (select zp.pracownik_id, z.data_odbioru, zp.rodzaj_z_p_id from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id) 
            where pracownik_id = v_pracownikID and rodzaj_z_p_id = 1 and (data_odbioru between new.data_odbioru - 
            interval '1' hour and new.data_odbioru + interval '1' hour);
        end if;
    end if; 
    end if;
    if(v_czyWolny = 0) THEN RAISE_APPLICATION_ERROR( 'Pracownik musi zostac przydzielony do zlecenia recznie' ); 
    end if;
END;

    
--    select count(*) from (select zp.pracownik_id, z.data_podstawienia, zp.rodzaj_z_p_id from zlecenie_pracownika zp left join zlecenie z on zp.zlecenie_id = z.id) 
--    where pracownik_id = 1 and rodzaj_z_p_id = 1 and (data_podstawienia between (TO_DATE('2018/02/23 07:30:00', 'yyyy/mm/dd hh24:mi:ss'))- 
--    interval '1' hour and (TO_DATE('2018/02/23 08:30:00', 'yyyy/mm/dd hh24:mi:ss'))+ interval '1' hour)
        
        v_data :=
    :new.pracownik_id := v_pracownikID;

/



--+W2 Zrobic date ostatniej aktualizacji do jakiejs tabeli

CREATE OR REPLACE TRIGGER zLastUpdate BEFORE
    UPDATE ON zlecenie
DECLARE 
v_data DATE := SYSDATE;
BEGIN
    insert into zlecenie (ostatnia_aktualizacja) values (v_data);
END;

--+W3 OnInsert automatycznie wyplac zaliczke nowemu pracownikowi

CREATE OR REPLACE TRIGGER zaliczkaNowy AFTER insert on pracownik 
DECLARE
v_pracownikId int;
BEGIN
    select id into v_pracownikId from (select * from pracownik order by ID desc) where ROWNUM = 1;
    insert into zaliczka (data_wplaty, pracownik_id, kwota) values (SYSDATE, v_pracownikID, 50);
END;

--W4 OnUpdate dla kolumny Data zakonczenia zatrudnienia w Pracownik - w przypadku wprowadzenia automatycznie wyplac pieniadze za pozostaly okres pomniejszona o zaliczke i ustaw status na niezatrudniony
drop trigger zaliczkaNowy;
CREATE OR REPLACE TRIGGER zaliczkaNowy AFTER update of data_zakonczenia_zatrudnienia on zatrudnienie
DECLARE
v_pracownikId int;
BEGIN
    select id into v_pracownikId from (select * from pracownik order by ID desc) where ROWNUM = 1;
    update zatrudnienie set status_zatrudnienia = 0 where pracownik_id = new:pracownik_id and stanowisko_id = new:stanowisko_id;
END;


--+W5 Przydziela status stalego klienta dla klienta ktory dokonal 3 wypozyczenia
CREATE OR REPLACE TRIGGER stalyKlient after insert on zlecenie
DECLARE
v_klientId int;
v_iloscZlecen int;
BEGIN
    select klient_id into v_klientId from (select * from zlecenie  order by data_przyjecia desc) where ROWNUM = 1;
    select count (*) into v_iloscZlecen from zlecenie where klient_id = v_klientId;
    if (v_iloscZlecen >= 3) then insert into klient (staly_klient) values (1);
    end if;
END;





CREATE [OR REPLACE ] TRIGGER trigger_name  
{BEFORE | AFTER | INSTEAD OF }  
{INSERT [OR] | UPDATE [OR] | DELETE}  
[OF col_name]  
ON table_name  
[REFERENCING OLD AS o NEW AS n]  
[FOR EACH ROW]  
WHEN (condition)   
DECLARE 
   Declaration-statements 
BEGIN  
   Executable-statements 
EXCEPTION 
   Exception-handling-statements 
END; 