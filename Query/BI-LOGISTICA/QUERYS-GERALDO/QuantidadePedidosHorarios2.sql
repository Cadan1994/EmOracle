SELECT 
    a.nropedvenda,
		a.dtahorsituacaopedalt DATA,	 
		CASE 
		WHEN a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '06:00:00', 'YYYY-MM-DD HH24:MI:SS') 
		                            AND     TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '08:59:59', 'YYYY-MM-DD HH24:MI:SS')
		THEN '06 AS 09'
		WHEN a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '09:00:00', 'YYYY-MM-DD HH24:MI:SS') 
		                            AND     TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '11:59:59', 'YYYY-MM-DD HH24:MI:SS')
		THEN '09 AS 12'
		WHEN a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '12:00:00', 'YYYY-MM-DD HH24:MI:SS') 
		                            AND     TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '14:59:59', 'YYYY-MM-DD HH24:MI:SS')
		THEN '12 AS 15'
		WHEN a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '15:00:00', 'YYYY-MM-DD HH24:MI:SS') 
		                            AND     TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '16:59:59', 'YYYY-MM-DD HH24:MI:SS')
		THEN '15 AS 18'
		WHEN a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '17:00:00', 'YYYY-MM-DD HH24:MI:SS') 
		                            AND     TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '19:59:59', 'YYYY-MM-DD HH24:MI:SS')
		THEN '18 AS 20'
		ELSE ''
		END INTERVALO
FROM implantacao.mad_pedvenda a 
WHERE 1=1
AND a.nroempresa = 1
AND a.situacaoped = 'L'
AND a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 06:00:00', 'YYYY-MM-DD HH24:MI:SS') 
AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 08:59:59', 'YYYY-MM-DD HH24:MI:SS')	 		
ORDER BY 2 DESC

