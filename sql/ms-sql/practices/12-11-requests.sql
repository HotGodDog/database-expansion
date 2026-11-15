SELECT * FROM [dbo].[product]

SELECT flaging, COUNT(*) cnt FROM [dbo].[product]
GROUP BY flaging

SELECT * from product
where flaging = 1
-- 1 Ингридиенты
-- 2 Полуфабрикаты



SELECT * from vendors
where id
    not in
    (
        select vendorId from product
        GROUP BY vendorid
    )



SELECT * from vendors t1
LEFT JOIN
    (
        select vendorId from product
        GROUP BY vendorid
    ) t2 on t1.id = t2.vendorId



SELECT * from vendors t1
RIGHT JOIN
    (
        select vendorId from product
        GROUP BY vendorid
    ) t2 on t1.id = t2.vendorId



SELECT * from category t1
LEFT JOIN
(
    select categoryId from product
    GROUP BY CategoryID
) as t2 
on t1.id = t2.CategoryID



SELECT * from category t1
RIGHT JOIN
(
    select categoryId from product
    GROUP BY CategoryID
) as t2 
on t1.id = t2.CategoryID



select * from size



SELECT * from size t1
LEFT JOIN
(
    select SizeID from product
    GROUP BY SizeID
) as t2 
on t1.id = t2.SizeID
