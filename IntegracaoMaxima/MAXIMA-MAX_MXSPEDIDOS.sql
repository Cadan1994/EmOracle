SELECT 
    DISTINCT
    a.nropedvenda                               AS  numped,
    '8888'                                      AS  codemitente,
    TO_CHAR(a.dtabasefaturamento,'YYYY-MM-DD')  AS  dtfat,
    a.motcancelamento                           AS  motivo,
    TO_CHAR(a.dtainiseparacao,'YYYY-MM-DD')     AS  dtinicialsep,
    TO_CHAR(a.dtafimseparacao,'YYYY-MM-DD')     AS  dtfinalsep,
    a.seqpessoa                                 AS  codcli,
    0                                           AS  numnota,
    0                                           AS  totpeso,
    'F'                                         AS  origemped,
    TO_CHAR(a.dtacancelamento,'YYYY-MM-DD')     AS  dtcancel,
    TO_CHAR(a.dtainclusao,'YYYY-MM-DD')         AS  data,
    TO_CHAR(a.dtabasefaturamento,'YYYY-MM-DD')  AS  dtlibera,
    TO_CHAR(a.dtabasefaturamento, 'MI')         AS  minutofat,
    CASE 
    WHEN a.situacaoped = 'S'
    THEN 'M'
    WHEN a.situacaoped IN ('A','D')
    THEN 'P'
    ELSE a.situacaoped
    END                                         AS  posicao,
    (SELECT SUM((qtdatendida/qtdembalagem)
    *vlrembtabpreco)
    FROM implantacao.mad_pedvendaitem 
    WHERE 1 = 1
    AND usuinclusao = 'AFV'
    AND dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')
    AND nroempresa = a.nroempresa
    AND nropedvenda = a.nropedvenda)            AS  vltabela,
    a.obspedido                                 AS  obsentrega,
    TO_CHAR(a.dtabasefaturamento, 'HH')         AS  horafat,
    1                                           AS  condvenda,
    a.nroempresa                                AS  codfilialnf,
    a.nroempresa                                AS  codfilial,
    a.nrorepresentante                          AS  codusur,
    TO_CHAR(a.dtainclusao, 'HH')                AS  hora,
    a.nrocarga                                  AS  numcar,
    a.nropedidoafv                              AS  numpedrca,
    TO_CHAR(a.dtainclusao, 'MI')                AS  minuto,
    a.obspedido                                 AS  obs,
    a.obscancelamento                           AS  obs1,
    a.obsavaliacredito                          AS  obs2,
    a.nrosegmento                               AS  coddistrib,
    a.nropedvenda                               AS  numtransvenda,
    a.nroformapagto                             AS  codcob,
    0                                           AS  totvolume,
    'A'                                         AS  status,
    b.vlratendido                               AS  vlatend,
    b.vlrtotal                                  AS  vltotal,
    (SELECT COUNT(t1.nropedvenda)
    FROM implantacao.mad_pedvendaitem t1 
    WHERE 1 = 1
    AND usuinclusao = 'AFV'
    AND dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')
    AND nroempresa = a.nroempresa
    AND nropedvenda = a.nropedvenda)            AS  numitens,
    NVL(e.sequsuario,0)                         AS  codfuncfat,
    NVL(f.sequsuario,0)                         AS  codfunccanc,
    g.codsupervisor                             AS  codsupervisor,
    h.codplpag                                  AS  codplpag,
    h.codpraca                                  AS  codpraca,
    MAX(i.dtaalteracao)                         AS  dtaalteracao
FROM implantacao.mad_pedvenda a
INNER JOIN (SELECT 
                nroempresa, 
                nropedvenda,
                SUM(vlrtotcomissao) AS vlrcomissao,
                SUM((qtdatendida / qtdembalagem ) * vlrembinformado) AS vlratendido,
                SUM(((qtdatendida / qtdembalagem ) * vlrembinformado) + vlrtoticmsst) AS vlrtotal,
                COUNT(nropedvenda) qtditens
            FROM implantacao.mad_pedvendaitem
            WHERE 1 = 1
            AND usuinclusao = 'AFV'
            AND dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')
            GROUP BY nroempresa, nropedvenda) b 
ON b.nroempresa = a.nroempresa AND b.nropedvenda = a.nropedvenda
-- PEGA CÓDIGO COBRANÇA
INNER JOIN (SELECT nrorepresentante, seqpessoa 
            FROM implantacao.mad_representante 
            WHERE 1 = 1) c 
ON c.nrorepresentante = a.nrorepresentante
LEFT JOIN implantacao.mrl_cargaexped d 
ON d.nrocarga = a.nrocarga 
LEFT JOIN implantacao.ge_usuario e 
ON e.codusuario = d.usufaturamento
LEFT JOIN implantacao.ge_usuario f 
ON f.codusuario = a.usucancelamento
-- PEGA O CÓDIGO DO SUPERVISOR
LEFT JOIN (SELECT
               a.nrorepresentante,
               (SELECT SUM(nrorepresentante)
                FROM implantacao.mad_representante
                WHERE 1 = 1
                AND   seqpessoa NOT IN (1,22401)
                AND   tiprepresentante = 'S'
                AND   nroequipe = a.nroequipe) AS codsupervisor
           FROM implantacao.mad_representante a
           INNER JOIN implantacao.ge_pessoa b 
           ON b.seqpessoa = a.seqpessoa
           WHERE 1 = 1
           AND   a.seqpessoa not in (1,22401)
           AND   a.tiprepresentante != 'G') g 
ON g.nrorepresentante = a.nrorepresentante
-- para criação do códigos das praças e códigos dos planos de pagamentos
INNER JOIN (SELECT 
                DISTINCT 
                b.nroempresa,
                a.seqpessoa,
                MIN(LPAD(b.nroempresa,2,0)||LPAD(a.nrosegmento,3,0)||LPAD(a.nrotabvendaprinc,4,0)) AS codpraca,
                MIN(LPAD(NVL(b.nrocondpagtopadrao,1),3,0)||LPAD(a.nrotabvendaprinc,3,0)) AS codplpag
            FROM implantacao.mrl_clienteseg a
            INNER JOIN implantacao.mrl_cliente b ON b.seqpessoa = a.seqpessoa 
            WHERE a.status = 'A'
            AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND (nrotabvendaprinc != 'NULL'
            OR (nrotabvendaprinc NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)))
            GROUP BY b.nroempresa,a.seqpessoa) h
ON h.nroempresa = a.nroempresa AND h.seqpessoa = a.seqpessoa
INNER JOIN (SELECT DISTINCT nroempresa,seqpessoa,nropedvenda,TO_DATE(dtahorsituacaopedalt) AS dtaalteracao 
            FROM implantacao.mad_pedvenda
            WHERE usuinclusao = 'AFV'
            AND dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')
            /*
            UNION ALL
            SELECT DISTINCT nroempresa,seqpessoa,nropedvenda,TO_DATE(dtabasefaturamento) AS dtaalteracao 
            FROM implantacao.mad_pedvenda
            WHERE usuinclusao = 'AFV'
            AND dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')
            UNION ALL
            SELECT DISTINCT nroempresa,seqpessoa,nropedvenda,TO_DATE(dtacancelamento) AS dtaalteracao 
            FROM implantacao.mad_pedvenda
            WHERE usuinclusao = 'AFV'
            AND dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')*/) i
ON i.nroempresa = a.nroempresa AND i.seqpessoa = a.seqpessoa AND i.nropedvenda = a.nropedvenda
WHERE 1 = 1
AND a.usuinclusao = 'AFV'
AND a.dtainclusao >= TRUNC(ADD_MONTHS(SYSDATE,0),'YY')
AND a.nropedvenda = 4069934
GROUP BY  a.nroempresa,a.seqpessoa,a.nrosegmento,a.nropedvenda,a.dtainclusao,a.dtaalteracao,a.dtacancelamento,a.dtabasefaturamento,
          a.motcancelamento,a.dtainiseparacao,a.dtafimseparacao,a.situacaoped,a.obspedido,a.nrorepresentante,a.nrocarga,
          a.nropedidoafv,a.obscancelamento,a.obsavaliacredito,a.nrocondicaopagtoaux,a.nroformapagto,b.vlratendido,b.vlrtotal,e.sequsuario,
          f.sequsuario,g.codsupervisor,h.codpraca,h.codplpag
ORDER BY 1 ASC;