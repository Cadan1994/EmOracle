SELECT b.nroempresa,b.codgeraloper,SUM(a.vlritem)
FROM implantacao.mlf_nfitem a
INNER JOIN implantacao.mlf_notafiscal b ON b.nroempresa = a.nroempresa AND b.seqpessoa = a.seqpessoa 
AND b.numeronf = a.numeronf AND b.serienf = a.serienf AND b.tipnotafiscal = a.tipnotafiscal
WHERE 1 = 1
AND b.codgeraloper = 122
AND b.dtaentrada BETWEEN '01-DEC-2023' AND '31-DEC-2023' 
AND a.seqproduto = 322
GROUP BY b.nroempresa,codgeraloper
ORDER BY 2 ASC, 1 ASC