/*

CLEANING DATA USING SQL

*/

SELECT *
FROM NashvilleHousing

-- STANDARD DATA FORMAT

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

----------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID
/*USING THE ABOVE QUERY WE CAN SEE THE SAME PARCELID'S HAVE THE SAME ADDRESS. SO, WE ARE GOING TO POPULATE IT BY TAKING REFERENCE OF PARCELID
FOR THAT WE NEED TO DO SELF JOIN*/

SELECT MAIN.ParcelID, MAIN.PropertyAddress, REF.ParcelID, REF.PropertyAddress, ISNULL(MAIN.PropertyAddress,REF.PropertyAddress)
FROM NashvilleHousing main
JOIN NashvilleHousing ref
ON MAIN.[UniqueID ]<>REF.[UniqueID ]
AND MAIN.ParcelID=REF.ParcelID
WHERE MAIN.PropertyAddress IS NULL

--WE CAN'T USE THE TABLE NAME IN UPDATE WHILE USING JOINS. WE NEED TO MENTION IT WITH THE ALIAS OF IT
UPDATE MAIN
SET PropertyAddress=ISNULL(MAIN.PropertyAddress,REF.PropertyAddress)
FROM NashvilleHousing main
JOIN NashvilleHousing ref
ON MAIN.[UniqueID ]<>REF.[UniqueID ]
AND MAIN.ParcelID=REF.ParcelID
WHERE MAIN.PropertyAddress IS NULL

--------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(250);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(250);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 


SELECT OwnerAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

/*FOR THIS WE WILL USE PARSENAME AND NOT SUBSTRING AS IT IS A TEDIOUS JOB. IT DOENS'T TAKE COMMA BUT A PERIOD(.). SO, WE NEED TO REPLACE IT AND IT WORKING IN A BACKWARD MANNAR
i.e. 1 MEANS LAST VALUE AND 3 MEANS THE 1ST ONE*/

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


-------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN "SoldAsVacant" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-------------------------------------------------------------------------------

--REMOVE DUPLICATES////CHECK HOW RANKS, DENSE RANKS WORK IN SQL

--ROW  NUM WILL INCREMENT THE COUNTER IF SAME DATA WILL APPEAR 
--WE WILL USE CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY
				ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM NashvilleHousing
--ORDER BY ParcelID----WE CAN'T USE ORDER BY CLAUSE IN CTE
)
SELECT *
FROM RowNumCTE
WHERE row_num>1


----------------------------------------------------

--DELETE UNUSED DATA
SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN saleDate, OwnerAddress, PropertyAddress, TaxDistrict