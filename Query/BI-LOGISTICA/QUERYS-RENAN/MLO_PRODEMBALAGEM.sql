SELECT 
		TO_CHAR(seqproduto) AS "ProdutoId",
		embalagem	 AS	"Embalagem",
		qtdembalagem AS "Embalagem(Q)" 
FROM implantacao.mlo_prodembalagem
WHERE 1=1	
AND nroempresa = 1
ORDER BY seqproduto ASC
