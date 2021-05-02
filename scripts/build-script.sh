#This script contains the docker build commands for the dbserver and the webserver
#I made the script executable: chmod +x build-script.sh
#execute with ./build-script.sh

#builds the dbserver (in the dbserver directory)
cd ../builds/dbserver
docker build -t u123/csvs2020-db_i .

#build the webserver (in the webserver directory)
cd ../webserver
docker build -t u123/csvs2020-web_i .
