SELECT
    b.seqvendedor                       AS  codusur,        --> C�digo do vendedor
    a.nroempresa                        AS  codfilial,      --> C�digo da filial
    LPAD(a.seqproduto,6,0)              AS  codprod,        --> C�digo do produto
    a.seqitemdf                         AS  numseq,         --> Sequ�ncia do item na NF
    'S'                                 AS  codoper,        --> S - Sa�da
    NVL(a.quantidade/a.qtdembalagem, 0) AS  qt,             --> Quantidade do item
    NVL(a.quantidade/a.qtdembalagem, 0) AS  qtcont,         --> Replicar a informa��o do campo QT
    NVL(b.nropedidovenda,0)             AS  numtransvenda,  --> Sequencial �nico "Identificador do cabe�alho do pedido
    a.numerodf||a.seqitemdf             AS  numtransitem,   --> Sequencial �nico "Identificador dos itens da NF"
    LPAD(a.codproduto,6,0)              AS  codauxiliar,    --> C�digo de barras do produto, obrigat�rio no caso de venda por embalagem
    b.nrocarga                          AS  numcar,         --> N�mero do carregamento/romaneio/carga
    a.numerodf                          AS  numnota,        --> N�mero
    NVL(b.nropedidovenda,0)             AS  numped,         --> N�mero do pedido
    ROUND((a.vlritem/a.quantidade),2)   AS  ptabela,        --> Pre�o de tabela
    ROUND((a.vlritem/a.quantidade),2)   AS  punitcont,      --> Pre�o de venda
    ROUND((a.vlritem/a.quantidade),2)   AS  punit,          --> Replicar a informa��o do campo PUNITCONT
    0                                   AS  custofin,       --> Custo financeiro. Se n�o existir enviar 0
    0                                   AS  vlipi,          --> Valor IPI. Se n�o existir enviar 0
    a.vlricmsst                         AS  st,             --> Valor ST. Se n�o existir enviar 0
    1                                   AS  coddevol,       --> C�digo do motivo da devolu��o. Se n�o existir enviar 1
    ROWNUM                              AS  numtransent,    --> Sequencial �nico "n�o se repete"
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
