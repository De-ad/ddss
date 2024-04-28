MAIN_RETENTION_DAYS=30
BACKUP_DIR="/var/db/postgres0/backups"

find "$BACKUP_DIR" -type d -mtime +$MAIN_RETENTION_DAYS -exec rm -rf {} \;