BACKUP_DIR="/var/db/postgres0/backups"
DATE=$(date +"%Y%m%d%H%M%S")
BACKUP_NAME="backup_$DATE"
BACKUP_FILE="$BACKUP_DIR/$BACKUP_NAME"
MAIN_RETENTION_DAYS=7

pg_basebackup -p 9004 -U replica --wal-method=stream -D $BACKUP_FILE -T "/var/db/postgres0/u04/wip97"="/var/db/postgres0/backups/tablespaces_backups_$DATE/u04/wip97" -T "/var/db/postgres0/u03/wip97"="/var/db/postgres0/backups/tablespaces_backups_$DATE/u03/wip97"

# копируем на резервный узел
scp -r "${BACKUP_FILE}" postgres0@pg126:~/backups/
scp -r "${BACKUP_DIR}/tablespaces_backups_${DATE}" postgres0@pg126:~/backups/

# Удаляем копии, которым больше недели
find "$BACKUP_DIR" -type d -mtime +$MAIN_RETENTION_DAYS -exec rm -rf {} \;

ssh postgres0@pg126 "bash /var/db/postgres0/remove_script.sh"