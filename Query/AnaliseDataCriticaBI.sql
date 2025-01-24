SELECT
    DISTINCT
		a.nroempresa,
    a.seqproduto,
		a.qtdatual,
		b.qtdpalete,
		b.qtdembalagem,
		b.dtavalidade,
    c.estqdeposito,
    c.qtdreservadavda
FROM implantacao.mlo_endereco a
INNER JOIN implantacao.mlo_paleteqtde b ON b.seqpaleterf = a.seqpaleterf
INNER JOIN implantacao.mrl_produtoempresa c ON c.nroempresa = a.nroempresa AND c.seqproduto = a.seqproduto 
WHERE 1=1
--AND nroempresa = 1
AND a.seqproduto = 462
--GROUP BY a.nroempresa, a.seqproduto, b.dtavalidade
ORDER BY 3 ASC