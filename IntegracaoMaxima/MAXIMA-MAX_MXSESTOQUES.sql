SELECT
    a.nroempresa                             AS  codfilial,
    a.seqproduto                             AS  codprod,
    0                                        AS  percicmsfretefobstultent,
    a.estqloja                               AS  qtfrenteloja,
    TO_CHAR(a.dtaultentrada, 'YYYY-MM-DD')   AS  dtultent,
    0                                        AS  qtbloqueada,
    a.estqdeposito                           AS  qtestger,
	a.qtdreservadavda                        AS  qtreserv,
    0                                        AS  ivaultent,
    1                                        AS  custorep,
    0                                        AS  vlfretecomhecultent,
    a.estqloja                               AS  qtloja,
    0                                        AS  custocont,
    1                                        AS  custoreal,
    CASE 
    WHEN a.cmultvlrnf <= 0 
    THEN 1 
    ELSE a.cmultvlrnf 
    END                                      AS  custofin,
    0                                        AS  custonfsemstguiaultent,
    0                                        AS  vlstguiaultent,
    0                                        AS  qtgirodia,
    0                                        AS  redbaseivaultent,
    0                                        AS  percaliqextguiaultent,
    b.custonfsemst                           AS  custonfsemst,
    b.peraliquotaicms                        AS  aliqicms1ultent,
    b.peraliquotaicms                        AS  aliqicms2ultent,
    b.vlricmsst                              AS  vlstultent,
    b.vlrtotalitem                           AS  valorultent,
    b.bascalcicms                            AS  baseicmsultent,
    NVL(c.qtdpendente,0)                     AS  qtpendente,
    a.statuscompra                           AS  status,
    TO_DATE(a.dtahorultmovtoestq)            AS  dtaalteracao
FROM implantacao.mrl_produtoempresa a
--
LEFT JOIN (SELECT 
               t2.nroempresa, 
               t2.seqproduto, 
               SUM(t2.vlrtotalitem-t2.vlricmsst) AS custonfsemst, 
               SUM(t2.peraliquotaicms) AS peraliquotaicms,
               SUM(CASE WHEN t2.vlricmsst <= 0 THEN 1 ELSE t2.vlricmsst END) AS vlricmsst,
               SUM(t2.vlrtotalitem) AS vlrtotalitem,
               SUM(t2.bascalcicms) AS bascalcicms
           FROM IMPLANTACAO.mlf_notafiscal t1 
           INNER JOIN implantacao.mlf_nfitem t2 
           ON t2.nroempresa = t1.nroempresa 
           AND t2.seqpessoa = t1.seqpessoa
           AND t2.numeronf = t1.numeronf 
           AND t2.tipnotafiscal = t1.tipnotafiscal
           WHERE 1 = 1
           AND t1.dtaentrada = (SELECT MAX(t3.dtaentrada) 
                                FROM IMPLANTACAO.mlf_notafiscal t3 
                                INNER JOIN implantacao.mlf_nfitem t4 
                                ON t4.nroempresa = t3.nroempresa 
                                AND t4.seqpessoa = t3.seqpessoa 
                                AND t4.numeronf = t3.numeronf 
                                AND t4.tipnotafiscal = t3.tipnotafiscal
                                WHERE 1 = 1
                                AND t3.nroempresa = t2.nroempresa
                                AND t4.seqproduto = t2.seqproduto)
            GROUP BY t2.nroempresa, t2.seqproduto) b 
ON b.nroempresa = a.nroempresa AND b.seqproduto = a.seqproduto
--
LEFT JOIN (SELECT t1.nroempresa, t1.seqproduto, SUM((t1.qtdsaldo - t1.qtdtransito) / '12') AS qtdpendente
           FROM implantacao.macv_psitemreceber t1
           WHERE 1 = 1
           AND t1.qtdsaldo > 0
           AND t1.statusitem != 'C'
           GROUP BY t1.nroempresa, t1.seqproduto) c 
ON c.nroempresa = a.nroempresa AND c.seqproduto = a.seqproduto
--
WHERE 1 = 1
AND a.statuscompra = 'A'
AND (a.estqdeposito + a.qtdreservadavda) <> 0;
