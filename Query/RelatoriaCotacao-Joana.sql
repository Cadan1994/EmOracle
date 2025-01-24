SELECT 
		DISTINCT
		a.seqlista, 	
		i.listacotconcor,
		c.nomerazao AS fornecedor,
		l.comprador,
		n.marca,
		a.seqfamilia AS cod_familia, 
    g.familia AS descricao,
    m.fantasia AS concorrente,
    a.vlrprecopraticado AS preco_concorrente, 
    implantacao.fmaxprecofamilia(e.seqfamilia,NULL,f.nrosegmento,a.nroempresa) * f.padraoembvenda AS preco_prat, 	
		ROUND((a.vlrprecopraticado / (implantacao.fmaxprecofamilia(e.seqfamilia,NULL,f.nrosegmento,a.nroempresa) * f.padraoembvenda))-1,2) AS diferenca,
    a.qtdembpreco AS emb_preco,
    TO_CHAR(a.dtapesquisa,'DD/MM/YYYY')as DataPesquisa, 
    TO_CHAR(a.dtavalidade,'DD/MM/YYYY') as DtaValidade           
FROM implantacao.mrl_cotacao a,  
     implantacao.map_famdivcateg b, 
     implantacao.ge_pessoa c,
     implantacao.map_famfornec d,
     implantacao.map_produto e,
     implantacao.mad_famsegmento f,
     implantacao.map_familia g,
     implantacao.map_categoria h,
		 implantacao.mrl_cotlista i,
		 implantacao.map_famdivisao j,
		 implantacao.max_comprador l,
		 implantacao.ge_pessoa m,
		 implantacao.map_marca n
WHERE a.seqfamilia  		  =  d.seqfamilia
AND		a.seqconcorrente		=	 m.seqpessoa
AND   a.seqfamilia        =  f.seqfamilia
AND   d.seqfamilia        =  f.seqfamilia	 
AND   d.seqfornecedor			=	 c.seqpessoa
AND   e.seqfamilia        =  f.seqfamilia
AND   d.seqfamilia        =  e.seqfamilia
AND   e.seqfamilia        =  a.seqfamilia
AND 	b.seqfamilia 				=  g.seqfamilia
AND 	b.seqcategoria 			=  h.seqcategoria 											 																					 
AND   a.seqlista					=  i.seqlista
AND 	j.seqfamilia				=  a.seqfamilia
AND		l.seqcomprador			=  j.seqcomprador
AND   n.seqmarca					=	 g.seqmarca
AND 	h.nivelhierarquia 	=  1
AND  	f.nrosegmento 			=  1					 
AND   (a.vlrprecopraticado > 0
AND		(implantacao.fmaxprecofamilia(e.seqfamilia,NULL,f.nrosegmento,a.nroempresa) * f.padraoembvenda > 0)) 
AND 	a.nroempresa = 1
AND 	trunc(a.dtavalidade) >=  SYSDATE
AND 	a.seqfamilia = g.seqfamilia
GROUP BY a.seqlista,
				 a.seqfamilia,
				 e.seqfamilia,		
				 a.nroempresa,
				 e.desccompleta, 
				 d.seqfornecedor,
				 m.fantasia,
				 g.familia,
				 a.vlrprecopraticado,
				 f.padraoembvenda,
				 f.nrosegmento,
         a.qtdembpreco,
         a.dtapesquisa, 
         a.dtavalidade,
				 i.listacotconcor,
				 c.nomerazao,
				 l.comprador	,
				 n.marca