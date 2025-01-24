SELECT * 
FROM implantacao.edi_pedvenda a 
WHERE 1=1
AND a.nropedidoafv = 1000009245

SELECT * 
FROM implantacao.mad_pedvenda a 
WHERE 1=1
AND a.nropedidoafv = 1000009245		 


SELECT * 
FROM implantacao.max_logalteracao a 
WHERE 1=1
--AND a.usualteracao = 'ECOMMERCE'
AND a.dtahoralteracao BETWEEN '29-NOV-2023' AND SYSDATE
AND a.seqidentifica in (4237861,4237858,2582099)
ORDER BY 2 ASC