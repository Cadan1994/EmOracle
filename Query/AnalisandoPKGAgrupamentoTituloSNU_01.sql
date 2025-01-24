SELECT * 
FROM implantacao.fi_titulo
WHERE seqtitulo IN (SELECT seqtitulo 
                    FROM implantacao.fi_titulo
                    WHERE 1=1
                    AND codespecie = 'CARTAO'
                    AND abertoquitado = 'A'
                    AND seqpessoa != '37266'
                    AND dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023')
ORDER BY seqpessoa ASC --FOR UPDATE
/*
UPDATE 
implantacao.fi_titulo
SET vlrpago=0,dtaquitacao='',abertoquitado='A'
WHERE seqtitulo IN (SELECT seqtitulo 
                    FROM implantacao.fi_titulo
                    WHERE 1=1
                    AND codespecie = 'CARTAO'
                    AND seqpessoa != '37266'
                    AND dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023')

SELECT * 
FROM implantacao.fi_titulo a 
WHERE 1=1
AND a.codespecie = 'CARTAO'
AND a.seqpessoa != '37266'
AND a.dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023' ORDER BY a.dtaemissao DESC
*/
--SELECT c.* FROM implantacao.fi_titulonsu c WHERE c.dtamovimento BETWEEN '10-DEC-2023' AND '16-DEC-2023' ORDER BY 4 ASC
--SELECT * FROM implantacao.fi_compltitulo d ORDER BY 1 DESC

/*
DELETE 
FROM implantacao.fi_titulo a 
WHERE seqtitulo IN (SELECT seqtitulo 
                    FROM implantacao.fi_titulo a 
                    WHERE 1=1
                    AND a.codespecie = 'CARTAO'
                    AND a.seqpessoa = '37266'
                    AND a.dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023')

DELETE 
FROM implantacao.fi_compltitulo 
WHERE seqtitulo IN (SELECT seqtitulo 
                    FROM implantacao.fi_titulo a 
                    WHERE 1=1
                    AND a.codespecie = 'CARTAO'
                    AND a.seqpessoa = '37266'
                    AND a.dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023')

DELETE FROM implantacao.fi_titulonsu WHERE seqtitulo IN (456544726)
*/
--SELECT * FROM implantacao.Fi_Baixacartaoarquivo WHERE ARQUIVO = 'EEXTRATO_03122023_09122023_VENDA.TXT'
--DELETE FROM implantacao.Fi_Baixacartaoarquivo WHERE ARQUIVO = 'EEXTRATO_19112023_25112023_VENDA.TXT'

/*
UPDATE implantacao.fi_titulonsu a
SET a.nomearqconciliado = '',a.conciliado = 'N',a.dtaconciliado = ''
WHERE 1=1
AND a.nomearqconciliado = 'EEXTRATO_19112023_25112023_VENDA.TXT'
AND a.dtamovimento >= '19-nov-2023'

SELECT * 
FROM implantacao.fi_logbaixatitauto 
WHERE seqtitulo IN (SELECT seqtitulo 
                    FROM implantacao.fi_titulo a 
                    WHERE 1=1
                    AND a.codespecie = 'CARTAO'
                    AND a.seqpessoa = '37266'
                    AND a.dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023')
DELETE FROM implantacao.fi_logbaixatitauto WHERE data BETWEEN '10-DEC-2023' AND '16-DEC-2023'

SELECT * 
FROM implantacao.fi_titoperacao 
WHERE seqtitulo IN (SELECT seqtitulo 
                    FROM implantacao.fi_titulo a 
                    WHERE 1=1
                    AND a.codespecie = 'CARTAO'
                    AND a.seqpessoa = '37266'
                    AND a.dtaemissao BETWEEN '10-DEC-2023' AND '16-DEC-2023')

DELETE FROM implantacao.fi_titoperacao WHERE dtaoperacao BETWEEN '10-DEC-2023' AND '16-DEC-2023'

SELECT * 
FROM implantacao.fi_movocor 
*/