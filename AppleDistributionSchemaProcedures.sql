CREATE PROCEDURE proc_StartManufacturing
(
	@p_ProductId int,
	@p_ProductionCenterId int,
	@p_initialCost decimal(18,2)
)
AS
BEGIN
	INSERT INTO ProductionCenterCosts values (@p_ProductionCenterId, @p_ProductId, 0, @p_initialCost)
END

exec proc_StartManufacturing 12, 100, 60
------------------------------------------------------------------------------------------------------------------------------------------



CREATE PROCEDURE proc_ManufactureProduct
(
	@p_ProductId int,
	@p_ProductionCenterId int,
	@p_Amount int
)
AS
BEGIN
	DECLARE @cnt INT = 0
	WHILE @cnt < @p_Amount
	BEGIN
		DECLARE @crntProductCount INT
		SET @crntProductCount = (SELECT ManufactureCount FROM ProductionCenterCosts where ProductionCenterCosts.ProductionCenterId = @p_ProductionCenterId AND ProductionCenterCosts.ProductId = @p_ProductId)
		INSERT INTO ProductsCreated VALUES (dbo.generateSerialNumber(@p_ProductionCenterId, @p_ProductId, @crntProductCount), @p_ProductId, GETDATE(), NULL)
		UPDATE ProductionCenterCosts
			SET ManufactureCount = ManufactureCount + 1
			WHERE ProductionCenterCosts.ProductId = @p_ProductId AND ProductionCenterCosts.ProductionCenterId = @p_ProductionCenterId
		SET @cnt = @cnt + 1
	END
END

exec proc_ManufactureProduct 13, 100, 20

exec proc_ManufactureProduct 12, 100, 30
------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE proc_SendToWarehouse
(
	@p_ProductSerialNumber varchar(18),
	@p_WarehouseId int
	
)
AS
BEGIN
	Update ProductsCreated
		SET SendDate = GETDATE()
		WHERE ProductSerialNumber = @p_ProductSerialNumber
	INSERT INTO WarehouseStockManifest VALUES (@p_WarehouseId, @p_ProductSerialNumber, null, null)
END

exec proc_SendToWarehouse AP10013000000001, 200


CREATE PROCEDURE proc_ReceiveWarehouse
(
	
	@p_ProductSerialNumber varchar(18),
	@p_WarehouseId int
)
AS
BEGIN
	Update WarehouseStockManifest
		SET ReceiveDate = GETDATE()
		WHERE ProductSerialNumber = @p_ProductSerialNumber
END

exec proc_ReceiveWarehouse AP10013000000001, 200

------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE proc_SendToDistributor
(
	@p_productSerialNumber varchar(18),
	@p_Distributor int
)
AS
BEGIN
	DECLARE @phDate DATE
	SET @phDate = (SELECT ReceiveDate FROM WarehouseStockManifest WHERE ProductSerialNumber = @p_productSerialNumber)
	if (@phDate is not NULL)
	begin
	UPDATE WarehouseStockManifest
		SET SendDate = GETDATE()
		WHERE ProductSerialNumber = @p_productSerialNumber

	INSERT INTO DistributorStockManifest VALUES(@p_Distributor, @p_productSerialNumber, null, null)
	end
	else
	begin
		print 'Have not received product. Cannot send'
	end
END

exec proc_SendToDistributor AP10013000000001, 10000

------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE proc_ReceiveDistributor
(
	@p_productSerialNumber varchar(18),
	@p_Distributor int
)
AS
BEGIN
	UPDATE DistributorStockManifest
		SET ReceiveDate = GETDATE()
		WHERE ProductSerialNumber = @p_productSerialNumber
END

exec proc_ReceiveDistributor AP10013000000001, 10000

------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE proc_SendToSubDistributor
(
	@p_productSerialNumber varchar(18),
	@p_SubDistributor int
)
AS
BEGIN
	DECLARE @phDate DATE
	SET @phDate = (SELECT ReceiveDate FROM DistributorStockManifest WHERE ProductSerialNumber = @p_productSerialNumber)
	if (@phDate is not NULL)
	begin
	UPDATE DistributorStockManifest
		SET SendDate = GETDATE()
		WHERE ProductSerialNumber = @p_productSerialNumber

	INSERT INTO SubDistributorStockManifest VALUES(@p_subDistributor, @p_productSerialNumber, null, null)
	end
	else
	begin
		print 'Have not received product. Cannot send'
	end
END

exec proc_SendToSubDistributor AP10013000000000, 10000

------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE proc_ReceiveSubDistributor
(
	@p_productSerialNumber varchar(18),
	@p_SubDistributor int
)
AS
BEGIN

	UPDATE SubDistributorStockManifest
		SET ReceiveDate = GETDATE()
		WHERE ProductSerialNumber = @p_productSerialNumber
END

exec proc_SendToStore AP10013000000000,1000001

------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE proc_SendToChannelPartner
(
	@p_productSerialNumber varchar(18),
	@p_Channel int
)
AS
BEGIN
	DECLARE @phDate DATE
	SET @phDate = (SELECT ReceiveDate FROM SubDistributorStockManifest WHERE ProductSerialNumber = @p_productSerialNumber)
	if (@phDate is not NULL)
	begin
		UPDATE SubDistributorStockManifest
			SET SendDate = GETDATE()
			WHERE ProductSerialNumber = @p_productSerialNumber

		INSERT INTO ChannelStockManifest VALUES(@p_Channel, @p_productSerialNumber, null, null)
	end
	else
	begin
		print 'Have not received product. Cannot send'
	end
END

------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE proc_ReceiveChannel
(
	@p_productSerialNumber varchar(18),
	@p_Channel int
)
AS
BEGIN

	UPDATE ChannelStockManifest
		SET ReceiveDate = GETDATE()
		WHERE ProductSerialNumber = @p_productSerialNumber
END

------------------------------------------------------------------------------------------------------------------------------------------


ALTER PROCEDURE proc_SendToStore
(
	@p_productSerialNumber varchar(18),
	@p_Store int
)
AS
BEGIN
	UPDATE ChannelStockManifest
		SET SendDate = GETDATE()
		WHERE ProductSerialNumber = @p_productSerialNumber

	
	
	DECLARE @pnum int
	SET @pnum = CAST(RIGHT(LEFT(@p_productSerialNumber, 7),2) as INT)

	DECLARE @count int
	SET @count = (SELECT COUNT(ProductId) FROM StoreListing WHERE ProductId = @pnum GROUP BY ProductId)
	IF (@count IS NULL)
	BEGIN
		DECLARE @ProductionCtr int
		DECLARE @Country varchar(20)
		DECLARE @ImportPercentage decimal(18,2)
		DECLARE @IPrice decimal(18,2)
		DECLARE @FPrice decimal(18,2)

		SET @ProductionCtr = CAST(LEFT(RIGHT(@p_productSerialNumber,3),5) AS INT)
		SET @Country = (SELECT CountryName FROM CountryImports WHERE CountryName = (SELECT WarehouseLocation
																					FROM Warehouses
																					WHERE CountryImports.ProductionCenterId = 200 AND Warehouses.ProductionCenterId = 200))

		SET @ImportPercentage = (SELECT ImportPercentage FROM CountryImports WHERE CountryName = @Country)
		SET @IPrice = (SELECT InitialCost From ProductionCenterCosts WHERE ProductId = @pnum AND ProductionCenterId = @ProductionCtr)
		SET @FPrice = dbo.GenerateFinalPrice(@IPrice, @Country)
		

		Insert INTO StoreListing VALUES (@p_Store, @pnum, @FPrice , 0)
	END
	
	INSERT INTO StoreStockManifest VALUES(@p_Store, @p_productSerialNumber, null)
	UPDATE StoreListing
		SET ProductQty = ProductQty + 1
		WHERE ProductId = @pnum

END

CREATE PROCEDURE proc_SellProduct
(
	@p_Store int,
	@p_ProductId varchar
	@p_CustomerId int
)
AS
BEGIN
	DECLARE @CurrentInv INT
	IF (@CurrentInv <> 0)
	BEGIN
		UPDATE StoreListing
			SET ProductQty = ProductQty - 1
			WHERE StoreId = @p_Store AND
	END
	ELSE
	BEGIN
		PRINT 'Product is out of stock. Please inform customer'
	END
END


CREATE PROCEDURE proc_ReturnToWareHouse
(
	@p_ReturnId int,
	@p_WarehouseId int
)
AS
BEGIN
	UPDATE ReturnedItemsDistributor
		SET SendDate = getDate()
		WHERE ReturnId = @p_ReturnId

	INSERT INTO ReturnedItemsWarehouse VALUES (@p_ReturnId,@p_WarehouseId, null)
END

