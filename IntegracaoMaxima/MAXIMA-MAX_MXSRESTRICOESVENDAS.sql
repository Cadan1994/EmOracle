--codrestricao,codcli,codusur,numregiao,origemped='F'
SELECT 
    DISTINCT 
    a.nrosegmento,
    a.descsegmento,
    LAST_VALUE(b.nrorepresentante IGNORE NULLS) 
    OVER(ORDER BY b.nrorepresentante) nrorepresentante,
    --f.numregiao,
    c.seqpessoa
    /*,
    CASE 
    WHEN b.nrosegmento IS NOT NULL
    THEN 'N'
    ELSE 'S'
    END restrito*/
FROM implantacao.mad_segmento a
LEFT JOIN implantacao.mad_repsegmento b ON b.nrosegmento = a.nrosegmento AND b.status = 'A' AND b.nrorepresentante NOT IN (1,1000,2000,22401,99999)
LEFT JOIN implantacao.mrl_clienteseg c ON c.nrosegmento = b.nrosegmento AND c.nrorepresentante NOT IN b.nrorepresentante AND c.seqpessoa NOT IN (1,22401)
/*
INNER JOIN (SELECT 
                DISTINCT 
                b.nroempresa,
                a.seqpessoa,
                a.nrosegmento,
                LPAD(b.nroempresa,1,0)||LPAD(a.nrosegmento,2,0)||LPAD(a.nrotabvenda,3,0) AS numregiao
            FROM implantacao.mad_clisegtabvenda a
            INNER JOIN implantacao.mrl_cliente b ON b.seqpessoa = a.seqpessoa 
            WHERE a.status = 'A'
            AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND (a.nrotabvenda != 'NULL'
            OR (a.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)))) f
ON f.seqpessoa = c.seqpessoa AND f.nrosegmento = c.nrosegmento
*/
WHERE 1=1
AND a.status = 'A'
ORDER BY 3 ASC