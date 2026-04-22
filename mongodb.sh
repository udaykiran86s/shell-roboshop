#!/bin/bash

USERID=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
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

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "ADDING MONGO REPO"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "ENABLED MONGODB"

systemctl start mongod  
VALIDATE $? "MONGODB STARTING"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "ALLOWING REMOTE CONNECTIONS TO MONGODB"

systemctl restart mongo 
VALIDATE $2 "MONGO RESTART"