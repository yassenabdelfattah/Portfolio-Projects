/*

Cleaning Data in SQL Queries

*/


Select*
From [Portfolio Project] .dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted , CONVERT(date,SaleDate)
from [Portfolio Project] .dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)


-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select *
from [Portfolio Project] .dbo.NashvilleHousing
--where propertyaddress is null
order by parcelid

Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from [Portfolio Project] .dbo.NashvilleHousing a
join [Portfolio Project] .dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from [Portfolio Project] .dbo.NashvilleHousing a
join [Portfolio Project] .dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
and a.[UniqueID ]<>b.[UniqueID ]
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from [Portfolio Project] .dbo.NashvilleHousing
--where propertyaddress is null
--order by parcelid

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress)) as Address
from [Portfolio Project] .dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))


select owneraddress
from [Portfolio Project] .dbo.NashvilleHousing

Select 
PARSENAME(Replace(owneraddress,',','.'),3)
,PARSENAME(Replace(owneraddress,',','.'),2)
,PARSENAME(Replace(owneraddress,',','.'),1)
from [Portfolio Project] .dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(owneraddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(owneraddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(owneraddress,',','.'),1)

Select*
from [Portfolio Project] .dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant),COUNT(SoldAsVacant)
from [Portfolio Project] .dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant ='y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end
from [Portfolio Project] .dbo.NashvilleHousing


update [Portfolio Project] .dbo.NashvilleHousing
set soldasvacant = case when SoldAsVacant ='y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
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

From [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)
select*
From RowNumCTE
where row_num>1
--order by PropertyAddress 

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
select*

From [Portfolio Project].dbo.NashvilleHousing

alter table [Portfolio Project].dbo.NashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress


alter table [Portfolio Project].dbo.NashvilleHousing
drop column saledate
