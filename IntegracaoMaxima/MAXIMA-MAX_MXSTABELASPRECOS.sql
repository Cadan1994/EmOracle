SELECT
    DISTINCT
    LPAD(a.seqproduto,6,0)             AS  codprod,             --> Código do produto
    LPAD(a.nroempresa,1,0)
    ||
    LPAD(a.nrosegmento,2,0)
    ||
    LPAD(b.nrotabvenda,3,0)            AS  numregiao,           --> Código
    MAX(
    ROUND(
    TRUNC(
    NVL(
    CASE
    WHEN TRUNC(a.precogerpromoc) = 0
    THEN ROUND(a.precogernormal,6)+
         (ROUND(a.precogernormal,6)*
         ROUND(d.peracrtributario,6)/100)
    ELSE ROUND(a.precogerpromoc,6)+
         (ROUND(a.precogerpromoc,6)*
         ROUND(d.peracrtributario,6)/100)
    END,0),6)/c.qtdembalagem,6))      AS  pvenda,             --> Preço de venda do produto sem impostos matriz
    MAX(
    ROUND(
    TRUNC(
    NVL(
    CASE
    WHEN TRUNC(a.precogerpromoc) = 0
    THEN ROUND(a.precogernormal,6)+
         (ROUND(a.precogernormal,6)*
         ROUND(d.peracrtributario,6)/100)
    ELSE ROUND(a.precogerpromoc,6)+
         (ROUND(a.precogerpromoc,6)*
         ROUND(d.peracrtributario,6)/100)
    END,0),6)/c.qtdembalagem,6))       AS  pvenda1,             --> Preço de venda do produto sem impostos matriz
    0                                  AS  vlst,                --> Destinado ao valor de ST, caso seja aplicado
    NVL(c.percmaxdescflex,0)           AS  perdescmax,          --> Define o maior desconto permitido para o produto
    NVL(c.percmaxdescflex,0)           AS  perdescmaxbalcao,  
    NVL(c.percmaxacrflex,0)            AS  peracrescmax,
    NVL(c.nrotributacao,0)||16         AS  codst,               --> Código da tributação aplicada ao produto
    0                                  AS  vlipi,               --> Valor do IPI
    0                                  AS  vlultentmes,         --> Valor do preço de última entrada do produto
    MAX(
    ROUND(
    TRUNC(
    NVL(
    CASE
    WHEN TRUNC(a.precogerpromoc) = 0
    THEN ROUND(a.precogernormal,6)+
         (ROUND(a.precogernormal,6)*
         ROUND(d.peracrtributario,6)/100)
    ELSE ROUND(a.precogerpromoc,6)+
         (ROUND(a.precogerpromoc,6)*
         ROUND(d.peracrtributario,6)/100)
    END,0),6)/c.qtdembalagem,6))       AS  ptabela,             --> Preço de tabela
    'N'                                AS  calcularipi,         --> Indica se produto foi calculado com IPI (S ou N)
    'A'                                AS  status,
    MAX(TO_DATE(e.dtaalteracao))       AS  dtaalteracao
FROM implantacao.mrl_prodempseg a
INNER JOIN implantacao.mad_segtabvenda b 
ON b.nrosegmento = a.nrosegmento AND b.status = 'A' AND b.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
INNER JOIN (SELECT DISTINCT b.seqproduto,a.nrosegmento,a.percmaxacrflex,a.percmaxdescflex,c.nrotributacao,d.qtdembalagem 
            FROM implantacao.mad_famsegmento a
            INNER JOIN implantacao.map_produto b 
            ON b.seqfamilia = a.seqfamilia
            INNER JOIN implantacao.map_famdivisao c 
            ON c.seqfamilia = b.seqfamilia
            INNER JOIN implantacao.map_prodcodigo d 
            ON d.seqfamilia = b.seqfamilia AND d.seqproduto = b.seqproduto AND d.indutilvenda = 'S' AND d.tipcodigo IN ('E','D')
            WHERE a.status = 'A'
            ORDER BY 1 ASC) c
ON c.nrosegmento = a.nrosegmento AND c.seqproduto = a.seqproduto
INNER JOIN implantacao.mad_tabvendatrib d ON d.nrotabvenda = b.nrotabvenda AND d.nrotributacao = c.nrotributacao
INNER JOIN (SELECT DISTINCT nrosegmento,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mrl_prodempseg
            WHERE statusvenda = 'A'
            GROUP BY nrosegmento
            UNION ALL
            SELECT nrosegmento,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mrl_clienteseg
            WHERE status = 'A'
            GROUP BY nrosegmento) e
ON e.nrosegmento = b.nrosegmento
WHERE 1 = 1
AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
AND a.statusvenda = 'A' AND a.seqproduto = 26262
GROUP BY a.nroempresa,a.nrosegmento,a.seqproduto,a.precogernormal,a.precogerpromoc,b.nrotabvenda,c.percmaxdescflex,c.percmaxacrflex,c.nrotributacao,d.peracrtributario
ORDER BY 1 ASC;
