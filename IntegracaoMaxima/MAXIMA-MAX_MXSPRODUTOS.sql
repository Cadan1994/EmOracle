SELECT 
    DISTINCT
    LPAD(a.seqproduto,6,0)                          AS  codprod,
    c.pmtdecimal                                    AS  aceitavendafracao,
    d.altura                                        AS  altura,
    'N'                                             AS  checarmultiplovendabnf,
    NULL                                            AS  classe,
    c.codnbmsh                                      AS  classificfiscal,
    NVL((SELECT t1.codacesso
         FROM (SELECT  t2.*
               FROM implantacao.map_prodcodigo t2
               WHERE t2.tipcodigo IN('E', 'D')
               AND t2.indutilvenda = 'S'
               ORDER BY t2.qtdembalagem) t1
         WHERE 1 = 1
         AND t1.seqproduto = a.seqproduto 
         AND ROWNUM = 1), a.seqproduto)             AS  codauxiliar,
    NVL((SELECT t1.codacesso
         FROM (SELECT  t2.*
               FROM implantacao.map_prodcodigo t2
               WHERE t2.tipcodigo IN('E', 'D')
               AND t2.indutilvenda = 'S'
               ORDER BY t2.qtdembalagem DESC) t1
         WHERE t1.seqproduto = a.seqproduto 
         AND ROWNUM = 1),a.seqproduto)              AS  codauxiliar2,
    m.codcategoria                                  AS  codcategoria,
    j.coddepartamento                               AS  codepto,
    a.reffabricante                                 AS  codfab,
    f.seqfornecedor                                 AS  codfornec,
    c.seqmarca                                      AS  codmarca,
    a.seqprodutobase                                AS  codprodprinc,
    l.codsecao                                      AS  codsec,
    n.codsubcategoria                               AS  codsubcategoria,
    c.indconfaz                                     AS  confaz,
    a.especificdetalhada                            AS  dadostecnicos,
    a.desccompleta                                  AS  descricao,
    a.descreduzida                                  AS  descricao2,
    NVL(
        TO_CHAR(
            a.dtahorinclusao,
            'YYYY-MM-DD'
        ),
        NULL
    )                                               AS  dtcadastro,
    NULL                                            AS  dtvenc,
    d.embalagem                                     AS  embalagem,
    g.embalagem                                     AS  embalagemmaster,
    g.codorigemtrib                                 AS  importado,
    a.especificdetalhada                            AS  informacoestecnicas,
    e.vlrnultiplovda                                AS  multiplo,
    c.codnbmsh                                      AS  nbm,
    a.desccompleta                                  AS  nomecommerce,
    NVL(h.peraliquotaipi, 0)                        AS  percipi,
    NVL(i.peraliquotaipisaida, 0)                   AS  percipivenda,
    d.pesobruto                                     AS  pesobruto,
    g.pesobruto                                     AS  pesobrutomaster,
    d.pesoliquido                                   AS  pesoliq,
    d.qtdembalagem                                  AS  qtunit,
    g.qtdembalagem                                  AS  qtunitcx,
    b.indutilvenda                                  AS  revenda,
    'PA'                                            AS  tipoestoque,
    'L'                                             AS  tipomerc,
    d.embalagem                                     AS  unidade,
    g.embalagem                                     AS  unidademaster,
    NVL(i.vlripipautasaida, 0)                      AS  vlpautaipivenda,
    'A'                                             As  status,
    TO_DATE(a.dtahoralteracao)                      AS  dtaalteracao
FROM implantacao.map_produto a
LEFT JOIN (SELECT DISTINCT t1.seqproduto, t1.indutilvenda
            FROM implantacao.map_prodcodigo t1 
            WHERE 1 = 1 
            AND t1.indutilvenda = 'S') b 
ON b.seqproduto = a.seqproduto 

INNER JOIN implantacao.map_familia c 
ON c.seqfamilia = a.seqfamilia
LEFT  JOIN (SELECT a.seqfamilia, a.embalagem, a.altura, a.pesobruto, a.pesoliquido, a.qtdembalagem
            FROM implantacao.map_famembalagem a
            WHERE a.status = 'A'
            AND a.qtdembalagem = (SELECT b.qtdembalagem
                                  FROM (SELECT c.*
                                        FROM implantacao.map_prodcodigo c
                                        WHERE c.indutilvenda = 'S'
                                        ORDER BY c.qtdembalagem) b
                                  WHERE 1 = 1 
                                  AND rownum = 1)) d
ON d.seqfamilia = c.seqfamilia
LEFT JOIN (SELECT a.seqfamilia,SUM(NVL(a.vlrnultiplovda,0)) AS vlrnultiplovda
            FROM implantacao.mad_famsegmento a
            WHERE 1 = 1
            GROUP BY a.seqfamilia) e
ON e.seqfamilia = d.seqfamilia
LEFT JOIN (SELECT a.seqfamilia, a.seqfornecedor
           FROM IMPLANTACAO.map_famfornec a
           WHERE 1 = 1
           AND a.principal = 'S'
           GROUP BY a.seqfamilia, a.seqfornecedor) f
ON f.seqfamilia = e.seqfamilia
LEFT JOIN (SELECT a.seqfamilia, CASE WHEN a.codorigemtrib IN (0,3,4,5,8) THEN 'N' ELSE 'S' END AS codorigemtrib, b.embalagem, b.pesobruto, b.qtdembalagem
            FROM implantacao.map_famdivisao a
            INNER JOIN implantacao.map_famembalagem b ON b.seqfamilia = a.seqfamilia AND b.qtdembalagem = a.padraoembcompra
            WHERE 1 = 1
            ORDER BY a.seqfamilia ASC) g
ON g.seqfamilia = f.seqfamilia
LEFT JOIN (SELECT b.seqproduto, SUM(b.peraliquotaipi) AS peraliquotaipi
            FROM IMPLANTACAO.mlf_notafiscal a 
            INNER JOIN implantacao.mlf_nfitem b 
            ON b.nroempresa = a.nroempresa 
            AND b.seqpessoa = a.seqpessoa 
            AND b.numeronf = a.numeronf 
            AND b.tipnotafiscal = a.tipnotafiscal
            WHERE 1 = 1
            AND a.dtaentrada = (SELECT MAX(a.dtaentrada) 
                                FROM IMPLANTACAO.mlf_notafiscal a 
                                INNER JOIN implantacao.mlf_nfitem b 
                                ON b.nroempresa = a.nroempresa 
                                AND b.seqpessoa = a.seqpessoa 
                                AND b.numeronf = a.numeronf 
                                AND b.tipnotafiscal = a.tipnotafiscal
                                WHERE 1 = 1)
            GROUP BY b.seqproduto) h
ON h.seqproduto = a.seqproduto
INNER JOIN (SELECT a.seqfamilia, a.peraliquotaipisaida, a.vlripipautasaida 
            FROM implantacao.map_famdivisao a) i 
ON i.seqfamilia = a.seqfamilia
-- PEGA O CÓDIGO DO DEPARTAMENTO
INNER JOIN (SELECT DISTINCT t12.seqfamilia, t12.nrodivisao AS coddepartamento
            FROM implantacao.map_famdivcateg t12 
            WHERE  t12.status = 'A') j 
ON j.seqfamilia = a.seqfamilia
-- PEGA O CÓDIGO DA SEÇÃO
LEFT JOIN (SELECT t13.seqproduto, t15.seqcategoria AS codsecao
           FROM  implantacao.map_produto t13
           INNER JOIN implantacao.map_famdivisao t14 ON t13.seqfamilia = t14.seqfamilia 
           INNER JOIN implantacao.map_categoria t15 ON t15.nrodivisao = t14.nrodivisao AND t15.nivelhierarquia = 1 AND t15.statuscategor = 'A'
           INNER JOIN implantacao.map_famdivcateg t16 ON t16.seqfamilia = t13.seqfamilia AND  t16.seqcategoria = t15.seqcategoria AND t16.status = 'A'
           AND t13.desccompleta NOT LIKE 'ZZ%') l 
ON l.seqproduto = a.seqproduto
-- PEGA O CÓDIGO DA CATEGORIA
LEFT JOIN (SELECT t17.seqproduto, t19.seqcategoria AS codcategoria
           FROM  implantacao.map_produto t17
           INNER JOIN implantacao.map_famdivisao t18 ON t17.seqfamilia = t18.seqfamilia 
           INNER JOIN implantacao.map_categoria t19 ON t19.nrodivisao = t18.nrodivisao AND t19.nivelhierarquia = 2 AND t19.statuscategor = 'A'
           INNER JOIN implantacao.map_famdivcateg t20 ON t20.seqfamilia = t17.seqfamilia AND  t20.seqcategoria = t19.seqcategoria AND t20.status = 'A'
           AND t17.desccompleta NOT LIKE 'ZZ%') m 
ON m.seqproduto = a.seqproduto
-- PEGA O CÓDIGO DA SUBCATEGORIA
LEFT JOIN (SELECT t21.seqproduto,t23.seqcategoria AS codsubcategoria
           FROM  implantacao.map_produto t21
           INNER JOIN implantacao.map_famdivisao t22 ON t21.seqfamilia = t22.seqfamilia 
           INNER JOIN implantacao.map_categoria t23 ON t23.nrodivisao = t22.nrodivisao AND t23.nivelhierarquia = 3 AND t23.statuscategor = 'A'
           INNER JOIN implantacao.map_famdivcateg t24 ON t24.seqfamilia = t21.seqfamilia AND  t24.seqcategoria = t23.seqcategoria AND t24.status = 'A'
           AND t21.desccompleta NOT LIKE 'ZZ%') n 
ON n.seqproduto = a.seqproduto
INNER JOIN implantacao.mrl_prodempseg o 
ON o.seqproduto = a.seqproduto AND o.statusvenda = 'A'
WHERE 1 = 1
AND a.desccompleta NOT LIKE 'ZZ%'
ORDER BY 1 ASC;
