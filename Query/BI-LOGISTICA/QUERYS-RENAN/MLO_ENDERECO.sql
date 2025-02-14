SELECT 
    DISTINCT	
		--codrua AS "RuaId",
		nropredio	AS "Predio",
		nroapartamento AS "Apartamento",
		nrosala AS "Sala"
		/*
		
		,
		,
		especieendereco AS "EndEspecieId",
		statusendereco AS "Status"
		
		indterreoaereo,
		seqpaleterf AS "PaleteId",
		seqproduto AS "ProdutoId",
		qtdembalagem AS "Embalagem(Q)",
		(qtdatual/qtdembalagem) AS "Atual(Q)",
		statusendereco AS "Status",
		dtaalteracao AS "Data Altera��o"
		*/
FROM implantacao.mlo_endereco
WHERE 1=1
AND nroempresa = 1
AND codrua LIKE '0%'
AND statusendereco != 'I'	
AND codrua = '015'		
AND especieendereco = 'P'
GROUP BY codrua,nropredio,nroapartamento,nrosala,especieendereco,statusendereco 
ORDER BY 1, 2, 3 ASC