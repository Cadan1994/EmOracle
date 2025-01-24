SELECT
    DISTINCT
    LPAD(a.nrocondicaopagto,3,0)
    ||
    LPAD(b.nrotabvenda,3,0)           AS  codplpag,    --> C�digo
    a.desccondicaopagto               AS  descricao,   --> Descri��o
    0                                 AS  numdias,     --> Prazo m�dio
    1                                 AS  numpr,       --> N�mero da coluna de pre�o - default 1
    ROUND(SUM(b.peracrfinanceiro),6)  AS  pertxfim,    --> Acr�scimo para a tabela de pre�o*/
    'S'                               AS  vendabk,     --> Venda com boleto (S ou N)
    0                                 AS  vlminpedido, --> Valor m�nimo para a condi�o de pagamento   
    0                                 AS  prazo1,      --> Margem m�nima
    'N'                               AS  tipoprazo,   --> Informar N�Normal, B�Bonificado, I-Inativo  
    'VP'                              AS  tipovenda,   --> Informar VP-Venda a prazo e VV-Venda a vista                 
    a.status                          AS  status,
    TO_DATE(a.dtahoralteracao)        AS  dtaalteracao
FROM implantacao.mad_condicaopagto a 
INNER JOIN implantacao.mad_tabvendacond b 
ON b.nrocondicaopagto = a.nrocondicaopagto AND b.status = 'A'
AND b.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
WHERE 1 = 1 
AND a.nrocondicaopagto NOT IN (41,201,868,901,964,965,997,998) 
AND a.status = 'A'
GROUP BY a.nrocondicaopagto,a.desccondicaopagto,a.status,a.dtahoralteracao,b.nrotabvenda
ORDER BY 1 ASC;