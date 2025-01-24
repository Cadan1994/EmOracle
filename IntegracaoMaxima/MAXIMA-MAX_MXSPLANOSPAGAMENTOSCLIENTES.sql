SELECT
    DISTINCT
    a.seqpessoa                         AS  codcli,     --> Código do cliente
    LPAD(NVL(c.nrocondicaopagto,1),3,0)
    ||
    LPAD(b.nrotabvenda,3,0)             AS  codplpag,   --> Código do plano de pagamento
    a.statuscliente                     AS  status,
    CASE
    WHEN TO_DATE(a.dtaalteracao) > 
         TO_DATE(c.dtahoralteracao)
    THEN TO_DATE(a.dtaalteracao)
    ELSE TO_DATE(c.dtahoralteracao)
    END                                 AS  dtaalteracao
FROM implantacao.mrl_cliente a
-- Tabela utilizada para pegar os campos: "NROSEGMENTO,NROTABVENDAPRINC"
INNER JOIN (SELECT DISTINCT seqpessoa,nrosegmento,nrotabvenda
            FROM implantacao.mad_clisegtabvenda a
            WHERE status = 'A' 
            AND nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND seqpessoa NOT IN (1, 22401)
            AND (nrotabvenda != 'NULL'
            OR (nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)))) b
ON b.seqpessoa = a.seqpessoa
-- Tabela utilizada para pegar o campo: "NROCONDICAOPAGTO"
INNER JOIN implantacao.mad_condicaopagto c 
ON c.nrodiavencto <= a.pzopagtomaximo AND c.nrocondicaopagto NOT IN (41,201,868,901,964,965,997,998) AND c.status = 'A'
WHERE 1 = 1 
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
ORDER BY 1 ASC, 2 ASC;
