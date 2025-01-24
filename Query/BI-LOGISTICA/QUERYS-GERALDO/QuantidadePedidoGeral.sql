SELECT 
	 DISTINCT
   a.nropedvenda,
	 TO_DATE(a.dtainclusao) AS dtainclusao,
   TO_DATE(a.dtainclusao + 8)
	 AS dtalimfatuta,
   DECODE(
	     a.indentregaretira,
			 'E', 'ENTREGA',
			 'R', 'RETIRA'
	 )
	 AS indentregaretira,
   a.seqpessoa,
	 b.nomerazao,
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
	 AS situacaoped,
   DECODE(
	     a.indcriticapedido, 
			 'F', 'FINANCEIRO', 
			 'B', 'COMERCIAL', 
			 '', 'COMERCIAL', 
			 'L', 'LIBERADO'
	 )
	 AS indcriticapedido,
   a.motcancelamento,
   ROUND(sysdate - a.dtainclusao)
	 AS quantidadedia,
   j.descrota
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
AND a.situacaoped NOT IN ('F', 'D', 'R')
AND (sysdate - a.dtainclusao) <= 8
AND TO_DATE(a.dtainclusao + 8) BETWEEN '26-mar-2024' AND '26-mar-2024'
GROUP BY a.nropedvenda, a.indentregaretira, a.nrocarga, a.seqpessoa,
         b.nomerazao, b.fantasia, a.situacaoped, a.dtainclusao, a.dtaalteracao,
         round(sysdate - a.dtainclusao), a.dtabasefaturamento, a.nrosegmento,
         d.descsegmento, a.dtalibcredped, j.descrota, a.motcancelamento,
         a.obspedido, a.INDCRITICAPEDIDO, a.dtahorgeracaonf, a.dtainclusao,
         a.dtageracaocarga, a.dtahorsituacaopedalt, a.usualteracao, a.usuaprovcredito,
				 e.qtdpedida, e.qtdatendida
ORDER BY 3 ASC