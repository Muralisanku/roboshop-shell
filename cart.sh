#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script executed at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .... $R FAILED $N"
        exit 1
    else
        echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: Please run the script with root user $N"
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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart application"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzing application"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Coping cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reload daemon"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling cart services"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting the services"






