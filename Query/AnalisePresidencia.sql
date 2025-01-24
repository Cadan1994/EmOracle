SELECT
      a.nroempresa,
      a.seqfornecedor,
      a.seqcomprador,
      a.seqfamilia,
      a.seqproduto,
      a.desccompleta,
      -------------------------------------------------------------------------
      NVL(
        ROUND(
        	(
            SELECT SUM(NVL((t1.qtditem - t1.qtddevolitem)/t1.qtdembalitem,0)) qtditemliquido
            FROM implantacao.maxv_abcdistribbase t1
            INNER JOIN implantacao.map_produto t2 ON t2.seqproduto = t1.seqproduto
            WHERE 1 = 1
            AND t1.nroempresa = a.nroempresa
            AND t1.seqproduto = a.seqproduto
            AND t1.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) IN ('S','I')
            AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)) AND TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)))
          )
        ),
      0)
      AS "Mês Out2022",
      -------------------------------------------------------------------------
      NVL(
        ROUND(
        	(
            SELECT SUM(NVL((t1.qtditem - t1.qtddevolitem)/t1.qtdembalitem,0)) qtditemliquido
            FROM implantacao.maxv_abcdistribbase t1
            INNER JOIN implantacao.map_produto t2 ON t2.seqproduto = t1.seqproduto
            WHERE 1 = 1
            AND t1.nroempresa = a.nroempresa
            AND t1.seqproduto = a.seqproduto
            AND t1.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) IN ('S','I')
            AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-2)) AND TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-2)))
          )
        ),
      0)  
      AS "Mês Nov2022",
      -------------------------------------------------------------------------
      NVL(
        ROUND(
        	(
            SELECT SUM(NVL((t1.qtditem - t1.qtddevolitem)/t1.qtdembalitem,0)) qtditemliquido
            FROM implantacao.maxv_abcdistribbase t1
            INNER JOIN implantacao.map_produto t2 ON t2.seqproduto = t1.seqproduto
            WHERE 1 = 1
            AND t1.nroempresa = a.nroempresa
            AND t1.seqproduto = a.seqproduto
            AND t1.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) IN ('S','I')
            AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)) AND TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))
          )
        ),
      0)
      AS "Mês Dez2022",
      -------------------------------------------------------------------------
      NVL(
        ROUND(
        	(
            SELECT SUM(NVL((t1.qtditem - t1.qtddevolitem)/t1.qtdembalitem,0)) qtditemliquido
            FROM implantacao.maxv_abcdistribbase t1
            INNER JOIN implantacao.map_produto t2 ON t2.seqproduto = t1.seqproduto
            WHERE 1 = 1
            AND t1.nroempresa = a.nroempresa
            AND t1.seqproduto = a.seqproduto
            AND t1.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) IN ('S','I')
            AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)) AND TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))
          )/3
        ),
      0)
      AS "Média Out,Nov,Dez2022",
      -------------------------------------------------------------------------
      NVL(
        ROUND(
        	(
            SELECT SUM(NVL((t1.qtditem - t1.qtddevolitem)/t1.qtdembalitem,0)) qtditemliquido
            FROM implantacao.maxv_abcdistribbase t1
            INNER JOIN implantacao.map_produto t2 ON t2.seqproduto = t1.seqproduto
            WHERE 1 = 1
            AND t1.nroempresa = a.nroempresa
            AND t1.seqproduto = a.seqproduto
            AND t1.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) IN ('S','I')
            AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),0)) AND TO_DATE(SYSDATE)
          )
        ),
      0)
      AS "Mês Jan2023",
      -------------------------------------------------------------------------
      NVL(
      ROUND(
        (SELECT
          SUM(
          implantacao.fC5_AbcDistribLucratividade(
          'L','L','N',ROUND(t1.vlritem,2),'S',t1.vlricmsst,t1.vlrfcpst,t1.vlricmsstemporig,t7.uf,t1.ufpessoa,'S',t11.vlrdescregra,'N',
          t1.vlripiitem,t1.vlripidevolitem,'N',t1.vlrdescforanf,t2.cmdiavlrnf-0,t2.cmdiaipi,NVL(t2.cmdiacredpis,0),NVL(t2.cmdiacredcofins,0),t2.cmdiaicmsst,
          t2.cmdiadespnf,t2.cmdiadespforanf,t2.cmdiadctoforanf,'S',t3.propqtdprodutobase,t1.qtditem,t1.vlrembdescressarcst,t1.acmcompravenda,t1.pisitem,
          t1.cofinsitem,DECODE(t1.tipcgo,'S',t2.qtdvda,NVL(t2.qtddevol,t2.qtdvda)),
          (DECODE(t1.tipcgo,'S',t2.vlrimpostovda - NVL(t2.vlripivda,0), 
          NVL(((t2.vlrimpostodevol / DECODE(NVL(t2.qtddevol,1),1,1,t2.qtddevol)) * t1.qtddevolitem) - NVL(t1.vlripidevolitem,0), 
          t2.vlrimpostovda - NVL( t2.vlripivda,0)))),
          'N',t1.vlrdespoperacionalitem,t2.vlrdespesavda,'N',NVL(t2.vlrverbavdaacr,0),t2.qtdverbavda,
          t2.vlrverbavda - NVL(t2.vlrverbavdaindevida,0),'N',NVL(t1.vlrtotcomissaoitem,0),t1.vlrdevolitem,
          t1.vlrdevolicmsst,t1.dvlrfcpst,t1.qtddevolitem,t1.pisdevolitem,t1.cofinsdevolitem,t1.vlrdespoperacionalitemdevol,
          t1.vlrtotcomissaoitemdevol,t7.perirlucrat,t7.percslllucrat,t2.cmdiacredicms,
          DECODE(t1.icmsefetivoitem,0,t1.ICMSITEM,t1.icmsefetivoitem),
          t1.vlrfcpicms,t1.percpmf,t1.peroutroimposto,
          DECODE(t1.icmsefetivodevolitem,0,t1.icmsdevolitem,t1.icmsefetivodevolitem),t1.Dvlrfcpicms, 
          CASE 
          WHEN ( 'S' ) = 'N' 
          THEN (NVL(t2.cmdiavlrdescpistransf,0) + NVL(t2.cmdiavlrdesccofinstransf,0) + NVL(t2.cmdiavlrdescicmstransf,0) + NVL(t2.cmdiavlrdescipitransf,0) + NVL(t2.cmdiavlrdesclucrotransf,0) + NVL(t2.cmdiavlrdescverbatransf,0))
          ELSE 0
          END, 
          CASE 
          WHEN t8.utilacresccustprodrelac = 'S' and NVL(t3.seqprodutobase,t3.seqprodutobaseantigo) IS NOT NULL
          THEN COALESCE(t9.percacresccustorelacvig,NVL(implantacao.f_retacresccustorelacabc(t1.seqproduto,t1.dtavda),1))
          ELSE 1 
          END,
          'N',0,0,'S',t1.vlrdescmedalha,'S',t1.vlrdescfornec,t1.vlrdescfornecdevol,'N',t1.vlrfreteitemrateio,t1.vlrfreteitemrateiodev,
          'S',t1.vlricmsstembutprod,t1.vlricmsstembutproddev,t1.vlrembdescressarcstdevol,
          CASE 
          WHEN 'N' = 'S' 
          THEN NVL(t1.vlrdescacordoverbapdv,0)
          ELSE 0 
          END,
          NVL(t2.cmdiacredipi,0),
          NVL(t1.vlritemrateiocte,0),
          'N',
          'C') * 100)
        FROM implantacao.maxv_abcdistribbase t1, 
             implantacao.mrl_custodiafam t2, 
             implantacao.map_produto t3, 
             implantacao.map_produto t4, 
             implantacao.map_famdivisao t5, 
             implantacao.map_famembalagem t6, 
             implantacao.max_empresa t7, 
             implantacao.max_divisao t8, 
             implantacao.map_prodacresccustorelac t9, 
             implantacao.mrlv_descontoregra t11 
        WHERE 1 = 1 
        AND t5.seqfamilia = t3.seqfamilia
        AND t5.nrodivisao = t1.nrodivisao
        AND t1.seqproduto = t3.seqproduto
        AND t1.seqprodutocusto = t4.seqproduto
        AND t1.nrodivisao = t5.nrodivisao
        AND t7.nroempresa = t1.nroempresa
        AND t7.nrodivisao = t8.nrodivisao
        AND t1.seqproduto = t9.seqproduto(+)
        AND t1.dtavda = t9.dtamovimentacao(+)
        AND t2.nroempresa = NVL( t7.nroempcustoabc, t7.nroempresa ) 
        AND t2.dtaentradasaida = t1.dtavda
        AND t6.seqfamilia = t3.seqfamilia AND t6.qtdembalagem = 1 AND t1.seqproduto = t11.seqproduto (+) 
        AND t1.dtavda = t11.datafaturamento (+)
        AND t1.nrodocto = t11.numerodf (+)
        AND t1.seriedocto = t11.seriedf (+) 
        AND t1.nroempresa = t11.nroempresa (+) 
        AND t2.seqfamilia = t4.seqfamilia
        AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) in ('S','I')
        AND t1.nrosegmento in (1,6,5,4,9,7,10,8,3)
        AND t1.seqpessoa NOT IN (1,22401)
        AND t5.seqcomprador NOT IN (8,11)
        AND t1.nroempresa = a.nroempresa
        AND t1.seqproduto = a.seqproduto
        AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)) AND TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))),
      2),0)
      AS "Lucro 3 Ultimos Meses R$",
      -------------------------------------------------------------------------
      NVL(
      ROUND(
        (SELECT
          SUM(t1.vlritem - t1.vlricmsst - t1.vlrfcpst - t1.vlrdevolitem + t1.vlrdevolicmsst + t1.dvlrfcpst) 
        FROM implantacao.maxv_abcdistribbase t1, 
             implantacao.mrl_custodiafam t2, 
             implantacao.map_produto t3, 
             implantacao.map_produto t4, 
             implantacao.map_famdivisao t5, 
             implantacao.map_famembalagem t6, 
             implantacao.max_empresa t7, 
             implantacao.max_divisao t8, 
             implantacao.map_prodacresccustorelac t9, 
             implantacao.mrlv_descontoregra t11 
        WHERE 1 = 1 
        AND t5.seqfamilia = t3.seqfamilia
        AND t5.nrodivisao = t1.nrodivisao
        AND t1.seqproduto = t3.seqproduto
        AND t1.seqprodutocusto = t4.seqproduto
        AND t1.nrodivisao = t5.nrodivisao
        AND t7.nroempresa = t1.nroempresa
        AND t7.nrodivisao = t8.nrodivisao
        AND t1.seqproduto = t9.seqproduto(+)
        AND t1.dtavda = t9.dtamovimentacao(+)
        AND t2.nroempresa = NVL( t7.nroempcustoabc, t7.nroempresa ) 
        AND t2.dtaentradasaida = t1.dtavda
        AND t6.seqfamilia = t3.seqfamilia AND t6.qtdembalagem = 1 AND t1.seqproduto = t11.seqproduto (+) 
        AND t1.dtavda = t11.datafaturamento (+)
        AND t1.nrodocto = t11.numerodf (+)
        AND t1.seriedocto = t11.seriedf (+) 
        AND t1.nroempresa = t11.nroempresa (+) 
        AND t2.seqfamilia = t4.seqfamilia
        AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) in ('S','I')
        AND t1.nrosegmento in (1,6,5,4,9,7,10,8,3)
        AND t1.seqpessoa NOT IN (1,22401)
        AND t5.seqcomprador NOT IN (8,11)
        AND t1.nroempresa = a.nroempresa
        AND t1.seqproduto = a.seqproduto
        AND t1.dtavda BETWEEN TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)) AND TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))),
      2),0)
      AS "Vendas 3 Ultimos Meses R$",
      -------------------------------------------------------------------------
      SUM(NVL(a.qtdreservadavda, 0)) 
      AS "Reserva Venda",
      -------------------------------------------------------------------------
      ROUND(
            (
             SELECT SUM((estqdeposito + estqloja) - NVL(qtdreservadavda,0))
             FROM	implantacao.mrl_produtoempresa
             WHERE	1=1
             AND nroempresa = a.nroempresa
             AND seqproduto = a.seqproduto
             )
      )
      AS "Estoque",
      SUM(a.qtdpendpedcompra) AS "Pedidos Receber",
      SUM(a.qtdpendpedexped) AS "Pedidos Expedir",
      -------------------------------------------------------------------------
      ROUND(
            SUM(
                DECODE('N','S',
                implantacao.fmrl_MediaCustoDia(a.nroempresa,a.seqproduto,TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)),TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))),
                a.medvdiageral) /
                DECODE('V','C',NVL(b.padraoembcomprafornec,a.padraoembcompra),a.padraoembvenda)
            ),
      2) 
      AS "Venda Dia",
      -------------------------------------------------------------------------
      ROUND(
            SUM(
                DECODE(DECODE('N','S',
                implantacao.fmrl_MediaCustoDia(a.nroempresa,a.seqproduto,TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)),TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))), 
                a.medvdiageral),0,0,
                ((a.estqdeposito + a.estqloja - NVL(a.qtdreservadavda,0)) /
                DECODE('N','S',
                implantacao.fmrl_MediaCustoDia(a.nroempresa,a.seqproduto,TO_DATE(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)),TO_DATE(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)))),
                a.medvdiageral)))
            ) 
      )      
      AS "Estoque Dia",      
      -------------------------------------------------------------------------
      NVL(
      ROUND(
        (
        SELECT
          (SUM(
          implantacao.fC5_AbcDistribLucratividade(
          'L','L','N',ROUND(t1.vlritem,2),'S',t1.vlricmsst,t1.vlrfcpst,t1.vlricmsstemporig,t7.uf,t1.ufpessoa,'S',t11.vlrdescregra,'N',
          t1.vlripiitem,t1.vlripidevolitem,'N',t1.vlrdescforanf,t2.cmdiavlrnf-0,t2.cmdiaipi,NVL(t2.cmdiacredpis,0),NVL(t2.cmdiacredcofins,0),t2.cmdiaicmsst,
          t2.cmdiadespnf,t2.cmdiadespforanf,t2.cmdiadctoforanf,'S',t3.propqtdprodutobase,t1.qtditem,t1.vlrembdescressarcst,t1.acmcompravenda,t1.pisitem,
          t1.cofinsitem,DECODE(t1.tipcgo,'S',t2.qtdvda,NVL(t2.qtddevol,t2.qtdvda)),
          (DECODE(t1.tipcgo,'S',t2.vlrimpostovda - NVL(t2.vlripivda,0), 
          NVL(((t2.vlrimpostodevol / DECODE(NVL(t2.qtddevol,0),0,1,t2.qtddevol)) * t1.qtddevolitem) - NVL(t1.vlripidevolitem,0), 
          t2.vlrimpostovda - NVL( t2.vlripivda,0)))),
          'N',t1.vlrdespoperacionalitem,t2.vlrdespesavda,'N',NVL(t2.vlrverbavdaacr,0),t2.qtdverbavda,
          t2.vlrverbavda - NVL(t2.vlrverbavdaindevida,0),'N',NVL(t1.vlrtotcomissaoitem,0),t1.vlrdevolitem,
          t1.vlrdevolicmsst,t1.dvlrfcpst,t1.qtddevolitem,t1.pisdevolitem,t1.cofinsdevolitem,t1.vlrdespoperacionalitemdevol,
          t1.vlrtotcomissaoitemdevol,t7.perirlucrat,t7.percslllucrat,t2.cmdiacredicms,
          DECODE(t1.icmsefetivoitem,0,t1.ICMSITEM,t1.icmsefetivoitem),
          t1.vlrfcpicms,t1.percpmf,t1.peroutroimposto,
          DECODE(t1.icmsefetivodevolitem,0,t1.icmsdevolitem,t1.icmsefetivodevolitem),t1.Dvlrfcpicms, 
          CASE 
          WHEN ( 'S' ) = 'N' 
          THEN (NVL(t2.cmdiavlrdescpistransf,0) + NVL(t2.cmdiavlrdesccofinstransf,0) + NVL(t2.cmdiavlrdescicmstransf,0) + NVL(t2.cmdiavlrdescipitransf,0) + NVL(t2.cmdiavlrdesclucrotransf,0) + NVL(t2.cmdiavlrdescverbatransf,0))
          ELSE 0
          END, 
          CASE 
          WHEN t8.utilacresccustprodrelac = 'S' and NVL(t3.seqprodutobase,t3.seqprodutobaseantigo) IS NOT NULL
          THEN COALESCE(t9.percacresccustorelacvig,NVL(implantacao.f_retacresccustorelacabc(t1.seqproduto,t1.dtavda),1))
          ELSE 1 
          END,
          'N',0,0,'S',t1.vlrdescmedalha,'S',t1.vlrdescfornec,t1.vlrdescfornecdevol,'N',t1.vlrfreteitemrateio,t1.vlrfreteitemrateiodev,
          'S',t1.vlricmsstembutprod,t1.vlricmsstembutproddev,t1.vlrembdescressarcstdevol,
          CASE 
          WHEN 'N' = 'S' 
          THEN NVL(t1.vlrdescacordoverbapdv,0)
          ELSE 0 
          END,
          NVL(t2.cmdiacredipi,0),NVL(t1.vlritemrateiocte,0),'N','C') * 100) / SUM(t1.vlritem - t1.vlricmsst - t1.vlrfcpst - t1.vlrdevolitem + t1.vlrdevolicmsst + t1.dvlrfcpst)
        )
        FROM implantacao.maxv_abcdistribbase t1, 
             implantacao.mrl_custodiafam t2, 
             implantacao.map_produto t3, 
             implantacao.map_produto t4, 
             implantacao.map_famdivisao t5, 
             implantacao.map_famembalagem t6, 
             implantacao.max_empresa t7, 
             implantacao.max_divisao t8, 
             implantacao.map_prodacresccustorelac t9, 
             implantacao.mrlv_descontoregra t11 
        WHERE 1 = 1 
        AND t5.seqfamilia = t3.seqfamilia
        AND t5.nrodivisao = t1.nrodivisao
        AND t1.seqproduto = t3.seqproduto
        AND t1.seqprodutocusto = t4.seqproduto
        AND t1.nrodivisao = t5.nrodivisao
        AND t7.nroempresa = t1.nroempresa
        AND t7.nrodivisao = t8.nrodivisao
        AND t1.seqproduto = t9.seqproduto(+)
        AND t1.dtavda = t9.dtamovimentacao(+)
        AND t2.nroempresa = NVL( t7.nroempcustoabc, t7.nroempresa ) 
        AND t2.dtaentradasaida = t1.dtavda
        AND t6.seqfamilia = t3.seqfamilia AND t6.qtdembalagem = 1 AND t1.seqproduto = t11.seqproduto (+) 
        AND t1.dtavda = t11.datafaturamento (+)
        AND t1.nrodocto = t11.numerodf (+)
        AND t1.seriedocto = t11.seriedf (+) 
        AND t1.nroempresa = t11.nroempresa (+) 
        AND t2.seqfamilia = t4.seqfamilia
        AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) in ('S','I')
        AND t1.nrosegmento in (1,6,5,4,9,7,10,8,3)
        AND t1.seqpessoa NOT IN (1,22401)
        AND t5.seqcomprador NOT IN (8,11)
        AND t1.nroempresa = a.nroempresa
        AND t1.seqproduto = a.seqproduto
        AND t1.dtavda BETWEEN TRUNC(SYSDATE,'MM') AND TO_DATE(SYSDATE -1)),
      2),0)
      AS "Lucro Mes Atual R$",
      -------------------------------------------------------------------------
      NVL(
      ROUND(
        (SELECT
          SUM(t1.vlritem - t1.vlricmsst - t1.vlrfcpst - t1.vlrdevolitem + t1.vlrdevolicmsst + t1.dvlrfcpst) 
        FROM implantacao.maxv_abcdistribbase t1, 
             implantacao.mrl_custodiafam t2, 
             implantacao.map_produto t3, 
             implantacao.map_produto t4, 
             implantacao.map_famdivisao t5, 
             implantacao.map_famembalagem t6, 
             implantacao.max_empresa t7, 
             implantacao.max_divisao t8, 
             implantacao.map_prodacresccustorelac t9, 
             implantacao.mrlv_descontoregra t11 
        WHERE 1 = 1 
        AND t5.seqfamilia = t3.seqfamilia
        AND t5.nrodivisao = t1.nrodivisao
        AND t1.seqproduto = t3.seqproduto
        AND t1.seqprodutocusto = t4.seqproduto
        AND t1.nrodivisao = t5.nrodivisao
        AND t7.nroempresa = t1.nroempresa
        AND t7.nrodivisao = t8.nrodivisao
        AND t1.seqproduto = t9.seqproduto(+)
        AND t1.dtavda = t9.dtamovimentacao(+)
        AND t2.nroempresa = NVL( t7.nroempcustoabc, t7.nroempresa ) 
        AND t2.dtaentradasaida = t1.dtavda
        AND t6.seqfamilia = t3.seqfamilia AND t6.qtdembalagem = 1 AND t1.seqproduto = t11.seqproduto (+) 
        AND t1.dtavda = t11.datafaturamento (+)
        AND t1.nrodocto = t11.numerodf (+)
        AND t1.seriedocto = t11.seriedf (+) 
        AND t1.nroempresa = t11.nroempresa (+) 
        AND t2.seqfamilia = t4.seqfamilia
        AND DECODE(t1.tiptabela,'S',t1.cgoacmcompravenda,t1.acmcompravenda) in ('S','I')
        AND t1.nrosegmento in (1,6,5,4,9,7,10,8,3)
        AND t1.seqpessoa NOT IN (1,22401)
        AND t5.seqcomprador NOT IN (8,11)
        AND t1.nroempresa = a.nroempresa
        AND t1.seqproduto = a.seqproduto
        AND t1.dtavda BETWEEN TRUNC(SYSDATE,'MM') AND TO_DATE(SYSDATE -1)),
      2),0)
      AS "Vendas Mes Atual R$",
      -------------------------------------------------------------------------
      a.embcompra || ' com ' || ROUND(a.qtdembalagem) AS "Emb.Compra"
      -------------------------------------------------------------------------
FROM implantacao.maxv_mgmbaseprodseg a
INNER JOIN implantacao.map_famfornec b ON a.seqfamilia = b.seqfamilia --AND b.seqfornecedor = '124'
WHERE 1=1
--AND a.nroempresa = 1
AND a.nrodivisao = 1
AND a.qtdembalagem = a.padraoembvenda
AND a.statusvenda = 'A'
AND a.statuscompra = 'A'
--AND a.seqproduto IN (1202,1219,41665,32257,20884)
--AND a.seqcomprador = '6'
GROUP BY a.nroempresa,
         a.seqfornecedor,
         a.seqcomprador,
         a.seqfamilia,
      	 a.seqproduto,
      	 a.desccompleta,
      	 a.qtdembalagem,
         a.embcompra
ORDER BY a.desccompleta ASC         
;
