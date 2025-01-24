CREATE OR REPLACE VIEW POLIBRAS.VWP_TABELA_PRECOPLB AS
SELECT t.u_pkey,
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
  FROM (SELECT
			 			DISTINCT
			 			0 u_pkey,
            d.nroempresa u_orgvenda,
            b.nrosegmento || '.' || e.nrotabvenda s_codtabela,
            a.seqproduto || '.' || c.qtdembalagem s_codproduto,
            0 d_faixa,
            1 u_referencia,
  					ROUND(d.precogernormal,2) d_preco,
            0 d_descontopadrao,
            b.percmaxdescflex d_cverbadesc,
            b.percmaxacrflex d_cverbaacres,
            0 u_situacao,
						TO_CHAR('{"acrescimo_tabela":'||g.peracrentrega||'}') j_data
        FROM implantacao.map_produto a
				JOIN implantacao.mad_famsegmento b
				ON b.seqfamilia = a.seqfamilia AND b.status = 'A'
        JOIN implantacao.map_famembalagem c
				ON c.seqfamilia = b.seqfamilia AND c.status = 'A'
        JOIN implantacao.mrl_prodempseg d
				ON d.seqproduto = a.seqproduto AND d.nrosegmento = b.nrosegmento AND d.qtdembalagem = c.qtdembalagem AND d.statusvenda = 'A'
        JOIN implantacao.mad_segtabvenda e
				ON e.nrosegmento = d.nrosegmento AND e.status = 'A'
        JOIN implantacao.map_prodcodigo f
				ON f.qtdembalagem = c.qtdembalagem AND f.qtdembalagem = d.qtdembalagem AND f.seqproduto = a.seqproduto AND f.Indutilvenda = 'S'
				JOIN implantacao.mad_tabvenda g ON g.nrotabvenda = e.nrotabvenda AND g.status = 'A' AND g.indprecobase = 'VN'
        JOIN implantacao.mad_segtabvenda h
				ON h.nrosegmento = e.nrosegmento AND h.nrotabvenda = e.nrotabvenda AND h.status = 'A'
        JOIN implantacao.map_famdivisao i
				ON i.seqfamilia = a.seqfamilia AND i.seqfamilia = b.seqfamilia AND i.seqfamilia = c.seqfamilia
        JOIN implantacao.mad_tabvendatrib j
				ON j.nrotributacao = i.nrotributacao AND j.nrotabvenda = h.nrotabvenda AND j.nrotabvenda = e.nrotabvenda
        WHERE 1=1
        ) t
---------------------------------------------------------------------------------------------------
-- Nome do objeto...........: VWP_TABELA_PRECOPLB																								 --
-- Alterado por.............: HILSON SANTOS																											 --
-- Data da alteração........: 21/01/2025																												 --
-- Observação...............: FOI ALTERADO A LINHA 22 MODIFICANDO A VIEW VWP_TABELA_PRECO_301117 --
-- 														E INCLUINDO A COLUNA D_ACRTABELA					 												 --
---------------------------------------------------------------------------------------------------

