--Price sql--
select o.catentry_id, l.listprice, o.offer_id,od.description, o.identifier, c.partnumber, op.price, o.tradeposcn_id,tp.name, o.startdate,o.enddate,o.published 
from WCS.offer o,WCS.listprice l, WCS.offerprice op, WCS.tradeposcn tp,WCS.offerdesc od, wcs.catentry c
where o.catentry_id = c.catentry_id
and o.catentry_id= l.catentry_id 
and o.offer_id= op.offer_id 
and o.tradeposcn_id= tp.tradeposcn_id 
and o.offer_id= od.offer_id
and o.published = 1
AND (c.partnumber IN ())
and sysdate between o.startdate and nvl(o.enddate,sysdate);   


