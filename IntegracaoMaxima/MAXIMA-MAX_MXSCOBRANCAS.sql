SELECT
    a.formapagtoreduz,
    CASE
    WHEN a.formapagtoreduz 
    IN ('BOLETO')
    THEN 'S'
    ELSE 'N'
    END                                       AS  boleto,           --> Boleto banc�rio (S ou N)
    CASE
    WHEN a.formapagtoreduz 
    IN ('CARTAO C','CARTAO D','CARTAO P')
    THEN 'S'
    ELSE 'N'
    END                                       AS  cartao,           --> Cart�o de cr�dito (S ou N)
    a.formapagto                              AS  descricao,        --> Descri��o
    a.nroformapagto                           AS  codcob,           --> C�digo
    NULL                                      AS  codfilial,        --> Ao selecionar a filial ser� permitido o uso desta cobran�a
    0                                         AS  nivelvenda,       --> N�vel de venda
    0                                         AS  prazomaximovenda, --> Prazo m�ximo de venda
    NULL                                      AS  cobrancabroker,   --> Gravar o valor "S" para indicar que a cobran�a � do tipo de opera��o Broker
    50.00                                     AS  vlminpedido,      --> Valor m�nimo de venda
    0                                         AS  txjuros,          --> Taxa (%) de juros dia (se pronta entrega)
    0                                         AS  percmulta,        --> Taxa (%) de multa (se pronta entrega)
    CASE
    WHEN a.formapagtoreduz 
    IN ('DINHEIRO','CHEQUE AVISTA','CHEQUE A VISTA','CARTAO D')
    THEN 'VV'
    ELSE 'VP'
    END                                       AS  tipovenda,        --> Informar "VP"-venda a prazo e "VV"-venda a vista
    CASE
    WHEN a.formapagtoreduz = 'BOLETO' THEN 'B'
    WHEN a.formapagtoreduz = 'DINHEIRO' THEN 'D'
    WHEN a.formapagtoreduz = 'CARTAO C' THEN 'C'
    WHEN a.formapagtoreduz = 'CARTAO D' THEN 'C'
    WHEN a.formapagtoreduz = 'CARTAO P' THEN 'C'
    WHEN a.formapagtoreduz = 'CARTAO P' THEN 'C'
    WHEN a.formapagtoreduz = 'CHEQUE PRE' THEN 'CH'
    WHEN a.formapagtoreduz = 'CHEQUE AVISTA' THEN 'CH'
    WHEN a.formapagtoreduz = 'CHEQUE A VISTA2' THEN 'CH'
    WHEN a.formapagtoreduz = 'CHEQUE PRE2' THEN 'CH'
    WHEN a.formapagtoreduz = 'CHEQUE A VISTA' THEN 'CH'
    ELSE ''
    END                                       AS  tipocobraca      --> B-Boleto, C-Cart�o, CH-Cheque e D-Dinheiro
FROM implantacao.mrl_formapagto a 
WHERE 1 = 1
AND a.statusformapagto = 'A'
AND a.formapagtoreduz IN ('DINHEIRO','BOLETO','CHEQUE PRE','CHEQUE AVISTA','CHEQUE A VISTA','CHEQUE PRE2','CARTAO C','CARTAO D','CARTAO P');
