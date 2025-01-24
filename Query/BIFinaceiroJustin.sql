SELECT
    a.nroempresa,
    a.seqpessoa,
    a.dtainclusao,
    b.numerodf,
    b.seriedf,
    b.nroserieecf,
    SUM(c.vlritem + c.vlricmsst - c.vlrdesconto) AS vlritem
FROM implantacao.mad_pedvenda a
INNER JOIN implantacao.mfl_doctofiscal b ON b.nropedidovenda IN a.nropedvenda
INNER JOIN implantacao.mfl_dfitem c ON c.nroempresa = b.nroempresa AND c.numerodf = b.numerodf AND c.seriedf = b.seriedf AND c.nroserieecf = b.nroserieecf
WHERE 1=1
AND a.situacaoped = 'F'
AND a.dtainclusao >= ADD_MONTHS(TRUNC(SYSDATE,'yyyy'), -48)
GROUP BY a.nroempresa,a.seqpessoa,a.dtainclusao,b.numerodf,b.seriedf,b.nroserieecf
ORDER BY a.nroempresa ASC,a.seqpessoa ASC
