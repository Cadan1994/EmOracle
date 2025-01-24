SELECT 
    DISTINCT
    'S'                                             AS  calcvlcontabilnfcf,
    CASE
    WHEN a.uf = 'AC' THEN '12'
    WHEN a.uf = 'AL' THEN '27'
    WHEN a.uf = 'AM' THEN '13'
    WHEN a.uf = 'AP' THEN '16'
    WHEN a.uf = 'BA' THEN '29'
    WHEN a.uf = 'CE' THEN '23'
    WHEN a.uf = 'DF' THEN '53'
    WHEN a.uf = 'ES' THEN '32'
    WHEN a.uf = 'GO' THEN '52'
    WHEN a.uf = 'MA' THEN '21'
    WHEN a.uf = 'MG' THEN '31'
    WHEN a.uf = 'MS' THEN '50'
    WHEN a.uf = 'MT' THEN '51'
    WHEN a.uf = 'PA' THEN '15'
    WHEN a.uf = 'PB' THEN '25'
    WHEN a.uf = 'PE' THEN '26'
    WHEN a.uf = 'PI' THEN '22'
    WHEN a.uf = 'PR' THEN '41'
    WHEN a.uf = 'RJ' THEN '33'
    WHEN a.uf = 'RN' THEN '24'
    WHEN a.uf = 'RO' THEN '11'
    WHEN a.uf = 'RR' THEN '14'
    WHEN a.uf = 'RS' THEN '43'
    WHEN a.uf = 'SC' THEN '42'
    WHEN a.uf = 'SE' THEN '28'
    WHEN a.uf = 'SP' THEN '35'
    WHEN a.uf = 'TO' THEN '17'
    END                                             AS  codibge,
    a.uf                                            AS  codigo,
    a.codpais                                       AS  codpais,
    a.uf                                            AS  uf,
    CASE
    WHEN a.uf = 'AC' THEN 'ACRE'
    WHEN a.uf = 'AL' THEN 'ALAGOAS'
    WHEN a.uf = 'AM' THEN 'AMAZONAS'
    WHEN a.uf = 'AP' THEN 'AMAPA'
    WHEN a.uf = 'BA' THEN 'BAHIA'
    WHEN a.uf = 'CE' THEN 'CEARA'
    WHEN a.uf = 'DF' THEN 'DISTRITO FEDERAL'
    WHEN a.uf = 'ES' THEN 'ESPIRITO SANTOS'
    WHEN a.uf = 'GO' THEN 'GOIAS'
    WHEN a.uf = 'MA' THEN 'MARANHAO'
    WHEN a.uf = 'MG' THEN 'MINAS GERAIS'
    WHEN a.uf = 'MS' THEN 'MATO GROSSO DO SUL'
    WHEN a.uf = 'MT' THEN 'MATO GROSSO'
    WHEN a.uf = 'PA' THEN 'PARA'
    WHEN a.uf = 'PB' THEN 'PARAIBA'
    WHEN a.uf = 'PE' THEN 'PERNAMBUCO'
    WHEN a.uf = 'PI' THEN 'PIAUI'
    WHEN a.uf = 'PR' THEN 'PARANA'
    WHEN a.uf = 'RJ' THEN 'RIO DE JANEIRO'
    WHEN a.uf = 'RN' THEN 'RIO GRANDE DO NORTE'
    WHEN a.uf = 'RO' THEN 'RONDONIA'
    WHEN a.uf = 'RR' THEN 'RORAIMA'
    WHEN a.uf = 'RS' THEN 'RIO GRANDE DO SUL'
    WHEN a.uf = 'SC' THEN 'SANTA CATARINA'
    WHEN a.uf = 'SE' THEN 'SERGIPE'
    WHEN a.uf = 'SP' THEN 'SAO PAULO'
    WHEN a.uf = 'TO' THEN 'TOCANTINS'
    END                                             AS Estado,
    MAX(
       TO_DATE(
          a.dtaalteracao
       )
    ) AS dtaalteracao
FROM implantacao.ge_cidade a
WHERE 1 = 1
GROUP BY 1,a.uf,a.codpais;