SELECT a.seqproduto,a.estqdeposito,a.qtdreservadavda
FROM implantacao.mrl_produtoempresa a
WHERE 1 = 1
AND a.nroempresa = 2
AND a.statuscompra = 'A' 
AND a.seqproduto IN (31446)
AND (a.estqdeposito + a.qtdreservadavda) <> 0
--FOR UPDATE;

