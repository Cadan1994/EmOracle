SELECT 
		DISTINCT 
		a.seqnotafiscal, 
		a.numerodf, 
		a.statusdf, 
		a.statusnfe, 
		a.apporigemcanc, 
		b.seqnfelog, 
		b.dtalog, 
		b.descricao
FROM implantacao.mfl_doctofiscal a 
INNER JOIN implantacao.mfl_nfelog b ON b.seqnotafiscal = a.seqnotafiscal
WHERE 1=1
AND a.nroempresa = 1
AND a.statusnfe = 8
--AND a.numerodf BETWEEN 5264540 AND 5264550	
ORDER BY a.numerodf DESC , b.seqnfelog DESC