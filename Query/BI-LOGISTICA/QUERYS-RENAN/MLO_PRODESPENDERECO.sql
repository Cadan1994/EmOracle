SELECT 
 		TO_CHAR(seqproduto) AS "ProdutoId",
		especieendereco AS "EndEspecieId",
		TO_CHAR(paletelastro) AS "Lastro",
		TO_CHAR(paletealtura) AS "Altura",
		qtdembalagem AS "Embalagem(Q)"
FROM implantacao.mlo_prodespendereco
WHERE 1=1
AND nroempresa = 1
AND seqproduto = 23442
ORDER BY seqproduto ASC
