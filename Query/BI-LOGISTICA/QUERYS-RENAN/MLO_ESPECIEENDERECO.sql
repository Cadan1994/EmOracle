SELECT
    especieendereco AS "EndEspecieId",
		descespecie AS "Descrição" 
FROM implantacao.mlo_especieendereco
WHERE 1=1
AND nroempresa = 1
AND statusespecieendereco = 'A'