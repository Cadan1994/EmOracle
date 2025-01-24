SELECT
    DISTINCT
    c.descequipe  AS equipe,  
    a.nrorepresentante  AS codigo,
    b.apelido, 
		-----------------------------------------------------------------------------------
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    LEFT JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1AND aa.situacaolancto = 'A'
    AND aa.valor > 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM'))
    AS  "Venda Mais",
    -----------------------------------------------------------------------------------
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    LEFT JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.situacaolancto = 'A'
    AND aa.valor < 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM'))
    AS  "Descontos",
    -----------------------------------------------------------------------------------
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    LEFT JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.situacaolancto = 'A'
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
		AND (bb.situacaoped IS NULL OR (bb.situacaoped = 'F' AND aa.valor > 0) OR (bb.situacaoped != 'F' AND aa.valor < 0)))
    AS  "Saldo Atual"
FROM implantacao.mad_repccflex a
INNER JOIN implantacao.mad_representante b 
ON b.nrorepresentante = a.nrorepresentante
INNER JOIN implantacao.mad_equipe c 
ON c.nroequipe = b.nroequipe
WHERE 1 = 1
AND a.situacaolancto = 'A'
AND a.nroempresa = :NR1
AND a.dtalancamento BETWEEN :DT1 AND :DT2
GROUP BY a.nrorepresentante,a.dtalancamento,b.apelido,c.descequipe 
ORDER BY 2 ASC
    