CREATE OR REPLACE VIEW POLIBRAS.VWP_TABELA_PRECO AS
SELECT
		t.u_pkey,
       t.u_orgvenda,
       t.s_codtabela,
       t.s_codproduto,
       t.d_faixa,
       t.u_referencia,
       t.d_preco,
       t.d_descontopadrao,
       t.d_cverbadesc,
       t.d_cverbaacres,
       t.u_situacao,
			 t.j_data
FROM (SELECT * 
      FROM polibras.cadan_tab_preco
			) t
---------------------------------------------------------------------------------------------------
-- Nome do objeto...........: VWP_TABELA_PRECO																								 	 --
-- Alterado por.............: HILSON SANTOS																											 --
-- Data da alteração........: 21/01/2025																												 --
-- Observação...............: FOI INCLUDO A COLUNA J_DATA					 												 			 --
---------------------------------------------------------------------------------------------------
