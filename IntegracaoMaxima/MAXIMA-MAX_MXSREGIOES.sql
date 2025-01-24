SELECT 
    DISTINCT
    b.numregiao,                                     --> Código
    e.percfretetransp              AS  perfrete,     --> Percentual de frete
    g.tipo
    ||
    ' » '
    ||
    c.descsegmento                 AS  regiao,       --> Descrição
    a.statuscliente                AS  status,       --> Indica se a região está "A" - ativa ou "I" - inativa
    MAX(g.dtaalteracao)            AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN (SELECT 
                DISTINCT 
                b.nroempresa,
                a.seqpessoa,
                a.nrosegmento,
                a.nrotabvenda,
                LPAD(b.nroempresa,1,0)||LPAD(a.nrosegmento,2,0)||LPAD(a.nrotabvenda,3,0) AS numregiao
            FROM implantacao.mad_clisegtabvenda a
            INNER JOIN implantacao.mrl_cliente b ON b.seqpessoa = a.seqpessoa 
            WHERE a.status = 'A'
            AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND (a.nrotabvenda != 'NULL'
            OR (a.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)))) b
ON b.nroempresa = a.nroempresa AND b.seqpessoa = a.seqpessoa
INNER JOIN implantacao.mad_segmento c 
ON c.nrosegmento = b.nrosegmento AND c.status = 'A'
INNER JOIN implantacao.mad_tabvenda e 
ON e.nrotabvenda = b.nrotabvenda AND e.status = 'A'
INNER JOIN (SELECT DISTINCT nrotabvenda,'CF' AS tipo 
            FROM implantacao.mad_tabvenda 
            WHERE status = 'A' 
            AND nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
            AND (UPPER(DESCTABVENDA) LIKE 'CUPOM%' OR(UPPER(DESCTABVENDA) LIKE 'CF%'))
            UNION ALL
            SELECT DISTINCT nrotabvenda,'NF' AS TIPO 
            FROM implantacao.mad_tabvenda 
            WHERE status = 'A'
            AND nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
            AND UPPER(DESCTABVENDA) NOT LIKE 'CUPOM%'
            AND UPPER(DESCTABVENDA) NOT LIKE 'CF%') g
ON g.nrotabvenda = e.nrotabvenda
INNER JOIN (SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.mrl_cliente 
            WHERE seqpessoa NOT IN (1, 22401)
            AND statuscliente = 'A'
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.mrl_clienteseg 
            WHERE nrosegmento IN (1,3,4,5,6,7,8,9,10) 
            AND status = 'A' 
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT b.seqpessoa,MAX(TO_DATE(a.dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_tabvenda a
            INNER JOIN implantacao.mad_clisegtabvenda b ON b.nrotabvenda = a.nrotabvenda
            WHERE a.status = 'A'
            AND a.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
            GROUP BY b.seqpessoa) g
ON g.seqpessoa = b.seqpessoa
WHERE 1 = 1
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
GROUP BY a.nroempresa,a.statuscliente,b.nrosegmento,b.numregiao,c.descsegmento,e.percfretetransp,g.tipo
ORDER BY 1 ASC;