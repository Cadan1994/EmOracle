SELECT
    DECODE(
        a.situacaoped, 
        'L', 'LIBERADO', 
        'S', 'SEPARACAO'
    )
    AS situacaoped,
    a.nrosegmento,
    TO_DATE(a.dtainclusao) 
    AS dtainclusao,
    SUM(a.totpesobrutoatendido)
    AS pesobruto,
    SUM(a.totpesoliquidoatendido)
    AS pesoliquido,
    SUM( a.vtotinformadoatendido )
    AS vtotinformadoatendido
FROM implantacao.maxv_abcpedvdabase a
WHERE 1=1
AND a.nrodivisaoep in (1)
AND a.nroempresaped = 1
AND a.nrosegmento in (1,3,4,5,6,7,8,9,10)
AND NOT EXISTS (SELECT 1
                FROM implantacao.mad_pedvendacontrol
                WHERE nropedvendaant = a.nropedvenda	AND a.situacaoped = 'C')			
AND a.dtainclusao BETWEEN TO_DATE(TO_CHAR(SYSDATE-8, 'YYYY-MM-DD')|| ' 00:00:00', 'YYYY-MM-DD HH24:MI:SS') 
AND SYSDATE
AND a.acmcompravenda IN ('S', 'I')
AND a.indacertoprepago IN ('S', 'D', 'Q', 'N')
AND a.tippedido IN ('B', 'C', 'L', 'O', 'V', 'X')
AND a.situacaoped IN ('L')
GROUP BY a.situacaoped,a.nrosegmento,a.dtainclusao	
ORDER BY 3 ASC