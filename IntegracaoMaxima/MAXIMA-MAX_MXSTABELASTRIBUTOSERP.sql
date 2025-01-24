SELECT
    DISTINCT
    LPAD(c.seqproduto,6,0)                  AS  codprod,                      --> Código do produto
    d.nroempresa                            AS  codfilialnf,                  --> Código da filial de emissão da nota fiscal
    a.ufclientefornec                       AS  ufdestino,                    --> Estado de entrega da mercadoria - UF do cliente
    1                                       AS  codoper,                      --> Código do tipo de operação
    0                                       AS  codcli,                       --> Código do cliente. Se não usar, fixar 0
    0                                       AS  codgrupotribut,
    CASE
    WHEN a.ufclientefornec = 'AC' 
    THEN TO_CHAR(a.nrotributacao) || 01
    WHEN a.ufclientefornec = 'AL' 
    THEN TO_CHAR(a.nrotributacao) || 02
    WHEN a.ufclientefornec = 'AM' 
    THEN TO_CHAR(a.nrotributacao) || 03
    WHEN a.ufclientefornec = 'AP' 
    THEN TO_CHAR(a.nrotributacao) || 04
    WHEN a.ufclientefornec = 'BA' 
    THEN TO_CHAR(a.nrotributacao) || 05
    WHEN a.ufclientefornec = 'CE' 
    THEN TO_CHAR(a.nrotributacao) || 06
    WHEN a.ufclientefornec = 'DF' 
    THEN TO_CHAR(a.nrotributacao) || 07
    WHEN a.ufclientefornec = 'ES' 
    THEN TO_CHAR(a.nrotributacao) || 08
    WHEN a.ufclientefornec = 'GO' 
    THEN TO_CHAR(a.nrotributacao) || 09
    WHEN a.ufclientefornec = 'MA' 
    THEN TO_CHAR(a.nrotributacao) || 10
    WHEN a.ufclientefornec = 'MG' 
    THEN TO_CHAR(a.nrotributacao) || 11
    WHEN a.ufclientefornec = 'MS' 
    THEN TO_CHAR(a.nrotributacao) || 12
    WHEN a.ufclientefornec = 'MT' 
    THEN TO_CHAR(a.nrotributacao) || 13
    WHEN a.ufclientefornec = 'PA' 
    THEN TO_CHAR(a.nrotributacao) || 14
    WHEN a.ufclientefornec = 'PB' 
    THEN TO_CHAR(a.nrotributacao) || 15
    WHEN a.ufclientefornec = 'PE' 
    THEN TO_CHAR(a.nrotributacao) || 16
    WHEN a.ufclientefornec = 'PI' 
    THEN TO_CHAR(a.nrotributacao) || 17
    WHEN a.ufclientefornec = 'PR' 
    THEN TO_CHAR(a.nrotributacao) || 18
    WHEN a.ufclientefornec = 'RJ' 
    THEN TO_CHAR(a.nrotributacao) || 19
    WHEN a.ufclientefornec = 'RN' 
    THEN TO_CHAR(a.nrotributacao) || 20
    WHEN a.ufclientefornec = 'RO' 
    THEN TO_CHAR(a.nrotributacao) || 21
    WHEN a.ufclientefornec = 'RR' 
    THEN TO_CHAR(a.nrotributacao) || 22
    WHEN a.ufclientefornec = 'RS' 
    THEN TO_CHAR(a.nrotributacao) || 23
    WHEN a.ufclientefornec = 'SC' 
    THEN TO_CHAR(a.nrotributacao) || 24
    WHEN a.ufclientefornec = 'SE' 
    THEN TO_CHAR(a.nrotributacao) || 25
    WHEN a.ufclientefornec = 'SP' 
    THEN TO_CHAR(a.nrotributacao) || 26
    WHEN a.ufclientefornec = 'TO' 
    THEN TO_CHAR(a.nrotributacao) || 27
    ELSE NULL
    END                                     AS  codst,                         --> Código da tributária
    d.statuscompra                          As  status,                                     
    TO_DATE(a.dtaalteracao)                 AS  dtaalteracao
FROM implantacao.map_tributacaouf a
LEFT JOIN implantacao.map_famdivisao b ON b.nrotributacao = a.nrotributacao
INNER JOIN implantacao.map_produto c ON c.seqfamilia = b.seqfamilia AND c.desccompleta NOT LIKE 'ZZ%'
INNER JOIN implantacao.mrl_produtoempresa d ON d.seqproduto = c.seqproduto AND d.statuscompra = 'A'
WHERE 1=1
AND a.nroregtributacao = 0
AND a.ufempresa = 'PE'
AND a.nrotributacao >= 1000
AND a.ufclientefornec NOT IN ('EX')
AND a.tiptributacao = 'SC'
ORDER BY 1 ASC;