SELECT 
    a.seqmarca                  AS  codmarca,       --> Código 
    a.marca                     AS  marca,          --> Descrição
    a.status,
    TO_DATE(datahoraalteracao)  AS  dtaalteracao
FROM implantacao.map_marca a
WHERE 1 = 1
ORDER BY 1 ASC;