SELECT a.codespecie,a.seqpessoa,a.nrotitulo,a.seqtitulo,a.vlroriginal,a.usualteracao,a.situacao,b.seqtitulo,b.seqtitulonsu,b.nsu
FROM implantacao.fi_titulo a
LEFT JOIN implantacao.fi_titulonsu b ON b.seqtitulo = a.seqtitulo
WHERE 1=1
AND a.codespecie = 'CARTAO' 
AND a.dtamovimento >= '01-may-2023' 
AND A.SEQPESSOA = 37266
--AND a.nrotitulo IN (53903,53918,53924,4915802,4915803,4915804) --
ORDER BY 1 ASC, 2 ASC