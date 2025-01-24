SELECT
    a.peraliquota                   AS  aliqicms1,                     --> Alíquota de ICMS 1
    0                               AS  aliqicms1fonte,                --> Alíquota ICMS 1 fonte
    a.peraliquota                   AS  aliqicms2,                     --> Alíquota de ICMS 2
    0                               AS  aliqicms2fonte,                --> Alíquota ICMS 2 fonte
    CASE
    WHEN a.ufclientefornec = 'AC' 
    THEN TO_NUMBER(a.nrotributacao || 01)
    WHEN a.ufclientefornec = 'AL' 
    THEN TO_NUMBER(a.nrotributacao || 02)
    WHEN a.ufclientefornec = 'AM' 
    THEN TO_NUMBER(a.nrotributacao || 03)
    WHEN a.ufclientefornec = 'AP' 
    THEN TO_NUMBER(a.nrotributacao || 04)
    WHEN a.ufclientefornec = 'BA' 
    THEN TO_NUMBER(a.nrotributacao || 05)
    WHEN a.ufclientefornec = 'CE' 
    THEN TO_NUMBER(a.nrotributacao || 06)
    WHEN a.ufclientefornec = 'DF' 
    THEN TO_NUMBER(a.nrotributacao || 07)
    WHEN a.ufclientefornec = 'ES' 
    THEN TO_NUMBER(a.nrotributacao || 08)
    WHEN a.ufclientefornec = 'GO' 
    THEN TO_NUMBER(a.nrotributacao || 09)
    WHEN a.ufclientefornec = 'MA' 
    THEN TO_NUMBER(a.nrotributacao || 10)
    WHEN a.ufclientefornec = 'MG' 
    THEN TO_NUMBER(a.nrotributacao || 11)
    WHEN a.ufclientefornec = 'MS' 
    THEN TO_NUMBER(a.nrotributacao || 12)
    WHEN a.ufclientefornec = 'MT' 
    THEN TO_NUMBER(a.nrotributacao || 13)
    WHEN a.ufclientefornec = 'PA' 
    THEN TO_NUMBER(a.nrotributacao || 14)
    WHEN a.ufclientefornec = 'PB' 
    THEN TO_NUMBER(a.nrotributacao || 15)
    WHEN a.ufclientefornec = 'PE' 
    THEN TO_NUMBER(a.nrotributacao || 16)
    WHEN a.ufclientefornec = 'PI' 
    THEN TO_NUMBER(a.nrotributacao || 17)
    WHEN a.ufclientefornec = 'PR' 
    THEN TO_NUMBER(a.nrotributacao || 18)
    WHEN a.ufclientefornec = 'RJ' 
    THEN TO_NUMBER(a.nrotributacao || 19)
    WHEN a.ufclientefornec = 'RN' 
    THEN TO_NUMBER(a.nrotributacao || 20)
    WHEN a.ufclientefornec = 'RO' 
    THEN TO_NUMBER(a.nrotributacao || 21)
    WHEN a.ufclientefornec = 'RR' 
    THEN TO_NUMBER(a.nrotributacao || 22)
    WHEN a.ufclientefornec = 'RS' 
    THEN TO_NUMBER(a.nrotributacao || 23)
    WHEN a.ufclientefornec = 'SC' 
    THEN TO_NUMBER(a.nrotributacao || 24)
    WHEN a.ufclientefornec = 'SE' 
    THEN TO_NUMBER(a.nrotributacao || 25)
    WHEN a.ufclientefornec = 'SP' 
    THEN TO_NUMBER(a.nrotributacao || 26)
    WHEN a.ufclientefornec = 'TO' 
    THEN TO_NUMBER(a.nrotributacao || 27)
    ELSE 0
    END                             AS  codst,                         --> Código da figura tributária
    a.peracrescst                   AS  iva,                           --> Iva
    0                               AS  ivafonte,                      --> Percentual Iva fonte
    NULL                            AS  obs,                           --> Descrição da tributação
    0                               AS  pauta,                         --> Valor de pauta
    NULL                            AS  sittribut,                     --> Código da situação tributário
    0                               AS  codfiscalvendaprontaent,       --> Código CFOP venda pronta entrega dentro do estado
    0                               AS  codfiscalvendaprontaentiner,   --> Código CFOP bonificação pronta entrega interestadual
    0                               AS  codfiscalbonific,              --> Código CFOP bonificação pronta entrega dentro do estado
    0                               AS  codfiscalbonificinter,         --> Código CFOP bonificação pronta entrega interestadual
    b.status                        AS  status,
    TO_DATE(a.dtaalteracao)         AS  dtaalteracao
FROM implantacao.map_tributacaouf a
INNER JOIN implantacao.map_tributacao b ON b.nrotributacao = a.nrotributacao AND b.status = 'A'
WHERE 1=1
AND a.nroregtributacao = 0
AND a.ufempresa = 'PE'
AND a.ufclientefornec = 'PE'
AND a.nrotributacao >= 1000
AND a.ufclientefornec NOT IN ('EX')
AND a.tiptributacao = 'SC';
