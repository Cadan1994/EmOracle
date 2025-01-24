SELECT 
    a.nroparcela                  AS  prest,          --> Número da prestação em caso de parcelamento
    a.nrobanco                    AS  numbanco,       --> Número do banco
    0                             AS  valordesc,      --> Valor de desconto
    a.vlrpago                     AS  vpago,          --> Valor pago
    a.seqpessoa                   AS  codcli,         --> Código do cliente
    a.vlrmulta                    AS  valormulta,     --> Valor da multa
    a.nroempresa                  AS  codfilial,      --> Código da empresa
    'N'                           AS  cartorio,       --> Informar se o título está em cartório? (S ou N)
    a.vlrnominal                  AS  valor,          --> Valor do título
    TO_CHAR(
    NVL(
       a.dtavencimentoorig,
       a.dtavencimento
    ),'YYYY-MM-DD')               AS  dtvenorig,      --> Data de vencimento original
    b.nrorepresentante            AS  codusur,        --> Código do vendedor,
    a.seqtitulo                   AS  numtransvenda,  --> Sequencial único - Identificador do cabeçalho do pedido que originou este
    TO_CHAR(
       a.dtavencimento,
       'YYYY-MM-DD'
    )                             AS  dtvenc,         --> Data de vencimento
    TO_CHAR(
       a.dtaquitacao,
       'YYYY-MM-DD'
    )                             AS  dtpag,          --> Data de pagamento
    a.vlrtarifa                   AS  vltxboleto,     --> Valor da taxa do boleto
    a.vlroriginal                 AS  valororig,      --> Valor original
    'N'                           AS  protesto,       --> Informar se o título está protestado? (S ou N)
    TO_CHAR(
       a.dtaemissao,
       'YYYY-MM-DD'
    )                             AS  dtemissao,      --> Data de emissão do título
    (SELECT nroformapagto
     FROM implantacao.mrl_clientecredito
     WHERE 1 = 1
     AND indprincipal = 'S'
     AND seqpessoa = d.seqpessoa) AS  codcob,             --> Código da cobrança
    d.nrocondpagtopadrao          AS  codplpag,       --  Código do plano de pagamento
    0                             AS  percom,         --> Percentual de desconto comercial
    a.nrotitulo                   AS  duplic,         --> Número da duplicata
    CASE
    WHEN a.dtaquitacao is null 
    THEN 'A' 
    ELSE 'P' 
    END                           AS  status,         --> Situação do título (A-Aberto ou P-Pago)
    'N'                           AS  nossonumbco,    --> Código do cliente no banco (Se pronta entrega)
    'N'                           AS  boleto,         --> Informar se tem boleto?
    'N'                           AS  recebivel,      --> Indicar se o título pode ser recebido pelo vendedor (Se pronto entrega)
    c.vlrcomissao                 AS  comissao,       --> Valor da comissão calculada
    TO_DATE(a.dtaalteracao)       AS  dtaalteracao
FROM implantacao.fi_titulo a
-- PEGA O CÓDIGO DO VENDEDOR
LEFT JOIN (SELECT t1.seqtitulo, t1.nrorepresentante
           FROM implantacao.fi_titrepres t1
           WHERE 1 = 1
           GROUP BY t1.seqtitulo, t1.nrorepresentante) b 
ON b.seqtitulo = a.seqtitulo
-- PEGA O VALOR DA COMISSÃO
LEFT JOIN (SELECT t1.seqtitulo, SUM(t1.vlrcomissao) AS vlrcomissao
           FROM implantacao.fiv_comissao t1
           WHERE 1 = 1
           GROUP BY t1.seqtitulo) c 
ON c.seqtitulo = a.seqtitulo
-- PEGA O CÓDIGO DO PLANO DE PAGAMENTO
LEFT JOIN (SELECT t1.nroempresa, t1.seqpessoa, t1.nrocondpagtopadrao
           FROM implantacao.mrl_cliente t1
           WHERE 1 = 1
           GROUP BY t1.nroempresa, t1.seqpessoa, t1.nrocondpagtopadrao) d
ON d.nroempresa = a.nroempresa AND d.seqpessoa = a.seqpessoa
--
WHERE 1 = 1
AND a.dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE, 0),'YY')
AND a.nrotitulo = 441130
--AND b.nrorepresentante = 11138
ORDER BY 1 ASC;
