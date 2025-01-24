SELECT a.seqpessoa,b.nomerazao,b.fantasia,b.palavrachave
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.ge_pessoa b 
ON b.seqpessoa = a.seqpessoa 
AND b.fisicajuridica = 'F' 
AND (b.nomerazao != b.fantasia OR(b.nomerazao != b.palavrachave))
WHERE 1 = 1
AND a.seqpessoa not in (1,22401)
AND a.statuscliente = 'A'
ORDER BY 1 ASC