--To add these functions to the current schema, highlight the entire body of the function and select execute.



-- GENERATES A SERIAL NUMBER FOR A GIVEN PRODUCT
CREATE FUNCTION generateSerialNumber(@p_ProductionCenterId int, @p_ProductId int, @p_ManufactureCount int)
returns varchar(18)
as
begin
	declare @formattedId varchar(10) = right(concat('000000000000',@p_ManufactureCount),9)
	return concat('AP',@p_ProductionCenterId,@p_ProductId, @formattedId)
end

/* Use Example

declare @num int
declare @str varchar(18)
set @str = dbo.generateSerialNumber(103,26,10)
set @num = CAST (right(left(@str,5),3) AS INT)

print @num + 1

*/

------------------------------------------------------------------------------------------------------------------------------------------
-- Generates A Final Price for a given Product
CREATE FUNCTION generateFinalPrice(@p_InitialPrice decimal(18,2), @p_CountryName varchar(20))
returns decimal(18,2)
as
begin
	DECLARE @ImportPercentage decimal(18,2)
	SET @ImportPercentage = (SELECT ImportPercentage FROM CountryImports WHERE CountryName = @p_CountryName)
	return ROUND(@p_InitialPrice * (1 + (@ImportPercentage/100)) * 1.08 * 1.08 *1.08 *1.08 ,-1)
end

/*

declare @num decimal(18,2)
set @num = dbo.GenerateFinalPrice(150, 'Bahamas')

print @num
*/