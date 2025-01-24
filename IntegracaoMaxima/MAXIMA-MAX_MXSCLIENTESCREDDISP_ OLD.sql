SELECT
    DISTINCT
    a.seqpessoa                             AS codcli,
    d.limitecredito                         AS vllimite,
    (SELECT	
    implantacao.Fge_Vlrcreduso(a.seqpessoa)	
    FROM 	DUAL)                             AS vltitulos,
    (SELECT
     ROUND(
     SUM(
        (pvi.qtdatendida/pvi.qtdembalagem)*
        pvi.vlrembinformado
     ),2) 
     FROM implantacao.mad_pedvendaitem pvi 
     INNER JOIN implantacao.mad_pedvenda pv 
     ON pv.nropedvenda = pvi.nropedvenda 
     AND pv.codgeraloper IN (201,207,314) 
     AND pv.usuinclusao = 'AFV' 
     AND pv.situacaoped != 'C'
     AND pv.seqpessoa = a.seqpessoa)        AS vlpedidos,
    (SELECT
     ROUND(
     NVL(
     SUM(
        CASE 
        WHEN tipoespecie = 'C'
        THEN +NVL(vlrnominal,0)
             -NVL(vlrpago,0)
        ELSE 0
        END
     ),0),2)
     FROM implantacao.fi_titulo 
     WHERE obrigdireito = 'D' 
     AND abertoquitado != 'Q' 
     AND dtaemissao <= SYSDATE
     AND seqpessoa = a.seqpessoa)           AS vlcheques,
    CASE 
    WHEN +NVL(d.limitecredito,0)
         -(SELECT	implantacao.Fge_Vlrcreduso(a.seqpessoa)	
           FROM 	DUAL) <= 0 
    THEN 0 
    ELSE +NVL(d.limitecredito,0)
         -(SELECT	implantacao.Fge_Vlrcreduso(a.seqpessoa)	
           FROM 	DUAL)
    END                                     AS vlcredito,
    0                                       AS vllimitcredsuppli,
    a.statuscliente                         AS status,
    MAX(e.dtaalteracao)                     AS dtaalteracao
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.mad_clienterep b 
ON b.seqpessoa = a.seqpessoa AND b.status = 'A'
INNER JOIN implantacao.mad_representante c 
ON c.nrorepresentante = b.nrorepresentante AND c.tiprepresentante IN ('F','R','S') AND c.status = 'A'
INNER JOIN implantacao.ge_pessoacadastro d 
ON d.seqpessoa = a.seqpessoa
INNER JOIN (SELECT DISTINCT seqpessoa AS codpessoa, MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.mrl_cliente
            WHERE statuscliente = 'A'
            AND seqpessoa NOT IN (1, 22401)
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_clienterep a
            WHERE a.seqpessoa NOT IN (1, 22401)
            AND a.status = 'A'
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_representante a
            WHERE tiprepresentante IN ('F','R','S')
            AND status = 'A'
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.ge_pessoacadastro
            GROUP BY seqpessoa) e 
ON e.codpessoa = a.seqpessoa
WHERE 1 = 1
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
GROUP BY a.seqpessoa,a.statuscliente,d.limitecredito;


