 SELECT 
    DISTINCT 
    a.seqpessoa                   AS  codcli,          --> Código do cliente
    TO_CHAR(
    TRUNC(
        ADD_MONTHS(SYSDATE, 0),
        'YY'
    ),'YYYY-MM-DD')               AS  dataini,        --> Data inicial de vigência
    '3000-12-31'                  AS  datafim,        --> Data final de vigência  
    NVL(
    CASE
    WHEN TRUNC(a.percacrdesccomerc) < 0
    THEN -CAST(a.percacrdesccomerc AS DECIMAL(10,3))
    ELSE -CAST(a.percacrdesccomerc AS DECIMAL(10,3))
    END,0)                       AS  percacrescimo,  --> Percentual de acréscimo/desconto sobre a tabela de preço
    a.status,
    MAX(a.dtaalteracao)           AS  dtaalteracao
FROM implantacao.mrl_clienteseg a
INNER JOIN implantacao.mrl_cliente b 
ON b.seqpessoa = a.seqpessoa AND b.statuscliente = 'A' AND b.seqpessoa NOT IN (1, 22401)
INNER JOIN (SELECT DISTINCT seqpessoa,dtaalteracao 
            FROM implantacao.mrl_clienteseg 
            WHERE status = 'A' 
            AND seqpessoa NOT IN (1, 22401)
            UNION ALL
            SELECT DISTINCT seqpessoa,dtaalteracao
            FROM implantacao.mrl_cliente
            WHERE statuscliente = 'A' 
            AND seqpessoa NOT IN (1, 22401)) c 
ON c.seqpessoa = b.seqpessoa
WHERE 1 = 1
AND a.seqpessoa NOT IN (1, 22401)
AND a.status = 'A'
AND a.percacrdesccomerc != 0
GROUP BY a.seqpessoa,a.percacrdesccomerc,a.status
ORDER BY 1 ASC

