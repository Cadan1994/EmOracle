SELECT
    DISTINCT
    a.seqpessoa                            AS  codcli,        --> Código do cliente
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)                AS numregiao,      --> Código
    LPAD(NVL(c.nrocondicaopagto,1),3,0)||
    LPAD(b.nrotabvenda,3,0)                AS codplpag,       --> Código do plano de pagamento
    a.statuscliente                        AS  status,
    MAX(TO_DATE(a.dtaalteracao))           AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mad_clisegtabvenda b
ON b.seqpessoa = a.seqpessoa AND b.nrosegmento IN (1,3,4,5,6,7,8,9,10)
AND (b.nrotabvenda != 'NULL' 
OR (b.nrotabvenda NOT IN (2,3,7,8,9,10,11,12,13,14,15,20,71,72,73,91,99,100,101,122,131,711,998,999)))
AND b.status = 'A'
INNER JOIN implantacao.mad_condicaopagto c 
ON c.nrodiavencto <= a.pzopagtomaximo AND c.nrocondicaopagto NOT IN (41,201,868,901,964,965,997,998) AND c.status = 'A'
WHERE 1 = 1 
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
GROUP BY a.nroempresa,a.seqpessoa,a.statuscliente,b.nrosegmento,b.nrotabvenda,c.nrocondicaopagto
ORDER BY 1 ASC, 2 ASC, 3 ASC;
