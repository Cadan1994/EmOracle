SELECT
	  a.seqcategoria 	    AS	codsec,
    a.nrodivisao		    AS  codepto,
	  a.categoria		      AS	descricao,
    a.statuscategor     AS  status,
	  a.datahoraalteracao AS  dtaalteracao
FROM implantacao.map_categoria a
INNER JOIN implantacao.max_divisao b ON b.nrodivisao = a.nrodivisao
WHERE 1 = 1
and nivelhierarquia = 1
AND statuscategor = 'A' 
AND actfamilia = 'N'
ORDER BY 1 ASC;