
#!/bin/bash
set -euo pipefail

trap 'echo "Error at line $LINENO: $BASH_COMMAND"' ERR

USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

echo "Script started at: $(date)" | tee -a $LOG_FILE

if [ "$USERID" -ne 0 ]; then
   echo "Please run as root"
   exit 1
fi

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$LOG_FILE

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod &>>$LOG_FILE

echo "MongoDB setup completed successfully" | tee -a $LOG_FILE