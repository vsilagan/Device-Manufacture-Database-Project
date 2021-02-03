--CREATE DATABASE AppleDistributionDB

Use AppleDistributionDB

CREATE TABLE Products
(
	ProductId int PRIMARY KEY identity(10,1),
	ProductName varchar(20),
);

CREATE TABLE ProductsCreated
(
	ProductSerialNumber varchar(18) PRIMARY KEY,
	ProductId int FOREIGN KEY REFERENCES Products(ProductId),
	CreationDate DATE, -- ON ADD, Will log product was created
	SendDate DATE -- initially null on add, ON UPDATE, will log product was sent
);

CREATE TABLE ProductionCenters
(
	ProductionCenterId int PRIMARY KEY IDENTITY (100,1),
	ProductionCenterContinent varchar(20),
	ProductionCenterCountry varchar(30) 
);

CREATE TABLE ProductionCenterCosts
(
	ProductionCenterId int FOREIGN KEY REFERENCES ProductionCenters(ProductionCenterId),
	ProductId int FOREIGN KEY REFERENCES Products(ProductId),
	ManufactureCount int,
	InitialCost decimal(18,2)

	CONSTRAINT PK_ProductionCosts PRIMARY KEY (ProductionCenterId, ProductId)
);

CREATE TABLE CountryImports
(
	CountryName varchar(30) PRIMARY KEY,
	ProductionCenterId int FOREIGN KEY REFERENCES ProductionCenters(ProductionCenterId),
	ImportPercentage decimal (18,2) -- accounts for currency conversion and taxes/tariffs
);


CREATE TABLE Warehouses
(
	WarehouseId int PRIMARY KEY IDENTITY (200,1),
	ProductionCenterId int FOREIGN KEY REFERENCES ProductionCenters(ProductionCenterId),
	WarehouseLocation varchar(30) FOREIGN KEY REFERENCES CountryImports(CountryName)
);

CREATE TABLE WarehouseStockManifest
(
	ProductWarehouseNumber int FOREIGN KEY REFERENCES Warehouses(WarehouseId),
	ProductSerialNumber varchar(18) PRIMARY KEY FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	ReceiveDate Date, -- initially null on add,  On Update - Log will note that product was recieved
	SendDate Date, -- initially null on add,  On Update - Log will note that product was sent
);

CREATE TABLE Distributors
(
	DistributorId int PRIMARY KEY IDENTITY(10000,1),
	DistributorName varchar(20) UNIQUE,
	WarehouseId int FOREIGN KEY REFERENCES Warehouses(WareHouseId)
);


CREATE TABLE DistributorStockManifest
(
	DistributorId int FOREIGN KEY REFERENCES Distributors(DistributorId),
	ProductSerialNumber varchar(18) PRIMARY KEY FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	ReceiveDate Date,  -- initially null on add,  On Update - Log will note that product was recieved
	SendDate Date -- initially null on add,  On Update - Log will note that product was sent
)


CREATE TABLE SubDistributors
(
	SubDistributorId int PRIMARY KEY IDENTITY (10000,1),
	SubDistributorName varchar(20) UNIQUE,
	DistributorId int FOREIGN KEY REFERENCES Distributors(DistributorId)
);

CREATE TABLE SubDistributorStockManifest
(
	SubDistributorId int FOREIGN KEY REFERENCES SubDistributors(SubDistributorId),
	ProductSerialNumber varchar(18) PRIMARY KEY FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	ReceiveDate Date,  -- initially null on add,  On Update - Log will note that product was recieved
	SendDate Date -- initially null on add,  On Update - Log will note that product was sent
)



CREATE TABLE ChannelPartners
(
	ChannelPartnerId int PRIMARY KEY IDENTITY (100000,1),
	ChannelPartnerName varchar(20) UNIQUE,
	ChannelPartnerZone varchar(20) UNIQUE,
	SubDistributorId int FOREIGN KEY REFERENCES SubDistributors(SubDistributorId)
);

CREATE TABLE ChannelStockManifest
(
	ChannelPartnerId int FOREIGN KEY REFERENCES ChannelPartners,
	ProductSerialNumber varchar(18) PRIMARY KEY FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	ReceiveDate Date,  -- initially null on add,  On Update - Log will note that product was recieved
	SendDate Date  -- initially null on add,  On Update - Log will note that product was sent
)

CREATE TABLE Storefronts
(
	StoreId int PRIMARY KEY Identity(1000000,1),
	StoreName varchar(20),
	StoreDesignation varchar(20) CHECK (StoreDesignation = 'Apple Store' OR StoreDesignation = 'Authorized Seller'),
	ChannelPartnerId int FOREIGN KEY REFERENCES ChannelPartners(ChannelPartnerId)
);

CREATE TABLE StoreListing
(
	StoreId int FOREIGN KEY REFERENCES Storefronts(StoreId),
	ProductId int FOREIGN KEY REFERENCES Products(ProductId),
	ProductCost decimal(18,2),
	ProductQty int
);

CREATE TABLE StoreStockManifest
(
	StoreId int FOREIGN KEY REFERENCES Storefronts(StoreId),
	ProductSerialNumber varchar(18) PRIMARY KEY FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	ReceiveDate DATE  -- initially null on add,  On Update - Log will note that product was recieved
);

-- Customer Section

CREATE TABLE Customers
(
	CustomerId int Identity,
	CustomerEmail varchar(20) PRIMARY KEY CHECK (CustomerEmail LIKE '%___@___%.___%'),
	CustomerName varchar(20)
);

CREATE TABLE CustomerPurchases -- ON ADD: Log will note Product was purchased
(
	CustomerEmail varchar(20) FOREIGN KEY REFERENCES Customers(CustomerEmail),
	ProductSerialNumber varchar(18) FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	PurchaseDate DATE

	CONSTRAINT PK_CustomerPurchase PRIMARY KEY (CustomerEmail,ProductSerialNumber)
);

-- Returns Record
CREATE TABLE ReturnedItems -- ON ADD: Log will note product was returned
(
	ReturnId int PRIMARY KEY Identity (1,1),
	StoreId int FOREIGN KEY REFERENCES Storefronts(StoreId),
	ProductSerialNumber varchar(18) FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	ReceiveDate DATE, 
	SendDate DATE -- initially null on add,  ON UPDATE: Log will note product was sent
);

CREATE TABLE ReturnedItemsChannel
(
	ReturnId int PRIMARY KEY FOREIGN KEY REFERENCES ReturnedItems(ReturnId),
	ChannelPartnerId int FOREIGN KEY REFERENCES ChannelPartners(ChannelPartnerId),
	ReceiveDate DATE,  -- initially null on add,  On Update - Log will note that product was recieved
	SendDate DATE -- initially null on add,  On Update - Log will note that product was sent
);

CREATE TABLE ReturnedItemsSubDistributor
(
	ReturnId int PRIMARY KEY FOREIGN KEY REFERENCES ReturnedItems(ReturnId),
	SubDistributorId int FOREIGN KEY REFERENCES SubDistributors(SubDistributorId),
	ReceiveDate DATE,  -- initially null on add,  On Update - Log will note that product was recieved
	SendDate DATE -- initially null on add,  On Update - Log will note that product was sent
);

CREATE TABLE ReturnedItemsDistributor
(
	ReturnId int PRIMARY KEY FOREIGN KEY REFERENCES ReturnedItems(ReturnId),
	DistributorId int FOREIGN KEY REFERENCES Distributors(DistributorId),
	ReceiveDate DATE,  -- initially null on add, On Update - Log will note that product was recieved
	SendDate DATE -- initially null on add,  On Update - Log will note that product was sent
);

CREATE TABLE ReturnedItemsWarehouse
(
	ReturnId int PRIMARY KEY FOREIGN KEY REFERENCES ReturnedItems(ReturnId),
	WarehouseId int FOREIGN KEY REFERENCES Warehouses(WarehouseId),
	ReceiveDate DATE,  -- On Update - Log will note that product was recieved
);

--Log Table
CREATE TABLE TransactionLog
(
	LogId int PRIMARY KEY IDENTITY,
	ProductSerialNumber varchar(18) FOREIGN KEY REFERENCES ProductsCreated(ProductSerialNumber),
	Record varchar(40),
	LogDate DATE
)