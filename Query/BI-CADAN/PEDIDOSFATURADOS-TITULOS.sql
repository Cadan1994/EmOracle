SELECT
    DISTINCT
    a.nroempresa,
    a.seqpessoa,
    a.dtainclusao,
    a.seqtitulo,
    a.nroparcela,
    a.nrotitulo numerodf,
    b.seriedf,
    NVL(b.nroserieecf,'CH') nroserieecf,
    SUM(NVL(D.vlritem + NVL(D.vlricmsst,0) - NVL(D.vlrdesconto,0),a.vlroriginal)) AS vlritem
FROM implantacao.fi_titulo a
LEFT JOIN implantacao.mfl_doctofiscal b 
ON b.seqpessoa = a.seqpessoa AND b.numerodf = a.nrotitulo AND b.seriedf = a.seriedoc AND b.statusdf = 'V'
LEFT JOIN implantacao.mad_pedvenda c 
ON c.seqpessoa = b.seqpessoa AND c.nropedvenda = b.nropedidovenda AND c.situacaoped = 'F' AND c.codgeraloper IN (201, 207, 314)
LEFT JOIN implantacao.mfl_dfitem d 
ON d.nroempresa = b.nroempresa AND d.numerodf = b.numerodf AND d.seriedf = b.seriedf AND d.nroserieecf = b.nroserieecf
WHERE 1=1	
AND a.obrigdireito = 'D'
AND a.dtainclusao >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -3)
GROUP BY a.nroempresa,a.seqpessoa,a.dtainclusao,a.seqtitulo,a.nroparcela,a.nrotitulo,b.numerodf,b.seriedf,b.nroserieecf
ORDER BY a.seqtitulo ASC,a.nroparcela ASC