SELECT
    a.seqfamilia, 
		a.nrosegmento,
		a.perdespesasegmento, 
		a.status,
		a.usualteracao,
		a.dtaalteracao,
		b.desccompleta
FROM implantacao.mad_famsegmento a
LEFT JOIN implantacao.map_produto b ON b.seqfamilia = a.seqfamilia
WHERE 1=1
AND a.perdespesasegmento = 22 --IS NOT NULL	 

/*
UPDATE implantacao.mad_famsegmento
SET    a.perdespesasegmento = 4.00, 
			 a.usualteracao = "IMPLANTACAO",
			 a.dtaalteracao = SYSDATE
WHERE 1=1
AND a.perdespesasegmento IS NOT NULL
*/