source common.sh

mysql_root_password=$1

Print_Task_Heading "Disable default NodeJS Version Module"
dnf module disable nodejs -y &>>/tmp/expense.log # This will help in excluding ambiguous output
echo $?

Print_Task_Heading "Enable NodeJS module for V20"
dnf module enable nodejs:20 -y
echo $?

Print_Task_Heading "Install NodeJS"
dnf install nodejs -y
echo $?

Print_Task_Heading "Adding Application User"
useradd expense &>> /tmp/expense.log
echo $?

Print_Task_Heading "Copy Backend Service File"
cp backend.service /etc/systemd/system/backend.service
echo $?

rm -rf /app

mkdir /app
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip
cd /app
unzip /tmp/backend.zip

cd /app
npm install


systemctl daemon-reload
systemctl enable backend
systemctl start backend

dnf install mysql -y
mysql -h 172.31.46.19 -uroot -p"mysql_root_password" < /app/schema/backend.sql
