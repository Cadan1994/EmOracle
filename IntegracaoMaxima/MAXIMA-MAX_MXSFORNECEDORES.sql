SELECT
    a.seqfornecedor                         AS  codfornec,
    substr(concat(lpad(b.nrocgccpf,12,'0'),
    lpad(b.digcgccpf,2,'0')),0,2)||'.'|| 
    substr(concat(lpad(b.nrocgccpf,12,'0'),
    lpad(b.digcgccpf,2,'0')),3,3)||'.'||
    substr(concat(lpad(b.nrocgccpf,12,'0'),
    lpad(b.digcgccpf,2,'0')),6,3)||'/'||
    substr(concat(lpad(b.nrocgccpf,12,'0'),
    lpad(b.digcgccpf,2,'0')),9,4)||'-'||
    substr(concat(lpad(b.nrocgccpf,12,'0'),
    lpad(b.digcgccpf,2,'0')),13,2)          AS  cgc,
    b.nomerazao                             AS  fornecedor,
    b.fantasia                              AS  fantasia,
    b.logradouro||', '||b.nrologradouro     AS  ender,
    b.bairro                                AS  bairro,
    b.cidade                                AS  cidade,
    b.uf                                    AS  estado,
    CASE
    WHEN a.statusgeral = 'A'
    THEN 'N'
    ELSE 'S'
    END                                     AS  bloqueio,
    NULL                                    AS  coddistrib,
    'N'                                     AS  eredespacho,
    'S'                                     AS  estrategico,
    'N'                                     AS  exigeredespacho,
    NVL(d.pesominpedido,0)                  AS  gatilho,
    'N'                                     AS  icmssobretxminima,
    'S'                                     AS  revenda,
    a.fonecontato                           AS  telfab,
    a.statusgeral                           AS  status,
    MAX(TO_DATE(e.dtaalteracao))            AS  dtaalteracao
FROM implantacao.maf_fornecedor a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqfornecedor
LEFT JOIN implantacao.map_famfornec c ON c.seqfornecedor = b.seqpessoa AND c.principal = 'S'
LEFT JOIN implantacao.maf_fornecdivisao d ON d.seqfornecedor = a.seqfornecedor 
LEFT JOIN (SELECT t0.seqfornecedor AS codfornecedor,MAX(TO_DATE(t0.dtaalteracao)) AS dtaalteracao
           FROM implantacao.maf_fornecedor t0
           GROUP BY t0.seqfornecedor
           UNION
           SELECT t1.seqpessoa AS codfornecedor,MAX(TO_DATE(t1.dtaalteracao)) AS dtaalteracao
           FROM implantacao.ge_pessoa t1
           GROUP BY t1.seqpessoa
           UNION
           SELECT t2.seqfornecedor AS codfornecedor,MAX(TO_DATE(t2.datahoraalteracao)) AS dtaalteracao
           FROM implantacao.map_famfornec t2
           GROUP BY t2.seqfornecedor
           UNION
           SELECT t3.seqfornecedor AS codfornecedor,MAX(TO_DATE(t3.dtaalteracao)) AS dtaalteracao
           FROM implantacao.maf_fornecdivisao t3
           GROUP BY t3.seqfornecedor
           ) e ON e.codfornecedor = a.seqfornecedor
WHERE 1 = 1
GROUP BY a.seqfornecedor,b.nrocgccpf,b.digcgccpf,b.nomerazao,b.fantasia,b.logradouro,
         b.nrologradouro,b.bairro,b.cidade,b.uf,a.statusgeral,d.pesominpedido,a.fonecontato;
