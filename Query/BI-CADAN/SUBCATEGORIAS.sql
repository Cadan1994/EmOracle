SELECT
    c.seqcategoria                  AS  seqsubcategoria,
    a.seqcategoria                  AS	seqsecao,
    b.seqcategoria                  AS  seqcategoria,
    c.categoria 				    AS 	subcategoria,
    a.statuscategor,
    TO_DATE(c.datahoraalteracao)    AS datahoraalteracao
FROM implantacao.map_categoria a
INNER JOIN implantacao.map_categoria b 
ON b.seqcategoriapai = a.seqcategoria AND b.nivelhierarquia = 2 AND b.statuscategor = 'A'
INNER JOIN implantacao.map_categoria c 
ON c.seqcategoriapai = b.seqcategoria AND c.nivelhierarquia = 3 AND c.statuscategor = 'A'
WHERE 1 = 1
AND a.nivelhierarquia = 1
AND a.statuscategor = 'A'
AND c.datahoraalteracao >= TO_DATE(SYSDATE -5)
ORDER BY 1 ASC