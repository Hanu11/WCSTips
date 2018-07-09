Price 
---------------
select o.catentry_id, l.listprice, o.offer_id,od.description, o.identifier, c.partnumber, op.price, o.tradeposcn_id,tp.name, o.startdate,o.enddate,o.published 
from WCS.offer o,WCS.listprice l, WCS.offerprice op, WCS.tradeposcn tp,WCS.offerdesc od, wcs.catentry c
where o.catentry_id = c.catentry_id
and o.catentry_id= l.catentry_id 
and o.offer_id= op.offer_id 
and o.tradeposcn_id= tp.tradeposcn_id 
and o.offer_id= od.offer_id
and o.published = 1
AND (c.partnumber IN ('CDJ00', 'CDH69', 'CHH88', 'CFY39', 'CJV03', 'CGM35'))
and sysdate between o.startdate and nvl(o.enddate,sysdate);   


Scheduler 
------------------

SELECT * FROM schstatus WHERE scsjobnbr IN (SELECT sccjobrefnum FROM schconfig WHERE sccpathinfo LIKE '%MattelPdsFallout%' AND sccactive='A')
ORDER BY scsactlstart DESC;

SELECT * FROM schstatus WHERE scsjobnbr IN (SELECT sccjobrefnum FROM schconfig WHERE sccpathinfo LIKE '%OrderQueueReleaseCmd%' AND sccactive='A')
ORDER BY scsactlstart DESC;

SELECT * FROM schstatus WHERE scsjobnbr IN (SELECT sccjobrefnum FROM schconfig WHERE sccpathinfo LIKE '%MattelReProcessOrdersCmd%' AND sccactive='A')
ORDER BY scsactlstart DESC;


SELECT sc.SCCJOBREFNUM, sc.SCCPATHINFO, ss.SCSQUEUE, se.STOREENT_ID as STORE_ID, se.identifier as STORE, ss.SCSSTATE, ss.SCSRESULT, ss.SCSACTLSTART, ss.SCSEND, sl.SCSERROR 
FROM wcs.SCHCONFIG sc, wcs.STOREENT se, wcs.SCHSTATUS ss LEFT JOIN wcs.SCHERRORLOG sl ON ss.SCSINSTREFNUM = sl.SCSINSTREFNUM 
WHERE sc.SCCJOBREFNUM = ss.SCSJOBNBR and sc.STOREENT_ID = se.STOREENT_ID and sc.SCCPATHINFO like '%AGEndecaProductFeed%' and SCCACTIVE = 'A' order by ss.SCSEND DESC;



cat group
------------------------------------------------------------

SELECT distinct(cat.partnumber) ,
catgrpdesc.name as salescategory , 
clg.identifier,
(select identifier from  catgroup where catgroup_id=(select catgroup_id_parent from catgrprel where catgroup_id_child=cg1.catgroup_id)) as ParentCategory,
cat.buyable,
catentdesc.published,
cat.markfordelete ,
catentdesc.auxdescription1,
xcatentry.erp_prod_type,
xcatentry.inc_in_srch_rslts
FROM catgroup cg1,catgpenrel cgpr,catentry cat, catalog clg,catgrprel cgr , catentdesc,xcatentry,catgrpdesc
WHERE 
cg1.catgroup_id = cgpr.catgroup_id 
AND cat.catentry_id = cgpr.catentry_id
--AND cat.partnumber IN ('DGT25')
AND clg.catalog_id = cgpr.catalog_id
AND catentdesc.catentry_id = cat.catentry_id
AND catentdesc.language_id = -1
AND xcatentry.catentry_id = cat.catentry_id
AND clg.identifier = 'AG'
AND catgrpdesc.catgroup_id =cg1.catgroup_id
AND catgrpdesc.language_id = -1
AND catgrpdesc.name IN ('Girl of the Year: Lea') 
order by cat.partnumber


SELECT c.catentry_id,
  c.partnumber,
  cg.catgroup_id,
  cg.identifier
FROM catentry c,
  catgpenrel cgr,
  catgroup cg
WHERE c.catentry_id=cgr.catentry_id
AND cgr.catgroup_id=cg.catgroup_id
AND c.partnumber  IN('DVF57','DVF58','FDB39','FDB40','DWJ46','FBR36','FDD44','FDD43','DYX63','DYX64','DYX32','DYX41','DYX40','DYX39')
AND cgr.CATALOG_ID = 10001
;

  SELECT catentry.partnumber,xcatentry.ERP_PROD_TYPE,catentry.CATENTTYPE_ID,ITEMSPC_ID FROM catentry,xcatentry 
  WHERE
  catentry.catentry_id = xcatentry.catentry_id
  AND catentry.partnumber IN ('FJF36','FNH39');

  
  

Inventory

SELECT catentry.partnumber,inventory.quantity,xinventory.status,inventory.inventoryflags
FROM inventory, xinventory , catentry 
WHERE 
inventory.catentry_id = xinventory.catentry_id
AND xinventory.catentry_id =catentry.catentry_id
AND catentry.partnumber IN (
'DFN61DS','DFN62DS','DFN63DS','DFN64DS','DFN65DS','DFN67DS'
)
UNION ALL
SELECT catentry.partnumber,inventory.quantity,xinventory.status,inventory.inventoryflags
FROM inventory, xinventory , catentry, catentrel , catentry parentitem
WHERE 
inventory.catentry_id = xinventory.catentry_id
AND xinventory.catentry_id = catentry.catentry_id
AND catentrel.CATENTRY_ID_CHILD = catentry.CATENTRY_ID
AND parentitem.CATENTRY_ID = catentrel.CATENTRY_ID_PARENT
AND parentitem.partnumber IN ('DFN61DS','DFN62DS','DFN63DS','DFN64DS','DFN65DS','DFN67DS');



DELETE
FROM inventory
WHERE catentry_id IN
  (SELECT b.catentry_id
  FROM catgpenrel a,
    inventory b
  WHERE a.catalog_id IN (10101,10102,10103,10104,11601)
  AND b.catentry_id   = a.CATENTRY_ID
  AND b.store_id      = 10151
  )
AND store_id = 10651; -- AG records


DELETE
FROM xinventory
WHERE catentry_id IN
  (SELECT b.catentry_id
  FROM catgpenrel a,
    xinventory b
  WHERE a.catalog_id IN (10101,10102,10103,10104,11601)
  AND b.catentry_id   = a.CATENTRY_ID
  AND b.store_id      = 10151
  )
AND store_id = 10651 -- AG records;



UPDATE inventory SET inventoryflags = 1 WHERE catentry_id = (SELECT catentry_id FROM catentry WHERE catentry.partnumber = 'BLR21' );



INSERT INTO inventory (CATENTRY_ID,QUANTITY,FFMCENTER_ID, STORE_ID,QUANTITYMEASURE,INVENTORYFLAGS,OPTCOUNTER)
SELECT CATENTRY_ID,24,10651,10651,'C62',0,1 FROM CATENTRY WHERE partnumber = 'FKM88'; 

INSERT INTO xinventory (CATENTRY_ID,FFMCENTER_ID,STORE_ID,status,BACKORDERDATE,OPTCOUNTER, LOW_INV_THRSHLD)
SELECT CATENTRY_ID,10651,10651,'B', TO_TIMESTAMP ('23-JUN-17 00:00:00.000000', 'DD-Mon-RR HH24:MI:SS.FF') BACKORDERDATE,1,100 FROM CATENTRY WHERE partnumber = 'FKM88'; 

-------------

PDS

select * from xinbndmsgstore where request like '%87558940%' and lastupdated >'01-Jun-15';

Queue
-------------
SELECT o.orders_id , x.NAME ,xqord.status
FROM orders o, xqueueord xq , xqueue x , xqueueordstatus xqord 
WHERE o.orders_id =xq.orders_id 
AND x.xqueue_id = xq.xqueue_id 
AND xqord.xqueueord_id =   xq.xqueueord_id 
AND x.NAME = 'Party Id was Unavailable'  
AND xqord.status <>  'REMOVED'
AND o.timeplaced IS NOT NULL
AND o.timeplaced > sysdate - 30;



Order details
--------------------------------
select o.orders_id as orders_id, 
oi.orderitems_id,
oi.partnum,
oi.supplierdata,
(o.totalproduct + o.totaltax + o.totalshipping + o.totaltaxshipping + o.totaladjustment) as ordertotal,
u.field1 as partyId,
billto.firstname,
billto.lastname,
billto.address1,
billto.city,
billto.state,
billto.country,
billto.phone1,
billto.zipcode,
shipTo.firstname as shipToFistName, 
shipTo.lastname as shipToLastName, 
shipto.address1,
shipto.city,
shipto.state,
shipto.country,
shipto.phone1,
shipto.zipcode,
shipTo.email1 as shiptoEmail
FROM 
orders o join orderitems oi  on o.orders_id= oi.orders_id
join users u on u.users_id = o.member_id
left join address ShipTo on  ShipTo.address_id = oi.address_id 
left join address billTo on  o.address_id = billTo.address_id
where o.orders_id IN ( 
92125968
);

unlocking account
-------------------------------- 

update userreg set status=1, passwordexpired=0, passwordretries=0,passwordcreation=sysdate, passwordinvalid=null where logonid='balgurin';

SELECT logonid,decode(PASSWORDEXPIRED,1,'expired',0,'not expired') expired,PASSWORDCREATION,PASSWORDRETRIES,PASSWORDINVALID FROM userreg where logonid LIKE '%SWRONIUK@GMAIL.COM%'
UNION
SELECT logonid,decode(PASSWORDEXPIRED,1,'expired',0,'not expired') expired,PASSWORDCREATION,PASSWORDRETRIES,PASSWORDINVALID FROM userreg where logonid LIKE '%hanu.test01@gmail.com%';


Query to fetch address/party details:
----------------------

SELECT
  distinct
  o.orders_id AS orders_id,
  U.USERS_ID                 AS users_id,
  u.field1                   AS userpartyId,
  billto.field1              AS billpartyid,
  billTo.firstname           AS BillTo_FirstName,
  billTo.lastname            AS BillTo_LastName,
  shipto.field1              AS shipToPartyId,
  shipto.firstname           AS shipToFirstName,
  shipto.lastname            AS shipToLastname,
  billTo.address_id          AS BillTo_Address_id,
  billTo.status              AS BILLTO_STATUS,
  ShipTo.address_id          AS ShipTo_Address_id,
  shipto.status              AS SHIPTO_STATUS,
  billto.address1            AS baddress1,
  billto.ADDRESS2            AS BADDRESS2,
  billto.city                AS bcity,
  billto.STATE               AS BSTATE,
  billto.ZIPCODE             AS BZIPCODE,
  shipto.address1            AS saddress,
  shipto.ADDRESS2            AS SADDRESS2,
  shipto.city                AS scity,
  shipto.STATE               AS sSTATE,
  shipto.ZIPCODE             AS sZIPCODE,
  o.totalproduct,
  o.totalshipping,
  o.totaltax,
  o.totaltaxshipping,
  o.timeplaced,
  o.lastupdate,
  o.status,
  o.field3,  
  u.registertype,
  u.registration  
FROM orders o,
  orderitems oi,
  users u,
  address ShipTo,
  address billTo  
WHERE o.timeplaced   IS NOT NULL
AND oi.orders_id      = o.orders_id
AND u.users_id        = o.member_id
AND o.address_id      = billTo.address_id
AND ShipTo.address_id = oi.address_id
AND o.orders_id =94737681;

--------------------------------

Payment Related Queries:

select *from ppcpayinst where paymentsystemname not like 'CreditCardPaymentSystem';
select * from edporder where order_id = ?;
select * from edppayinst where edporder_id in (select edporder_id from edporder where order_id = ?);
select * from edpatmpay where edppayinst_id in (select edppayinst_id from edppayinst where edporder_id in ( select edporder_id from edporder where order_id = ?));
select * from edppayhist where order_id = ?;
select * from edprelease where edporder_id in (select edporder_id from edporder where order_id = ? );
 
select * from ppcpayinst where order_id = ?;
select * from ppcpayment where ppcpayinst_id in (select ppcpayinst_id from ppcpayinst where order_id = ?);
select * from ppcpaytran where ppcpayment_id in (select ppcpayment_id from ppcpayment where ppcpayinst_id in (select ppcpayinst_id from ppcpayinst where order_id = ?));
select * from ppcextdata where ppcpayinst_id in (select ppcpayinst_id from ppcpayinst where order_id = ? AND STATE = 1);

 
SELECT  
  o.orders_id, 
  o.timeplaced, 
  ppcpayinst.ppcpayinst_id,
  ppcpaytran.requestedamount, 
  ppcpaytran.processedamount, 
  ppcpaytran.state, 
  ppcpaytran.responsecode, 
  ppcpaytran.reasoncode, 
  referencenumber, 
  ppcpaytran.trackingid, 
  ppcextdata.searchvalue as cvv, 
  ppcextdata1.searchvalue as token   
FROM ppcpaytran, 
  ppcpayment, 
  ppcpayinst, 
  orders o, 
  ppcextdata ppcextdata, 
  ppcextdata ppcextdata1 
WHERE ppcpayinst.order_id    =o.orders_id 
AND ppcpayment.ppcpayinst_id = ppcpayinst.ppcpayinst_id 
AND ppcpayment.ppcpayment_id = ppcpaytran.ppcpayment_id  
AND ppcextdata.ppcpayinst_id = ppcpayinst.ppcpayinst_id 
AND ppcextdata.attributename ='cc_cvc'  
AND ppcextdata1.ppcpayinst_id = ppcpayinst.ppcpayinst_id 
AND ppcextdata1.ppcpayinst_id = ppcpayinst.ppcpayinst_id 
AND ppcextdata1.attributename ='token'  
AND ppcpayinst.state = 1
AND o.orders_id = 94570222 
order by orders_id desc;




select i.order_id, o.status, p.expectedamount, p.approvedamount, t.requestedamount, t.processedamount,
e.attributename, e.searchvalue, t.state, t.timecreated,
t.responsecode, t.reasoncode, t.referencenumber, t.trackingid,
p.ppcpayment_id, p.ppcpayinst_id, p.ppcpaytran_id
from ppcpaytran t
join ppcpayment p on p.ppcpayment_id = t.ppcpayment_id
join ppcpayinst i on i.ppcpayinst_id = p.ppcpayinst_id
join ppcextdata e on e.ppcpayinst_id = i.ppcpayinst_id
join orders o on o.orders_id = i.order_id
where i.state = 1 and i.paymentsystemname = 'CreditCardPaymentSystem'
and e.attributename = 'cc_brand' and e.searchvalue = 'AMEX'
and t.timecreated >= to_timestamp('01-07-2017 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
order by t.timecreated desc, p.ppcpayinst_id;





SELECT pi.PPCPAYINST_ID,
  pi.STATE,
  p.PPCPAYMENT_ID,
  ppt.PPCPAYTRAN_ID,
  decode (ppt.transactiontype,0 , 'APPROVE', 4,'REVERSE_APPROVAL',ppt.transactiontype)transactiontype,
  ppt.requestedamount,
  ppt.processedamount ,
  ppt.TIMECREATED,
  ppt.REASONCODE,
  ppt.RESPONSECODE,
  ppt.STATE transactionstatus,
  ppt.TRACKINGID,
  ppt.REFERENCENUMBER
FROM wcs.ppcpayinst pi,
  wcs.ppcpayment p,
  wcs.ppcpaytran ppt
WHERE 
pi.paymentsystemname='CreditCardPaymentSystem'
AND pi.ppcpayinst_id      =p.ppcpayinst_id
AND p.PPCPAYMENT_ID   =ppt.PPCPAYMENT_ID
and ppt.state=2
AND pi.order_id = 1410530389;

select * from wcs.ppcpaytran where PPCPAYTRAN_ID = 1337940;
SELECT * FROM WCS.ppcpayment where PPCPAYTRAN_ID = 2456940;

select o.orders_id from wcs.orders o where o.timeplaced is not null and o.timeplaced > TO_TIMESTAMP ('01-Aug-17 00:00:00.000000', 'DD-Mon-RR HH24:MI:SS.FF')
and o.orders_id in (select pi.order_id from wcs.ppcpayinst pi, wcs.ppcpayment p, wcs.ppcpaytran ppt where  pi.paymentsystemname='CreditCardPaymentSystem' 
and pi.ppcpayinst_id=p.ppcpayinst_id and p.ppcpaytran_id=ppt.ppcpaytran_id and ppt.state=2 and ppt.referencenumber is null);



xecom
--------------------------------

SELECT o.orders_id,outerloop.m_ecommsg_id,outerloop.timecreated,o.timeplaced
FROM XECOM.m_ecommsg outerloop, orders o,
(
SELECT reference_id,count(*) FROM xecom.m_ecommsg
group by reference_id having count( *) > 1
order by reference_id

) t 
WHERE outerloop.reference_id = t.reference_id 
AND o.orders_id = outerloop.reference_id
AND to_char(o.timeplaced,'dd-mon-yyyy') = '10-jun-2015'
order by  outerloop.reference_id,outerloop.timecreated desc;


----------------
xbom relation

SELECT * FROM catentry WHERE  catentry_id in (

  SELECT x_bomrelationship.childitemnumber FROM x_bomrelationship , catentry 
  WHERE   
  x_bomrelationship.parentitemnumber = catentry.catentry_id
  AND catentry.partnumber  = 'DMK58'
  AND (x_bomrelationship.effectiveenddate is null or x_bomrelationship.effectiveenddate > sysdate)
  AND (x_bomrelationship.effectivestartdate <= sysdate)

);


--bundle
SELECT * FROM catentry WHERE  catentry_id in (

SELECT catentrel.catentry_id_child FROM catentrel WHERE catentry_id_parent = (SELECT catentry_id FROM catentry WHERE partnumber= '05BUN12')

);

delete from x_bomrelationship where parentitemnumber in (select catentry_id from catentry where partnumber = 'DTC10');



UPDATE catentry SET catentrype_id = 'PackageBean' WHERE catentry_id = 428502;
update wcs.xcatentry x set x.erp_prod_type = 'STKT' where x.catentry_id in (select c.catentry_id from wcs.catentry c where c.catenttype_id = 'PackageBean') and x.erp_prod_type = 'SET'; 



-------------- 


delete attribue

SELECT cat.partnumber,att.identifier,catattr.usage,cat.catentry_id,att.attr_id, 
('delete FROM catentryattr where catentry_id= ' || cat.catentry_id || ' and attr_id= ' || att.attr_id) deletescript
FROM catentryattr catattr, catentry cat, 
attr att
WHERE catattr.catentry_id = cat.catentry_id
AND att.attr_id = catattr.attr_id
AND cat.partnumber in (

) and catattr.usage = 1;


--Select attribute


SELECT catentry.partnumber,attr.identifier,attrval.identifier  , attrvaldesc.value
FROM catentryattr , catentry , attr , attrval,ATTRVALDESC
WHERE 
catentry.partnumber = 'BLR21' 
AND catentryattr.catentry_id = catentry.catentry_id
AND catentryattr.attr_id = attr.attr_id
AND attrval.attrval_id = catentryattr.attrval_id
AND attrval.attrval_id = ATTRVALDESC.attrval_id
AND attrvaldesc.language_id = -1;
-----------------


UPDATE xecom.m_ecommsg set message=replace(message, '<mat:queueName>Ship-to</mat:queueName>', '<mat:queueName>Check Ship-To Customer</mat:queueName>') where reference_id  IN (XXX );

UPDATE xecom.m_ecommsg set STATUS = 'P', TIMECREATED = SYSTIMESTAMP, TIMEPROCESSED = null, COMMENTS = null where reference_id  IN (XXX );


-----------------

Order count

SELECT 
orderitems.orders_id, orders.lastupdate,orders.status,orders.storeent_id,storeent.identifier,
count(*) count FROM orderitems,orders,storeent
WHERE orders.orders_id = orderitems.orders_id
AND orders.lastupdate  >  sysdate - 15
AND orders.storeent_id = storeent.storeent_id
group by orderitems.orders_id, orders.storeent_id, orders.status, orders.lastupdate,storeent.identifier having count(*) > 15 
order by orders.lastupdate desc; 


SELECT
orderitems.partnum,orders.status,count(*)
FROM orderitems,orders,storeent
WHERE orders.orders_id = orderitems.orders_id
AND orders.lastupdate  >  sysdate - 1
AND orders.storeent_id = storeent.storeent_id
AND orderitems.partnum IN ('DTC05','DTC06','DTC07','DTC08','DTC09','DTC10','DTC11','DTC12','DTC13','DTC14','DTD21')
AND orders.status IN ('M','G','F','B')
group by orderitems.partnum,orders.status
order by orderitems.partnum desc; 


SELECT orders.orders_id,
  orderitems.partnum,
  orders.status,
  (orders.totalproduct + orders.totaltax + orders.totalshipping + orders.totaltaxshipping + orders.totaladjustment) as total
FROM orderitems,
  orders,
  storeent,
  ORDADJUST
WHERE orders.orders_id  = orderitems.orders_id
AND orders.storeent_id  = storeent.storeent_id
AND ORDADJUST.ORDERS_ID = orders.ORDERS_ID
AND ORDADJUST.CALCODE_ID = 40653
AND orders.status <> 'X'
ORDER BY orders.TIMEPLACED desc;


--------------

charge & send

SELECT orders.* FROM orders , xorders 
WHERE 
orders.orders_id = xorders.orders_id
AND xorders.xordertype_id = 6 
order by timeplaced desc;
----------
Sets missing components

select 
--oi.partnum,
count(1),
o.orders_id
--select o.*
from wcs.orders o,
wcs.orderitems oi,
wcs.xorders xo
where o.timeplaced >= trunc(sysdate)-1
and o.orders_id = oi.orders_id
and o.status  IN ('P','M')
and o.orders_id = xo.orders_id
and oi.partnum IN ('DTD12',
'DTD26',
'DTD27',
'DTD28',
'DTD29',
'DPR40',
'DPR41',
'DPR45',
'DPR46',
'DTD39')               
AND not exists (select 'x' from wcs.orderitems oi2, WCS.x_bomrelationship xb where oi.catentry_id = xb.parentitemnumber and xb.childitemnumber = oi2.catentry_id and oi2.orders_id = oi.orders_id)
--group by o.status
--group by oi.partnum
group by o.orders_id
--group by xo.order_source
--order by decode(o.status,'E',0,'M',1,'B',2,'W',3,'F',4,'G',5)
;

select 
distinct o.orders_id,O.status,o.timeplaced
from wcs.orders o,
wcs.orderitems oi
where 
o.orders_id = oi.orders_id
and o.status  IN ('M','I')
and timeplaced is  not null
and o.storeent_id = 10151
and trunc(o.timeplaced) = '02-SEP-15'
and oi.partnum IN (
'DTM59',
'DTM60',
'DTM61',
'DTM62',
'DTM63',
'DTM64',
'DTM65',
'DTM66',
'DTM67',
'DTM68',
'DTM69',
'DTM70',
'DTM71',
'DTM72',
'DTM73',
'DTM74',
'DTM75',
'DTN19',
'DTN20',
'DTN21',
'DTN22'
);            



SELECT  distinct o.orders_id
,xqueueord.xqueueord_id, xqueue.name,xqueueordstatus.status
FROM orders o
JOIN orderitems oi 
ON (o.orders_id   = oi.orders_id)
LEFT JOIN xqueueord ON (o.orders_id = xqueueord.orders_id) 
JOIN xqueueordstatus ON (xqueueordstatus.xqueueord_id =xqueueord.xqueueord_id )
JOIN xqueue ON xqueueord.xqueue_id = xqueue.xqueue_id
WHERE o.orders_id = oi.orders_id
AND o.status     IN ('M','I','W')
AND timeplaced   IS NOT NULL
AND o.storeent_id = 10151
AND oi.partnum   IN ( 'DTM59', 'DTM60', 'DTM61', 'DTM62', 'DTM63', 'DTM64', 'DTM65', 'DTM66', 'DTM67', 'DTM68', 'DTM69', 'DTM70', 'DTM71', 'DTM72', 'DTM73', 'DTM74', 'DTM75', 'DTN19', 'DTN20', 'DTN21', 'DTN22' )
ORDER BY orders_id, xqueue.name;


--------------

SELECT mbrattr.description,mbrattrval.stringvalue FROM mbrattr , mbrattrval ,address 
WHERE
mbrattr.mbrattr_id = mbrattrval.mbrattr_id
AND address.member_id =mbrattrval.member_id
AND address.email1 = 'simpletest1@test.com';

SIGN_UP_FOR_EMAIL


SELECT DISTINCT USERREG.USERS_ID,
  address.email1 ,
  mbrattr.NAME ,
  mbrattr.description,
  mbrattrval.stringvalue
FROM mbrattr ,
  mbrattrval ,
  address ,
  USERREG
WHERE USERREG.USERS_ID = address.member_id
AND address.email1    IS NOT NULL
AND address.member_id  = mbrattrval.member_id
AND mbrattr.mbrattr_id = mbrattrval.mbrattr_id
  --AND mbrattr.NAME           IN ('DO_NOT_SHARE','CATALOG_MAIL_PREFERENCE','SIGN_UP_FOR_EMAIL')
AND mbrattrval.stringvalue IS NOT NULL
AND USERREG.USERS_ID        = 66669700 ;
SELECT * FROM USERS WHERE FIELD1 = '126353607';

-----------

SELECT totalproduct, totaltax,totalshipping,totaltaxshipping,totaladjustment , (totalproduct + totaltax + totalshipping + totaltaxshipping + totaladjustment) as total FROM orders WHERE orders_id = 92107209;

SELECT  price,totalproduct,taxamount,totaladjustment,shipcharge, shiptaxamount, (price + totalproduct + taxamount + totaladjustment + shipcharge + shiptaxamount ) as totla from orderitems  where orders_id = 92107209;

---------
SELECT rmaitem.rmaitem_id,creditamount, totalcredit ,xrmaitax.*
FROM rmaitem  LEFT JOIN xrmaitax 
ON rmaitem.rmaitem_id = xrmaitax.rmaitem_id
AND rmaitem.rmaitem_id = xrmaitax.rmaitem_id 
WHERE rmaitem.rma_id = 84057944;
------------


promotions
---

SELECT 
--px_cdpromo.px_cdpool_id , 
--xpromocdusage.redeem_time,
px_promotion.name, 
xpromocdusage.promotion_code,
count(*)
FROM px_promotion ,
  px_cdpromo,
  xpromocdusage ,
  px_cdpool 
WHERE px_promotion.px_promotion_id = px_cdpromo.px_promotion_id
AND xpromocdusage.px_cdpool_id = px_cdpromo.px_cdpool_id
--AND trunc(xpromocdusage.redeem_time) > '17-Sep-15'
AND px_cdpool.px_cdpool_id = px_cdpromo.px_cdpool_id
AND px_cdpool.code LIKE '%SAVE20NOW%'
AND xpromocdusage.redeem_channel = 'online'
group  by px_promotion.name,xpromocdusage.promotion_code;
;


SELECT * FROM px_cdpool WHERE PX_CDPOOL_ID IN (

SELECT px_cdpool_id FROM PX_CDPROMO WHERE px_promotion_id  = 10106502
) AND status = 1 ;



workspace
------------- 

SELECT * FROM  cmftaskdsc  where NAME like '%2015-09-08 BLR23%';
ALTER SESSION SET CURRENT_SCHEMA = WCW106;
SELECT * FROM CMFWKSPC;
SELECT * FROM CMFWKSPCDSC WHERE name = 'MattelBrands_Production';
SELECT * FROM CMFWSTGREL where cmfwkspc_id = 14001;
SELECT * FROM CMFTASKGRP WHERE identifier = 'G_42002';
SELECT * FROM CMFTGDSC WHERE NAME '%%';

hourly count
---------
SELECT  TO_CHAR (TRUNC (timeplaced, 'HH'), 'DD-MON-YYYY HH24:MI:SS') hour, count(*) FROM orders 
WHERE storeent_id = 10151 
AND trunc(timeplaced) =  '05-DEC-2015'
AND status !='J'
group by TO_CHAR (TRUNC (timeplaced, 'HH'), 'DD-MON-YYYY HH24:MI:SS') 
order by TO_CHAR (TRUNC (timeplaced, 'HH'), 'DD-MON-YYYY HH24:MI:SS') 
;
-----


SELECT mbrgrp.mbrgrpname,  SUBSTR(userreg.logonid,instr(userreg.logonid, '|')+1 , length(userreg.logonid)+1 ) logon ,users.FIELD1 as account
FROM mbrgrp, mbrgrpmbr, userreg, users
WHERE mbrgrp.mbrgrp_id =mbrgrpmbr.mbrgrp_id
AND mbrgrp.MBRGRP_ID IN (8000000000000004051,8000000000000004052,8000000000000004061 )
AND userreg.users_id =mbrgrpmbr.member_id 
AND users.USERS_ID = userreg.users_id 
;

SELECT 
USERREG.USERS_ID,
USERREG.USERS_ID,
ORDERS.ORDERS_ID, 
ORDERITEMS.ORDERITEMS_ID,
ORDERITEMS.PARTNUM, 
ORDERITEMS.QUANTITY,
ADDRESS.FIRSTNAME, 
ADDRESS.LASTNAME
FROM ORDERS ,ORDERITEMS, ADDRESS,USERREG
WHERE 
ORDERS.ORDERS_ID = ORDERITEMS.ORDERS_ID
AND ORDERS.MEMBER_ID = ADDRESS.MEMBER_ID
AND ORDERS.MEMBER_ID = USERREG.USERS_ID
AND ORDERS.ORDERS_ID IN (1408582887,1408038561,1407936116,1408577903,1408082159,1408020247,1408038560,1408020254,1407942046,1403353834)
; 





-------
SEO URL

SELECT  catentry.partnumber,seourlkeyword.urlkeyword,seourlkeyword.language_id  
FROM seourlkeyword,seourl,catentry 
WHERE 
seourlkeyword.seourl_id = seourl.seourl_id
AND (seourl.tokenvalue) = TO_CHAR(catentry.catentry_id)
AND seourl.tokenname = 'ProductToken'
AND catentry.partnumber ='DGT25' 
AND status = 1;


---
return order 

select distinct rit.rmaitem_id orderitemid, rit.lastupdate,dispcode.description dispositioncode, r.rma_id orderid, cat.partnumber sku,xrit.dashcode,rit.quantity 
from catentry cat
inner join rmaitem rit on rit.catentry_id = cat.catentry_id
inner join rma r on r.rma_id = rit.rma_id
inner join RTNRECEIPT rtnr on rtnr.rma_id = r.rma_id
inner join rmaitemcmp  on rmaitemcmp.rmaitemcmp_id = rtnr.rmaitemcmp_id
and rmaitemcmp.rmaitem_id = rit.rmaitem_id
inner join xrmaitem xrit on xrit.rmaitem_id = rit.rmaitem_id
inner join RTNRCPTDSP rtnd on rtnd.rtnreceipt_id = rtnr.rtnreceipt_id
inner join RTNDSPCODE disp on disp.rtndspcode_id = rtnd.rtndspcode_id
inner join rtndspdesc dispcode on dispcode.rtndspcode_id = disp.rtndspcode_id
where 
--trunc(rit.lastupdate) >= '01-MAY-15'
--and trunc(rit.lastupdate) < '01-JUN-15'
r.rma_id=84056105
order by r.rma_id, rit.lastupdate;

-------

SELECT Jurst.* FROM JURSTGROUP , JURSTGPREL , Jurst
WHERE jurstgroup.jurstgroup_id = JURSTGPREL.jurstgroup_id
AND jurst.jurst_id = jurstgprel.jurst_id 
AND jurstgroup.description LIKE '%Country: Canada%' 
AND Jurst.STOREENT_ID = 10154;


SELECT 
SUBSTR(JURSTGROUP.CODE, 1,20) JURSTGROUP ,
decode ( shipmode.STOREENT_ID,10151,'Mattel',10651,'AG'  ) BRAND,
shipmode.carrier,
shipmode.code shipcode,
SHPMODEDSC.DESCRIPTION,
shipmode.TRACKINGURL
FROM WCS.SHIPMODE , WCS.SHPMODEDSC ,SHPJCRULE, JURSTGROUP
where 
shipmode.shipmode_id = SHPMODEDSC.shipmode_id 
--AND shipmode.STOREENT_ID = 10151
AND SHPMODEDSC.LANGUAGE_ID = -1 
AND SHPJCRULE.shipmode_id = shipmode.shipmode_id
AND JURSTGROUP.jurstgroup_id = SHPJCRULE.jurstgroup_id;

-----------------------------------------------------

SELECT calcode.code,calrule.identifier as calrulecode,
calscale.code as calscalecode,
calrange.rangestart ,
calrlookup.* 
FROM calcode , calrule,CRULESCALE,CALSCALE,calrange,calrlookup
WHERE calcode.calusage_id = -2 
AND calcode.storeent_id = 10154 
AND calcode.CODE = 'All Shippable Items' 
AND calscale.code = 'Fixed Delivery Charge - CA'
AND crulescale.calrule_id = calrule.calrule_id
AND calrule.calcode_id =calcode.calcode_id 
AND calscale.calscale_id = crulescale.calscale_id
AND calrange.calscale_id = calscale.calscale_id
AND calrlookup.calrange_id = calrange.calrange_id;



stag log
-----------

SELECT * FROM emspot WHERE emspot_id IN ( 97756);
SELECT * FROM dmemspotdef WHERE dmemspotdef_id = 94109;
SELECT * FROM collateral WHERE COLLATERAL_ID = 94759;
SELECT * FROM COLLDESC where COLLATERAL_ID = 94759;


SELECT * FROM esmapobj WHERE object_id = 63785;
SELECT * FROM INTVSCHED WHERE emspot_id = 63785;

SELECT * FROM DMEMSPOTDEF WHERE  emspot_id =83873;136702


SELECT * FROM staglog WHERE stgtable = lower('DMEMSPOTDEF') AND trunc(stgstmp) = '28-JAN-2016' and stgprocessed = 0 AND STGOKEY1 = '136702'  ;


massoccece
---
SELECT * FROM catentry where catentry_id IN (
SELECT catentry_id_from FROM massoccece WHERE massoctype_id = 'ADDONSERVICES' AND catentry_id_to = (SELECT catentry_id FROM catentry WHERE catentry.partnumber = 'GOTYEP')
);


Bundle
http://www.americangirl.com/shop/bitty-twins/girl-girl-bitty-twins-dolls-with-starter-set-04tbun01


Product count
---
SELECT orderitems.partnum,
sum(orderitems.quantity)
FROM orders , orderitems
WHERE 
orders.orders_id = orderitems.orders_id 
AND orderitems.partnum IN ( 'PFDR51' ,'PFFB59','PFND40')
AND orders.timeplaced IS NOT NULL 
group by orderitems.partnum
;

catentryattr
----
insert into catentryattr (CATENTRY_ID,ATTR_ID,ATTRVAL_ID,USAGE,SEQUENCE,OPTCOUNTER) VALUES (69090,7000000000000008040,7000000000000048362,1,0,1);
insert into catentryattr (CATENTRY_ID,ATTR_ID,ATTRVAL_ID,USAGE,SEQUENCE,OPTCOUNTER) VALUES (69090,7000000000000008041,7000000000000048259,1,0,1);


DELETE FROM catentryattr WHERE catentry_id IN (

) AND attr_id IN (7000000000000008041,7000000000000008040);

solr check
----

To identify if there is a catalog entry that has more than one parent category, run the following SQL query against the database:

select catentry_id, catgroup_id from catgpenrel where catentry_id in (select catentry_id from catgpenrel where catalog_id = <catalog_id> group by catentry_id having count(catentry_id) > 1)

where <catalogId> is the catalog ID value for which di-preprocess is being run.

The above query will provide a list of catalog entry IDs and the categories that they are mapped to if they are mapped to more than one category in the master catalog ID.

To identify if the issue is caused by a category having multiple parent categories in the master catalog, run the following SQL query against the database:

select catgroup_id_parent, catgroup_id_child from catgrprel where catalog_id = <catalogId> and catgroup_id_child in (select catgroup_id_child from catgrprel where catalog_id = <catalogId> group by catgroup_id_child having count(catgroup_id_child) > 1)




SELECT * FROM PLWIDGET	
SELECT * FROM PLWIDGETDEF	
SELECT * FROM PLWIDGETDEFDESC	
SELECT * FROM PAGELAYOUT	
SELECT * FROM PLWIDGETNVP	
SELECT * FROM PLWIDGETREL	
SELECT * FROM PLWIDGETSLOT	
SELECT * FROM PLLOCATION	
SELECT * FROM PLTEMPLATEREL	


SELECT ORDERS.orders_id,ORDERITEMS.PARTNUM,SHIPMODE.CARRIER,SHIPMODE.code
FROM ORDERS, ORDERITEMS,ADDRESS ,SHIPMODE WHERE
ORDERS.ORDERS_ID = ORDERITEMS.ORDERS_ID
AND ORDERITEMS.ADDRESS_ID = ADDRESS.ADDRESS_ID
AND ORDERITEMS.SHIPMODE_ID =SHIPMODE.SHIPMODE_ID
AND (ADDRESS.COUNTRY = 'CA' OR ADDRESS.COUNTRY = 'Canada') 
AND orders.timeplaced > sysdate -10
;


SELECT DECODE (MERCHCONF.MERCHANT_ID , 10001, 'Mattel', 10002,'AG' ) MERCHANT,
  WCS.MERCHCONFINFO.MERCHCONFINFO_ID,
  MERCHCONF.PAYMENTSYSTEM,
  MERCHCONFINFO.PROPERTY_VALUE
FROM WCS.MERCHCONFINFO,
  MERCHCONF
WHERE PROPERTY_NAME            = 'merchantNumber'
AND MERCHCONFINFO.MERCHCONF_ID = MERCHCONF.MERCHCONF_ID ;


select * from pagelayout where name='FP Shop Landing Layout';
select * from plwidget where pagelayout_id=11210;
select * from PLWIDGETDEF where plwidgetdef_id=1058;
select * from PLSTOREWIDGET where plwidgetdef_id=1058;
select * from PLWIDGETREL where plwidget_id_parent=1058;
select * from plwidget where pagelayout_id in(select pagelayout_id from pagelayout where name='FP Shop Landing Layout');
select * from PLWIDGETDEF where plwidgetdef_id in(select plwidgetdef_id from plwidget where pagelayout_id in(select pagelayout_id from pagelayout where name='FP Shop Landing Layout')); 

SELECT 
  SUBSTR(USERREG.LOGONID, INSTR(USERREG.LOGONID,'|')+1, length(userreg.logonid)+1 ) LOGIN,
  GRGFTREG.NAME ,
  GRGFTREG.CREATEDTIME,
  GRGFTREG.DESCRIPTION ,
  GRGFTITM.PARTNUMBER 
FROM GRGFTREG ,
  GRGFTITM ,
  GRRGSTRNT ,
  USERREG
WHERE GRGFTREG.GIFTREGISTRY_ID = GRGFTITM.GIFTREGISTRY_ID
AND GRRGSTRNT.GIFTREGISTRY_ID  = GRGFTREG.GIFTREGISTRY_ID
AND GRRGSTRNT.USERID           = USERREG.users_id
AND GRGFTITM.PARTNUMBER        ='FPN63';


