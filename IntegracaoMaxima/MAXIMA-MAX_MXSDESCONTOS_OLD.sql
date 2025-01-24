SELECT
    DISTINCT
    c.seqpessoa                                     AS  codcli,           --> Código do cliente
    'S'                                             AS  alteraptabela,    --> Alterar preço de tabela
    'N'                                             AS  basecreddebrca,   --> Altera base para cálculo de débito/crédito do RCA
    'S'                                             AS  aplicadesconto,   --> Aplicar desconto automaticamente
    LPAD(e.nroempresa,2,0)
    ||
    LPAD(c.seqpessoa,7,0)
    ||
    LPAD(c.nrosegmento,3,0)
    ||
    LPAD(a.nrocondicaopagto,3,0)
    ||
    LPAD(c.nrotabvenda,4,0)                          AS  coddesconto,     --> Código
    LPAD(NVL(a.nrocondicaopagto,1),3,0)              AS  codplpag,        --> Código do plano de pagamento
    TO_CHAR(
         TO_DATE(
              '31/12/3000',
              'DD/MM/YYYY'
         ),
         'YYYY-MM-DD'
    )                                               AS  dtfim,            --> Data de fim
    TO_CHAR(
         TRUNC(
            ADD_MONTHS(SYSDATE, 0),
            'YYYY'
         ),
         'YYYY-MM-DD'
    )                                               AS  dtinicio,         --> Data de início
    LPAD(e.nroempresa,2,0)
    ||
    LPAD(c.nrosegmento,3,0)
    ||
    LPAD(c.nrotabvenda,4,0)                         AS  numregiao,        --> Código da região (praça de atendimento)
    'F'                                             AS  origemped,        --> Origem do pedido (F=Força Venda, R=Balcão Reserva, B=Balcão e O=Outros)
    -CAST(
        ((((NVL(d.percacrdesccomerc,0)/100)+1) *
        ((NVL(a.peracrfinanceiro,0)/100)+1))-1) *
        100
        AS DECIMAL(10,2)
    )                                               AS  percdesc,         --> Percentual (%) de desconto comercial                                          
    'C'                                             AS  tipo,             --> Tipo de desconto (C=Comercial e F=Financeiro
    a.status,
    MAX(TO_DATE(f.dtaalteracao))                    AS  dtaalteracao
FROM implantacao.mad_tabvendacond a
--INNER JOIN implantacao.mad_condicaopagto b ON b.nrocondicaopagto = a.nrocondicaopagto AND b.status = 'A'
INNER JOIN implantacao.mad_clisegtabvenda c 
ON c.nrotabvenda = a.nrotabvenda AND c.status = 'A' AND c.seqpessoa IN (531) --NOT IN (1, 22401) 531, 37698, 40866, 42797
INNER JOIN implantacao.mrl_clienteseg d 
ON d.seqpessoa = c.seqpessoa AND d.nrosegmento = c.nrosegmento
INNER JOIN (SELECT DISTINCT nrosegmento,nroempresa 
            FROM implantacao.mrl_prodempseg 
            WHERE nrosegmento IN (1,3,4,5,6,7,8,9,10) 
            AND statusvenda = 'A') e
ON e.nrosegmento = d.nrosegmento
INNER JOIN (SELECT DISTINCT nrotabvenda,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_tabvendacond 
            WHERE status = 'A'
            AND nrotabvenda NOT IN (2,3,7,8,9,10,11,12,13,14,15,20,71,72,73,91,99,100,101,122,131,711,998,999)
            AND peracrfinanceiro != 0
            GROUP BY nrotabvenda
            UNION ALL
            SELECT DISTINCT nrotabvenda,MAX(TO_DATE(dtahoralteracao)) AS dtaalteracao
            FROM implantacao.mad_clisegtabvenda
            WHERE status = 'A'
            GROUP BY nrotabvenda) f
ON f.nrotabvenda = c.nrotabvenda
WHERE 1 = 1 
AND a.status = 'A'
AND a.nrotabvenda NOT IN (2,3,7,8,9,10,11,12,13,14,15,20,71,72,73,91,99,100,101,122,131,711,998,999)
AND a.peracrfinanceiro != 0
GROUP BY a.nrotabvenda,a.nrocondicaopagto,a.peracrfinanceiro,a.status,c.nrosegmento,c.nrotabvenda,c.seqpessoa,d.percacrdesccomerc,e.nroempresa
ORDER BY 1 ASC, 9 ASC, 6 ASC