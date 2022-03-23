-- Check data types of columns and change the inappropriate dtypes of columns
ALTER TABLE Property
ALTER COLUMN [SaleDate] DATE;

-- removing null rows
DELETE FROM Property
WHERE [UniqueID ] is null

-- removing duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Property)
DELETE FROM RowNumCTE
WHERE row_num >1

-- Check null in property add for parcel id's with same value

select ParcelID
from Property
WHERE PropertyAddress is null
AND ParcelID IN ( select ParcelID
from Property

group by ParcelID
HAVING COUNT(ParcelID) > 1)

select * from Property
WHERE ParcelID = '109 04 0A 080.00'

-- Now replcae null in property add with the add of same parcel id

select 
A.ParcelID,
A.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress) AS Property_Address,
B.PropertyAddress
From Property A
Join Property B on
A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress is null

UPDATE  A
SET [PropertyAddress] = ISNULL(A.PropertyAddress, B.PropertyAddress)

From Property A
Join Property B on
A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]

select * From Property
order by [UniqueID ]

-- Extracting street,city from property add

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING( PropertyAddress , CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))
FROM Property

ALTER TABLE Property
ADD Street NVARCHAR(255),
    City NVARCHAR(255)

UPDATE Property
SET Street = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
    City  = SUBSTRING( PropertyAddress , CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

	Select * from Property
	order by [UniqueID ]

-- Splitting Owner address

select
PARSENAME(REPLACE([OwnerAddress], ',','.'),1),
PARSENAME(REPLACE([OwnerAddress], ',','.'),2),
PARSENAME(REPLACE([OwnerAddress], ',','.'),3)
FROM Property
WHERE OwnerAddress is not null

ALTER TABLE Property
ADD Ownerstate NVARCHAR(255),
    Ownercity NVARCHAR(255),
	Ownerstreet NVARCHAR(255)

UPDATE Property
SET Ownerstate = PARSENAME(REPLACE([OwnerAddress], ',','.'),1),
    Ownercity = PARSENAME(REPLACE([OwnerAddress], ',','.'),2),
	Ownerstreet = PARSENAME(REPLACE([OwnerAddress], ',','.'),3)

-- Updating Y/N to yes/no

select 
distinct(SoldAsVacant),
count(SoldAsVacant)
FROM Property
group by SoldAsVacant

UPDATE Property
SET SoldAsVacant = case when SoldAsVacant = 'N' then 'No' 
                         when SoldAsVacant = 'Y' then 'Yes'
						 else SoldAsVacant  end 





