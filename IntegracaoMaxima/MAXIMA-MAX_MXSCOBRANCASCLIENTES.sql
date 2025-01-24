SELECT 
    a.nroformapagto         AS  codcob,     --> Código da cobrança
    a.seqpessoa             AS  codcli,     --> Código do cliente
    'A'                     AS  status,
    TO_DATE(a.dtaalteracao) AS dtaalteracao
FROM implantacao.mrl_clientecredito a 
INNER JOIN implantacao.mrl_formapagto b 
ON b.nroformapagto = a.nroformapagto AND b.statusformapagto = 'A'
WHERE 1 = 1
AND a.statuscredito = 'L';
