SELECT 
    a.nropedvenda                       AS  numped,
    a.seqpedvendaitem                   AS  numseq,
    LPAD(a.seqproduto,6,0)              AS  codprod,
    a.qtdatendida / a.qtdembalagem      AS  qt,
    a.vlrembtabpreco                    AS  ptabela,
    a.vlrembinformado                   AS  pvenda,
    a.percomissao                       AS  percom,
    TO_CHAR(a.dtainclusao,'YYYY-MM-DD') AS  data,
    'A'                                 AS  status,
    TO_DATE(b.dtahorsituacaopedalt)     AS  dtaalteracao
FROM implantacao.mad_pedvendaitem a
INNER JOIN implantacao.mad_pedvenda b
ON b.nropedvenda = a.nropedvenda
WHERE 1 = 1
AND a.usuinclusao = 'AFV'
AND a.dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE, -1),'MM')
ORDER BY 1 ASC;
