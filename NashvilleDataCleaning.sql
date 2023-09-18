
-----------------------------------------------------------------------------------------------------
-- Cleaning Data 

 Select *
 From PortfolioProject..NashvilleHousing
 
-----------------------------------------------------------------------------------------------------
-- Standardizing Data Format

 Select SaleDateConverted, CONVERT(DATE, SaleDate)
 From PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing 
 Add SaleDateConverted Date;

 UPDATE NashvilleHousing
 SET SaleDateConverted = CONVERT(DATE, SaleDate)

 Select SaleDateConverted, CONVERT(DATE, SaleDate)
 From PortfolioProject..NashvilleHousing

 
-----------------------------------------------------------------------------------------------------
-- Populate Property Address Data

 Select *
 From PortfolioProject..NashvilleHousing
 --where PropertyAddress is Null
 order by ParcelID



 --Filling the Null Values in Property Address
 -- Same ParcelID must have the same address

 Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PortfolioProject..NashvilleHousing a
 JOIN PortfolioProject..NashvilleHousing b
 ON a.ParcelID=b.ParcelID AND
 a.[UniqueID] <> b.[UniqueID ]
 where a.PropertyAddress is NULL



 -- Setting Values
 UPDATE a
 SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a
 JOIN PortfolioProject..NashvilleHousing b
 ON a.ParcelID=b.ParcelID AND
 a.[UniqueID] <> b.[UniqueID ]
 where a.PropertyAddress is NULL


 -- Filled the NULL values in PropertyAddress

 SELECT * FROM NashvilleHousing
 where PropertyAddress is NULL

 
-----------------------------------------------------------------------------------------------------
 -- Disintegrating the Address into Address, City , State using Substring

 Select PropertyAddress
 From PortfolioProject..NashvilleHousing
 --where PropertyAddress is Null
 --order by ParcelID


 --Using the comma as a delimiter to seperate the columns

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address, 
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) AS City
 FROM PortfolioProject..NashvilleHousing

 -- Creating 2 new columns 
 ALTER TABLE NashvilleHousing 
 Add PropertySplitAddress nvarchar(255)	;

 UPDATE NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


 ALTER TABLE NashvilleHousing 
 Add PropertySplitCity nvarchar(255)	;

 UPDATE NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))

 -- Testing 
 SELECT *
 from NashvilleHousing
 
-----------------------------------------------------------------------------------------------------
-- Owner Address Data Cleaning

 Select OwnerAddress 
 From NashvilleHousing

 -- Disintegrating the Owner Address Column into 3 different columns USING PARSENAME

 Select 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 from NashvilleHousing

 -- Adding the columns to the data

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress nvarchar(255)	;

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing 
Add OwnerSplitCity nvarchar(255)	;

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)



ALTER TABLE NashvilleHousing 
Add OwnerSplitState nvarchar(255)	;

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)




-- Changing Y and N to Yes and No

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' then 'Yes'
     WHEN SoldAsVacant ='N' then 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' then 'Yes'
     WHEN SoldAsVacant ='N' then 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


-----------------------------------------------------------------------------------------------------
--- Removing Duplicates 
WITH RowNumCTE AS (
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
	                       
FROM NashvilleHousing
--order by ParcelID
)
DELETE FROM RowNumCTE
WHERE row_num>1
--order by PropertyAddress


-- Checking for duplicates now
WITH RowNumCTE AS (
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
	                       
FROM NashvilleHousing
--order by ParcelID
)
Select * FROM RowNumCTE 
WHERE row_num>1


-----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP Column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousing
DROP Column SaleDate

---Data Cleaned
