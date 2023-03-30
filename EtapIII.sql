-- DROP FUNCTION gokarty.random_string(integer)
CREATE OR REPLACE FUNCTION gokarty.random_string(length integer) RETURNS varchar AS
$$
DECLARE
    chars  varchar[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
    result varchar   := '';
    i      integer   := 0;
BEGIN
    IF length < 0 THEN
        RAISE EXCEPTION 'Given length cannot be less than 0';
    END IF;
    FOR i IN 1..length
        LOOP
            result := result || chars[1 + RANDOM() * (ARRAY_LENGTH(chars, 1) - 1)];
        END LOOP;
    RETURN (SELECT crypt(result, gen_salt('md5')));
END;
$$ LANGUAGE plpgsql;
-- select gokarty.random_string(15)
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_app_role()
    RETURNS BOOLEAN AS
$GENERATOR$

BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli APP_ROLE';
    INSERT INTO gokarty.app_role (name)
    VALUES ('ROLE_USER'),
           ('ROLE_EMPLOYEE'),
           ('ROLE_ADMIN');
    -- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_app_user()
    RETURNS BOOLEAN AS
$GENERATOR$
DECLARE
    -- Zmienne modelu danych
    imie     CHARACTER VARYING(40);
    nazwisko CHARACTER VARYING(40);
    -- Zmienne pomocnicze
    i        int;
BEGIN

    RAISE NOTICE 'Generuję dane dla tabeli APP_USER';
    FOR i IN 1..5000
        LOOP

            SELECT imie.imie
            INTO STRICT imie
            FROM slownik.imie
            WHERE imie.id_imienia =
                  (SELECT TRUNC(1 + RANDOM() * (SELECT MAX(imie.id_imienia) FROM slownik.imie))::INTEGER);

            SELECT nazwisko.nazwisko
            INTO STRICT nazwisko
            FROM slownik.nazwisko
            WHERE nazwisko.id_nazwiska =
                  (SELECT TRUNC(1 + RANDOM() * (SELECT MAX(nazwisko.id_nazwiska) FROM slownik.nazwisko))::INTEGER);

            BEGIN
                INSERT INTO gokarty.app_user (id_app_user, name, phone, email, password, locked, enabled)
                VALUES (i,
                        imie || ' ' || nazwisko,
                        (SELECT '+48' || RPAD(TRUNC(RANDOM() * 10 ^ 9)::BIGINT::VARCHAR, 9, '0')),
                        LOWER(imie) || TRUNC(RANDOM() * 1000)::VARCHAR || '@' ||
                        (CASE TRUNC(RANDOM() * 10)::INTEGER
                             WHEN 0 THEN 'gmail.com'
                             WHEN 1 THEN 'onet.pl'
                             WHEN 2 THEN 'wp.pl'
                             WHEN 3 THEN 'interia.pl'
                             WHEN 4 THEN 'hotmail.com'
                             WHEN 5 THEN 'tarnow.pl'
                             WHEN 6 THEN 'apple.com'
                             WHEN 7 THEN 'samsung.com'
                             WHEN 8 THEN 'microsoft.com'
                             WHEN 9 THEN 'twitter.com'
                            END),
                        (SELECT gokarty.random_string(15)),
                        (SELECT (ARRAY [TRUE, FALSE])[TRUNC(1 + RANDOM() * 2)]),
                        (SELECT TRUE));
            EXCEPTION
                WHEN unique_violation THEN
                -- Nic nie rób. Spróbuj dodać kolejny rekord w pętli.
            END;

        END LOOP;
-- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_app_user_role()
    RETURNS BOOLEAN AS
$GENERATOR$
DECLARE
    data  bigint[];
    i     int;
    losuj integer;
    l_pracownikow integer := 0;
BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli APP_USER_ROLE';
    SELECT ARRAY(SELECT id_app_user FROM gokarty.app_user) INTO data;
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[1], 3);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[2], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[3], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[4], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[5], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[6], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[7], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[8], 2);
    INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role") VALUES (data[9], 2);
    FOR i IN 10..5000
        LOOP
            SELECT (1 + RANDOM() * 2)::int INTO losuj;
            INSERT INTO gokarty.app_user_role(id_app_user, "id_app_role")
            VALUES ((data[i]), 1);
        END LOOP;
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_email_confirmation_token()
    RETURNS BOOLEAN AS
$GENERATOR$
DECLARE
    -- Zmienne pomocnicze
    i      int;
    losowa timestamp;
BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli EMAIL_CONFIRMATION_TOKEN';
    FOR i IN 1..5000
        LOOP
            losowa := '2010-06-22 19:10:25'::timestamp - TRUNC(RANDOM() * (365 * 1 + 1)) * '1 day'::INTERVAL - '1 day'::INTERVAL;
            INSERT INTO gokarty.email_confirmation_token (id_email_confirmation_token, token, created_at, expires_at,
                                                          confirmed_at, id_app_user)
            VALUES (i,
                    (SELECT gen_random_uuid()::VARCHAR),
                    (SELECT losowa),
                    (SELECT losowa + INTERVAL '1 day'),
                    ((SELECT losowa + INTERVAL '15 minutes')),
                    i);
        END LOOP;
-- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_invoice()
    RETURNS BOOLEAN AS
$GENERATOR$
DECLARE
    data bigint[];
    i    int;
BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli INVOICE';
    SELECT ARRAY(SELECT id_reservation FROM gokarty.reservation) INTO data;
    FOR i IN 1..5000
        LOOP
            INSERT INTO gokarty.invoice (id_reservation)
            VALUES (data[i]);
        END LOOP;
-- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_kart()
    RETURNS BOOLEAN AS
$GENERATOR$

BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli KART';
    INSERT INTO gokarty.kart (name, difficulty_level)
    VALUES ('Lightning McQueen', 'Hard'),
           ('Britney Steers', 'Easy'),
           ('Captain Amerikart', 'Easy'),
           ('Steervester Stallone', 'Medium'),
           ('Karty Perry', 'Medium'),
           ('Naskart', 'Hard'),
           ('Taylor Drift', 'Medium');
-- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_reservation()
    RETURNS BOOLEAN AS
$GENERATOR$
DECLARE
    -- Zmienne pomocnicze
    i                 int;
    start_timestamp   TIMESTAMP;
    end_timestamp     TIMESTAMP;
    end_timestamp2    TIMESTAMP;
    random_timestamp  TIMESTAMP;
    random_timestamp2 TIMESTAMP;
    data              bigint[];
    random_value      int;
    money_value       numeric;
    minInterval       interval;

BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli RESERVATION';
    minInterval = '30 minutes';
    start_timestamp = '2010-06-22 19:10:25'::timestamp;
    end_timestamp = '2010-06-22 19:10:25'::timestamp - INTERVAL '10 day' - INTERVAL '15 minutes';
    end_timestamp2 = '2010-06-22 19:10:25'::timestamp - INTERVAL '10 day' + INTERVAL '15 minutes';
    random_timestamp = start_timestamp + (minInterval + (end_timestamp - start_timestamp));
    random_timestamp2 = start_timestamp + (minInterval + (end_timestamp2 - start_timestamp));
    SELECT ARRAY(SELECT id_app_user FROM gokarty.app_user) INTO data;

    FOR i IN 1..5000
        LOOP
            SELECT (100 + RANDOM() * 450)::numeric INTO random_value;
            money_value := random_value::numeric;
            IF random_timestamp2 + minInterval >= CURRENT_TIMESTAMP
            THEN
                EXIT;
            ELSE
                INSERT INTO gokarty.reservation
                VALUES (i,
                        TSRANGE(random_timestamp + minInterval, random_timestamp2 + minInterval, '[]'),
                        (SELECT (1 + RANDOM() * 3)::int),
                        data[i],
                        (SELECT (1 + RANDOM() * 6)::int),
                        money_value);
                minInterval := minInterval + INTERVAL '31 minutes';
            END IF;
        END LOOP;
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_reservation_kart()
    RETURNS BOOLEAN AS
$GENERATOR$
DECLARE
    -- Zmienne pomocnicze
    i           int;
    kart        bigint[];
    periodRange tsrange[];
    track       bigint[];
    appUser     bigint[];
BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli RESERVATION KART';
    SELECT ARRAY(SELECT id_kart FROM gokarty.kart) INTO kart;
    SELECT ARRAY(SELECT period FROM gokarty.reservation) INTO periodRange;
    SELECT ARRAY(SELECT id_track FROM gokarty.reservation) INTO track;
    SELECT ARRAY(SELECT id_app_user FROM gokarty.reservation) INTO appUser;
    FOR i IN 1..5000
        LOOP
            INSERT INTO gokarty.reservation_kart (id_kart, period, id_track, id_app_user)
            VALUES ((SELECT (1 + RANDOM() * 6)::int),
                    periodRange[i],
                    track[i],
                    appUser[i]);
        END LOOP;
-- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generate_track()
    RETURNS BOOLEAN AS
$GENERATOR$

BEGIN
    RAISE NOTICE 'Generuję dane dla tabeli TRACK';
    INSERT INTO gokarty.track (length)
    VALUES (1000),
           (1250),
           (950),
           (1500);
-- 	Koniec funkcji
    RETURN TRUE;
END;
$GENERATOR$
    LANGUAGE 'plpgsql';
-- -----------------------------------------------------------------
CREATE OR REPLACE FUNCTION gokarty.generuj_dane()
    RETURNS BOOLEAN AS
$GENERATOR$
BEGIN
    -- Usunięcie istniejących danych z tabel
    DELETE FROM gokarty.email_confirmation_token;
    DELETE FROM gokarty.reservation_kart;
    DELETE FROM gokarty.invoice;
    DELETE FROM gokarty.reservation;
    DELETE FROM gokarty.app_user_role;
    DELETE FROM gokarty.app_role;
    DELETE FROM gokarty.app_user;
    DELETE FROM gokarty.kart;
    DELETE FROM gokarty.track;

    -- Ustawienie wartości sekwencji
    ALTER SEQUENCE gokarty."app_role_id_app_role_seq" RESTART WITH 1;
    ALTER SEQUENCE gokarty.app_user_id_app_user_seq RESTART WITH 1;
    ALTER SEQUENCE gokarty.email_confirmation_token_id_email_confirmation_token_seq RESTART WITH 1;
    ALTER SEQUENCE gokarty.invoice_id_invoice_seq RESTART WITH 1;
    ALTER SEQUENCE gokarty.kart_id_kart_seq RESTART WITH 1;
    ALTER SEQUENCE gokarty.track_id_track_seq RESTART WITH 1;

-- 	Wywolanie funkcji generujacych
    PERFORM * FROM gokarty.generate_app_role();
    PERFORM * FROM gokarty.generate_app_user();
    PERFORM * FROM gokarty.generate_app_user_role();
    PERFORM * FROM gokarty.generate_email_confirmation_token();
    PERFORM * FROM gokarty.generate_kart();
    PERFORM * FROM gokarty.generate_track();
    PERFORM * FROM gokarty.generate_reservation();
    PERFORM * FROM gokarty.generate_reservation_kart();
    PERFORM * FROM gokarty.generate_invoice();

-- 	Koniec funkcji
    RETURN TRUE;
END;

$GENERATOR$
    LANGUAGE 'plpgsql';

SELECT *
FROM gokarty.generuj_dane();

-- Zapytania

DROP VIEW IF EXISTS gokarty.query_A1;
DROP VIEW IF EXISTS gokarty.query_A2;
DROP VIEW IF EXISTS gokarty.query_A3;
DROP VIEW IF EXISTS gokarty.query_A4;
DROP VIEW IF EXISTS gokarty.query_A5;
DROP VIEW IF EXISTS gokarty.query_B1;
DROP VIEW IF EXISTS gokarty.query_B2;
DROP VIEW IF EXISTS gokarty.query_B3;
DROP VIEW IF EXISTS gokarty.query_B4;
DROP VIEW IF EXISTS gokarty.query_B5;
DROP VIEW IF EXISTS gokarty.query_B6;
DROP VIEW IF EXISTS gokarty.query_B7;
DROP VIEW IF EXISTS gokarty.query_B8;
DROP VIEW IF EXISTS gokarty.query_B9;
DROP VIEW IF EXISTS gokarty.query_B10;



CREATE VIEW gokarty.query_A1 AS
	SELECT name 
	FROM gokarty.app_user;
COMMENT ON VIEW gokarty.query_A1 IS 'Wyświetl imiona wszystkich użytkowniów';

CREATE VIEW gokarty.query_A2 AS 
	SELECT name
	FROM gokarty.app_role;
COMMENT ON VIEW gokarty.query_A2 IS 'Wyświetl wszystkie dostępne role';

CREATE VIEW gokarty.query_A3 AS
	SELECT token, created_at, expires_at
	FROM gokarty.email_confirmation_token;
COMMENT ON VIEW gokarty.query_A3 IS 'Wyswietl dane dotyczące tokenu';

CREATE VIEW gokarty.query_A4 AS 
	SELECT name, difficulty_level
	FROM gokarty.kart;
COMMENT ON VIEW gokarty.query_A4 IS 'Wyswietl informacje na temat torów gokartowych';

CREATE VIEW gokarty.query_A5 AS
	SELECT length
	FROM gokarty.track;
COMMENT ON VIEW gokarty.query_A5 IS 'Pokaż informacje na temat długości danych torów gokartowych';

CREATE VIEW gokarty.query_B1 AS
	SELECT name 
	FROM gokarty.app_user
	INNER JOIN gokarty.app_user_role ON app_user_role.id_app_user = app_user.id_app_user
	WHERE id_app_role = 2
	ORDER BY 1 asc;
COMMENT ON VIEW gokarty.query_B1 IS 'Wyświetl imiona osób, którzy należą do grupy pracowników. Posortuj rosnąco wedlug Imion';
	
CREATE VIEW gokarty.query_B2 AS
	SELECT name, phone, email, created_at, expires_at 
	FROM gokarty.app_user
	INNER JOIN gokarty.email_confirmation_token ON email_confirmation_token.id_app_user = app_user.id_app_user
	WHERE locked = true;
COMMENT ON VIEW gokarty.query_B2 IS 'Wyświetl imie, nazwisko, telefon osób, których konto jest zablokowane wraz z informacjami o emailu i o tym kiedy został utworzony i kiedy wygasa ich token ';
	
CREATE VIEW gokarty.query_B3 AS 
	SELECT u.name, k.name AS "Kart", k.difficulty_level, r.cost
	FROM gokarty.app_user u
	INNER JOIN gokarty.reservation r using (id_app_user)
	INNER JOIN gokarty.reservation_kart using (id_app_user)
	INNER JOIN gokarty.kart k using (id_kart)
	GROUP BY 3,1,2,4
	ORDER BY 4 desc;
COMMENT ON VIEW gokarty.query_B3 is 'Wysiwetl imie i nazwisko osoby rezerwujacej tor gokartowy wraz z nazwa gokarta, poziomem trudnosci i ceny za rezerwacje gokartu.
Pogrupowane wg. poziomu trudnosci, posortowane wg ceny malejaco';
	
CREATE VIEW gokarty.query_B4 AS
	SELECT DISTINCT u.name,r.cost,t.length
	FROM gokarty.reservation r
	INNER JOIN gokarty.app_user u ON u.id_app_user = r.id_app_user
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_track = r.id_track
	INNER JOIN gokarty.track t ON t.id_track = r.id_track
	INNER JOIN gokarty.kart k using (id_kart)
	WHERE r.number_of_people >= 6 and k.difficulty_level ='Medium'
	ORDER BY 2 DESC;
COMMENT ON VIEW gokarty.query_B4 IS 'Wyswietl dane o klientach, którzy zarezerwowali tor dla sześciu lub więcej osób, długość toru i koszt zapłaty. Posortowane wg. ceny.';
	
CREATE VIEW gokarty.query_B5 AS
	SELECT COUNT(k.id_kart) as "Gokarty"
	FROM gokarty.kart k
	INNER JOIN gokarty.reservation_kart rk ON rk.id_kart = k.id_kart
	INNER JOIN gokarty.reservation r ON r.id_app_user = rk.id_app_user
	INNER JOIN gokarty.track t ON t.id_track = r.id_track
	WHERE t.length = 1000;	
COMMENT ON VIEW gokarty.query_B5 IS 'Policz ile jest gokartów zarezerwowanych na tory o długości 1000 metrów';
	
CREATE VIEW gokarty.query_B6 AS 
	SELECT u.email, u.phone
	FROM gokarty.app_user u
	INNER JOIN gokarty.reservation r ON r.id_app_user = u.id_app_user
	INNER JOIN gokarty.reservation_kart rk ON rk.id_app_user = r.id_app_user
	INNER JOIN gokarty.kart k ON k.id_kart = rk.id_kart
	WHERE k.name ='Lightning McQueen';
COMMENT ON VIEW gokarty.query_B6 IS 'Wyświetl email i numer telefonu tych osób, które zarezerwowały gokart Lightning McQueen';
	
CREATE VIEW gokarty.query_B7 AS 
	SELECT e.token, r.cost
	FROM gokarty.email_confirmation_token e
	INNER JOIN gokarty.app_user u ON u.id_app_user = e.id_app_user
	INNER JOIN gokarty.reservation r ON r.id_app_user = u.id_app_user
	WHERE u.locked = false
	ORDER BY 2 desc;
COMMENT ON VIEW gokarty.query_B7 IS 'Wyświetl tokeny emailowe osób, których konto nie jest zablokowane i cene za zarezerwowanie toru. Posortuj wg. cenu malejąco.';

CREATE VIEW gokarty.query_B8 AS 
	SELECT u.name, r.period, k.name AS "Kart"
	FROM gokarty.app_user u
	INNER JOIN gokarty.reservation r ON r.id_app_user = u.id_app_user
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_app_user = r.id_app_user	
	INNER JOIN gokarty.kart k ON k.id_kart = reservation_kart.id_kart
	WHERE k.difficulty_level ='Easy'
	ORDER BY 1 asc;
COMMENT ON VIEW gokarty.query_B8 IS 'Wyswietl imie, nazwisko, zakres czasowy i gokarty tych klientów, którzy zarezerwowali najłatwiejsze trasy. Posortowac wg. Imion rosnąco';
	
CREATE VIEW gokarty.query_B9 AS 
	SELECT DISTINCT k.name
	FROM gokarty.kart k
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_kart = k.id_kart
	INNER JOIN gokarty.reservation r ON r.id_track = reservation_kart.id_track
	INNER JOIN gokarty.track t ON t.id_track = r.id_track
	WHERE r.cost <= '250' and t.length <= 1250;
COMMENT ON VIEW gokarty.query_B9 IS 'Wyświetl gokarty, za które rezerwacja kosztowała do 250 zł i długość toru była do 1250 metrów';
	
CREATE VIEW gokarty.query_B10 AS 
	SELECT COUNT(u.id_app_user) AS "Użytkownicy"
	FROM gokarty.app_user u
	INNER JOIN gokarty.app_user_role r ON r.id_app_user = u.id_app_user
	WHERE r.id_app_role = 1;
COMMENT ON VIEW gokarty.query_B10 IS 'Policz ilu mamy użytkowników w bazie';


-- Widoki

CREATE MATERIALIZED VIEW gokarty.average_cost_for_x_people_Mview AS
	SELECT number_of_people, ROUND(AVG(cost),2) AS sredni_koszt 
	FROM gokarty.reservation
	GROUP BY 1
	ORDER BY 2 DESC;
COMMENT ON MATERIALIZED VIEW gokarty.average_cost_for_x_people_Mview IS 'M View pokazujacy sredni koszt dla grup 1,2,3..6 osobowych';

-- select * from gokarty.average_cost_for_x_people_Mview;

CREATE MATERIALIZED VIEW gokarty.users_token_Mview AS
	SELECT token, a.name, a.email
	FROM gokarty.email_confirmation_token
	INNER JOIN gokarty.app_user a ON a.id_app_user = email_confirmation_token.id_app_user
	ORDER BY 2 ASC;
COMMENT ON MATERIALIZED VIEW gokarty.users_token_Mview IS 'token dla imie i nazwisko + email';

-- select * from gokarty.users_token_Mview;


CREATE MATERIALIZED VIEW gokarty.hard_diff_gokart_res_Mview AS
	SELECT u.email
	FROM gokarty.app_user u
	INNER JOIN gokarty.reservation ON reservation.id_app_user = u.id_app_user
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_app_user = reservation.id_app_user
	INNER JOIN gokarty.kart k ON k.id_kart = reservation_kart.id_kart
	WHERE k.difficulty_level ='Hard'
	ORDER BY 1 ASC;
COMMENT ON MATERIALIZED VIEW gokarty.hard_diff_gokart_res_Mview IS 'Emaile klientów, którzy zamówili gokarty najwyższego poziomu trudności';

-- select * from gokarty.hard_diff_gokart_res_Mview;


CREATE MATERIALIZED VIEW gokarty.res_archive_Mview AS
	SELECT r.id_reservation, r.period, r.id_track, u.name AS imie_i_nazwisko, r.number_of_people, r.cost
	FROM gokarty.reservation r
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_app_user = r.id_app_user
	INNER JOIN gokarty.app_user u ON u.id_app_user = r.id_app_user
	ORDER BY 2 ASC;
COMMENT ON MATERIALIZED VIEW gokarty.res_archive_Mview IS 'M view rezerwacji danego klienta';

-- select * from gokarty.res_archive_mview;

CREATE MATERIALIZED VIEW gokarty.user_role_Mview AS
	SELECT u.name AS Imie_i_Nazwisko, r.name as Rola   
	FROM gokarty.app_user u
	INNER JOIN gokarty.app_user_role ON app_user_role.id_app_user = u.id_app_user
	INNER JOIN gokarty.app_role r ON r.id_app_role = app_user_role.id_app_role
	ORDER BY 1 ASC;
COMMENT ON MATERIALIZED VIEW gokarty.user_role_Mview IS 'lista osób wraz z ich rolą';

-- select * from gokarty.user_role_Mview;

CREATE VIEW gokarty.count_user_role_view AS
	SELECT COUNT(u.name) AS liczba_osob, r.name AS rola
	FROM gokarty.app_role r
	INNER JOIN gokarty.app_user_role ON app_user_role.id_app_role = r.id_app_role
	INNER JOIN gokarty.app_user u ON u.id_app_user = app_user_role.id_app_user
	GROUP BY 2;
COMMENT ON VIEW gokarty.count_user_role_view IS 'lista wyliczajaca ile osób ma daną role';
	
-- select * from gokarty.count_user_role_view;

CREATE VIEW gokarty.reservation_with_kartName_view AS
	SELECT r.id_reservation, r.id_track, r.id_app_user, k.name
	FROM gokarty.reservation r
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_app_user = r.id_app_user
	INNER JOIN gokarty.kart k ON k.id_kart = reservation_kart.id_kart
	ORDER BY 1 ASC;
COMMENT ON VIEW gokarty.reservation_with_kartName_view IS 'Dane o id rezerwacji, id tracku, id usera i gokarty jaki zostal zarezerwowany';

-- select * from gokarty.reservation_with_kartName_view

CREATE VIEW gokarty.track_and_gokart_view AS
	SELECT t.length, k.name, r.id_reservation
	FROM gokarty.track t
	INNER JOIN gokarty.reservation r ON r.id_track = t.id_track
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_app_user = r.id_app_user
	INNER JOIN gokarty.kart k ON k.id_kart = reservation_kart.id_kart
	ORDER BY 1 ASC;
COMMENT ON VIEW gokarty.track_and_gokart_view IS 'info o dlugosci toru dla danego zarezerwowanego gokartu';

-- select * from gokarty.track_and_gokart_view;

CREATE VIEW gokarty.locked_users_view AS
	SELECT u.phone, u.name, u.email
	FROM gokarty.app_user u
	INNER JOIN gokarty.app_user_role ON app_user_role.id_app_user = u.id_app_user
	INNER JOIN gokarty.app_role ar ON ar.id_app_role = app_user_role.id_app_role
	WHERE u.locked = TRUE AND ar.name ='ROLE_USER'
	ORDER BY 2 ASC;
COMMENT ON VIEW gokarty.locked_users_view IS 'Lista uzytkownikow, którzych konto jest zablokowane(stan locked)';

-- select * from gokarty.locked_users_view;

CREATE VIEW gokarty.hardest_track_n_gokart_reservations_view AS
	SELECT u.name, u.email
	FROM gokarty.app_user u
	INNER JOIN gokarty.reservation ON reservation.id_app_user = u.id_app_user
	INNER JOIN gokarty.track t ON t.id_track = reservation.id_track
	INNER JOIN gokarty.reservation_kart ON reservation_kart.id_app_user = reservation.id_app_user
	INNER JOIN gokarty.kart k ON k.id_kart = reservation_kart.id_kart
	INNER JOIN gokarty.app_user_role ON app_user_role.id_app_user = u.id_app_user
	INNER JOIN gokarty.app_role ar ON ar.id_app_role = app_user_role.id_app_role
	WHERE t.length = 1500 AND k.difficulty_level = 'Hard' AND ar.name = 'ROLE_USER'
	ORDER BY 1 ASC;
COMMENT ON VIEW gokarty.hardest_track_n_gokart_reservations_view IS 'Lista uzytkownikow, którzy zarezerwowali najdluzszy tor gokartowy z gokartem o najtrudniejszym poziomie trudnosci';

-- select * from gokarty.hardest_track_n_gokart_reservations_view


-- Wyzwalacze z funkcjami

CREATE OR REPLACE FUNCTION gokarty.NineToFiveCheck_fun() RETURNS TRIGGER AS $$
	BEGIN
		IF (EXTRACT(HOUR FROM lower(NEW.period)) < 9 OR EXTRACT(HOUR FROM upper(NEW.period)) >= 17)
		THEN
			RAISE EXCEPTION 'Cannot insert row outside of business hours (9am to 5pm)';
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql' VOLATILE;


DROP TRIGGER IF EXISTS NineToFiveCheck_trigger ON gokarty.reservation;

CREATE TRIGGER NineToFiveCheck_trigger
	BEFORE INSERT OR UPDATE ON gokarty.reservation
	FOR EACH ROW
	EXECUTE FUNCTION gokarty.NineToFiveCheck_fun();


-- insert into gokarty.reservation values(777777,'[2010-06-10 19:50:00, 2010-06-11 20:20:00]',1,1,2,450);



CREATE OR REPLACE FUNCTION gokarty.blockAfterFourThirty_fun() RETURNS TRIGGER AS $$
	DECLARE
	prev_end_time TIMESTAMP;
	BEGIN
		SELECT upper(period) INTO prev_end_time
		FROM gokarty.reservation
		WHERE date_trunc('day', upper(period)) < date_trunc('day', upper(NEW.period))
		ORDER BY upper(period) DESC
		LIMIT 1;

		IF  prev_end_time::time >= '16:30:00'::time
		THEN
    		RAISE EXCEPTION 'Cannot insert reservation after 4:30pm.';
    	END IF;

    RETURN NEW;	
	END;
$$ LANGUAGE 'plpgsql' VOLATILE;

DROP TRIGGER IF EXISTS blockAfterFourThirty_trigger ON gokarty.reservation;

CREATE TRIGGER blockAfterFourThirty_trigger
	BEFORE INSERT ON gokarty.reservation
	FOR EACH ROW
	EXECUTE FUNCTION gokarty.blockAfterFourThirty_fun();
	
	
-- insert into gokarty.reservation values(777777,'[2010-09-28 16:00:00, 2010-09-28 16:30:00]',1,1,2,450); insert 0 1

-- insert into gokarty.reservation values(7777778,'[2010-09-28 16:31:00, 2010-09-28 16:55:00]',1,1,2,450);

-- select id_reservation, period from gokarty.reservation order by 1 desc

-- delete from gokarty.reservation where id_reservation = 7777778
