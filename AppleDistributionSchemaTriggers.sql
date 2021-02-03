use AppleDistributionDB

CREATE TRIGGER ProductCreated
on ProductsCreated
after INSERT
as
begin
	declare @currentPSN varchar(18)
	set @currentPSN = (select ProductSerialNumber from inserted i)

	insert into TransactionLog values (@currentPSN, 'Has been manufactured', GETDATE())
end

CREATE TRIGGER ProductsSent
on ProductsCreated
after update
as
begin
	declare @currentPSN varchar(18)
	declare @sendDate DATE

	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @sendDate = (select SendDate from inserted i)

	if (@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, 'Has left production', @sendDate)
	end

end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER WarehouseUpdateManifest
on WarehouseStockManifest
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentPSN varchar(18)
	declare @currentWH int
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentWH = (select ProductWarehouseNumber from inserted i);

	
	if (@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Has left Warehouse ',@currentWH), @sendDate)
	end else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Was recieved at Warehouse ',@currentWH), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER WarehouseUpdateReturn
on ReturnedItemsWarehouse
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @currentRID int
	declare @currentWH int

	declare @currentPSN varchar(18)
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @currentRID = (select ReturnId from inserted i)
	set @currentWH = (select WarehouseId from inserted i);
	set @currentPSN = (select ProductSerialNumber from ReturnedItems where ReturnId = @currentRID)

	if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Is a return. This was recieved at Warehouse ',@currentWH), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER DistributorUpdateManifest
on DistributorStockManifest
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentPSN varchar(18)
	declare @currentDis int
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentDis = (select DistributorId from inserted i);

	
	if (@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Has left Distributor ',@currentDis), @sendDate)
	end
	else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Was recieved at Distributor ',@currentDis), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER DistributorUpdateReturn
on ReturnedItemsDistributor
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentRID int
	declare @currentDis int

	declare @currentPSN varchar(18)
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentRID = (select ReturnId from inserted i)
	set @currentDis = (select DistributorId from inserted i);
	set @currentPSN = (select ProductSerialNumber from ReturnedItems where ReturnId = @currentRID)

	if(@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Is a return. Has Left Distributor ',@currentDis), @receivedDate)
	end 
	else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Is a return. This was recieved at Distributor ',@currentDis), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER SubDistributorUpdateManifest
on SubDistributorStockManifest
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentPSN varchar(18)
	declare @currentSub int
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentSub = (select SubDistributorId from inserted i);

	if (@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Has left Sub-Distributor ',@currentSub), @sendDate)
	end
	else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Was recieved at Sub-Distributor ',@currentSub), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER SubDistributorUpdateReturn
on ReturnedItemsSubDistributor
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentRID int
	declare @currentSub int

	declare @currentPSN varchar(18)
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentRID = (select ReturnId from inserted i)
	set @currentSub = (select SubDistributorId from inserted i);
	set @currentPSN = (select ProductSerialNumber from ReturnedItems where ReturnId = @currentRID)

	if(@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Is a return. Has left Sub-Distributor ',@currentSub), @receivedDate)
	end
	else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Is a return. This was recieved at Sub-Distributor ',@currentSub), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER ChannelPartnerUpdateManifest
on ChannelStockManifest
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentPSN varchar(18)
	declare @currentCnl int
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentCnl = (select ChannelPartnerId from inserted i);

	if (@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Has left Channel Partner ',@currentCnl), @sendDate)
	end
	else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Was recieved at Channel Partner ',@currentCnl), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER ChannelUpdateReturn
on ReturnedItemsChannel
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @sendDate DATE
	declare @currentRID int
	declare @currentSub int

	declare @currentPSN varchar(18)
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @sendDate = (select SendDate from inserted i)
	set @currentRID = (select ReturnId from inserted i)
	set @currentSub = (select ChannelPartnerId from inserted i);
	set @currentPSN = (select ProductSerialNumber from ReturnedItems where ReturnId = @currentRID)

	if(@sendDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('is a return. Has left Channel Partner ',@currentSub), @receivedDate)
	end
	else if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('is a return. This was recieved at Channel Partner ',@currentSub), @receivedDate)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER StoreUpdateStock
on StoreStockManifest
after UPDATE
as
begin
	declare @receivedDate DATE
	declare @currentPSN varchar(18)
	declare @currentStr int
	
	set @receivedDate = (select ReceiveDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentStr = (select StoreId from inserted i)

	if (@receivedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Was recieved at Store ',@currentStr), @receivedDate)
	end

end

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER CustomerPurchase
on CustomerPurchases
after INSERT
AS
BEGIN
	declare @purchaseDate DATE
	declare @currentPSN varchar(18)
	declare @currentCustomer varchar(20)
	declare @currentCusId int

	set @purchaseDate = (select PurchaseDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentCustomer = (select CustomerEmail from inserted i);
	set @currentCusId = (select CustomerId from Customers where CustomerEmail = @currentCustomer)

	insert into TransactionLog values (@currentPSN, concat('Was Purchased by User ',@currentCusId), @purchaseDate)
END

------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER ReturnedItemAdded
on ReturnedItems
after INSERT
AS
BEGIN
	declare @recievedDate DATE
	declare @currentPSN varchar(18)
	declare @currentStr int

	set @recievedDate = (select ReceiveDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentStr = (select StoreId from inserted i)

	insert into TransactionLog values (@currentPSN, 'Was Returned', GETDATE())
END

CREATE TRIGGER ReturnedItemsUpdate
on ReturnedItems
after update
AS
BEGIN
	declare @recievedDate DATE
	declare @currentPSN varchar(18)
	declare @currentStr int

	set @recievedDate = (select ReceiveDate from inserted i)
	set @currentPSN = (select ProductSerialNumber from inserted i)
	set @currentStr = (select StoreId from inserted i);
	if(@recievedDate IS NOT NULL)
	begin
		insert into TransactionLog values (@currentPSN, concat('Is a Return. Has left Store ', @currentStr), @recievedDate)
	end
END
