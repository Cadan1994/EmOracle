SELECT 
    DISTINCT
    w.seqpessoa,
    a.nomerazao,
    a.fantasia,
    a.atividade,
    TO_CHAR(a.dtainclusao, 'DD/MM/YYYY') AS data,
    'R$ ' || e.Limitecredito AS limite,
    a.Logradouro || ',' || a.nrologradouro AS endereco,
    'BAIRRO: ' || a.bairro AS bairro,
    'CIDADE: ' || a.cidade AS cidade,
    'UF: ' || a.uf AS uf,
    a.cep AS cep,
    a.foneddd1 || a.fonenro1 AS fone,
    a.nrocgccpf || '-' || LPAD(a.digcgccpf, 2, 0) AS cpfcnpj,
		LISTAGG(g.descequipe, '; ') WITHIN GROUP (ORDER BY w.Seqpessoa) AS equipes,
		LISTAGG(w.nrorepresentante||'-'||apelido, '; ') WITHIN GROUP (ORDER BY w.seqpessoa) AS representante
FROM (SELECT y.seqpessoa,
		         y.nrorepresentante,
             MAX(DECODE(seq, 1, nrorepresentante, '0')) Primeiro,
             MAX(DECODE(seq, 2, nrorepresentante, '0')) Segundo,
             MAX(DECODE(seq, 3, nrorepresentante, '0')) Terceiro,
             MAX(DECODE(seq, 4, nrorepresentante, '0')) Quarto,
             MAX(DECODE(seq, 5, nrorepresentante, '0')) Quinto
			FROM (SELECT x.seqpessoa,
					         x.nrorepresentante,
									 ROW_NUMBER() OVER(PARTITION BY x.seqpessoa ORDER BY x.nrorepresentante) seq
						FROM implantacao.mad_clienterep x) y
						GROUP BY y.seqpessoa, y.nrorepresentante) w
JOIN implantacao.ge_pessoacadastro e ON e.seqpessoa = w.seqpessoa
JOIN implantacao.ge_pessoa a ON a.seqpessoa = w.seqpessoa
JOIN implantacao.mad_representante b ON b.nrorepresentante = w.nrorepresentante
JOIN implantacao.ge_pessoa c ON c.seqpessoa = b.seqpessoa
JOIN implantacao.mad_equipe g ON g.nroequipe = b.nroequipe
GROUP BY w.Seqpessoa,
    		 a.Nomerazao,
    		 a.Fantasia,
    		 a.atividade,
				 a.Dtainclusao,
				 e.Limitecredito,
				 a.Logradouro,
				 a.Nrologradouro,
				 a.bairro,
				 a.cidade,
				 a.uf,
				 a.cep,
				 a.foneddd1,
				 a.Fonenro1,
				 a.nrocgccpf,
				 a.digcgccpf
