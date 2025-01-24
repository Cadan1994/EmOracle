SELECT
    DISTINCT
    a.seqproduto,
    b.desccompleta
FROM implantacao.maxv_abcdistribbase a
INNER JOIN implantacao.map_produto b ON b.seqproduto = a.seqproduto
WHERE 1=1
AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
AND DECODE(a.tiptabela,'S',a.cgoacmcompravenda,a.acmcompravenda) IN ('S','I')
AND a.codgeraloper IN (201, 202, 225, 228, 235, 307, 313, 314, 575, 598, 701, 102, 133, 173, 177, 188, 401, 402, 567, 581, 708)
AND a.dtavda BETWEEN '01-DEC-2023' AND '31-DEC-2023'
ORDER BY 1 ASC