SELECT  DISTINCT a.seqpessoa,b.nomerazao,c.usualteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.ge_pessoa b 
ON b.seqpessoa = a.seqpessoa AND b.fisicajuridica = 'J' AND b.status = 'A'
INNER JOIN implantacao.mad_clientecgo c 
ON c.seqpessoa = b.seqpessoa AND c.status = 'A' AND c.codgeraloper = 307
INNER JOIN implantacao.mad_pedvenda d 
ON d.nroempresa = a.nroempresa AND d.seqpessoa = a.seqpessoa AND d.codgeraloper=c.codgeraloper
WHERE 1 = 1
AND a.seqpessoa not in (1,22401)
AND a.statuscliente = 'A'
ORDER BY 1 ASC