SELECT
	  a.seqcategoria 	        AS	codcategoria,   --> Código
    a.seqcategoriapai   	  AS  codsec,         --> Código da seção
	  a.categoria		          AS	categoria,      --> Descrição
    a.statuscategor         AS  status,
	  a.datahoraalteracao     AS  dtaalteracao
FROM implantacao.map_categoria a
WHERE 1 = 1
AND a.nivelhierarquia = 2
AND a.statuscategor = 'A'
ORDER BY 1 DESC;