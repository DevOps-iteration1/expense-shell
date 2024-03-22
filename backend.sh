source common.sh

mysql_root_password=$1
app_dir=/app
component=backend

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
cp ${component}.service /etc/systemd/system/${component}.service&>>$LOG
Check_Status $?

App_PreReq

cd /app
npm install


systemctl daemon-reload
systemctl enable backend
systemctl start backend

dnf install mysql -y
mysql -h 172.31.46.19 -uroot -p${mysql_root_password} < /app/schema/backend.sql
