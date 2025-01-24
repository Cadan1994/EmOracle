SELECT
    LPAD(a.seqproduto,6,0)      AS  codprod,
    a.nroempresa                AS  codfilial,
    e.pmtdecimal                AS  aceitavendafracao,
    'S'                         AS  enviarforcavendas,
    d.vlrnultiplovda            AS  multiplo,
    NULL                        AS  proibidavenda,
    a.statuscompra              AS  status,
    TO_DATE(c.dtahoralteracao)  AS  dtaalteracao
FROM implantacao.mrl_produtoempresa a
INNER JOIN (SELECT DISTINCT nroempresa,seqproduto 
            FROM implantacao.mrl_prodempseg
            WHERE 1 = 1 AND statusvenda = 'A') b
ON b.nroempresa = a.nroempresa AND b.seqproduto = a.seqproduto 
INNER JOIN implantacao.map_produto c 
ON c.seqproduto = b.seqproduto AND c.desccompleta NOT LIKE 'ZZ%'
INNER JOIN (SELECT DISTINCT seqfamilia,NVL(vlrnultiplovda,1) AS vlrnultiplovda
            FROM implantacao.mad_famsegmento
            WHERE 1 = 1 AND status = 'A') d
ON d.seqfamilia = c.seqfamilia
INNER JOIN implantacao.map_familia e
ON e.seqfamilia = d.seqfamilia
INNER JOIN implantacao.mrl_prodempseg f 
ON f.seqproduto = a.seqproduto AND f.statusvenda = 'A'
WHERE 1 = 1
AND a.statuscompra = 'A'
GROUP BY a.nroempresa,a.seqproduto,a.statuscompra,c.dtahoralteracao,d.vlrnultiplovda,e.pmtdecimal
ORDER BY 1 ASC;
