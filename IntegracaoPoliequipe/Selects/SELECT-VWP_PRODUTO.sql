SELECT
    DISTINCT t.U_PKEY,
	  t.U_ORGVENDA,
	  t.S_CODPRODUTO,
	  t.D_ESTOQUE,
	  nvl(t.D_MULTIPLO_VENDA, 1)
		AS D_MULTIPLO_VENDA,
	  t.D_UNIDADE,
	  t.D_UNIDADE_MACRO,
	  t.S_DESCRICAO,
	  t.S_DESCRICAO_UNIDADE,
	  t.S_DESCRICAO_UNIDADE_MACRO,
	  t.D_PESO,
	  t.S_EAN,
	  t.S_IMAGEM,
	  t.S_DESCRITIVO,
	  t.S_XILINCADO,
	  t.U_STATUS,
	  t.D_PERCBONIFICVENDA,
	  t.D_GIRODIARIO,
		'{'||
		NVL(
    		SUBSTR(
    		    b.jsondata,
    				INSTR(b.jsondata, '{') + 1,
    				INSTR(b.jsondata, '}') - INSTR(b.jsondata, '{') - 1
    		),
    		'"produto_base": "N"'
		) 
		||','||
		NVL(
    		SUBSTR(
    		    a.jsondata,
    				INSTR(a.jsondata, '{') + 1,
    				INSTR(a.jsondata, '}') - INSTR(a.jsondata, '{') - 1
    		),
    		'"produto_disc": "N"'
		)
		||']' as jsondata
FROM (SELECT
          DISTINCT
	    		0 U_PKEY,
	    		E.NROEMPRESA U_ORGVENDA,
	    		A.SEQPRODUTO || '.' || F.qtdEMBALAGEM S_CODPRODUTO,
	    		CASE
	       	WHEN ((E.ESTQLOJA + E.ESTQDEPOSITO) - ABS (E.QTDRESERVADAVDA) - E.QTDRESERVADAFIXA) / F.QTDEMBALAGEM > 0
	       	THEN ((E.ESTQLOJA + E.ESTQDEPOSITO) - ABS (E.QTDRESERVADAVDA) - E.QTDRESERVADAFIXA) / F.QTDEMBALAGEM
	       	ELSE 0
	    		END D_ESTOQUE,
	    		NVL(implantacao.cadan_fpegaMultiplo(b.seqfamilia), 1)
					AS D_MULTIPLO_VENDA,
	    		TRUNC(F.QTDEMBALAGEM) D_UNIDADE,
	    		0 D_UNIDADE_MACRO,
	    		A.DESCCOMPLETA S_DESCRICAO,
	    		F.EMBALAGEM || '-' || F.QTDEMBALAGEM S_DESCRICAO_UNIDADE,
	    		'' S_DESCRICAO_UNIDADE_MACRO,
	    		F.PESOBRUTO D_PESO,
	    		--decode(L.TIPCODIGO, 'D', 'DUN'||'-'||L.CODACESSO,'E',  'EAN'||'-'||L.CODACESSO,'B' , 'B'||'-'||L.CODACESSO ) S_EAN,
          /*L.CODACESSO S_EAN,*/		 -- Comentado por Hilson Santos em 27/08/2024 
					L.SEQPRODUTO S_EAN,				 -- Incluido por Hilson Santos em 27/08/2024 
          A.SEQPRODUTO S_IMAGEM,
 	    		'' S_DESCRITIVO,
	    		'' S_XILINCADO,
	    		CASE
	       	WHEN (est.CODIGONIVEL = 0) then 256
	       	WHEN (est.CODIGONIVEL = 1) then 768
	       	ELSE 0
	    		END U_STATUS,
	    		0 AS D_PERCBONIFICVENDA,
	    		0 AS D_GIRODIARIO
      FROM implantacao.MAP_PRODUTO A,
	         implantacao.MAP_FAMILIA B,
	    		 implantacao.MRL_PRODUTOEMPRESA E,
	    		 implantacao.MAP_FAMEMBALAGEM F,
	    		 implantacao.MAP_FAMDIVISAO X,
	    		 implantacao.MAD_LISTAITEM W,
	    		 implantacao.MAD_FAMSEGMENTO Z,
	    		 implantacao.MRL_PRODEMPSEG ZZ,
	    		 implantacao.MAP_PRODCODIGO L,
	    		 implantacao.vafvac_nivelestoque est
    	WHERE	A.SEQPRODUTO = E.SEQPRODUTO
	    AND A.SEQPRODUTO = ZZ.SEQPRODUTO
	    AND L.SEQPRODUTO = ZZ.SEQPRODUTO
	    AND A.SEQFAMILIA = F.SEQFAMILIA
	    AND A.SEQFAMILIA = W.SEQFAMILIA
	    AND A.SEQFAMILIA = B.SEQFAMILIA
	    AND B.SEQFAMILIA = L.SEQFAMILIA
	    AND A.SEQFAMILIA = X.SEQFAMILIA
	    AND A.SEQFAMILIA = Z.SEQFAMILIA
	    AND E.NROEMPRESA = ZZ.NROEMPRESA
	    and A.SEQPRODUTO = est.CODIGOPRODUTO
	    and E.NROEMPRESA = est.CODIGOUNIDFAT
	    AND E.NROEMPRESA IN (1,2)
			AND F.QTDEMBALAGEM = Z.PADRAOEMBVENDA
	    AND F.QTDEMBALAGEM = ZZ.QTDEMBALAGEM
      AND F.QTDEMBALAGEM = L.QTDEMBALAGEM
	    AND L.QTDEMBALAGEM = ZZ.QTDEMBALAGEM
      AND L.QTDEMBALAGEM = Z.PADRAOEMBVENDA
			AND a.DESCCOMPLETA NOT LIKE 'ZZ %'
			AND a.DESCCOMPLETA NOT LIKE '=%'
			AND X.NRODIVISAO IN (1)
	    AND Z.NROSEGMENTO = ZZ.NROSEGMENTO
	    AND E.INDBLOQAFV = 'N'
	    AND Z.STATUS = 'A'
	    AND f.status = 'A'
      AND zz.statusvenda = 'A'
      AND l.indutilvenda = 'S'
	    AND ZZ.PRECOBASENORMAL > 0
	    AND L.TIPCODIGO in ('D','E')
     	AND Z.VLRNULTIPLOVDA is not null
			AND A.SEQPRODUTO IN (42612,42002,42003,3588,24059,3593,34254,467,31578,345,1162)

			UNION all

   		SELECT
			    DISTINCT
	    		0 U_PKEY,
	    		E.NROEMPRESA U_ORGVENDA,
	    		A.SEQPRODUTO || '.' || F.qtdEMBALAGEM S_CODPRODUTO,
	    		CASE
	       	WHEN ((E.ESTQLOJA + E.ESTQDEPOSITO) - ABS (E.QTDRESERVADAVDA) - E.QTDRESERVADAFIXA) / F.QTDEMBALAGEM > 0
	       	THEN ((E.ESTQLOJA + E.ESTQDEPOSITO) - ABS (E.QTDRESERVADAVDA) - E.QTDRESERVADAFIXA) / F.QTDEMBALAGEM
	       	ELSE 0
	    		END D_ESTOQUE,
	    		NVL(implantacao.cadan_fpegaMultiplo(b.seqfamilia), 1) as
	       	D_MULTIPLO_VENDA,
	    		TRUNC (F.QTDEMBALAGEM) D_UNIDADE,
	    		0 D_UNIDADE_MACRO,
	    		A.DESCCOMPLETA S_DESCRICAO,
	    		F.EMBALAGEM || '-' || F.QTDEMBALAGEM S_DESCRICAO_UNIDADE,
	    		'' S_DESCRICAO_UNIDADE_MACRO,
	    		F.PESOBRUTO D_PESO,
					--decode(L.TIPCODIGO, 'D', 'DUN'||'-'||L.CODACESSO,'E',  'EAN'||'-'||L.CODACESSO,'B' , 'B'||'-'||L.CODACESSO ) S_EAN,
          /*L.CODACESSO S_EAN,*/		 -- Comentado por Hilson Santos em 27/08/2024 
					L.SEQPRODUTO S_EAN,				 -- Incluido por Hilson Santos em 27/08/2024 
 					A.SEQPRODUTO S_IMAGEM,
	    		'' S_DESCRITIVO,
	    		'' S_XILINCADO,
	    		CASE
	       	WHEN (est.CODIGONIVEL = 0) then 256
	       	when (est.CODIGONIVEL = 1) then 768
	       	else 0
	    		END U_STATUS,
	    		0 AS D_PERCBONIFICVENDA,
	    		0 AS D_GIRODIARIO
     	FROM implantacao.MAP_PRODUTO A,
	    		 implantacao.MAP_FAMILIA B,
	    		 implantacao.MRL_PRODUTOEMPRESA E,
	    		 implantacao.MAP_FAMEMBALAGEM F,
	    		 implantacao.MAP_FAMDIVISAO X,
	    		 implantacao.MAD_LISTAITEM W,
	    		 implantacao.MAD_FAMSEGMENTO Z,
	    		 implantacao.MRL_PRODEMPSEG ZZ,
	    		 implantacao.MAP_PRODCODIGO L,
	    		 implantacao.vafvac_nivelestoque est
    	WHERE	A.SEQPRODUTO = E.SEQPRODUTO
	    AND A.SEQPRODUTO = ZZ.SEQPRODUTO
	    AND L.SEQPRODUTO = ZZ.SEQPRODUTO
	    and A.SEQPRODUTO = est.CODIGOPRODUTO
	    and E.NROEMPRESA = est.CODIGOUNIDFAT
	    AND A.SEQFAMILIA = F.SEQFAMILIA
	    AND A.SEQFAMILIA = W.SEQFAMILIA
	    AND A.SEQFAMILIA = B.SEQFAMILIA
	    AND B.SEQFAMILIA = L.SEQFAMILIA
	    AND A.SEQFAMILIA = X.SEQFAMILIA
	    AND A.SEQFAMILIA = Z.SEQFAMILIA
	    AND E.NROEMPRESA = ZZ.NROEMPRESA
	    AND E.NROEMPRESA IN (1,2)
	    AND F.QTDEMBALAGEM = Z.PADRAOEMBVENDA
	    AND F.QTDEMBALAGEM = ZZ.QTDEMBALAGEM
      AND F.QTDEMBALAGEM = L.QTDEMBALAGEM
	    AND L.QTDEMBALAGEM = ZZ.QTDEMBALAGEM
      AND L.QTDEMBALAGEM = Z.PADRAOEMBVENDA
      AND a.DESCCOMPLETA NOT LIKE 'ZZ %'
			AND a.DESCCOMPLETA NOT LIKE '=%'
	    AND Z.NROSEGMENTO = ZZ.NROSEGMENTO
    	AND L.TIPCODIGO in ('D','E','B')
	    AND Z.STATUS = 'A'
	    AND f.status = 'A'
      AND l.indutilvenda = 'S'
      AND zz.statusvenda = 'A'
	    AND ZZ.PRECOBASENORMAL > 0
			AND A.SEQPRODUTO IN (42612,42002,42003,3588,24059,3593,34254,467,31578,345,1162)
			) t
LEFT JOIN (SELECT 
	 	 					TRIM(TO_CHAR(a.seqproduto||'.'||TRUNC(b.qtdembalagem))) seqproduto,
							'{"produto_disc": "S"}'	jsondata
					 FROM implantacao.map_produto a 
					 INNER JOIN implantacao.map_prodcodigo b ON b.seqproduto = a.seqproduto AND b.indutilvenda = 'S'
					 INNER JOIN implantacao.mrl_prodempseg c ON c.seqproduto = b.seqproduto AND c.qtdembalagem = b.qtdembalagem AND c.statusvenda = 'A'
					 INNER JOIN implantacao.mad_famsegmento d ON d.nrosegmento = c.nrosegmento AND d.seqfamilia = b.seqfamilia AND d.nrosegmento = 6 AND d.status = 'A'
					 WHERE 1=1	
					 AND a.desccompleta NOT LIKE ('ZZ%')	
					 AND a.desccompleta NOT LIKE ('=%')) a 
ON a.seqproduto = t.S_CODPRODUTO
LEFT JOIN implantacao.cadan_produtobase b 
ON TRIM(b.seqproduto) = t.S_CODPRODUTO
