SELECT 
    a.nroformapagto         AS  codcob,     --> C�digo da cobran�a
    a.seqpessoa             AS  codcli,     --> C�digo do cliente
    'A'                     AS  status,
    TO_DATE(a.dtaalteracao) AS dtaalteracao
FROM implantacao.mrl_clientecredito a 
INNER JOIN implantacao.mrl_formapagto b 
ON b.nroformapagto = a.nroformapagto AND b.statusformapagto = 'A'
WHERE 1 = 1
AND a.statuscredito = 'L';
