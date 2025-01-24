SELECT * 
FROM implantacao.edi_pedvenda a 
WHERE a.seqpessoa = 47734
AND a.dtainclusao BETWEEN '29-nov-2023' AND '30-nov-2023'
ORDER BY TO_DATE(a.dtainclusao) ASC

SELECT * 
FROM implantacao.mad_pedvenda a 
WHERE 1=1
AND a.seqpessoa = 47734
AND a.dtainclusao BETWEEN '01-JAN-2023' AND SYSDATE
ORDER BY TO_DATE(a.dtainclusao) ASC		 


SELECT * 
FROM implantacao.max_logalteracao a 
WHERE 1=1
--AND a.usualteracao = 'AFV'
AND a.seqidentifica IN (4237861,4237858)
--AND a.dtahoralteracao BETWEEN '12-JAN-2024' AND '13-JAN-2024'
ORDER BY 2 ASC