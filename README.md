# Device Manufacturer Database

A design and implementation of an SQL database for use of an international manufacturer (Apple Inc).

## Technologies Used

* Microsoft SQL Server 2016
* SQL and TSQL

## Features

List of features ready and TODOs for future development
* 3NF Tables
* Queries and Procedures for production level use. 

To-do list:
* SSIS integration
* Finish production level queries

## Getting Started
Requirements:
* Git
* Microsoft SQL Server 2016 or Later
* Microsoft SQL Server Management Studio (SSMS)

1. Opening Git Bash in your SQL Queries folder, use "git clone https://github.com/vsilagan/Device-Manufacture-Database-Project" to clone the project onto your computer.
2. Open up AppleDistributionSchemaTables.sql in SSMS, then hit execute query.
3. Open up AppleDistributionSchemaViews.sql in SSMS. For every "CREATE VIEW" statement, do the following:
	3a. Select the entire definition of the CREATE VIEW statement
	3b. Hit Execute Query.
4. Open up AppleDistributionSchemaTriggers.sql in SSMS. For every "CREATE TRIGGER" statement, do the following:
	4a. Select the entire definition of the CREATE TRIGGER statement
	4b. Hit Execute Query.
5. Open up AppleDistributionSchemaFunctions.sql in SSMS. For every "CREATE FUNCTION" statement, do the following:
	3a. Select the entire definition of the CREATE FUNCTION statement
	3b. Hit Execute Query.
6. Open up AppleDistributionSchemaProcedure.sql in SSMS. For every "CREATE PROCEDURE" statement, do the following:
	4a. Select the entire definition of the CREATE Procedure statement
	4b. Hit Execute Query.
7. Insert your distribution chain information into the Products, Production Center, Warehouse, CountryImports, Distributors, Subdistributors, ChannelPartners, and Storefront tables.

- All the `code` required to get started
- Images of what it should look like

## Usage
The Distribution Chain Goes as Follows:
	Production House -> Warehouse -> Distributor -> Sub-Distributor -> Channel Partner -> Storefront


When a product is sent to a member in the production chain, appears into that member's manifest view
	*To see your current manifest, use the View Manifest query in AppleDistributionSchemaQueries.sql
	*To declare that the product has arrived at the member's inventory, use that member's Recieve procedure. (If you are a Distributor, use the RecieveDistributor Procedure.)
		*Conversely, if that product is a return, use the ReturnRecieved procudure. (For example, if you are a Distributor, use the ReturnRecievedDistributor Procedure.)
	*To declare that the product has left a member's inventory, use the SendTo Procedure of the next level. (For example, if you are a Distributor, use the SendToSubDistributor 	procedure)
		*If that product is a return, use the ReturnSendTo Procedure. (For example, if you are a Distributor, use the ReturnSendToWarehouse Procedure. )

## License

This project uses the following license: [Microsoft SQL Server 2016 License](https://www.microsoft.com/en-us/sql-server/sql-server-2016)
