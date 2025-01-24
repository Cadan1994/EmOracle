SELECT 
    a.nrocarga                          AS  numcar,             --> N�mero do carregamento/romaneio/carga
    a.numerodf                          AS  numnota,            --> N�mero
    a.seriedf                           AS  serie,              --> N�mero de s�rie
    a.seqvendedor                       AS  codusur,            --> C�digo do vendedor do pedido
    1                                   AS  codvenda,           --> Tipo de venda (1=Venda, 5=Bonificada, 11=Troca, 13=Manifesto, 14=Venda pronta entrega, 24=Bonifica��o pronta entrega)
    a.numerodf                          AS  numtransvenda,      --> Sequencial �nico, identificador da nota fiscal
    TO_CHAR(
        a.dtahoremissao,
        'YYYY-MM-DD'
    )                                   AS  dtsaida,            --> Data de sa�da
    TO_CHAR(
        a.dtacancelamento,
        'YYYY-MM-DD'
    )                                   AS  dtcancel,           --> Data de cancelamento
    (SELECT (SUM(t1.vlritem)+SUM(t1.vlricmsst))-SUM(t1.vlrdesconto)
     FROM implantacao.mfl_dfitem t1 
     INNER JOIN implantacao.mfl_doctofiscal t2 
     ON t2.nroempresa = t1.nroempresa
     AND t2.numerodf = t1.numerodf
     AND t2.seriedf = t1.seriedf
     AND t2.nroserieecf = t1.nroserieecf
     AND t2.codoperador = 'AFV'
     AND t2.dtahoremissao >= TRUNC(ADD_MONTHS(SYSDATE, 0),'MM')
     WHERE 1 = 1
     AND t1.numerodf = a.numerodf)      AS  vltotal,            --> Valor total
    CASE
    WHEN a.seriedf = 1
    THEN 'NF'
    ELSE 'CF'
    END                                 AS  especie,            --> Esp�cie (NF, CF ...)
    a.seqpessoa                         AS  codcli,             --> C�digo do cliente
    NVL(a.nropedidovenda,0)             AS  numped,             --> N�mero do pedido
      (SELECT nroformapagto
       FROM implantacao.mrl_clientecredito
       WHERE 1 = 1
       AND indprincipal = 'S'
       AND seqpessoa = a.seqpessoa)     AS  codcob,
    a.nrocondicaopagto                  AS  codplpag,           --> C�digo de plano de pagamento
    a.nroempresa                        AS  codfilial,          --> C�digo da filial
    'A'                                 AS  status,
    TO_DATE(a.dtahoremissao)            AS  dtaalteracao
FROM implantacao.mfl_doctofiscal a
WHERE 1 = 1
AND a.codoperador = 'AFV'
AND a.dtahoremissao >= TRUNC(ADD_MONTHS(SYSDATE, 0),'MM');