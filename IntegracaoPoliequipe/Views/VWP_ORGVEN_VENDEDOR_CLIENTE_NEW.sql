CREATE OR REPLACE VIEW POLIBRAS.VWP_ORGVEN_VENDEDOR_CLIENTE AS
SELECT
    DISTINCT
		0 u_pkey,
    a.nroempresa u_orgvenda,
    a.seqpessoa s_codcliente,
   	b.nrorepresentante s_codvendedor,
 		(c.limitecredito - d.vlrcreduso) d_limite_credito,
    0 d_descpetalao,
    2 u_prazoentrega,
		NVL(e.jsondata, '{"foco":"", "colgate_faixa":"", "frequencia_atendimento":"S"}')
		AS
		j_data
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mad_clienterep b ON b.seqpessoa = a.seqpessoa AND b.status = 'A'
INNER JOIN implantacao.ge_pessoacadastro c ON c.seqpessoa = a.seqpessoa
INNER JOIN implantacao.mrl_clientecreduso d ON d.seqpessoa = a.seqpessoa
LEFT  JOIN implantacao.cadan_clientefocofaixa e ON e.seqpessoa = a.seqpessoa
WHERE 1=1
AND a.statuscliente = 'A'

