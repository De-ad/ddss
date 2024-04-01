CREATE PROCEDURE get_data(schema_name TEXT, table_name TEXT) LANGUAGE plpgsql AS $$
DECLARE
    t_name TEXT := table_name;
    s_name TEXT := schema_name;
    no_header TEXT := 'No.';
    no_delimeter TEXT := '---';
    name_header TEXT := 'Имя столбца';
    name_delimeter TEXT := '-----------';
    attr_header TEXT := 'Атрибуты';
    attr_delimeter TEXT := '------------------------------------------------------';
    prev_attr TEXT := '';
    pointer CURSOR FOR (
        SELECT
            patt.attnum num,
            patt.attname master_att, 
            pt.typname, 
            pcstr.contype, 
            pcstr.confrelid, 
            patt2.attname slave_att, 
            pclass2.relname 
        FROM pg_class pclass 
        JOIN pg_attribute patt ON pclass.oid = patt.attrelid 
        JOIN pg_type pt ON pt.oid = patt.atttypid 
        JOIN pg_namespace pn ON pclass.relnamespace = pn.oid 
        LEFT JOIN pg_constraint pcstr ON patt.attrelid = pcstr.conrelid AND patt.attnum = ANY(pcstr.conkey) 
        LEFT JOIN pg_attribute patt2 ON pcstr.confrelid = patt2.attrelid AND pcstr.confkey[1] = patt2.attnum 
        LEFT JOIN pg_class pclass2 ON pclass2.oid = patt2.attrelid
        where pclass.relname = t_name and pn.nspname = s_name and patt.attnum > 0
    );

BEGIN
    RAISE NOTICE 'Схема: %', s_name;
    RAISE NOTICE 'Таблица: %', t_name;
    RAISE NOTICE '';
    RAISE NOTICE '%  %  %', no_header, name_header, attr_header;
    RAISE NOTICE '%  %  %', no_delimeter, name_delimeter, attr_delimeter;

    FOR c IN pointer
    LOOP
        IF prev_attr <> c.master_att THEN
            IF prev_attr <> '' THEN
                RAISE NOTICE ' ';
            END IF;
            RAISE NOTICE '%  %  Type: %', RPAD(c.num::TEXT, 3, ' '), RPAD(c.master_att, 11, ' '), c.typname;
            IF c.contype = 'f' THEN
                RAISE NOTICE '% % Constr: "%" References %(%)', RPAD('', 4, ' '),  RPAD('', 13, ' '), c.master_att, c.relname, c.slave_att;
            END IF;
        ELSE
            IF c.contype = 'f' THEN
                RAISE NOTICE '% % Constr: "%" References %(%)', RPAD('', 4, ' '),  RPAD('', 13, ' '), c.master_att, c.relname, c.slave_att;
            END IF;
        END IF;
        prev_attr = c.master_att;
    END LOOP;
    RAISE NOTICE '';

END;
$$;