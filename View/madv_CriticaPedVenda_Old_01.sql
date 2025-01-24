CREATE OR REPLACE VIEW IMPLANTACAO.MADV_CRITICAPEDVENDA AS
select /*+rule*/
 a.nropedvenda, a.nroempresa, 'Valor Minimo' codcritica
  from madv_pedvenda a, mad_parametro b
 where a.situacaoped = 'L'
   and a.vlrpedido < b.vlrminimopedido
   and a.nroempresa = b.nroempresa

union

Select x.nropedvenda, x.nroempresa, 'Exclusivo CGO ECF'
  from madv_pedvenda x, mad_condicaopagto c
 Where x.nrocodicaopagto = c.nrocondicaopagto
      /*and c.desccondicaopagto not like 'ECF%'*/
   and x.nrotabvenda not in (12, 13, 14, 122, 131, 141,711)
   and x.codgeraloper in (313,314,307)
   and x.nroempresa in (1, 2)

--ok
/*union

select a.nropedvenda, a.nroempresa, 'Markup'
  from madv_pedbasemarkup a
 where a.vlratendido < a.vlrcustoatendido*/

union

select x.nropedvenda, x.nroempresa, 'Cliente Sem Rota Associada'

  from mad_pedvenda x
  join mad_clienteend w
    on w.seqpessoa = x.seqpessoa

 where w.seqpraca is null
   and x.situacaoped not in ('C', 'F')
   and w.seqpessoaend != 2
   /*
union

select x.nropedvenda, x.nroempresa, 'Valor Ped. Acima do Disp. Segt'
\*       FMAD_VLRTOTPEDVENDA(x.nropedvenda,
x.nroempresa,
null,null) Total*\
  from mad_pedvenda x

  join mrl_clienteseg w
    on w.nrosegmento = x.nrosegmento
   and w.nrorepresentante = w.nrorepresentante
   and w.seqpessoa = x.seqpessoa
 where \*x.nropedvenda = 1422
   and*\
 FMAD_VLRTOTPEDVENDA(x.nropedvenda, x.nroempresa, null, null) >
 w.vlrlimitevda

 and x.situacaoped not in ('C', 'F')
 and x.nrorepresentante = 251*/

union

select x.nropedvenda, x.nroempresa, 'Cond. Pagto. Proib.c/ Forma'
  from mad_pedvenda x

  join mad_pedvendaitem w
    on w.nropedvenda = x.nropedvenda
   and w.nroempresa = x.nroempresa
      /* and w.nrocondicaopagto  = (select a.nrocondicaopagto  from mad_condicaopagto a
      where a.nrocondicaopagto = w.nrocondicaopagto
        and a.desccondicaopagto like '%ECF%')*/
   and x.nrotabvenda in (12, 13, 14, 122, 131, 141)
   and x.nroempresa in (1, 2)

 where x.nroformapagto =
       (select b.nroformapagto
          from mrl_formapagto b
         where b.nroformapagto = x.nroformapagto
           and b.nroformapagto in ( 4, /*9,*/ 998)) -- informação retirada por GSILVA mediante solicitação de Tim
   and x.situacaoped not in ('C', 'F')

--ok
union

select x.nropedvenda, x.nroempresa, 'Cond. Pagto. Proib. nesse CGO'

  from mad_pedvenda x

  join mad_pedvendaitem w
    on w.nropedvenda = x.nropedvenda
   and w.nroempresa = x.nroempresa
      /*and w.nrocondicaopagto  = (select a.nrocondicaopagto  from mad_condicaopagto a
      where a.nrocondicaopagto = w.nrocondicaopagto
        and a.desccondicaopagto like '%ECF%')*/
   and x.nrotabvenda in (12, 13, 14, 122, 131, 141)
   and x.nroformapagto not in (6,7,8)

 where x.codgeraloper = 201
   and x.situacaoped not in ('C', 'F')
   and x.nroempresa in (1, 2)
   union

 select x.nropedvenda, x.nroempresa,

               'Consumidor fim. entrega'

 from mad_pedvenda x
join ge_pessoa a on (a.seqpessoa =x.seqpessoa)

 where x.codgeraloper = 307
 and  a.fisicajuridica in ('F','J')
 and  x.situacaoped not in ('C','F')

/*
union

  select x.nropedvenda,
               x.nroempresa,
               'Cond. Pagto. Proib. nesse CGO'

               from mad_pedvenda x

        join mad_pedvendaitem w
          on w.nropedvenda = x.nropedvenda
         and w.nroempresa  = x.nroempresa
         and w.nrocondicaopagto  = (select a.nrocondicaopagto  from mad_condicaopagto a
                                          where a.nrocondicaopagto = w.nrocondicaopagto
                                            and a.desccondicaopagto Not like '%ECF%')

         where x.codgeraloper = 307
          and  x.situacaoped not in ('C','F')*/

union

Select x.nropedvenda, x.nroempresa, 'Tab. Venda. Exclusiva PDV'

  from mad_pedvenda x
 Where x.codgeraloper <> 202
   and x.nrotabvenda In (1,12, 13, 14, 122, 131, 141)
   and x.nroempresa in (1, 2)

union

Select x.nropedvenda, x.nroempresa, 'Cgo. Venda. Exclusiva NF'

  From mad_pedvenda x, ge_pessoa q
 Where x.seqpessoa = q.seqpessoa
   and q.fisicajuridica = 'F'
   and x.codgeraloper = 201
   and x.nrotabvenda In (14, 13, 12, 122, 131, 141)
   and x.nroempresa in (1, 2)
--ok

union

Select x.nropedvenda, x.nroempresa, 'Tab. Venda. Proib. nesse CGO'

  from mad_pedvenda x
 Where x.codgeraloper = 575

   and x.nroempresa in (1, 2)

union

Select x.nropedvenda, x.nroempresa, 'Tab. Venda. Proib. nesse Segm'

  from mad_pedvenda x
 Where x.codgeraloper = 202
   and x.nrotabvenda = 12
   and x.nrosegmento = 5
   and x.nroempresa in (1, 2)

union

Select x.nropedvenda, x.nroempresa, 'Tab. Venda. Exclusiva Seg.Food'

  from mad_pedvenda x
 Where x.codgeraloper = 202
   and x.nrotabvenda <> 13
   and x.nrosegmento = 5
   and x.nroempresa in (1, 2)

union

select a.nropedvenda, a.nroempresa, 'Limite de Crédito Zerado'

  from mad_pedvenda a, ge_pessoacadastro b

 where a.seqpessoa = b.seqpessoa
   and b.limitecredito = 0
   and a.situacaoped not in ('C', 'F')

union

select a.nropedvenda, a.nroempresa, 'Entrega a Vista' codcritica
  from mad_pedvenda a, mad_pedvendaitem b
 where a.nropedvenda = b.nropedvenda
   and a.nroempresa = b.nroempresa
   and a.indentregaretira = 'E'
   and a.nroformapagto in( 1,5,2,7,8,6)
   and b.nrocondicaopagto IN (01,501,502,503)
   AND a.codgeraloper != 205 -- alterado dia 15/07/2013 , para que as bonificações não fossem para analise
   and a.nrorepresentante  in (100,200)
   and a.usuinclusao != 'ECOMMERCE'

union

Select x.nropedvenda, x.nroempresa, 'Bloqueia Venda Tabela 8 - Food'
  from mad_pedvenda x
 Where x.nrotabvenda in (8)
   and x.nrosegmento = 5
--comentar tab 14 nessa critica apartir do dia 01/04/2015

union

select a.nropedvenda, a.nroempresa, 'Entrega Cheque' codcritica

  from mad_pedvenda a
 where a.indentregaretira = 'E'
   and a.nroformapagto in (2, 5)

union

select a.nropedvenda,
       a.nroempresa,
       'Condicao Dinheiro-Forma Avista' codcritica
  from mad_pedvenda a, mad_pedvendaitem b
 where a.nropedvenda = b.nropedvenda
   and a.nroempresa = b.nroempresa
   and a.indentregaretira = 'E'
      --and b.nrocondicaopagto in (0, 1, 501, 574, 999) -- comentado por Gustavo Silva no dia 29/09/2015
   and a.nroformapagto in (1,2,5,6,7)
   and a.nrorepresentante not in (100,200)
   and a.usuinclusao not in('ECOMMERCE')
   AND a.codgeraloper != 205

union

select y.nropedvenda, y.nroempresa, 'Pedido CF fora da tab. 15'
  from mad_pedvenda y, ge_pessoa pe
 where y.seqpessoa  =  pe.seqpessoa
   and y.codgeraloper in (201,307)
   and y.nrotabvenda != 15
   and pe.uf         != 'PE'
   and y.nroempresa in (1, 2)
   and y.dtainclusao >= '01-apr-2015'

UNION

select y.nropedvenda, y.nroempresa, 'Pedido CF fora da tab. 14'
  from mad_pedvenda y, ge_pessoa pe
 where y.seqpessoa  =  pe.seqpessoa
   and y.codgeraloper in (313,307,314)
   and pe.fisicajuridica = 'F'
   and y.nrotabvenda not in (14, 13, 12, 122, 131, 141,711)
   and y.nroempresa in (1, 2)
   and y.dtainclusao >= '01-apr-2015'


union

select x.nropedvenda, x.nroempresa, 'Bloqueio para análise'
/*       FMAD_VLRTOTPEDVENDA(x.nropedvenda,
x.nroempresa,
null,null) Total*/
  from mad_pedvenda x

 where x.situacaoped not in ('C', 'F')
   and x.nropedidoafv = 501133
   AND X.NROPEDIDOAFV IS NOT NULL
   AND x.nropedidoafv <= 20000000

union

select y.nropedvenda, y.nroempresa, 'pedido cgo cf boleto'
  from mad_pedvenda y
 where y.codgeraloper in (314)
   and y.nroformapagto =3
  --and y.nrotabvenda in (14, 13, 12, 122, 131, 141)
   and y.nroempresa in (1, 2)

union

Select x.nropedvenda, x.nroempresa, 'cgo 757'

  from mad_pedvenda x
 Where x.codgeraloper = 575
      -- and x.nrotabvenda  In (14,13,12,122,131,141)
   and x.nroempresa in (1, 2)
   and x.situacaoped not in ('F', 'C')

   /*union

 select y.nropedvenda, y.nroempresa, 'cupom bloqueado'
  from mad_pedvenda y, (select f.seqpessoa from ge_pessoa f where f.uf = 'PE') x
 where y.codgeraloper in (313,307)
   and y.nroempresa in (2)
   and y.nrotabvenda in (14, 13, 12, 122, 131, 141)
   and y.nroformapagto not in (3)
   and y.nrosegmento !=3
   and y.seqpessoa = x.seqpessoa*/

/*   union gustavo gomes 04-10-2018

      select y.nropedvenda, y.nroempresa, 'Consumidor fim. entrega'
  from mad_pedvenda y
 where y.codgeraloper in (307)

   and y.nroempresa in (2)
   and y.nrotabvenda in (14, 13, 12, 122, 131, 141)
   and y.indentregaretira = 'E'*/

  union

      select vd.nropedvenda, vd.nroempresa, 'Cupom com Bonificacao'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   =                vi.nropedvenda
   and vd.codgeraloper in (313,314)
   and vd.nroempresa in (1,2)
   and vi.nrotabvenda in (7)
   and vd.indentregaretira = 'R'

   union

/*     select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   =                vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 200
   and vd.codgeraloper not in ( 571 )
   and vi.seqproduto    = 26262
   and vd.nroempresa in (1,2)

   union*/

     select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   =                vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 300
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (24172,27635,27626)
   and vd.nroempresa in (1,2)

   union

   select vd.nropedvenda, vd.nroempresa, 'PEDIDO ECOMMERCE'
  from mad_pedvenda vd
 where
   vd.usuinclusao = 'ECOMMERCE'
   AND VD.SITUACAOPED NOT IN ('C','F','R','S')

   UNION

     select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 480
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (27626,27627,23434,24171,34815,37680)
   and vd.nroempresa in (1,2)

   union

     select vd.nropedvenda, vd.nroempresa, 'venda cupom fora estado'
  from mad_pedvenda vd, mad_pedvendaitem vi, ge_pessoa p
 where vd.nropedvenda   = vi.nropedvenda
   and vd.nropedvenda   = vi.nropedvenda
   and vd.seqpessoa     = p.seqpessoa
   and p.uf             != 'PE'
   and p.uf             != 'BA'
   and vd.codgeraloper  IN ( 307,201)
   and vd.nroempresa in (1,2)
   AND vd.situacaoped not in ( 'C', 'F')

/*
  union

     select vd.nropedvenda, vd.nroempresa, 'venda cupom fora do estado'
  from mad_pedvenda vd, mad_pedvendaitem vi, ge_pessoa p
 where vd.nropedvenda   = vi.nropedvenda
   and vd.nropedvenda   = vi.nropedvenda
   and vd.seqpessoa     = p.seqpessoa
   and p.uf             != 'PE'
   and vd.codgeraloper  = 314
   and vd.nroempresa in (1,2)*/

/*   union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 240
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (38883,38904)
   and vd.nroempresa in (1,2)
*/
/*

  union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 24
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (1161)
   and vd.nroempresa in (1,2)

     union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 12
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (1162)
   and vd.nroempresa in (1,2)



    union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 60
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (3322)
   and vd.nroempresa in (1,2)

\*       union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 24
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (35976)
   and vd.nroempresa in (1,2)
   *\
          union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 60
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (2640)
   and vd.nroempresa in (1,2)


            union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 60
   and   vd.nrosegmento in (1,3,4,5,7,8,9,10,12)
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (39016)
   and vd.nroempresa in (1,2)
\*    union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 12
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (3057)
   and vd.nroempresa in (1,2)*\

   union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 12
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (3057)
   and vd.nroempresa in (1,2)

      union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 120
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (38946)
   and vd.nroempresa in (1,2)*/

 /*      union

      select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 30
   and vd.codgeraloper not in (571)
   and vi.seqproduto    in (38867)
   and vd.nroempresa in (1,2)*/

   /*union

     select vd.nropedvenda,
         vd.nroempresa,
         'Qtd Maior que a permitida'
  from mad_pedvenda vd,
       mad_pedvendaitem vi,
       fi_cliente vc
 where vd.nropedvenda   = vi.nropedvenda
   and vd.nropedvenda = vi.nropedvenda
   and vd.seqpessoa   = vc.seqpessoa
   and vc.sitcredito  = 'S'
   and vd.indentregaretira  = 'E'
   and vd.codgeraloper in ( 307 )
   and vd.nroempresa in (1,2) -- trecho editado por GSILVA em 08/11/2017*/

/*   union
     select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and vd.codgeraloper in ( 313 )
   and vd.nroempresa in (1,2)


   union
     select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and vd.codgeraloper in ( 313 )
   and vd.nroempresa in (1,2)*/
  /* union

   select y.nropedvenda, y.nroempresa, 'Pedido CF fora da tab. 14'
  from mad_pedvenda y, ge_pessoa pe
 where y.seqpessoa  =  pe.seqpessoa
   and y.codgeraloper in (201)
   and y.nrotabvenda  not in (14)
   and y.nroempresa in (1, 2)
   and y.nroformapagto in (6,7,8)
   and y.dtainclusao >= '01-apr-2015'
   --criado por GSILVA em 06/12/19*/

/*   union all

   select a.nropedvenda, a.nroempresa, 'Ped Pend Proc desconto'
  from mad_pedvenda a
  join edi_pedvenda b
    on b.nropedvenda = a.nropedvenda
  join max_codgeraloper d
    on d.codgeraloper = a.codgeraloper
   and d.acmcompravenda = 'S'
  join mad_tabvenda e
    on e.nrotabvenda = a.nrotabvenda
 where a.situacaoped in ('L', 'A')
   and e.tipotabvenda = 'V'
   and a.seqpessoa not in (select seqpessoaemp from max_empresa)
   AND A.DTAINCLUSAO >= '01-JAN-2019'
   AND NOT EXISTS (SELECT 1
          FROM CAD_PEDVENDA_PROCESSADO XX
         WHERE XX.NROPEDVENDA = A.NROPEDVENDA)*/

 /*  UNION
   --linha de teste gustavo gomes
  SELECT t.nropedvenda, t.NROEMPRESA, 'ERRO - 401' FROM (
  SELECT CADAN_401_CK(x.NROPEDVENDA) AS NROPEDVENDA , X.NROEMPRESA
  FROM MAD_PEDVENDA X WHERE x.codgeraloper = 314)t
  WHERE t.nropedvenda != 0;*/


  /* union

   SELECT X.NROPEDVENDA, X.NROEMPRESA, 'ERRO - 401'
  FROM MAD_PEDVENDA X,
       (SELECT B.SEQPESSOA,B.NROPEDVENDA,
                SUM( A.VLREMBINFORMADO * A.QTDATENDIDA / A.QTDEMBALAGEM) AS VALOR,
                B.CODGERALOPER
          FROM MAD_PEDVENDA B

          JOIN MAD_PEDVENDAITEM A
            ON (A.NROPEDVENDA = B.NROPEDVENDA)
         WHERE B.CODGERALOPER = 314
         --AND B.NROREPRESENTANTE = 1000
AND B.SITUACAOPED NOT IN ('F','R', 'C')
         GROUP BY B.CODGERALOPER, B.SEQPESSOA, B.NROPEDVENDA) T

 WHERE X.NROPEDVENDA = T.NROPEDVENDA AND T.VALOR > 980
   AND T.CODGERALOPER = 314
   --AND X.NROPEDVENDA = 2035070
   ;*/

 -- trecho editado por GSILVA em 28/12/2017

       /* select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   = vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   --and   vi.qtdatendida   > 180
   and vd.indentregaretira  = 'E'
   and vd.codgeraloper in ( 307 )
   --and vi.seqproduto    in (27626,27627)
   and vd.nroempresa in (1,2)*/

  /* union

   select vd.nropedvenda, vd.nroempresa, 'Qtd Maior que a permitida'
  from mad_pedvenda vd, mad_pedvendaitem vi
 where vd.nropedvenda   =               vi.nropedvenda
   and   vd.nropedvenda = vi.nropedvenda
   and   vi.qtdatendida   > 400
   and vd.codgeraloper not in ( 571 )
   and vi.seqproduto    in (21536,11254)
   and vd.nroempresa in (1,2)*\*/

