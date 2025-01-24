SELECT
    DISTINCT
		a.nroempresa,
    a.seqproduto,
		CASE
		WHEN a.precogerpromoc = 0
		THEN a.precogernormal
		ELSE a.precogerpromoc
		END
		AS precovenda
FROM implantacao.mrl_prodempseg a
WHERE 1 = 1
AND a.nrosegmento IN (1, 3, 4, 5, 6, 7, 8, 9, 10)
AND a.statusvenda = 'A'
ORDER BY 2 ASC, 1 ASC;
