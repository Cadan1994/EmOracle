-- PERCENTUAL REFERENTE A ENTREGA
SELECT
    DISTINCT
    a.seqpessoa                                AS  codcli,           --> C�digo do cliente
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)                    AS  numregiao,        --> Regi�o 
    'S'                                        AS  alteraptabela,    --> Alterar pre�o de tabela
    'N'                                        AS  basecreddebrca,   --> Altera base para c�lculo de d�bito/cr�dito do RCA
    'S'                                        AS  aplicadesconto,   --> Aplicar desconto automaticamente
    'N'                                        AS  prioritaria,      --> For�ar aplica��o de pol�tica priorit�ria
    'N'                                        AS  prioritariageral, --> For�ar aplica��o de pol�tica priorit�ria
    'E'||
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)||
    LPAD(a.seqpessoa,7,0)                      AS  coddesconto,     --> C�digo
    TO_CHAR(
      TRUNC(
        ADD_MONTHS(SYSDATE, 0),
        'YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtinicio,         --> Data de in�cio
    TO_CHAR(
      TO_DATE(
        '31/12/3000',
        'DD/MM/YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtfim,            --> Data de fim
    'F'                                        AS  origemped,        --> Origem do pedido (F=For�a Venda, R=Balc�o Reserva, B=Balc�o e O=Outros)
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
    a.seqpessoa                                AS  codcli,           --> C�digo do cliente
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)                    AS  numregiao,        --> Regi�o 
    'S'                                        AS  alteraptabela,    --> Alterar pre�o de tabela
    'N'                                        AS  basecreddebrca,   --> Altera base para c�lculo de d�bito/cr�dito do RCA
    'S'                                        AS  aplicadesconto,   --> Aplicar desconto automaticamente
    'N'                                        AS  prioritaria,      --> For�ar aplica��o de pol�tica priorit�ria
    'N'                                        AS  prioritariageral, --> For�ar aplica��o de pol�tica priorit�ria
    'R'||
    LPAD(a.nroempresa,1,0)||
    LPAD(b.nrosegmento,2,0)||
    LPAD(b.nrotabvenda,3,0)||
    LPAD(a.seqpessoa,7,0)                      AS  coddesconto,     --> C�digo
    TO_CHAR(
      TRUNC(
        ADD_MONTHS(SYSDATE, 0),
        'YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtinicio,         --> Data de in�cio
    TO_CHAR(
      TO_DATE(
        '31/12/3000',
        'DD/MM/YYYY'
      ),
      'YYYY-MM-DD'
    )                                          AS  dtfim,            --> Data de fim
    'R'                                        AS  origemped,        --> Origem do pedido (F=For�a Venda, R=Balc�o Reserva, B=Balc�o e O=Outros)
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
