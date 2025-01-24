SELECT 1 id,
    (SELECT COUNT(*) 
     FROM implantacao.mad_pedvenda a
     WHERE 1=1
     AND a.nroempresa = 1
		 AND a.situacaoped = 'L'
     AND a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 06:00:00', 'YYYY-MM-DD HH24:MI:SS') 
     AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 08:59:59', 'YYYY-MM-DD HH24:MI:SS')
    ) 
    AS "06 às 08 horas",
    (SELECT COUNT(*) 
     FROM implantacao.mad_pedvenda a
     WHERE 1=1
     AND a.nroempresa = 1
		 AND a.situacaoped = 'L'
		 AND a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 09:00:00', 'YYYY-MM-DD HH24:MI:SS') 
     AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 11:59:59', 'YYYY-MM-DD HH24:MI:SS')
    ) 
    AS "09 às 11 horas",
    (SELECT COUNT(*) 
     FROM implantacao.mad_pedvenda a
     WHERE 1=1
     AND a.nroempresa = 1
		 AND a.situacaoped = 'L'
		 AND a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 12:00:00', 'YYYY-MM-DD HH24:MI:SS') 
     AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 14:59:59', 'YYYY-MM-DD HH24:MI:SS')
    ) 
    AS "12 às 14 horas",
    (SELECT COUNT(*) 
     FROM implantacao.mad_pedvenda a
     WHERE 1=1
     AND a.nroempresa = 1
		 AND a.situacaoped = 'L'
		 AND a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 15:00:00', 'YYYY-MM-DD HH24:MI:SS') 
     AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 17:59:59', 'YYYY-MM-DD HH24:MI:SS')
    ) 
    AS "15 às 17 horas",
    (SELECT COUNT(*) 
     FROM implantacao.mad_pedvenda a
     WHERE 1=1
     AND a.nroempresa = 1
		 AND a.situacaoped = 'L'
		 AND a.dtahorsituacaopedalt BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 18:00:00', 'YYYY-MM-DD HH24:MI:SS') 
     AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 20:59:59', 'YYYY-MM-DD HH24:MI:SS')
    ) 
    AS "18 às 20 horas"
FROM DUAL