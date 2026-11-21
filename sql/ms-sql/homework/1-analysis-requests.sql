-- 1. Анализ закупки продукции

-- Связь документов со складскими операциями поступления
select * from bm_JournalBarnetDocs t1
left join (
    select DocumentID
    from bm_StorageOperations
    where OperationID = 1
    group by DocumentID
) t2 on t1.ID = t2.DocumentID;

-- Связь типов операций со складскими операциями и подсчет их количества
select * from bm_StorageOperationsType t1
left join (
    select OperationID, count(*) count
    from bm_StorageOperations
    group by OperationID
) t2 on t1.ID = t2.OperationID;

-- Связь товаров со складскими операциями поступления
select * from product t1
left join (
    select ProductID
    from bm_StorageOperations
    where OperationID = 1
    group by ProductID
) t2 on t1.id = t2.ProductID;

-- Связь поставщиков со складскими операциями поступления
select * from vendors t1
left join (
    select VendorID
    from bm_StorageOperations
    where OperationID = 1
    group by VendorID
) t2 on t1.id = t2.VendorID;

-- Связь складов со складскими операциями поступления и количество поступлений
select * from storages t1
left join (
    select StorageID, count(*) count
    from bm_StorageOperations
    where OperationID = 1
    group by StorageID
) t2 on t1.id = t2.StorageID;

-- Общая цепочка поступления: операция, тип, документ, товар, поставщик и склад
select
    t1.ID StorageOperationID,
    t1.OperationID,
    t3.Description OperationName,
    t2.ID DocumentID,
    t2.DocumentNumber,
    t2.Period DocumentDate,
    t4.id ProductID,
    t4.description ProductName,
    t5.id VendorID,
    t5.firstname VendorName,
    t6.id StorageID,
    t6.description StorageName
from bm_StorageOperations t1
left join bm_JournalBarnetDocs t2
    on t1.DocumentID = t2.ID
left join bm_StorageOperationsType t3
    on t1.OperationID = t3.ID
left join product t4
    on t1.ProductID = t4.id
left join vendors t5
    on t1.VendorID = t5.id
left join storages t6
    on t1.StorageID = t6.id
where t1.OperationID = 1;



-- 2. Анализ продажи товара

-- в процессе разработки...



-- 3. Анализ взаимоотношений с поставщиками

-- в процессе разработки...



-- 4. Анализ работы персонала

-- в процессе разработки...



-- 5. Анализ остатков

-- в процессе разработки...
