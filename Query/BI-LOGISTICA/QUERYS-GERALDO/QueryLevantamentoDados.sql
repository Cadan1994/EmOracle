SELECT 
   a.nropedvenda as pedido,	
	 a.dtainclusao,
   --a.dtahorsituacaopedalt,
   --a.dtabasefaturamento,
   --a.dtaalteracao,
   --to_char(a.dtalibcredped, 'DD/MM/YYYY')|| '-' || a.usuaprovcredito as dta_lib_financeiro ,
   to_date (a.dtainclusao + 8)as dtalimfatutamento,
   --a.dtahorgeracaonf as dtahorafaturamento,
   DECODE(
	     a.indentregaretira,
			 'E', 'ENTREGA',
			 'R', 'RETIRA'
	 ) 
	 as entregaretira,
   --a.nrocarga as carga,
   --a.dtageracaocarga,
   a.seqpessoa as cliente,
   DECODE(
	     a.situacaoped, 
			 'A', 'ANALISE', 
			 'C', 'CANCELADO', 
			 'D', 'DIGITACAO', 
			 'F', 'FATURADO', 
			 'L', 'LIBERADO', 
			 'P', 'PRE-SEPARACAO', 
			 'R', 'RETEIRIZACAO', 
			 'S', 'SEPARACAO', 
			 'W', 'SEPARADO'
	 ) 
	 as situacao,
   DECODE(
	     a.indcriticapedido, 
			 'F', 'FINANCEIRO', 
			 'B', 'COMERCIAL', 
			 '', 'COMERCIAL', 
			 'L', 'LIBERADO'
	 ) 
	 as situcaodescricao,
   a.motcancelamento as motivocancelamento,
   ROUND(sysdate - a.dtainclusao)  as qtddia,
   --a.dtabasefaturamento,
   --a.nrosegmento as cod_segmento,
   --a.obspedido as obs_pedido
   b.nomerazao as nomerazaosocial,
   --b.fantasia as fantasia,
   --d.descsegmento as segmento,
   sum(e.qtdatendida / e.qtdembalagem * e.vlrembinformado) as vlr_pedido,
   --sum((f.pesoliquido / e.qtdembalagem) * e.qtdatendida) as peso_liq,
   --sum((f.pesobruto / e.qtdembalagem) * e.qtdatendida) as peso_bruto,
   j.descrota as rota
FROM implantacao.mad_pedvenda     a,
     implantacao.ge_pessoa        b,
     implantacao.mad_segmento     d,
     implantacao.mad_pedvendaitem e,
     implantacao.map_famembalagem f,
     implantacao.map_produto      g,
     implantacao.mad_clienteend   h,
     implantacao.mad_praca        i,
     implantacao.mad_rota         j
WHERE 1=1
AND b.seqpessoa = a.seqpessoa
AND h.seqpessoa = a.seqpessoa
AND d.nrosegmento = a.nrosegmento
AND e.nropedvenda = a.nropedvenda
AND e.qtdembalagem = f.qtdembalagem
AND e.seqproduto = g.seqproduto
AND f.seqfamilia = g.seqfamilia
AND h.seqpraca = i.seqpraca
AND i.seqrota = j.seqrota
AND a.nroempresa = 1
AND a.situacaoped <> 'F'
AND a.situacaoped <> 'D'
AND a.situacaoped <> 'R'
AND (sysdate - a.dtainclusao) <= 8
GROUP BY a.nropedvenda, a.indentregaretira, a.nrocarga, a.seqpessoa,
         b.nomerazao, b.fantasia, a.situacaoped, a.dtainclusao, a.dtaalteracao,
         round(sysdate - a.dtainclusao), a.dtabasefaturamento, a.nrosegmento,
         d.descsegmento, a.dtalibcredped, j.descrota, a.motcancelamento,
         a.obspedido, a.INDCRITICAPEDIDO, a.dtahorgeracaonf, a.dtainclusao,
         a.dtageracaocarga, a.dtahorsituacaopedalt, a.usualteracao, a.usuaprovcredito
ORDER BY a.dtainclusao ASC