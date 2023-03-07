sudo apt-get update -y


#checking apache2 is installed or not

var1="install"
if [[ $var1 != $(dpkg --get-selections apache2 | awk '{print $2}') ]]
then
        sudo apt-get install apache2 -y
fi


#checking apache2 is running or not

var2="running"
if [[ $var2 != $(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()') ]]
then
        sudo service apache2 start
fi

#checking apache2 is enabled or not

var3="enabled"
if [[ $var3 != $(systemctl is-enabled apache2 | grep "enabled") ]]
then
        sudo systemctl enable apache2
fi


#Compressing log files

name="basavaraju"
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2/
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log
s3_bucket="upgrad-basavaraju143"
if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]
then
        aws s3 \
        cp /tmp/${name}-httpd-logs-${timestamp}.tar \
        s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi


#Checks if inventory file exists

var5="/var/www/html"
if [[ ! -f ${var5}/inventory.html ]]
then
        echo -e "Log Type\t\tTime Created\t\tType\t\tSize\n" >${var5}/inventory.html
fi

#Provide logs to inventory file

if [[ -f ${var5}/inventory.html ]]
then
        size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
        echo -e "httpd-logs\t\t${timestamp}\t\ttar\t\t${size}\n" >>${var5}/inventory.html
fi


#Execute crone jobs


if [[ ! -f /etc/cron.d/automation ]]
then
        echo "0 1 * * * root /root/Automation_Project/automation.sh " >>/etc/cron.d/automation
fi


