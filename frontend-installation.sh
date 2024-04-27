#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "scripting started executing at: $TIMESTAMP"

VALIDATE(){     #function is checking if the installation is SUCCESS or FAILURE.
if [ $1 -ne 0 ]
then 
    echo -e "$2....$R FAILURE $N"
    exit 1
else
    echo -e "$2....$G SUCCESS $N"
fi

}

if [ $USERID -ne 0 ] #checking if the USERID is 0 or not, if 0 it is a SUPER-USER, will have access for installation and exit status is 0
then
    echo "please run this script with root access."
    exit 1 #manually exit if there is a error.
else
    echo "You are a Super User"
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/expense-shell-new/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf file"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting Nginx"






