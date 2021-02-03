CREATE VIEW v_AvailableProductionCenters
AS
	SELECT ProductionCenterId as ID, CONCAT (ProductionCenterCountry, ', ', ProductionCenterContinent) as [Location]
	From ProductionCenters
	;
	
------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_ListProducedProducts
as
	SELECT pcc.ProductionCenterId as [Production Center], p.ProductName as Product, pcc.InitialCost as [Initial Cost], pcc.ManufactureCount as [Total Manufactured]
	FROM Products p,  ProductionCenterCosts pcc
	WHERE p.ProductId = pcc.ProductId


------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_AvailableWarehouses
AS
	SELECT WarehouseId as ID, WarehouseLocation as [Location], ProductionCenterId as [Production Center]
	From Warehouses
	;

------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_WarehouseManifest
as
	SELECT WarehouseStockManifest.ProductWarehouseNumber as [Warehouse Id], WarehouseStockManifest.ProductSerialNumber as [Serial Number], WarehouseStockManifest.ReceiveDate as [Recieved Date], WarehouseStockManifest.SendDate as [Send Date], ReturnedItemsWarehouse.ReceiveDate[Return Date]
	FROM WarehouseStockManifest 
		FULL JOIN ReturnedItemsWarehouse ON WarehouseStockManifest.ProductSerialNumber = (SELECT ProductSerialNumber FROM ReturnedItems WHERE ReturnedItemsWarehouse.ReturnId = ReturnedItems.ReturnId)
		;

		

------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_AvailableDistributors
AS
	SELECT DistributorName as [Name], WarehouseId as [Warehouse]
	FROM Distributors
	;

------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_DistributorManifest
AS
	SELECT DistributorStockManifest.DistributorId as [Distributor Id], DistributorStockManifest.ProductSerialNumber as [Serial Number],  DistributorStockManifest.ReceiveDate as [Recieved Date], DistributorStockManifest.SendDate as [Send Date], ReturnedItemsDistributor.ReceiveDate as [Return Recieved Date], ReturnedItemsDistributor.SendDate as [Return Send Date]
		FROM DistributorStockManifest
		FULL JOIN ReturnedItemsDistributor ON DistributorStockManifest.ProductSerialNumber = (SELECT ProductSerialNumber FROM ReturnedItems WHERE ReturnedItemsDistributor.ReturnId = ReturnedItems.ReturnId)

------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_AvailableSubDistributors
AS
	SELECT SubDistributorName as [Name], DistributorId as [Distributor]
	FROM SubDistributors
	;

------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_SubDistributorManifest
AS
	SELECT SubDistributorStockManifest.SubDistributorId as [Sub-Distributor Id], SubDistributorStockManifest.ProductSerialNumber as [Serial Number],  SubDistributorStockManifest.ReceiveDate as [Recieved Date], SubDistributorStockManifest.SendDate as [Send Date], ReturnedItemsSubDistributor.ReceiveDate as [Return Recieved Date], ReturnedItemsSubDistributor.SendDate as [Return Send Date]
		FROM SubDistributorStockManifest
		FULL JOIN ReturnedItemsSubDistributor ON SubDistributorStockManifest.ProductSerialNumber = (SELECT ProductSerialNumber FROM ReturnedItems WHERE ReturnedItemsSubDistributor.ReturnId = ReturnedItems.ReturnId)


------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_AvailableChannelPartners
AS
	SELECT ChannelPartnerName as [Name], ChannelPartnerZone as [Zone], SubDistributorId as [Sub-Distributor]
	FROM ChannelPartners
	;

------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW v_ChannelManifest
AS
	SELECT ChannelStockManifest.ChannelPartnerId as [Channel Id],ProductSerialNumber as [Serial Number],  ChannelStockManifest.ReceiveDate as [Recieved Date], ChannelStockManifest.SendDate as [Send Date], ReturnedItemsChannel.ReceiveDate as [Return Recieved Date], ReturnedItemsChannel.SendDate as [Return Send Date]
		FROM ChannelStockManifest
		FULL JOIN ReturnedItemsChannel ON ChannelStockManifest.ProductSerialNumber = (SELECT ProductSerialNumber FROM ReturnedItems WHERE ReturnedItemsChannel.ReturnId = ReturnedItems.ReturnId)



CREATE VIEW v_AvailableStores
AS
	SELECT StoreName as [Name], StoreDesignation as [Designation], SubDistributorId as [Sub-Distributor], ChannelPartnerZone as [Zone]
	FROM Storefronts, ChannelPartners
	WHERE Storefronts.ChannelPartnerId = ChannelPartners.ChannelPartnerId
	;

CREATE VIEW v_StoreListing
AS 
	Select StoreListing.StoreId as Store, ProductName as [Name], ProductCost as [Price], ProductQty as [Qty]
	From StoreListing, Products, StoreStockManifest
	Where StoreListing.ProductId = Products.ProductId
	;

CREATE VIEW v_StockLog
AS
	SELECT ProductSerialNumber as [Product], Record as [Message], LogDate as [Message Date]
	From TransactionLog
	;