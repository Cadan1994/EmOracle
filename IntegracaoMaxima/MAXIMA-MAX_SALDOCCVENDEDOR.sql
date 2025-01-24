SELECT
    DISTINCT  
    a.nrorepresentante                                  AS  codusur,    --> Código do vendedor
    --> TODOS OS LANÇAMENTOS MANUAIS
    NVL(
    (SELECT SUM(aa.valor)
    FROM implantacao.mad_repccflex aa
    WHERE 1=1
    AND aa.tipolancamento = 'M'
    AND aa.situacaolancto = 'A'
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(b.dtalancamento, 0),'MM')
    AND aa.nrorepresentante = a.nrorepresentante),0)
    --> TODOS OS LANÇAMENTOS AUTOMÁTICOS REFERENTE AOS PEDIDOS FATURADOS
    + 
    NVL(
    (SELECT SUM(aa.valor)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(b.dtalancamento, 0),'MM')
    AND aa.nrorepresentante = a.nrorepresentante
    AND bb.situacaoped = 'F'),0)
    --> TODOS OS LANÇAMENTOS AUTOMÁTICOS REFERENTE AOS PEDIDOS FATURADOS
    + 
    NVL(
    (SELECT SUM(aa.valor)
    FROM implantacao.mad_repccflex aa
    INNER JOIN implantacao.mad_pedvenda bb 
    ON bb.nrorepresentante = aa.nrorepresentante 
    AND bb.nropedvenda = aa.nropedvenda
    WHERE 1=1
    AND aa.tipolancamento = 'A'
    AND aa.situacaolancto = 'A'
    AND aa.dtalancamento >= TRUNC(ADD_MONTHS(b.dtalancamento, 0),'MM')
    AND aa.nrorepresentante = a.nrorepresentante
    AND aa.valor < 0
    AND bb.situacaoped != 'F'),0)                  AS  saldocc,    --> Saldo da conta corrente do vendedor
    0                                              AS  limcredcc,  --> Limite de crédito do vendedor
    NVL(
     (SELECT MAX(TO_DATE(dtahorsituacaopedalt)) 
     FROM implantacao.mad_pedvenda
     WHERE 1=1
     AND dtahorsituacaopedalt 
     >= 
     TRUNC(ADD_MONTHS(b.dtalancamento, 0),'MM')
     AND nrorepresentante = a.nrorepresentante),
     b.dtalancamento)                              AS  dtaalteracao,
    a.situacaolancto                               AS  status
FROM implantacao.mad_repccflex a
INNER JOIN (SELECT nrorepresentante,MAX(TO_DATE(dtalancamento)) dtalancamento 
            FROM implantacao.mad_repccflex
            WHERE 1=1
            AND situacaolancto = 'A'
            GROUP BY nrorepresentante) b
ON b.nrorepresentante = a.nrorepresentante
INNER JOIN implantacao.mad_pedvenda c ON c.nropedvenda = a.nropedvenda AND c.nrorepresentante = a.nrorepresentante
WHERE 1=1
AND a.situacaolancto = 'A'
AND a.nrorepresentante NOT IN (1,22401,99999)
GROUP BY a.nropedvenda,a.nrorepresentante,a.situacaolancto,b.dtalancamento,c.dtahorsituacaopedalt
ORDER BY 1 ASC