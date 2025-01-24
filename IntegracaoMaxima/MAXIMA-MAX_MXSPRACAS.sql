SELECT 
    DISTINCT
    b.codpraca,                                        --> Código
    'PRACA '
    ||
    c.descsegmento                 AS  praca,          --> Descrição
    b.numregiao,                                       --> Código da região
    a.statuscliente                AS  situacao,       --> Situação (A=Ativo / I=Inativo)
    'A'                            AS  status,
    MAX(TO_DATE(d.dtaalteracao))   AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN (SELECT 
                DISTINCT 
                b.nroempresa,
                a.seqpessoa,
                a.nrosegmento,
                MIN(LPAD(b.nroempresa,2,0)||LPAD(a.nrosegmento,3,0)||LPAD(a.nrotabvendaprinc,4,0)) AS codpraca,
                MIN(LPAD(b.nroempresa,1,0)||LPAD(a.nrosegmento,2,0)||LPAD(a.nrotabvendaprinc,3,0)) AS numregiao
            FROM implantacao.mrl_clienteseg a
            INNER JOIN implantacao.mrl_cliente b ON b.seqpessoa = a.seqpessoa 
            WHERE a.status = 'A'
            AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND (nrotabvendaprinc != 'NULL'
            OR (nrotabvendaprinc NOT IN (2,3,7,8,9,10,11,12,13,14,15,20,71,72,73,91,99,100,101,122,131,711,998,999)))
            GROUP BY b.nroempresa,a.nrosegmento,a.seqpessoa) b
ON b.nroempresa = b.nroempresa AND b.seqpessoa = a.seqpessoa
INNER JOIN implantacao.mad_segmento c 
ON c.nrosegmento = b.nrosegmento AND c.status = 'A'
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
            GROUP BY seqpessoa) d
ON d.seqpessoa = b.seqpessoa
WHERE 1 = 1
--AND a.seqpessoa NOT IN (1, 22401)
AND a.seqpessoa IN (531, 37698, 40866, 42797)
AND a.statuscliente = 'A'
GROUP BY a.nroempresa,a.statuscliente,b.nrosegmento,b.codpraca,b.numregiao,c.descsegmento
ORDER BY 1 ASC, 2 ASC, 3 ASC;
