select * from NHousing

--Standazing date

select SaleDate, convert(date,SaleDate) from NHousing

update NHousing set SaleDate=convert(date,SaleDate) where SaleDate=SaleDate

Alter table NHousing
Add saledateconverted date

update NHousing set saledateconverted=convert(date,SaleDate)


----Find out duplicate values in ParcelID

SELECT ParcelID, COUNT(ParcelID) as [Count]
FROM NHousing
GROUP BY ParcelID
HAVING COUNT(ParcelID) > 1


   -----By using window function


With duplicaterows as
(
select *,ROW_NUMBER() Over (Partition by ParcelID order by ParcelID) as rn
from NHousing
)
select * from duplicaterows
where rn>1 and PropertyAddress is null


select * , 
Case When ROW_NUMBER() Over (Partition by ParcelID order by ParcelID)>1 then 'True'
     else 'False' end  as rn
from NHousing


select a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress ,
isnull(a.PropertyAddress,b.PropertyAddress) from NHousing a
join NHousing b on a.ParcelID=b.ParcelID
and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
 from NHousing a
join NHousing b on a.ParcelID=b.ParcelID
and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking down  property address

select PropertyAddress,SUBSTRING( PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1) as adress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+2,len(PropertyAddress)-CHARINDEX(',',PropertyAddress,1)+2) as place
from NHousing address


---Adding these two columns in the table

alter Table NHousing
add splitaddress nvarchar(250)

alter Table NHousing
add splitplace nvarchar(250)

update NHousing set splitaddress=SUBSTRING( PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1)

update NHousing set splitplace=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+2,len(PropertyAddress)-CHARINDEX(',',PropertyAddress,1)+2)


--Breaking down   owneraddress

select owneraddress from NHousing

select owneraddress,PARSENAME(Replace(owneraddress,',','.'),3) as address,
PARSENAME(Replace(owneraddress,',','.'),2) as address,
PARSENAME(Replace(owneraddress,',','.'),1) as address
from NHousing
 -----adding these splited address in tables
alter Table NHousing
add ownersplitaddress nvarchar(250)

update NHousing set ownersplitaddress=PARSENAME(Replace(owneraddress,',','.'),3)

alter Table NHousing
add ownersplitplace nvarchar(250)

update NHousing set ownersplitplace=PARSENAME(Replace(owneraddress,',','.'),2)

alter Table NHousing
add ownersplitcity nvarchar(250)


update NHousing set ownersplitcity=PARSENAME(Replace(owneraddress,',','.'),1)




---change Y  or N into Yes or No


select distinct SoldasVacant,count(SoldasVacant) from NHousing
group by SoldasVacant
order by 2

select distinct SoldasVacant ,
Case When SoldasVacant='y' then 'Yes'
     when SoldasVacant='n' then 'NO'
	 else SoldasVacant end 
from NHousing


update NHousing set SoldasVacant=Case When SoldasVacant='y' then 'Yes'
     when SoldasVacant='n' then 'NO'
	 else SoldasVacant end 

---Finding duplicate valueson in the table
with tempren as
(
select * ,
row_number() over (partition by ParcelID,PropertyAddress,
                                 SaleDate,SalePrice,LegalReference
								 ,OwnerName,OwnerAddress
								 order by ParcelID)rn
from NHousing
----order by UniqueID
)

delete from tempren where rn>1
--select * from tempren where rn>1---ParcelID='081 02 0 144.00'


----Delete unused columns

Alter table NHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress


Alter table NHousing
Drop Column SaleDate

