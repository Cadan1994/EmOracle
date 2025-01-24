SELECT 
		TO_CHAR(seqproduto) AS "ProdutoId",
		desccompleta AS "Descricao",
		padraoembcompra AS "Embalagem Compra(Q)",
		padraoembvenda AS "Embalagem Venda(Q)",
		statuscompra AS "Status Compra",
		statusvenda AS "Status Venda",
		NVL(dtahoralteracao,dtainclusao) AS "Data Alteração"
FROM implantacao.mlo_produto a
WHERE 1=1
AND nroempresa = 1	
ORDER BY seqproduto ASC