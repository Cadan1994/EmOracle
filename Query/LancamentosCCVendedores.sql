SELECT b.situacaoped, a.*
FROM implantacao.mad_repccflex a	
LEFT JOIN implantacao.mad_pedvenda b ON b.nropedvenda = a.nropedvenda AND b.nrorepresentante = a.nrorepresentante
WHERE 1=1
AND a.situacaolancto = 'A'
AND a.dtalancamento >= '01-jul-2024'
AND a.nrorepresentante = 300
ORDER BY 1 DESC, 7 ASC
--FOR UPDATE;

--DELETE FROM implantacao.mad_repccflex WHERE nrorepresentante = 300 AND dtalancamento >= '01-aug-2023'
--UPDATE implantacao.mad_repccflex SET valor = 765.26 WHERE seqlanctoflex = 2872293