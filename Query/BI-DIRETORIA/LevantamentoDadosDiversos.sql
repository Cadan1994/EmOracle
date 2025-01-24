SELECT
		a.nroempresa,	
		a.dtavda,
		a.codgeraloper,
		ROUND(
		SUM(
		implantacao.fC5_AbcDistribLucratividade(
		'L',
		'L',
		'N',
		ROUND(a.vlritem,2),
		'S',
		a.vlricmsst,
		a.vlrfcpst,
		a.vlricmsstemporig,
		g.uf,
		a.ufpessoa,
		'S',
		j.vlrdescregra,
		'N',
		a.vlripiitem,
		a.vlripidevolitem,
		'N',
		a.vlrdescforanf,
		b.cmdiavlrnf-0,
		b.cmdiaipi,
		NVL(b.cmdiacredpis,0),
		NVL(b.cmdiacredcofins,0),
		b.cmdiaicmsst,
		b.cmdiadespnf,
		b.cmdiadespforanf,
		b.cmdiadctoforanf,
		'S',
		c.propqtdprodutobase,
		a.qtditem,
		a.vlrembdescressarcst,
		a.acmcompravenda,
		a.pisitem,
		a.cofinsitem,
		DECODE(a.tipcgo,'S',b.qtdvda,NVL(b.qtddevol,b.qtdvda)),
		(DECODE(a.tipcgo,'S',b.vlrimpostovda - NVL(b.vlripivda,0),NVL(((b.vlrimpostodevol / DECODE(NVL(b.qtddevol,0),0,1,b.qtddevol)) * a.qtddevolitem) - NVL(a.vlripidevolitem,0), 
		b.vlrimpostovda - NVL( b.vlripivda,0)))),
		'N',
		a.vlrdespoperacionalitem,
		b.vlrdespesavda,
		'N',
		NVL(b.vlrverbavdaacr,0),
		b.qtdverbavda,
		b.vlrverbavda - NVL(b.vlrverbavdaindevida,0),
		'N',
		NVL(a.vlrtotcomissaoitem,0),
		a.vlrdevolitem,
		a.vlrdevolicmsst,
		a.dvlrfcpst,
		a.qtddevolitem,
		a.pisdevolitem,
		a.cofinsdevolitem,
		a.vlrdespoperacionalitemdevol,
		a.vlrtotcomissaoitemdevol,
		g.perirlucrat,
		g.percslllucrat,
		b.cmdiacredicms,
		DECODE(a.icmsefetivoitem,0,a.ICMSITEM,a.icmsefetivoitem),
		a.vlrfcpicms,
		a.percpmf,
		a.peroutroimposto,
		DECODE(a.icmsefetivodevolitem,0,a.icmsdevolitem,a.icmsefetivodevolitem),
		a.Dvlrfcpicms, 
		CASE 
		WHEN ('S') = 'N' 
		THEN (NVL(b.cmdiavlrdescpistransf,0) 
		     +NVL(b.cmdiavlrdesccofinstransf,0)
				 +NVL(b.cmdiavlrdescicmstransf,0)
				 +NVL(b.cmdiavlrdescipitransf,0)
				 +NVL(b.cmdiavlrdesclucrotransf,0)
				 +NVL(b.cmdiavlrdescverbatransf,0))
		ELSE 0
		END, 
		CASE 
		WHEN h.utilacresccustprodrelac = 'S' and NVL(c.seqprodutobase,c.seqprodutobaseantigo) IS NOT NULL
		THEN COALESCE(i.percacresccustorelacvig,NVL(implantacao.f_retacresccustorelacabc(a.seqproduto,a.dtavda),1))
		ELSE 1 
		END,
		'N',
		0,
		0,
		'S',
		a.vlrdescmedalha,
		'S',
		a.vlrdescfornec,
		a.vlrdescfornecdevol,
		'N',
		a.vlrfreteitemrateio,
		a.vlrfreteitemrateiodev,
		'S',
		a.vlricmsstembutprod,
		a.vlricmsstembutproddev,
		a.vlrembdescressarcstdevol,
		CASE 
		WHEN 'N' = 'S' 
		THEN NVL(a.vlrdescacordoverbapdv,0)
		ELSE 0 
		END,
		NVL(b.cmdiacredipi,0),NVL(a.vlritemrateiocte,0),'N','C')) * 100 / 100, 2)
		AS LUCRATIVIDADE, 
		ROUND(SUM(a.vlritem - a.vlricmsst - a.vlrfcpst - a.vlrdevolitem + a.vlrdevolicmsst + a.dvlrfcpst), 2)
		AS VENDAS,
		ROUND(SUM((a.qtditem - a.qtddevolitem) / f.qtdembalagem * f.pesobruto), 2) 
		AS PESOBRUTO
FROM implantacao.maxv_abcdistribbase a, 
		 implantacao.mrl_custodiafam b, 
		 implantacao.map_produto c, 
		 implantacao.map_produto d, 
		 implantacao.map_famdivisao e, 
		 implantacao.map_famembalagem f, 
		 implantacao.max_empresa g, 
		 implantacao.max_divisao h, 
		 implantacao.map_prodacresccustorelac i, 
		 implantacao.mrlv_descontoregra j 
WHERE 1 = 1 
AND a.seqproduto = c.seqproduto
AND a.seqprodutocusto = d.seqproduto
AND a.nrodivisao = e.nrodivisao
AND a.seqproduto = i.seqproduto(+)
AND a.dtavda = i.dtamovimentacao(+)
AND a.dtavda = j.datafaturamento (+)
AND a.nrodocto = j.numerodf (+)
AND a.seriedocto = j.seriedf (+) 
AND a.nroempresa = j.nroempresa (+) 	 
AND DECODE(a.tiptabela,'S',a.cgoacmcompravenda,a.acmcompravenda) IN ('S', 'I')
AND a.nrosegmento IN (1, 3, 4, 5, 6, 7, 8, 9, 10)
AND a.seqpessoa NOT IN (1, 22401)
AND b.nroempresa = NVL(g.nroempcustoabc, g.nroempresa) 
AND b.dtaentradasaida = a.dtavda
AND b.seqfamilia = d.seqfamilia
AND e.seqfamilia = c.seqfamilia
AND e.nrodivisao = a.nrodivisao
AND e.seqcomprador NOT IN (8, 11)		
AND f.seqfamilia = c.seqfamilia AND f.qtdembalagem = 1 AND a.seqproduto = j.seqproduto (+) 
AND g.nroempresa = a.nroempresa
AND g.nrodivisao = h.nrodivisao
AND a.dtavda BETWEEN TRUNC(ADD_MONTHS(SYSDATE, 0),'MM') AND TRUNC(SYSDATE)
GROUP BY a.nroempresa,a.dtavda, a.codgeraloper 
ORDER BY a.dtavda ASC