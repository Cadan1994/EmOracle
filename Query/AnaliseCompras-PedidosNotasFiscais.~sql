SELECT
    DISTINCT
    I.SEQPRODUTO as CodProduto,
    PR.DESCCOMPLETA as DESCPRODUTO, 
		I.NUMERONF as nronota,
    I.SERIENF as serienf,
		x.nropedidosuprim,
		NVL(to_char(A.DTAENTRADA, 'DD-MM-YYYY'),
    TO_CHAR(I.DTAMOVTOITEM, 'dd-mm-yyyy')) as DtaEntrada,
    A.SEQPESSOA as CodPessoa,
    G.NOMERAZAO as NomeRazao,
    I.EMBALAGEM || ' - ' || I.QTDEMBALAGEM EMBALAGEM,
    SUM(ROUND(x.vlrembitem + x.vlrembipi + x.vlrembicmsst + x.vlrembdesconto + x.vlrembdespesa + x.vlrembfrete, 2)) pedido_un,
    SUM(ROUND(((i.vlritem + i.vlripi + i.vlricmsst + i.vlrdesptributitem + i.vlrdespntributitem - i.vlrdescitem + i.vlrfrete + i.vlrfretenanf)/i.quantidade) * i.qtdembalagem, 2)) VLRNF_un,
		I.QTDEMBALAGEM as QtdEmbalagem,
		SUM(round(ABS((ROUND(I.VLRITEM / i.quantidade, 8) /
                   ROUND(X.VLREMBITEM / X.QTDEMBALAGEM, 8) - 1) * 100),
               3)) as PERDIFERENCA,	
							 
    SUM(ROUND((I.VLRITEM / i.quantidade) - (X.VLREMBITEM / X.QTDEMBALAGEM),
               4)) as TOTALDIVERG,
        
    SUM(ROUND((x.vlrembitem + x.vlrembipi + x.vlrembicmsst + x.vlrembdesconto + x.vlrembdespesa + x.vlrembfrete) -
    (((i.vlritem + i.vlripi + i.vlricmsst + i.vlrdesptributitem + i.vlrdespntributitem - i.vlrdescitem + i.vlrfrete + i.vlrfretenanf)/i.quantidade) * i.qtdembalagem), 2)) as Divergencia,
          
         decode(nvl(r.nropedidosuprim, 0), 0, 'SEM PED.', r.nropedidosuprim) as NROPEDIDO,
         nvl(r.qtdrecebida, i.quantidade) / I.QTDEMBALAGEM as QTDNOTA,
         X.QTDSOLICITADA / X.QTDEMBALAGEM QTDPEDIDO,
         A.JUSTIFACEITEPEDIDO as Justificativa,
         A.USUACEITEPEDIDO as UsuAceite,
         nvl(implantacao.Fpegavencimento(a.numeronf, a.serienf, a.seqpessoa), 0) as vencimento,
         (nvl(x.vlrembverbacompra, 0) *
         (nvl(r.qtdrecebida, i.quantidade) /
         nvl(x.qtdembalagem, I.QTDEMBALAGEM))) as verba, 
				 
         SUM(ROUND(((((X.VLREMBITEM
                  +nvl(x.vlrembipi, 0) - nvl(x.vlrembdesconto, 0) +
                  nvl(x.vlrembdespesa, 0) + nvl(x.vlrembicmsst, 0))
                   * nvl(r.qtdrecebida, i.quantidade)) / x.qtdembalagem) *
         nvl(x.qtdembalagem, i.qtdembalagem)) /
         nvl(x.qtdembalagem, i.qtdembalagem),2)) pedidototal,
         
         SUM(ROUND((I.VLRITEM 
				          + i.vlripi + i.vlricmsst + i.vlrdesptributitem +
                  i.vlrdespntributitem - i.vlrdescitem + i.vlrfretenanf) / (i.quantidade / i.qtdembalagem) *
         nvl(r.qtdrecebida, i.quantidade) /
         nvl(x.qtdembalagem, i.qtdembalagem),2)) VLRNFTotal,
         
         SUM(round((i.vlrdespforanf), 4) / (i.quantidade / i.qtdembalagem) *
         (nvl(r.qtdrecebida, i.quantidade) /
          nvl(x.qtdembalagem, i.qtdembalagem))) Vlr_Desp
					
  FROM implantacao.MLF_NFITEM            I,
       implantacao.msuv_psitemrecebidonf r, 
       implantacao.MSU_PEDIDOSUPRIM      P,
       implantacao.MSU_PSITEMRECEBER     X, 
       implantacao.MLF_NOTAFISCAL        A, 
       implantacao.GE_PESSOA             G,
       implantacao.MAP_PRODUTO           PR,
       implantacao.MAX_EMPRESA           E

 where r.seqproduto = I.SEQPRODUTO
   AND r.nroEMPRESA = I.NROEMPRESA
   AND r.numeronf = I.NUMERONF
   AND P.NROPEDIDOSUPRIM = R.NROPEDIDOSUPRIM
   AND P.NROEMPRESA = R.NROEMPRESA
   AND P.CENTRALLOJA = R.CENTRALLOJA
   AND X.NROPEDIDOSUPRIM = R.NROPEDIDOSUPRIM
   AND X.NROEMPRESA = R.NROEMPRESA
   AND X.CENTRALLOJA = R.CENTRALLOJA
   AND X.SEQPRODUTO = R.SEQPRODUTO
   AND X.NROPEDIDOSUPRIM = P.NROPEDIDOSUPRIM
   AND X.NROEMPRESA      = P.NROEMPRESA
   AND I.NUMERONF = A.NUMERONF
   AND I.NROEMPRESA = A.NROEMPRESA
   AND I.SERIENF = A.SERIENF
   AND I.SEQPESSOA = A.SEQPESSOA
   AND I.TIPNOTAFISCAL = A.TIPNOTAFISCAL
   AND NVL(I.TIPPEDCOMPRAITEM, A.TIPPEDIDOCOMPRA) = P.TIPPEDIDOSUPRIM
   AND G.SEQPESSOA = A.SEQPESSOA
   AND PR.SEQPRODUTO = I.SEQPRODUTO
   AND E.NROEMPRESA = I.NROEMPRESA
   AND I.NUMERONF = :NR1
	 AND I.SERIENF = :LT1
   AND g.nrocgccpf || lpad(g.digcgccpf, 2, 0) = :NR2
	 GROUP BY I.NUMERONF,
    I.SERIENF,
		x.nropedidosuprim,
		A.DTAENTRADA,
    I.DTAMOVTOITEM,
    A.SEQPESSOA,
    G.NOMERAZAO,
    I.SEQPRODUTO,
    PR.DESCCOMPLETA,
    I.EMBALAGEM,
		I.QTDEMBALAGEM,
		r.nropedidosuprim ,
		r.qtdrecebida,
		i.quantidade,
		X.QTDSOLICITADA,
		X.QTDEMBALAGEM,
		A.JUSTIFACEITEPEDIDO,
		A.USUACEITEPEDIDO,
		a.numeronf,
		a.serienf,
		x.vlrembverbacompra