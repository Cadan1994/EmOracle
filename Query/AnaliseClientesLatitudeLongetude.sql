SELECT 
    DISTINCT
    a.seqpessoa,
    b.nomerazao,
    b.cep,
    b.logradouro||','||b.nrologradouro AS logradouro,
    b.bairro,
    b.cidade,
    b.uf,
    b.pais
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa AND b.status = 'A'
INNER JOIN implantacao.gev_pessoacadastro c ON c.seqpessoa = b.seqpessoa
INNER JOIN implantacao.ge_pessoacadastro d ON d.seqpessoa = c.seqpessoa and d.seqpessoa = b.seqpessoa
INNER JOIN (SELECT NVL(MAX(percacrdesccomerc), 0) percacrdesccomerc, seqpessoa
            FROM implantacao.mrl_clienteseg
          	WHERE 1=1
						AND status = 'A'
          	GROUP BY seqpessoa) e
ON a.seqpessoa = e.seqpessoa
WHERE 1=1
AND a.statuscliente = 'A'
AND a.seqpessoa = 35853
