SELECT
    DISTINCT 
    j.descrota,
		a.seqpessoa,
    b.nomerazao,
    a.nropedvenda
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
AND a.situacaoped = 'L'
AND a.indentregaretira = 'E'
AND a.usuinclusao = 'ECOMMERCE'
AND a.nroformapagto = 6
ORDER BY 1 ASC
