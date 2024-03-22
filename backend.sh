source common.sh

mysql_root_password=$1

# If password is not provided then we will exit
if [ -z "${mysql_root_password}" ]; then
  echo Input password is missing
  exit 1
fi

Print_Task_Heading "Disable default NodeJS Version Module"
dnf module disable nodejs -y &>>$LOG # This will help in excluding ambiguous output
Check_Status $?

Print_Task_Heading "Enable NodeJS module for V20"
dnf module enable nodejs:20 -y &>>$LOG
Check_Status $?

Print_Task_Heading "Install NodeJS"
dnf install nodejs -y &>>$LOG
Check_Status $?

Print_Task_Heading "Adding Application User"
id expense &>> LOG
if [ $? -ne 0 ]; then
  useradd expense &>> $LOG
fi
Check_Status $?

Print_Task_Heading "Copy Backend Service File"
cp backend.service /etc/systemd/system/backend.service&>>$LOG
Check_Status $?

rm -rf /app &>>$LOG

mkdir /app
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip
cd /app
unzip /tmp/backend.zip &>>$LOG

cd /app
npm install


systemctl daemon-reload
systemctl enable backend
systemctl start backend

dnf install mysql -y
mysql -h 172.31.46.19 -uroot -p${mysql_root_password} < /app/schema/backend.sql
