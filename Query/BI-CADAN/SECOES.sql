SELECT
a.seqcategoria 	    AS	seqsecao,
a.categoria		    	AS	secao,
a.statuscategor     AS  status,
TO_DATE(a.datahoraalteracao) AS  dtaalteracao
FROM implantacao.map_categoria a
INNER JOIN implantacao.max_divisao b ON b.nrodivisao = a.nrodivisao
WHERE 1 = 1
AND a.nivelhierarquia = 1
AND a.statuscategor = 'A' 
AND a.actfamilia = 'N'
ORDER BY 1 ASC;