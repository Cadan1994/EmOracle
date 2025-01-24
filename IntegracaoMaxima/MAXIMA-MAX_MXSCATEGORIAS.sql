SELECT
	  a.seqcategoria 	        AS	codcategoria,   --> C�digo
    a.seqcategoriapai   	  AS  codsec,         --> C�digo da se��o
	  a.categoria		          AS	categoria,      --> Descri��o
    a.statuscategor         AS  status,
	  a.datahoraalteracao     AS  dtaalteracao
FROM implantacao.map_categoria a
WHERE 1 = 1
AND a.nivelhierarquia = 2
AND a.statuscategor = 'A'
ORDER BY 1 DESC;