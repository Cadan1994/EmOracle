SELECT 
    a.seqmarca                  AS  codmarca,       --> C�digo 
    a.marca                     AS  marca,          --> Descri��o
    a.status,
    TO_DATE(datahoraalteracao)  AS  dtaalteracao
FROM implantacao.map_marca a
WHERE 1 = 1
ORDER BY 1 ASC;