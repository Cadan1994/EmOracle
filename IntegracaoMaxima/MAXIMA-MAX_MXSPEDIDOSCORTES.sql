SELECT
    a.nropedvenda                   AS  numped,
    LPAD(a.seqproduto,6,0)          AS  codprod,
    a.qtdcortewm                    AS  qtcortada,
    'A'                             AS  status,
    TO_DATE(b.dtahorsituacaopedalt) AS  dtaalteracao
FROM implantacao.mad_pedvendaitem a
INNER JOIN implantacao.mad_pedvenda b
ON b.nropedvenda = a.nropedvenda
WHERE 1 = 1
AND a.usuinclusao = 'AFV'
AND a.qtdcortewm IS NOT NULL
AND a.dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE, 0),'MM')
ORDER BY 1 ASC;