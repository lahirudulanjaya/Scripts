#!/bin/bash

file="./upgrade.properties"
TODAY=`date +"%d%b%Y"`


#read propertyfile
function readProperty()
{
if [ -f "$file" ]
then
  echo "$file found."
  while IFS='=' read -r key value
  do
    key=$(echo $key | tr '.' '_')
    eval ${key}=\${value}
  done < "$file"
else
  echo "$file not found."
fi
}

#get all databases and backup
function backUpDatabases()
{
mapfile databases< <(mysql -N -u${USER_MYSQL_USER} -p${USER_MYSQL_PASSWORD} -h${USER_MYSQL_HOST} -P${USER_MYSQL_PORT} -se "SHOW DATABASES")
Length=${#databases[@]}
I=1
for element in "${databases[@]}";do
    echo
    echo Database Name:  ${element}
    echo backup ${I} of ${Length} databases
    backUpDatabase ${element}
    echo
    I=$(expr $I + 1)
done
}

#backup
function backUpDatabase()
{
mkdir -p ${USER_BACKUP_PATH}/${TODAY}
echo "Backup started for database $1"

mysqldump -h ${USER_MYSQL_HOST} \
   -P ${USER_MYSQL_PORT} \
   -u ${USER_MYSQL_USER} \
   -p${USER_MYSQL_PASSWORD} \
   "$1" | gzip > ${USER_BACKUP_PATH}/${TODAY}/"$1"-${TODAY}.sql.gz

if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
  exit 1
fi
}

readProperty
backUpDatabases

