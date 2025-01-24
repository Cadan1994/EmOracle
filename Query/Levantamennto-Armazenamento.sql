SELECT a.seqendereco,a.tiparmazenagem 
FROM implantacao.mlo_armazenperm a
WHERE 1=1
AND a.tiparmazenagem = 'P'
ORDER BY 1 ASC
 
SELECT a.seqpaleterf,a.coddepositante,a.nrocargareceb,a.seqproduto,a.qtdembalagem,a.nroempresa,a.lastro,a.altura,a.sobra,a.tipespecie,a.grauprioridade 
FROM implantacao.mlo_palete a
WHERE 1=1
AND a.nroempresa = 1
AND a.seqproduto = 23442

SELECT a.seqpaleterf,a.seqpaleteqtde,a.qtdpalete,a.dtavalidade,a.dtarecebimento,a.dtafabricacao,a.qtdembalagem 
FROM implantacao.mlo_paleteqtde a
WHERE 1=1
AND a.seqpaleterf IN (SELECT seqpaleterf 
										  FROM implantacao.mlo_palete a
											WHERE 1=1
											AND a.nroempresa = 1
											AND a.seqproduto = 23442)
ORDER BY a.dtarecebimento DESC		 
				

SELECT *
FROM implantacao.mrl_produtoempresa a
WHERE 1=1
AND a.nroempresa = 1
AND a.seqproduto = 23442
ORDER BY 1 ASC



select 
	 	A.SEQPRODUTO,
		A.ESPECIEENDERECO,
		A.STATUSENDERECO,
		D.DESCESPECIE,
		F.RUA,
		A.NROPREDIO,
		A.NROAPARTAMENTO,
		A.NROSALA,
		A.SEQPALETERF,		
		G.EMBALAGEM || '-' || A.QTDEMBALAGEM EMBALAGEM,
	 	B.DESCCOMPLETA,
   	E.PALETELASTRO || ' x ' || E.PALETEALTURA NORMA_PALETE,
	 	SUM(A.QTDATUAL/A.QTDEMBALAGEM) QTDATUAL								 
from implantacao.MLO_ENDERECO A 
join implantacao.MLO_PRODUTO B on B.NROEMPRESA = 1 And B.SEQPRODUTO = A.SEQPRODUTO 
join implantacao.MLO_PRODEMBALAGEM C on C.NROEMPRESA = 1 And C.SEQPRODUTO = B.SEQPRODUTO	And C.QTDEMBALAGEM = B.PADRAOEMBCOMPRA
join implantacao.MLO_ESPECIEENDERECO D on D.NROEMPRESA = 1 And D.ESPECIEENDERECO = A.ESPECIEENDERECO And D.STATUSESPECIEENDERECO = 'A'
join implantacao.MLO_PRODESPENDERECO E on E.NROEMPRESA = 1	And E.SEQPRODUTO = A.SEQPRODUTO And E.ESPECIEENDERECO = A.ESPECIEENDERECO
join implantacao.MLO_RUA F on F.NROEMPRESA = 1 And F.CODRUA = A.CODRUA
join implantacao.MAP_FAMEMBALAGEM G on G.SEQFAMILIA = B.SEQFAMILIA And G.QTDEMBALAGEM = A.QTDEMBALAGEM
Where 1=1
And A.NROEMPRESA = 1
And A.SEQPRODUTO = 23442
And A.CODDEPOSITANTE = 1
And A.QTDATUAL != 0	
group by 
			A.SEQPRODUTO,	
			A.ESPECIEENDERECO,
			A.QTDEMBALAGEM,
			A.SEQPALETERF,
			A.STATUSENDERECO,
			A.NROPREDIO,
			A.NROAPARTAMENTO,
			A.NROSALA,
			B.DESCCOMPLETA,
			D.DESCESPECIE,
			E.PALETELASTRO,
			E.PALETEALTURA,
			F.RUA,
			G.EMBALAGEM
order by B.DESCCOMPLETA