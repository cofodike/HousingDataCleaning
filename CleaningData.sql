select * from HousingData;


-- Cleaning the provided data

-- Standardizing the Date format

select SaleDate, convert(Date, saledate) from HousingData;

update HousingData
set SaleDate = CONVERT(Date, SaleDate);

alter table HousingData
Add SaleDateConverted Date;

update HousingData
set SaleDateConverted = CONVERT(Date, SaleDate);

select SaleDateConverted from HousingData;

select *
from HousingData
where propertyaddress is null
order by ParcelID;

select count(PropertyAddress)
from HousingData
where propertyaddress is null;

select sum(case when PropertyAddress is null then 1 else 0 end) as CountOfNullInAddress,
	count(PropertyAddress) as CountOfNonNull
from HousingData;

select *
from HousingData
where propertyaddress is null
order by ParcelID;

-- noticing apartments w the same ParcelIDs have the same addresses,
-- first join on itself, the property ids that dont have an address, but have a parcelid, 
-- should be populated with the same addy as the parcelID w an addy


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from HousingData A
join HousingData B
	on A.ParcelID = B.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

-- populate empty addresses that have the same parcel ids w the same addresses.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingData A
join HousingData B
	on A.ParcelID = B.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--update
update a 
set propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingData A
join HousingData B
	on A.ParcelID = B.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--recheck
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from HousingData A
join HousingData B
	on A.ParcelID = B.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--- splitting address by actual address and city
--- the comma is used to seperate the address from the city, so i can seperate both based on the comma
select SUBSTRING(PropertyAddress,0,charindex(',', PropertyAddress)) as [Actual Address],
	SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as [Actual City],
propertyAddress 
from HousingData;

--updating 
alter table HousingData
Add [Actual City Address] varchar(255);

update HousingData
set [Actual City Address] = SUBSTRING(PropertyAddress,0,charindex(',', PropertyAddress));

alter table HousingData
Add [Actual City Name] varchar(255);

update HousingData
set [Actual City Name] = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress));

-- rechecking
select [Actual City Address], [Actual City Name], PropertyAddress
from HousingData;

-- cleaning ownerAddress category
select OwnerAddress
from HousingData;

-- parsing w a different method
select ownerAddress, PARSENAME(replace(owneraddress, ',','.'),1),
	PARSENAME(replace(owneraddress, ',','.'),2),
	PARSENAME(replace(owneraddress, ',','.'),3)
from HousingData

-- updating
alter table HousingData
Add 
	[Owner Actual State] varchar(50),
	[Owner Actual City] varchar(255),
	[Owner Actual Address] varchar(255);


update HousingData
set [Owner Actual State] = PARSENAME(replace(owneraddress, ',','.'),1);

update HousingData
set [Owner Actual City] = PARSENAME(replace(owneraddress, ',','.'),2);

update HousingData
set [Owner Actual Address] = PARSENAME(replace(owneraddress, ',','.'),3);

--rechecking 
select [Owner Actual State], [Owner Actual City], [Owner Actual Address]
from HousingData;

--standardizing 'SoldAsVacant' Columns
--i.e. there are 'y','n','yes','no' responses; 
--making them either 'yes','no' or 'y','n' depending on my choice

	--viewing the distinct options for the column
select distinct(SoldAsVacant), COUNT(soldasvacant)
from HousingData
group by SoldAsVacant
order by 2

	--defining logic
select SoldAsVacant,
	Case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else soldAsVacant
	End
from HousingData

--updating w logic
Update HousingData
set SoldAsVacant = 
	Case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else soldAsVacant
	End;

--checking
select distinct(SoldAsVacant), COUNT(soldasvacant)
from HousingData
group by SoldAsVacant
order by 2;


--removing duplicates the hard way
--gets the # of rows w the same info and increase row_num by 1
select *,	
	ROW_NUMBER() over (
	partition by 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by 
		uniqueID
			) row_num
from HousingData
order by ParcelID;
	--needs to be in a cte to be able to specify row_nums > 1; therefore:
With RowNumCTE as (
select *,	
	ROW_NUMBER() over (
	partition by 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by 
		uniqueID
			) row_num
from HousingData
)
--confirming before deleting
--select * 
--from RowNumCTE
--where row_num > 1
--order by PropertyAddress;

--deleting
delete 
from RowNumCTE
where row_num > 1

--being a cte, only the statement right after it can run,
--the necessary statement is ran, the rest are commented out.

select * 
from HousingData;

-- deleting some unnecessary columns
alter table HousingData
Drop column OwnerAddress, PropertyAddress, SaleDate;

select * 
from HousingData;