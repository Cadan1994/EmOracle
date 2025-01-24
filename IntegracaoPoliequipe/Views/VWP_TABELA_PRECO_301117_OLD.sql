CREATE OR REPLACE VIEW POLIBRAS.VWP_TABELA_PRECO_301117 AS
SELECT T.U_PKEY,
       T.U_ORGVENDA,
       T.S_CODTABELA,
       T.S_CODPRODUTO,
       T.D_FAIXA,
       T.U_REFERENCIA,
       T.D_PRECO,
       T.D_DESCONTOPADRAO,
       T.D_CVERBADESC,
       T.D_CVERBAACRES,
       T.U_SITUACAO
  FROM (

        SELECT 0 U_PKEY,
                E.NROEMPRESA U_ORGVENDA,
                C.NROSEGMENTO || '.' || G.NROTABVENDA S_CODTABELA,
                A.SEQPRODUTO || '.' || F.QTDEMBALAGEM S_CODPRODUTO,
                0 D_FAIXA,
                1 U_REFERENCIA,

              /*CASE

  WHEN
  e.nrosegmento = 9
THEN  REPLACE(ROUND(NVL(ROUND(IMPLANTACAO.CADAN_FIMVENDA(A.SEQPRODUTO,
                                                                   E.NROEMPRESA,
                                                                   E.NROSEGMENTO,
                                                                   F.QTDEMBALAGEM,
                                                                   S.NROTABVENDA,
                                                                   '1',
                                                                   '1000',
                                                                   'PE',
                                                                   '416',
                                                                   'R',
                                                                   'N',
                                                                   NULL,
                                                                   'S',
                                                                   '1750393',
                                                                   NULL,
                                                                   'I',
                                                                   '201',
                                                                   NULL)

                                       ,
                                        2),
                                  0),
                              2),
                        ',',
                        '.')
												else
*/
													REPLACE(ROUND(NVL(ROUND(IMPLANTACAO.CADAN_FIMVENDA(A.SEQPRODUTO,
                                                                   E.NROEMPRESA,
                                                                   E.NROSEGMENTO,
                                                                   F.QTDEMBALAGEM,
                                                                   S.NROTABVENDA,
                                                                   '1',
                                                                   '1000',
                                                                   'PE',
                                                                   '416',
                                                                   'R',
                                                                   null,
                                                                   NULL,
                                                                   'S',
                                                                   '1750393',
                                                                   NULL,
                                                                   'I',
                                                                   '201',
                                                                   NULL)

                                       ,
                                        2),
                                  0),
                              2),
                        ',',
                        '.')



                /*END*/ D_PRECO

                --preço promoção/
                --vnPrecoVda := vnPrecoVda + vnPrecoVda * vnPercAcrDesctoTributarioUf / 100;
                --coluna de preço

               ,
                0                 D_DESCONTOPADRAO,
                C.PERCMAXDESCFLEX D_CVERBADESC,
                C.PERCMAXACRFLEX  D_CVERBAACRES,
                0                 U_SITUACAO

          FROM IMPLANTACAO.MAP_PRODUTO A -- seqproduto,seqfamilia,desccompleta,descreduzida,
          JOIN IMPLANTACAO.MAD_FAMSEGMENTO C
            ON (A.SEQFAMILIA = C.SEQFAMILIA) --seqfamilia,nrosegmento,padraoembvenda,classificomercabc,status='A'
          JOIN IMPLANTACAO.MAP_FAMEMBALAGEM F
            ON (A.SEQFAMILIA = F.SEQFAMILIA) -- seqfamilia,qtdembalagem,embalagem,satus,qtdunidemb
          JOIN IMPLANTACAO.MRL_PRODEMPSEG E
            ON (A.SEQPRODUTO = E.SEQPRODUTO AND C.NROSEGMENTO = E.NROSEGMENTO AND
               E.QTDEMBALAGEM = F.QTDEMBALAGEM AND E.NROEMPRESA IN (1, 2) AND
               E.STATUSVENDA = 'A') -- seqproduto,qtdembalagem,nrosegmento,nroempresa,statusvenda
          JOIN IMPLANTACAO.MAD_SEGTABVENDA G
            ON (G.NROSEGMENTO = C.NROSEGMENTO AND G.STATUS = 'A')
          JOIN IMPLANTACAO.MAP_PRODCODIGO H
            ON (F.QTDEMBALAGEM = H.QTDEMBALAGEM AND
               E.QTDEMBALAGEM = H.QTDEMBALAGEM AND
               H.SEQPRODUTO = A.SEQPRODUTO AND INDUTILVENDA = 'S')
          JOIN POLIBRAS.VWP_SEGMENTO_TABVENDA S
            ON (S.NROSEGMENTO = G.NROSEGMENTO AND
               S.NROTABVENDA = G.NROTABVENDA)
          JOIN IMPLANTACAO.VAFVAC_TABELAPRECO ZZ
            ON (ZZ.CODIGO = G.NROTABVENDA)

          JOIN IMPLANTACAO.MAP_FAMDIVISAO Y
            ON (Y.SEQFAMILIA = A.SEQFAMILIA AND Y.SEQFAMILIA = C.SEQFAMILIA AND
               Y.SEQFAMILIA = F.SEQFAMILIA)
          JOIN IMPLANTACAO.MAD_TABVENDATRIB X
            ON (X.NROTRIBUTACAO = Y.NROTRIBUTACAO AND
               X.NROTABVENDA = S.NROTABVENDA AND
               X.NROTABVENDA = G.NROTABVENDA)

         WHERE C.STATUS = 'A'
           AND F.STATUS = 'A'
					  --AND C.NROSEGMENTO != 9
          /*AND A.SEQPRODUTO = 467
         AND C.NROSEGMENTO = 9
         AND e.nroempresa = 1*/
        ) T
/*
where t.d_preco IS NULL*/

