#This script tests the database interactions as outlined in section 1 of the pdf

if (docker exec -it u123_csvs2020-db_c mysql -uroot -pRubbishPassWord \
	-Bse "use csvsdb; select * from comment;;")
then 
	echo "Correct database selected and printed out the contents of 'comment'"
	docker exec -it u123_csvs2020-db_c mysql -uroot -pRubbishPassWord \
	-Bse "use csvsdb; delete from comment where id=2; select * from comment;"
	echo "Successfully deleted test row"
	docker exec -it u123_csvs2020-db_c mysql -uroot -pRubbishPassWord \
	-Bse "use csvsdb; alter table comment add testcolumn varchar(255); select * from comment;"
	echo "Successfully added a new testcolumn"
	docker exec -it u123_csvs2020-db_c mysql -uroot -pRubbishPassWord \
	-Bse "use csvsdb; drop table comment; select * from comment;"
	echo "Successfully dropped the table for testing purposes"
	
else
	echo "Please start the database by either launching the build script or by starting \
		command manually using: docker exec -i u123_csvs2020-db_c mysql -uroot \ 
		-pRubbishPassWord < sqlconfig/csvsdb.sql"
	exit 1
fi
