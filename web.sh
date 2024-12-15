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


dnf install nginx -y &>> $LOGFILE

VALIDATE $? "Installig nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Enabling nginx services"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "starting nginx services"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "Removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "Downloading new website"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "moving to html directory"

unzip -o /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unziping website"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copying conf file"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restarting services"

