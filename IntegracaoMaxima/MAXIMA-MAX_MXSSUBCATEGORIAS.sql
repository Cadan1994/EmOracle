SELECT
    c.seqcategoria      AS  codsubcategoria,
    a.seqcategoria      AS	codsec,
    b.seqcategoria      AS  codcategoria,
	  c.categoria		      AS	subcategoria,
    a.statuscategor     AS  status,
	  c.datahoraalteracao AS  dtaalteracao
FROM implantacao.map_categoria a
INNER JOIN implantacao.map_categoria b ON b.seqcategoriapai = a.seqcategoria AND b.nivelhierarquia = 2 AND b.statuscategor = 'A'
INNER JOIN implantacao.map_categoria c ON c.seqcategoriapai = b.seqcategoria AND c.nivelhierarquia = 3 AND c.statuscategor = 'A'
WHERE 1 = 1
AND a.nivelhierarquia = 1
AND a.statuscategor = 'A'
ORDER BY 1 ASC;
