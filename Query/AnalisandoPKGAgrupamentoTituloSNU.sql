SELECT
    a.nroempresa,
    c.seqpessoa,
    c.dtainclusao,
    c.dtavencimento,
    c.seqtitulo,
    c.nrotitulo,
    c.dtaemissao,
    c.dtaquitacao,
    c.vlroriginal,
    d.nropedvenda,
    d.dtamovimento,
    d.nsu,
    d.rede,
    d.bandeira,
    e.nsu
FROM implantacao.mad_pedvenda a
INNER JOIN implantacao.mfl_doctofiscal b ON b.nrosegmento = a.nrosegmento AND b.nrocarga IN a.nrocarga
INNER JOIN implantacao.fi_titulo c ON c.nrotitulo = b.numerodf
INNER JOIN implantacao.mad_pedvendansu d ON d.nropedvenda = a.nropedvenda
LEFT JOIN implantacao.fi_titulonsu e ON e.seqtitulo = c.seqtitulo
INNER JOIN implantacao.fi_especie f ON f.codespecie = c.codespecie AND f.nroempresamae = c.nroempresamae
INNER JOIN implantacao.fi_compltitulo g ON g.seqtitulo = c.seqtitulo
WHERE 1=1
AND a.situacaoped = 'F'
AND a.usuinclusao = 'ECOMMERCE'
AND c.abertoquitado = 'A'
AND c.obrigdireito = 'D' 
AND c.codespecie IN ('CARDEB', 'CARTAO', 'TICKET')
AND c.seqpessoa != 37266
AND c.dtaemissao between '11-FEB-2024' AND '29-FEB-2024'	
ORDER BY d.dtamovimento ASC