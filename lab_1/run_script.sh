schema_name="$1"
table_name="$2"


psql -h pg -d studs -c 'DROP PROCEDURE IF EXISTS get_data;'
psql -h pg -d studs -f ~/script.sql 2>&1 | sed 's|.*NOTICE:  ||g'
psql -h pg -d studs -c "CALL get_data('$schema_name', '$table_name');"