psql -h pg -d studs -c 'DROP PROCEDURE IF EXISTS get_data;'
psql -h pg -d studs -f ~/script.sql 2>&1 | sed 's|.*NOTICE:  ||g'