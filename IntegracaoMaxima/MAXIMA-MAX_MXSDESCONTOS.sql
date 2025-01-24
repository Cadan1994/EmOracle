-- PERCENTUAL REFERENTE A ENTREGA
SELECT
    DISTINCT
    a.seqpessoa                                AS  codcli,           --> Código do cliente
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)                    AS  numregiao,        --> Região 
    'S'                                        AS  alteraptabela,    --> Alterar preço de tabela
    'N'                                        AS  basecreddebrca,   --> Altera base para cálculo de débito/crédito do RCA
    'S'                                        AS  aplicadesconto,   --> Aplicar desconto automaticamente
    'N'                                        AS  prioritaria,      --> Forçar aplicação de política prioritária
    'N'                                        AS  prioritariageral, --> Forçar aplicação de política prioritária
    'E'||
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)||
    LPAD(a.seqpessoa,7,0)                      AS  coddesconto,     --> Código
    TO_CHAR(
      TRUNC(
        ADD_MONTHS(SYSDATE, 0),
        'YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtinicio,         --> Data de início
    TO_CHAR(
      TO_DATE(
        '31/12/3000',
        'DD/MM/YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtfim,            --> Data de fim
    'F'                                        AS  origemped,        --> Origem do pedido (F=Força Venda, R=Balcão Reserva, B=Balcão e O=Outros)
    -TRUNC(
       (
       (1+(NVL(ROUND(d.peracrentrega,6),0)/100))*
       (1+(NVL(ROUND(c.percacrdesccomerc,6),0)/100))*
       (1+(NVL(ROUND(d.percfretetransp,6),0)/100))
       -1)*100,6)                              AS  percdesc,         --> Percentual (%) de desconto comercial                                          
    'C'                                        AS  tipo,             --> Tipo de desconto (C=Comercial e F=Financeiro
    a.statuscliente                            AS  status,
    MAX(e.dtaalteracao)                        AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mad_clisegtabvenda b 
ON b.seqpessoa = a.seqpessoa AND b.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
INNER JOIN implantacao.mrl_clienteseg c 
ON c.seqpessoa = b.seqpessoa AND c.nrosegmento = b.nrosegmento
INNER JOIN implantacao.mad_tabvenda d 
ON d.nrotabvenda = b.nrotabvenda
AND d.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
INNER JOIN (SELECT DISTINCT nrotabvendaprinc AS nrotabvenda,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.mrl_clienteseg 
            WHERE status = 'A' 
            AND seqpessoa NOT IN (1,22401)
            GROUP BY nrotabvendaprinc
            UNION ALL
            SELECT DISTINCT nrotabvenda,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_tabvenda
            WHERE nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
            AND status = 'A'
            GROUP BY nrotabvenda) e
ON e.nrotabvenda = b.nrotabvenda
WHERE 1 = 1 
AND a.statuscliente  = 'A'
AND a.seqpessoa=24101-- NOT IN (1, 22401)
AND -TRUNC(
       (
       (1+(NVL(ROUND(d.peracrentrega,6),0)/100))*
       (1+(NVL(ROUND(c.percacrdesccomerc,6),0)/100))*
       (1+(NVL(ROUND(d.percfretetransp,6),0)/100))
       -1)*100,6) != 0
GROUP BY a.nroempresa,a.seqpessoa,a.statuscliente,b.nrosegmento,b.nrotabvenda,c.percacrdesccomerc,d.peracrentrega,d.percfretetransp

UNION ALL

-- PERCENTUAL REFERENTE A RETIRA
SELECT
    DISTINCT
    a.seqpessoa                                AS  codcli,           --> Código do cliente
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)                    AS  numregiao,        --> Região 
    'S'                                        AS  alteraptabela,    --> Alterar preço de tabela
    'N'                                        AS  basecreddebrca,   --> Altera base para cálculo de débito/crédito do RCA
    'S'                                        AS  aplicadesconto,   --> Aplicar desconto automaticamente
    'N'                                        AS  prioritaria,      --> Forçar aplicação de política prioritária
    'N'                                        AS  prioritariageral, --> Forçar aplicação de política prioritária
    'R'||
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)||
    LPAD(a.seqpessoa,7,0)                      AS  coddesconto,     --> Código
    TO_CHAR(
      TRUNC(
        ADD_MONTHS(SYSDATE, 0),
        'YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtinicio,         --> Data de início
    TO_CHAR(
      TO_DATE(
        '31/12/3000',
        'DD/MM/YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtfim,            --> Data de fim
    'R'                                        AS  origemped,        --> Origem do pedido (F=Força Venda, R=Balcão Reserva, B=Balcão e O=Outros)
    -TRUNC(
       (
       (1+(NVL(ROUND(d.peracrentrega,6),0)/100))*
       (1+(NVL(ROUND(c.percacrdesccomerc,6),0)/100))
       -1)*100,6)                              AS  percdesc,         --> Percentual (%) de desconto comercial                                          
    'C'                                        AS  tipo,             --> Tipo de desconto (C=Comercial e F=Financeiro
    a.statuscliente                            AS  status,
    MAX(e.dtaalteracao)                        AS  dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mad_clisegtabvenda b 
ON b.seqpessoa = a.seqpessoa AND b.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
INNER JOIN implantacao.mrl_clienteseg c 
ON c.seqpessoa = b.seqpessoa AND c.nrosegmento = b.nrosegmento
INNER JOIN implantacao.mad_tabvenda d 
ON d.nrotabvenda = b.nrotabvenda
AND d.nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
INNER JOIN (SELECT DISTINCT nrotabvendaprinc AS nrotabvenda,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.mrl_clienteseg 
            WHERE status = 'A' 
            AND seqpessoa NOT IN (1,22401)
            GROUP BY nrotabvendaprinc
            UNION ALL
            SELECT DISTINCT nrotabvenda,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_tabvenda
            WHERE nrotabvenda NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)
            AND status = 'A'
            GROUP BY nrotabvenda) e
ON e.nrotabvenda = b.nrotabvenda
WHERE 1 = 1 
AND a.statuscliente  = 'A'
AND a.seqpessoa=24101-- NOT IN (1, 22401)
AND -TRUNC(
       (
       (1+(NVL(ROUND(d.peracrentrega,6),0)/100))*
       (1+(NVL(ROUND(c.percacrdesccomerc,6),0)/100))
       -1)*100,6) != 0
GROUP BY a.nroempresa,a.seqpessoa,a.statuscliente,b.nrosegmento,b.nrotabvenda,c.percacrdesccomerc,d.peracrentrega,d.percfretetransp;
