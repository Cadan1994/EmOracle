CREATE OR REPLACE VIEW implantacao.madv_criticapedvenda AS
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

union

select x.nropedvenda, x.nroempresa, 'Cliente Sem Rota Associada'

  from mad_pedvenda x
  join mad_clienteend w
    on w.seqpessoa = x.seqpessoa

 where w.seqpraca is null
   and x.situacaoped not in ('C', 'F')
   and w.seqpessoaend != 2
   
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
           and b.nroformapagto in ( 4, /*9,*/ 998)) -- informa��o retirada por GSILVA mediante solicita��o de Tim
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
   
UNION

SELECT x.nropedvenda, 
	     x.nroempresa,
	     'Consumidor fim. entrega'
FROM implantacao.mad_pedvenda x
INNER JOIN implantacao.ge_pessoa a ON a.seqpessoa = x.seqpessoa AND a.fisicajuridica = 'F'
WHERE x.codgeraloper = 307
AND   x.situacaoped not in ('C','F')
AND   x.indentregaretira = 'E'

UNION

SELECT x.nropedvenda, 
	     x.nroempresa,
	     'Consumidor fim. entrega'
FROM implantacao.mad_pedvenda x
INNER JOIN implantacao.ge_pessoa a ON a.seqpessoa = x.seqpessoa AND a.fisicajuridica = 'J'
WHERE x.codgeraloper = 307
AND   x.situacaoped not in ('C','F')


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

select a.nropedvenda, a.nroempresa, 'Limite de Cr�dito Zerado'

  from mad_pedvenda a, ge_pessoacadastro b

 where a.seqpessoa = b.seqpessoa
   and b.limitecredito = 0
   and a.situacaoped not in ('C', 'F')
   
union

--� Cria em 03/07/2023 por Hilson Santos - Para bloqueios dos pedidos do ECOMMERCE �--
SELECT a.nropedvenda, a.nroempresa, 'CRITICA ECOMMERCE' codcritica
FROM mad_pedvenda a, mad_pedvendaitem b
WHERE a.nropedvenda = b.nropedvenda
AND a.nroempresa = b.nroempresa
AND a.indentregaretira = 'E'
AND a.nroformapagto IN (1,2,4,5,7,8)
AND b.nrocondicaopagto IN (1,501,502)
AND a.codgeraloper != 205
AND a.usuinclusao = 'ECOMMERCE'

union

select a.nropedvenda, a.nroempresa, 'Entrega a Vista' codcritica
from mad_pedvenda a, mad_pedvendaitem b
where a.nropedvenda = b.nropedvenda
and a.nroempresa = b.nroempresa
and a.indentregaretira = 'E'
and a.nroformapagto in(1,2,5,6,7,8)
and b.nrocondicaopagto IN (01,501,502,503)
and a.codgeraloper != 205 -- alterado dia 15/07/2013 , para que as bonifica��es n�o fossem para analise
and a.nrorepresentante in (100,200)
and a.usuinclusao != 'ECOMMERCE' --� Foi desabilitado no dia 28/06/2023 por Hilson Santos
								 --� Foi habilitado no dia 03/07/2023 por Hilson Santos

union

select a.nropedvenda,a.nroempresa,'Condicao Dinheiro-Forma Avista' codcritica
from mad_pedvenda a, mad_pedvendaitem b
where a.nropedvenda = b.nropedvenda
and a.nroempresa = b.nroempresa
and a.indentregaretira = 'E'
and a.nroformapagto in (1,2,5,6,7)
--and b.nrocondicaopagto in (0, 1, 501, 574, 999) -- comentado por Gustavo Silva no dia 29/09/2015
and a.codgeraloper != 205
and a.nrorepresentante not in (100,200)
and a.usuinclusao not in('ECOMMERCE') --� Foi desabilitado no dia 28/06/2023 por Hilson Santos
									  --� Foi habilitado no dia 03/07/2023 por Hilson Santos

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

select x.nropedvenda, x.nroempresa, 'Bloqueio para an�lise'
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