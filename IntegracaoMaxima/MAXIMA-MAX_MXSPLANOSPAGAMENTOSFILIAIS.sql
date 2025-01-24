SELECT
    DISTINCT
    a.nroempresa                         AS  codfilial,      --> Código da filial
    LPAD(NVL(c.nrocondicaopagto,1),3,0)  AS  codplpag,       --> Código do plano de pagamento
    a.statuscliente                      AS  status,
    TO_DATE(a.dtaalteracao)              AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mrl_clienteseg b 
ON b.seqpessoa = a.seqpessoa AND b.nrosegmento IN (1,3,4,5,6,7,8,9,10) 
AND b.nrotabvendaprinc NOT IN (2,3,7,8,9,10,11,12,13,14,15,20,71,72,73,91,99,100,101,122,131,711,998,999)
INNER JOIN implantacao.mad_tabvendacond c 
ON c.nrotabvenda = b.nrotabvendaprinc AND c.nrocondicaopagto NOT IN (41,201,868,901,964,965,997,998)
WHERE 1 = 1 
--AND a.seqpessoa NOT IN (1, 22401)
AND a.seqpessoa IN (531, 37698, 40866, 42797)
AND a.statuscliente = 'A'
ORDER BY 1 ASC;
