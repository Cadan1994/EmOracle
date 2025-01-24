SELECT
    b.seqvendedor                       AS  codusur,        --> Código do vendedor
    a.nroempresa                        AS  codfilial,      --> Código da filial
    LPAD(a.seqproduto,6,0)              AS  codprod,        --> Código do produto
    a.seqitemdf                         AS  numseq,         --> Sequência do item na NF
    'S'                                 AS  codoper,        --> S - Saída
    NVL(a.quantidade/a.qtdembalagem, 0) AS  qt,             --> Quantidade do item
    NVL(a.quantidade/a.qtdembalagem, 0) AS  qtcont,         --> Replicar a informação do campo QT
    NVL(b.nropedidovenda,0)             AS  numtransvenda,  --> Sequencial único "Identificador do cabeçalho do pedido
    a.numerodf||a.seqitemdf             AS  numtransitem,   --> Sequencial único "Identificador dos itens da NF"
    LPAD(a.codproduto,6,0)              AS  codauxiliar,    --> Código de barras do produto, obrigatório no caso de venda por embalagem
    b.nrocarga                          AS  numcar,         --> Número do carregamento/romaneio/carga
    a.numerodf                          AS  numnota,        --> Número
    NVL(b.nropedidovenda,0)             AS  numped,         --> Número do pedido
    ROUND((a.vlritem/a.quantidade),2)   AS  ptabela,        --> Preço de tabela
    ROUND((a.vlritem/a.quantidade),2)   AS  punitcont,      --> Preço de venda
    ROUND((a.vlritem/a.quantidade),2)   AS  punit,          --> Replicar a informação do campo PUNITCONT
    0                                   AS  custofin,       --> Custo financeiro. Se não existir enviar 0
    0                                   AS  vlipi,          --> Valor IPI. Se não existir enviar 0
    a.vlricmsst                         AS  st,             --> Valor ST. Se não existir enviar 0
    1                                   AS  coddevol,       --> Código do motivo da devolução. Se não existir enviar 1
    ROWNUM                              AS  numtransent,    --> Sequencial único "não se repete"
    0                                   AS  qtdevol,        --> Fixar 0
    'A'                                 AS  status,
    TO_DATE(b.dtahoremissao)            AS  dtaalteracao
FROM implantacao.mfl_dfitem a 
INNER JOIN implantacao.mfl_doctofiscal b 
ON b.nroempresa = a.nroempresa
AND b.numerodf = a.numerodf
AND b.seriedf = a.seriedf
AND b.nroserieecf = a.nroserieecf
AND b.codoperador = 'AFV'
AND b.dtahoremissao >= TRUNC(ADD_MONTHS(SYSDATE, 0),'MM')
WHERE 1 = 1;
