SELECT
		e.descrota AS Rota,
    a.seqpessoa||' <> '||b.nomerazao AS Cliente,
		COUNT(DISTINCT a.nropedvenda) AS quantidade,
		SUM(((f.qtdatendida / f.qtdembalagem ) * f.vlrembinformado) + f.vlrtoticmsst) AS valor		
FROM implantacao.mad_pedvenda a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa
INNER JOIN implantacao.mad_clienteend c ON c.seqpessoa = b.seqpessoa 
INNER JOIN implantacao.mad_praca d ON d.seqpraca = c.seqpraca
INNER JOIN implantacao.mad_rota e ON e.seqrota = d.seqrota
INNER JOIN implantacao.mad_pedvendaitem f ON f.nroempresa = a.nroempresa AND f.nropedvenda = a.nropedvenda
WHERE 1=1
AND a.situacaoped IN ('A', 'L', 'S')
AND a.indentregaretira = 'E'
GROUP BY a.seqpessoa, b.nomerazao, e.descrota
HAVING SUM(((f.qtdatendida / f.qtdembalagem ) * f.vlrembinformado) + f.vlrtoticmsst) < 200
ORDER BY 1 ASC, 2 ASC