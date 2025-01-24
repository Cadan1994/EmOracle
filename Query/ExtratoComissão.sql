SELECT 
      CASE 
      WHEN a.status = 'A'
      THEN 'N'
      ELSE 'S'
      END                                                   AS  bloqueio,
      a.nrosegmento                                         AS  coddistrib,
      (
      SELECT SUM(t1.nrorepresentante)
      FROM implantacao.mad_representante t1
      WHERE 1 = 1
      AND   t1.seqpessoa not in (1,22401)
      AND   t1.tiprepresentante = 'S'
      AND   t1.nroequipe = a.nroequipe
      )                                                     AS  codsupervisor,
      a.nrorepresentante                                    AS  codusur,
      a.nroempresa        AS  codfilial,
      a.percmaxacrflex    AS  peracresfv,
      a.percmaxacrflex    AS  permaxvenda,
      a.premvlrvenda      AS  percent,
      a.metaqtdprodmix    AS  percent2,
      NVL(a.vlrminimopedido,0) AS  vlvendaminped,
      b.nomerazao         AS  nome,
      b.email             AS  email,
      '(' || b.foneddd1 ||') ' || b.fonenro1 AS TELEFONE1
FROM implantacao.mad_representante a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa
--INNER JOIN implantacao.mad_equipe b ON b.nroequipe = a.nroequipe 
--INNER JOIN implantacao.mad_equipe c ON c.nroequipe = b.nroequipesuperior
WHERE 1=1
AND   a.seqpessoa not in (1,22401)
AND   a.tiprepresentante != 'G'
--AND   (a.dtaalteracao >= TO_DATE(SYSDATE - 1) 
--OR    (d.datahoraalteracao >= TO_DATE(SYSDATE - 1)))
ORDER BY a.nrorepresentante ASC