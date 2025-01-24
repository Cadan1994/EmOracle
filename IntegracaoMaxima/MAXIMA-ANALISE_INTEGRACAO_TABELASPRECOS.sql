SELECT
    DISTINCT
    LPAD(a.seqproduto,6,0)             AS  codprod,        --> Código do produto
    LPAD(a.nroempresa,1,0)
    ||
    LPAD(a.nrosegmento,2,0)
    ||
    LPAD(b.nrotabvenda,3,0)            AS  numregiao,            --> Código
    a.precogernormal,
    a.precogerpromoc,
    d.percdesconto,
    MAX(
    ROUND(
    NVL(
    CASE
    WHEN TRUNC(a.precogerpromoc) = 0
    THEN a.precogernormal 
         +((a.precogernormal 
         *d.percdesconto)/100)
    ELSE a.precogerpromoc 
         +((a.precogerpromoc 
         *d.percdesconto)/100)
    END,0),2))                         AS  pvenda,         --> Preço de venda do produto sem impostos matriz
    MAX(
    ROUND(
    NVL(
    CASE
    WHEN TRUNC(a.precogerpromoc) = 0
    THEN a.precogernormal 
         +((a.precogernormal 
         *d.percdesconto)/100)
    ELSE a.precogerpromoc 
         +((a.precogerpromoc 
         *d.percdesconto)/100)
    END,0),2))                   AS  pvenda1,        --> Preço de venda do produto sem impostos matriz
    0                       AS  vlst,           --> Destinado ao valor de ST, caso seja aplicado
    NVL(e.percmaxdescflex,0)       AS  perdescmax,     --> Define o maior desconto permitido para o produto
    NVL(e.percmaxacrflex,0)        AS  peracrescmax,
    '100116'                AS  codst,          --> Código da tributação aplicada ao produto
    0                       AS  vlipi,          --> Valor do IPI
    0                       AS  vlultentmes,    --> Valor do preço de última entrada do produto
    MAX(
    ROUND(
    NVL(
    CASE
    WHEN TRUNC(a.precogerpromoc) = 0
    THEN a.precogernormal 
         +((a.precogernormal 
         *d.percdesconto)/100)
    ELSE a.precogerpromoc 
         +((a.precogerpromoc 
         *d.percdesconto)/100)
    END,0),2))                   AS  ptabela,        --> Preço de tabela
    'N'                     AS  calcularipi,    --> Indica se produto foi calculado com IPI (S ou N)
    'A'                     AS  status
    --MAX(TO_DATE(f.dtaalteracao))     AS  dtaalteracao
FROM implantacao.mrl_prodempseg a
INNER JOIN implantacao.mad_segtabvenda b 
ON b.nrosegmento = a.nrosegmento AND b.status = 'A' AND b.nrotabvenda NOT IN (2,3,7,8,9,10,11,12,13,14,15,20,71,72,73,91,99,100,101,122,131,141,711,998,999)
INNER JOIN implantacao.mad_tabvendacond c 
ON c.nrotabvenda = b.nrotabvenda
INNER JOIN (SELECT DISTINCT a.nroempresa,a.seqpessoa,b.nrosegmento,b.nrotabvendaprinc,NVL(b.percacrdesccomerc,0) AS  percdesconto
            FROM implantacao.mrl_cliente a
            INNER JOIN implantacao.mrl_clienteseg b 
            ON b.seqpessoa = a.seqpessoa AND b.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            WHERE a.seqpessoa NOT IN (1, 22401)
            AND a.statuscliente = 'A') d
ON d.nroempresa = a.nroempresa AND d.nrosegmento = a.nrosegmento AND d.nrotabvendaprinc = b.nrotabvenda AND d.seqpessoa = 531
LEFT JOIN (SELECT DISTINCT b.seqproduto,a.nrosegmento,a.percmaxacrflex,a.percmaxdescflex 
            FROM implantacao.mad_famsegmento a
            INNER JOIN implantacao.map_produto b ON b.seqfamilia = a.seqfamilia
            WHERE a.status = 'A'
            ORDER BY 1 ASC) e
ON e.nrosegmento = a.nrosegmento AND e.seqproduto = a.seqproduto
/*
INNER JOIN (SELECT DISTINCT nrosegmento,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mrl_prodempseg
            WHERE statusvenda = 'A'
            GROUP BY nrosegmento
            UNION ALL
            SELECT nrosegmento,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_segtabvenda
            WHERE status = 'A'
            GROUP BY nrosegmento) f
ON f.nrosegmento = b.nrosegmento
*/
WHERE 1 = 1
AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
AND a.statusvenda = 'A'
AND a.seqproduto = 1996
GROUP BY a.nroempresa,a.nrosegmento,a.seqproduto,a.precogernormal,a.precogerpromoc,b.nrotabvenda,c.nrocondicaopagto,d.seqpessoa,d.percdesconto,e.percmaxdescflex,e.percmaxacrflex
ORDER BY 1 ASC, 2 ASC;