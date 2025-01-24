SELECT
    a.seqcategoria AS	seqcategoria,
		a.seqcategoriapai AS seqsecao,
		a.categoria,
		a.statuscategor AS status,
		TO_DATE(a.datahoraalteracao) AS dtaalteracao
FROM implantacao.map_categoria a
WHERE 1 = 1
AND a.statuscategor = 'A'
AND a.nivelhierarquia = 2
ORDER BY 1 ASC;