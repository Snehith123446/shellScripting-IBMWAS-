
#!/bin/bash

set -e
read -p "Do you want to create j2calias: (Y/N) " j2c
## Taking the input from the user for the creation of j2c alias
if [[ j2c == "y" ]];then
	read -p "Name of j2calias: " j2cname
	read -p "Enter the Username: " j2cusername
	read -p "Enter the Password: " j2cpasssword

	echo "AdminTask.createAuthDataEntry('[-alias ${j2cname} -user ${j2cusername} -password ${j2cpassword}  ]')" > ./jdbc/j2calias.py
	echo "AdminConfig.save()"
	#./connectWsadmin.sh -path ./jdbc/j2calias.py
	
fi

read -p "Do you want to use existing JDBC Provider (Y/N): " userProvider
userProvider="${userProvider,,}"
echo "${userProvider}"
if [[ ${userProvider} == "n" ]];then
	echo "Creation of JDBC provider"
	read -p "Enter DB type [DB2,ORACLE,sqlserver] :" db
	db="${db^^}"
	if [ $db == "DB2" ];then
		echo "Please select the provider Type from below list: "
		echo "1. DB2 Universal JDBC Driver Provider "
		echo "2. DB2 UDB for iSeries (Toolbox) "
		echo "3. DB2 UDB for iSeries (Native) "
		read -p "Enter the option number eg:1 " providerType
		case $providerType in
			 1)
      				 providerType="DB2 Universal JDBC Driver Provider"
       	 			 ;;
   			 2)
       				 providerType="DB2 UDB for iSeries (Toolbox)"
       				 ;;
   			 3)
       				 providerType="DB2 UDB for iSeries (Native)"
       				 ;;
   			 *)
				echo "Please provide the provider Type"
				;;
		esac
	fi
	echo "You have selected provider type as  ${providerType}"

	if [ $db == "ORACLE" ];then
		 echo "Please select the provider Type from below list: "
		 echo "1. Oracle JDBC Driver "
		 echo "2. Oracle JDBC Driver UCP "
		 read -p "Enter the option number eg:1 " providerType
                 case $providerType in
                         1)
                                 providerType="Oracle JDBC Driver"
                                 ;;
                         2)
                                 providerType= "Oracle JDBC Driver UCP"
                                 ;;      
                         *)
                                echo "Please provide the provider Type"
                                ;;
                esac
        fi

	read -p "Implementation Type \n Connection pool data source \n XA data source :" implType
	read -p "Enter name for provider :" name
	read -p "path for the drivers:" driver
	db="${db^^}"
	echo "AdminTask.createJDBCProvider('[-scope Cell=swasCell02 -databaseType "${db}" -providerType \"${providerType}\" -implementationType \"${implType}\" -name \"${name}\" -classpath \"${driver}\"]')" > ./jdbc/Newproviders.py
	echo "AdminConfig.save()" >> ./jdbc/Newproviders.py
	echo "AdminConfig.reset()" >> ./jdbc/Newproviders.py
	echo "Making connection to scripting tool"
	./connectWsadmin.sh -path ./jdbc/Newproviders.py
	echo "JBBC provider is scuessfully created"

fi

echo "creation of Data Source"

echo "print(AdminConfig.list('JDBCProvider', AdminConfig.getid( '/Cell:swasCell02/')))" > ./jdbc/providerscript.py
echo "printed script data intp .py file"
./connectWsadmin.sh -path ./jdbc/providerscript.py -output_file ./jdbc/Flitered_providers.txt 
echo "connected and give list of providers in file ./jdbc/Flitered_providers.txt"
./jdbc/provider_flitered.sh
echo "problem"

cat ./jdbc/Flitered_providers.txt
read -p "select the jdbc provider from above list " jdbcProvider
read -p "Enter the name of Data source Name: " dataSourceName
read -p "Enter the jndi name: " jndiName
read -p "Enter the database name: " dbName
read -p "Enter driver Type: " driverType
read -p "Enter the hostname of DB " DBHostname
read -p "Enter the port Number " dbPort


echo "AdminTask.createDatasource('"${jdbcProvider}"', '[-name ${dataSourceName} -jndiName ${jndiName} -dataStoreHelperClassName com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper -containerManagedPersistence true -componentManagedAuthenticationAlias ${j2calias} -configureResourceProperties [[databaseName java.lang.String ${dbName}] [driverType java.lang.Integer ${driverType}] [serverName java.lang.String ${DBHostname}] [portNumber java.lang.Integer ${dbPort}]]]')" > ./jdbc/datasource.py

echo "AdminConfig.save()" >> ./jdbc/datasource.py
	
echo "Configuring the JDBC Data Source"



./connectWsadmin.sh -path ./jdbc/datasource.py
 
#echo "AdminTask.createJDBCProvider('[-scope Cell=swasCell02 -databaseType "${db}" -providerType \"${providerType}\" -implementationType \"${implType}\" -name \"${name}\" -classpath \"${driver}\"]')"

#AdminTask.createDatasource('"DB2 Universal JDBC Driver Provider_nn(cells/diskCell01|resources.xml#JDBCProvider_1712744985680)"',"[-name JMSDS -jndiName jndi/dev1 -dataStoreHelperClassName com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper -containerManagedPersistence true -componentManagedAuthenticationAlias diskCellManager01/db2_auth -configureResourceProperties [[databaseName java.lang.String maxdb76] [driverType java.lang.Integer 4] [serverName java.lang.String 10.0.0.114] [portNumber java.lang.Integer 50000]]]",)

