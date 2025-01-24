SELECT
    DECODE(
        a.situacaoped, 
        'L', 'LIBERADO',
				'R', 'LIBERADO',
				'S', 'SEPARACAO'
    )
    AS situacaoped,
		a.nrosegmento,
    TO_DATE(a.dtainclusao) 
    AS dtainclusao,	
		TO_DATE(a.dtabasefaturamento) 
    AS dtabasefaturamento,	
		TO_DATE(a.dtageracaocarga) 
    AS dtageracaocarga,	 
		SUM(NVL((d.pesobruto / b.qtdembalagem) * b.qtdatendida, 0))
    AS pesobruto,	 
		SUM(NVL((d.pesoliquido / b.qtdembalagem) * b.qtdatendida, 0))
    AS pesoliquido,
    SUM(NVL((b.qtdatendida / b.qtdembalagem) * b.vlrembinformado, 0))
    AS vtotinformadoatendido
FROM implantacao.mad_pedvenda a
INNER JOIN implantacao.mad_pedvendaitem b 
ON b.nroempresa=a.nroempresa AND b.nropedvenda=a.nropedvenda AND b.qtdatendida > 0
INNER JOIN implantacao.map_produto c ON c.seqproduto = b.seqproduto
INNER JOIN implantacao.map_famembalagem d ON d.seqfamilia = c.seqfamilia AND d.qtdembalagem = b.qtdembalagem
WHERE 1=1
AND a.nroempresa = 1
AND a.situacaoped IN ('S')
AND a.indentregaretira = 'E'	 
AND a.dtageracaocarga BETWEEN SYSDATE-1 AND SYSDATE
GROUP BY a.situacaoped,a.nrosegmento,a.dtainclusao,a.dtabasefaturamento,a.dtageracaocarga
ORDER BY a.dtabasefaturamento ASC
 
/*
SELECT * 
FROM implantacao.mad_xroteirizacao 	
WHERE 1=1
ORDER BY 1 ASC
*/