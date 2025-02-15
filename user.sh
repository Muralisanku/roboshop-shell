#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
    }   

if [ $ID -ne 0 ]
    then    
        echo -e "$R ERROR:: Please run this script with root access $N"
        exit 1
    else
        echo "You are root user"
    fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Diabling current NodJS" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling NodeJS:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else
    echo -e "roboshop user already exsist $Y SKIPPING $N"
fi

mkdir -p /app 

VALIDATE $? "creating /app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzing user"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reloading daemon"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabling services"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting the services"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Coping mongo.repo service file"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb"

mongo --host mongodb.joinaiops.store </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into mongodb"

