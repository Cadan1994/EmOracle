SELECT
    DISTINCT
    c.descequipe  AS equipe,  
    a.nrorepresentante  AS codigo,
    b.apelido,
    (SELECT NVL(SUM(valor),0)
    FROM implantacao.mad_repccflex
    WHERE 1=1
    AND tipolancamento = 'M'
    AND situacaolancto = 'A'
    AND valor > 0
    AND nrorepresentante = a.nrorepresentante
    AND dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM'))
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor > 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped = 'F')
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor > 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped != 'F')
    AS  "Venda Mais",
    -----------------------------------------------------------------------------------
    (SELECT NVL(SUM(valor),0)
    FROM implantacao.mad_repccflex
    WHERE 1=1
    AND tipolancamento = 'M'
    AND situacaolancto = 'A'
    AND valor < 0
    AND nrorepresentante = a.nrorepresentante
    AND dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM'))
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor < 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped = 'F') 
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor < 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped != 'F')
    AS  "Descontos",
    -----------------------------------------------------------------------------------
    ((SELECT NVL(SUM(valor),0)
    FROM implantacao.mad_repccflex
    WHERE 1=1
    AND tipolancamento = 'M'
    AND situacaolancto = 'A'
    AND valor > 0
    AND nrorepresentante = a.nrorepresentante
    AND dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM'))
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor > 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped = 'F') 
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor > 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped != 'F'))
    +
    ((SELECT NVL(SUM(valor),0)
    FROM implantacao.mad_repccflex
    WHERE 1=1
    AND tipolancamento = 'M'
    AND situacaolancto = 'A'
    AND valor < 0
    AND nrorepresentante = a.nrorepresentante
    AND dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM'))
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor < 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped = 'F') 
    +
    (SELECT NVL(SUM(aa.valor),0)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.valor < 0
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(a.dtalancamento, 0),'MM')
    AND bb.situacaoped != 'F'))
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
ORDER BY 2
    