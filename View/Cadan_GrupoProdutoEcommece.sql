/*
View que traz o grupo de produtos cadastrado no campo "PALAVRACHAVEECOMMERCE" da tabela "MAP_PRODUTO"
QUEM CRIOU..........: Hilson Santos
DATA DA CRIAÇÃO.....: 15/01/2024
DATA DA ALTERAÇÃO 1.: 23/02/2024
*/
CREATE OR REPLACE VIEW implantacao.Cadan_GrupoProdutoEcommerce 
AS
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
SELECT a.grupo, a.seqproduto, a.desccompleta, b.promocao
FROM DADOS a
/* 
INCLUIDO O RELACIONAMENTO COM A TABELA MRL_PROMOCAOITEM
QUEM ALTEROU........: Hilson Santos
DATA DA ALTERAÇÃO...: 23/02/2024
*/
LEFT JOIN (SELECT DISTINCT seqproduto, 'S' promocao FROM implantacao.mrl_promocaoitem WHERE dtafimprom >= SYSDATE) b 
ON b.seqproduto = a.seqproduto
WHERE grupo IS NOT NULL	