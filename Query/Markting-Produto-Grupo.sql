WITH DADOS AS (
		 SELECT 
		     REGEXP_SUBSTR(UPPER(palavrachaveecommerce), '[^;]+', 1, 1) grupo,
				 seqproduto,
				 desccompleta
		 FROM implantacao.map_produto
		 WHERE palavrachaveecommerce IS NOT NULL
		 UNION ALL
		 SELECT 
		     REGEXP_SUBSTR(UPPER(palavrachaveecommerce), '[^;]+', 1, 2) grupo,
				 seqproduto,
				 desccompleta
		 FROM implantacao.map_produto
		 WHERE palavrachaveecommerce IS NOT NULL
		 UNION ALL
		 SELECT 
		     REGEXP_SUBSTR(UPPER(palavrachaveecommerce), '[^;]+', 1, 3) grupo,
				 seqproduto,
				 desccompleta
		 FROM implantacao.map_produto
		 WHERE palavrachaveecommerce IS NOT NULL
		 UNION ALL
		 SELECT 
		     REGEXP_SUBSTR(UPPER(palavrachaveecommerce), '[^;]+', 1, 4) grupo,
				 seqproduto,
				 desccompleta
		 FROM implantacao.map_produto
		 WHERE palavrachaveecommerce IS NOT NULL
		 UNION ALL
		 SELECT 
		     REGEXP_SUBSTR(UPPER(palavrachaveecommerce), '[^;]+', 1, 5) grupo,
				 seqproduto,
				 desccompleta
		 FROM implantacao.map_produto
		 WHERE palavrachaveecommerce IS NOT NULL
		 UNION ALL
		 SELECT 
		     REGEXP_SUBSTR(UPPER(palavrachaveecommerce), '[^;]+', 1, 6) grupo,
				 seqproduto,
				 desccompleta
		 FROM implantacao.map_produto
		 WHERE palavrachaveecommerce IS NOT NULL
)				 
SELECT 
    grupo,
		seqproduto,
		desccompleta
FROM DADOS
WHERE grupo IS NOT NULL	