#!/bin/bash
#set -euo pipefail
# trap 'echo "there is an erro in $LINED ,command is $bash_command"' ERR
USERID=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
MONGO_HOST=mongo.udaykiran.site
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER

echo "Script started executed at: $(date)"  | tee -a $LOG_FILE

if [ $USERID -ne 0 ];then
   echo "please run with root user"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2..... $r failed $n" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 is....   $g success $n" | tee -a $LOG_FILE
    fi
}

##### NodeJS ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y&>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading catalogue application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip
VALIDATE $? "unzip catalogue"

cd /app 
VALIDATE $? "Changing to app directory"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload

systemctl enable catalogue  &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"



