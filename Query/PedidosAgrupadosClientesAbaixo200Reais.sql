SELECT
		e.descrota AS Rota,
		d.descpraca AS Praca,
    a.seqpessoa||' <> '||b.nomerazao AS Cliente, 
		g.apelido,
		a.nropedvenda,
		a.situacaoped AS status,
		COUNT(DISTINCT a.nropedvenda) AS quantidade,
		SUM(((f.qtdatendida / f.qtdembalagem ) * f.vlrembinformado) + f.vlrtoticmsst) AS valor		
FROM implantacao.mad_pedvenda a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa
INNER JOIN implantacao.mad_clienteend c ON c.seqpessoa = b.seqpessoa 
INNER JOIN implantacao.mad_praca d ON d.seqpraca = c.seqpraca
INNER JOIN implantacao.mad_rota e ON e.seqrota = d.seqrota
INNER JOIN implantacao.mad_pedvendaitem f ON f.nroempresa = a.nroempresa AND f.nropedvenda = a.nropedvenda
INNER JOIN implantacao.mad_representante g ON g.nrorepresentante = a.nrorepresentante
WHERE 1=1
AND a.situacaoped IN ('A', 'L', 'S')
AND a.indentregaretira = 'E'
GROUP BY a.seqpessoa, a.nrorepresentante, a.situacaoped, b.nomerazao,a.nropedvenda, d.descpraca, e.descrota, g.apelido
HAVING (SELECT SUM(((b.qtdatendida / b.qtdembalagem ) * b.vlrembinformado) + b.vlrtoticmsst) AS valor		
        FROM implantacao.mad_pedvenda c
        INNER JOIN implantacao.mad_pedvendaitem b ON b.nroempresa = c.nroempresa AND b.nropedvenda = c.nropedvenda
        WHERE 1=1
				AND c.situacaoped IN ('A', 'L', 'S')
				AND c.indentregaretira = 'E'		
				AND c.seqpessoa = a.seqpessoa
				GROUP BY a.seqpessoa) < 200
ORDER BY 1 ASC, 2 ASC