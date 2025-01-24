SELECT 
    a.nrobanco                    AS  numbanco,       --> N�mero do banco
    0                             AS  valordesc,      --> Valor de desconto
    a.vlrpago                     AS  vpago,          --> Valor pago
    a.seqpessoa                   AS  codcli,         --> C�digo do cliente
    a.vlrmulta                    AS  valormulta,     --> Valor da multa
    a.nroempresa                  AS  codfilial,      --> C�digo da empresa
    'N'                           AS  cartorio,       --> Informar se o t�tulo est� em cart�rio? (S ou N)
    a.vlrnominal                  AS  valor,          --> Valor do t�tulo
    a.nroparcela                  AS  prest,          --> N�mero da presta��o em caso de parcelamento
    TO_CHAR(
    NVL(
       a.dtavencimentoorig,
       a.dtavencimento
    ),'YYYY-MM-DD')               AS  dtvenorig,      --> Data de vencimento original
    b.nrorepresentante                 AS  codusur,        --> C�digo do vendedor,
    a.seqtitulo                   AS  numtransvenda,  --> Sequencial �nico - Identificador do cabe�alho do pedido que originou este
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
    'N'                           AS  protesto,       --> Informar se o t�tulo est� protestado? (S ou N)
    TO_CHAR(
       a.dtaemissao,
       'YYYY-MM-DD'
    )                             AS  dtemissao,      --> Data de emiss�o do t�tulo
    d.seqpessoa                   AS  codcob,         --> C�digo de cobran�a
    d.nrocondpagtopadrao          AS  codplpag,       --  C�digo do plano de pagamento
    0                             AS  percom,         --> Percentual de desconto comercial
    a.nrotitulo                   AS  duplic,         --> N�mero da duplicata
    CASE 
    WHEN a.dtaquitacao is null 
    THEN 'A' 
    ELSE 'P' 
    END                           AS  status,         --> Situa��o do t�tulo (A-Aberto ou P-Pago)
    NULL                          AS  nossonumbco,    --> C�digo do cliente no banco (Se pronta entrega)
    NULL                          AS  boleto,         --> Informar se tem boleto?
    NULL                          AS  recebivel,      --> Indicar se o t�tulo pode ser recebido pelo vendedor (Se pronto entrega)
    c.vlrcomissao                 AS  comissao,       --> Valor da comiss�o calculada
    TO_DATE(a.dtaalteracao)       AS  dtaalteracao
FROM implantacao.fi_titulo a
-- PEGA O C�DIGO DO VENDEDOR
LEFT JOIN (SELECT t1.seqtitulo, t1.nrorepresentante
           FROM implantacao.fi_titrepres t1
           WHERE 1 = 1
           GROUP BY t1.seqtitulo, t1.nrorepresentante) b 
ON b.seqtitulo = a.seqtitulo
-- PEGA O VALOR DA COMISS�O
LEFT JOIN (SELECT t1.seqtitulo, SUM(t1.vlrcomissao) AS vlrcomissao
           FROM implantacao.fiv_comissao t1
           WHERE 1 = 1
           GROUP BY t1.seqtitulo) c 
ON c.seqtitulo = a.seqtitulo
-- PEGA O C�DIGO DO PLANO DE PAGAMENTO
LEFT JOIN (SELECT t1.nroempresa, t1.seqpessoa, t1.nrocondpagtopadrao
           FROM implantacao.mrl_cliente t1
           WHERE 1 = 1
           GROUP BY t1.nroempresa, t1.seqpessoa, t1.nrocondpagtopadrao) d
ON d.nroempresa = a.nroempresa AND d.seqpessoa = a.seqpessoa
--
WHERE 1 = 1
AND a.dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE, -3),'MM')

