SELECT
      DISTINCT
      a.seqpessoa                AS  codcli,
      NVL(b.nrorepresentante,0)  AS  codusur,
      a.statuscliente            AS  status,
      TO_DATE(a.dtaalteracao)    AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mad_clienterep b 
ON b.seqpessoa = a.seqpessoa AND b.nrorepresentante NOT IN (1,1000,22401,99999) AND b.status = 'A'
WHERE 1 = 1
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
AND b.nrorepresentante = 11138
ORDER BY 1 ASC;