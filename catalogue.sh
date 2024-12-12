#/bin/bash

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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue application"

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzing application"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Coping catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reload daemon"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue services"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue services"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Coping mongo.repo service file"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb"

mongo --host mongodb.joinaiops.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading Catalogue data into mongodb"




