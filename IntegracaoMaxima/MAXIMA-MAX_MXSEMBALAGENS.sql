SELECT
    DISTINCT 
    b.codacesso                 AS  codauxiliar,    --> Código auxiliar da embalagem
    d.nroempresa                AS  codfilial,      --> Código da filial
    LPAD(a.seqproduto,6,0)      AS  codprod,        --> Código do produto
    c.embalagem 
    || 
    ' com ' 
    || b.qtdembalagem           AS  embalagem,      --> Descrição da embalagem
    b.qtdembalagem              AS  qtunit,         --> Fator de conversão das unidades da embalagem
    0                           AS  fatorpreco,     --> Fator de acréscimo ao preço de tabela
    c.embalagem                 AS  unidade,        --> Informação de unidade (CX, UN, LT, PCT ...)
    'A'                         AS  status,
    MAX(e.dtaalteracao)         AS  dtaalteracao
FROM implantacao.map_produto a
-- Tabela utilizada para pegar os campos: "CODACESSO,QTDEMBALAGEM"
INNER JOIN implantacao.map_prodcodigo b 
ON b.seqproduto = a.seqproduto and b.seqfamilia = a.seqfamilia AND b.indutilvenda = 'S' AND b.tipcodigo IN ('E','D')
-- Tabela utilizada para pegar o campo: "EMBALAGEM"
INNER JOIN implantacao.map_famembalagem c 
ON c.seqfamilia = b.seqfamilia AND c.qtdembalagem = b.qtdembalagem AND c.status = 'A'
-- Tabela utilizada para pegar o campo: "NROEMPRESA"
INNER JOIN implantacao.mrl_produtoempresa d 
ON d.seqproduto = a.seqproduto
-- Select's utilizados para pegar o campo da datas de alterações das tabelas:
-- "MAP_PRODUTO,MAP_PRODUTOCODIGO,MAP_FAMEMBALAGEM,MRL_PRODUTOEMPRESA"
INNER JOIN (SELECT seqproduto, TO_DATE(dtahoralteracao) AS dtaalteracao 
            FROM implantacao.map_produto 
            WHERE desccompleta NOT LIKE 'ZZ%'
            UNION ALL
            SELECT seqproduto,TO_DATE(dtahoralteracargapdv) AS dtaalteracao
            FROM implantacao.map_prodcodigo
            WHERE indutilvenda = 'S' 
            AND tipcodigo IN ('E','D')
            UNION ALL
            SELECT DISTINCT a.seqproduto,TO_DATE(b.datahoraalteracao) AS dtaalteracao 
            FROM implantacao.map_prodcodigo a
            INNER JOIN implantacao.map_famembalagem b 
            ON b.seqfamilia = a.seqfamilia AND b.qtdembalagem = a.qtdembalagem AND b.status = 'A'
            WHERE a.indutilvenda = 'S' 
            AND a.tipcodigo IN ('E','D')
            UNION ALL
            SELECT seqproduto,TO_DATE(dtaalteracao) AS dtaalteracao 
            FROM implantacao.mrl_produtoempresa) e
ON e.seqproduto = d.seqproduto
WHERE a.desccompleta NOT LIKE 'ZZ%'
GROUP BY b.codacesso,d.nroempresa,a.seqproduto,c.embalagem,b.qtdembalagem;
