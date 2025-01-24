SELECT 												 
		a.sequsuario,													 
    a.nroempresa,
		UPPER(a.codusuario) AS codusuario, 
		UPPER(a.nome) AS nome,
		a.tipousuario,
		a.nivel,
		a.seqpessoa,
		b.usersenha,
		b.userdtaimportacao
FROM implantacao.ge_usuario a
LEFT JOIN implantacao.cadan_pixusuarios b ON b.userid = a.sequsuario
WHERE 1=1
AND a.nroempresa IN (1, 2)	
AND a.nivel IN (3, 8)
AND (a.codusuario NOT LIKE ('C5%') AND(a.codusuario NOT LIKE ('DEVIT%') AND(a.codusuario NOT LIKE ('CONSINCO%')))) 
AND b.userdtaimportacao IS NULL 
ORDER BY a.sequsuario ASC