select
    a.seqfamilia,
		nvl(b.seqmarca,0) seqmarca,
		ROUND(d.seqsecao) seqsecao,
		e.seqcategoria,
		f.seqsubcategoria,
		c.seqfornecedor,
		a.seqproduto,
		regexp_replace(a.desccompleta, '''', '') desccompleta,
		regexp_replace(a.descreduzida, '''', '') descreduzida,
		nvl(regexp_replace(a.complemento, '''', ''),'NAO INFORMADO') complemento,
		a.indprocfabricacao,
		to_char(a.dtahorinclusao,'dd/mm/yyyy') dtahorinclusao,
		nvl(to_char(a.dtahoralteracao,'dd/mm/yyyy'),to_char(a.dtahorinclusao,'dd/mm/yyyy')) dtahoralteracao 
from implantacao.map_produto a
inner join implantacao.map_familia b 
on b.seqfamilia = a.seqfamilia
inner join implantacao.map_famfornec c 
on c.seqfamilia = b.seqfamilia and c.principal = 'S'
left join (select a.seqproduto, trunc(c.seqcategoria) AS seqsecao
           from  implantacao.map_produto a
           inner join implantacao.map_famdivisao b on b.seqfamilia = a.seqfamilia
           inner join implantacao.map_categoria c on c.nrodivisao = b.nrodivisao AND c.nivelhierarquia = 1 AND c.statuscategor = 'A'
           inner join implantacao.map_famdivcateg d on d.seqfamilia = a.seqfamilia AND  d.seqcategoria = c.seqcategoria AND d.status = 'A') d 
on d.seqproduto = a.seqproduto
left join (select a.seqproduto, c.seqcategoria AS seqcategoria
           from  implantacao.map_produto a
           inner join implantacao.map_famdivisao b on b.seqfamilia = a.seqfamilia 
           inner join implantacao.map_categoria c on c.nrodivisao = b.nrodivisao AND c.nivelhierarquia = 2 AND c.statuscategor = 'A'
           inner join implantacao.map_famdivcateg d on d.seqfamilia = a.seqfamilia AND  d.seqcategoria = c.seqcategoria AND d.status = 'A') e 
on e.seqproduto = a.seqproduto
left join (select a.seqproduto,c.seqcategoria AS seqsubcategoria
           from  implantacao.map_produto a
           inner join implantacao.map_famdivisao b on b.seqfamilia = a.seqfamilia 
           inner join implantacao.map_categoria c on c.nrodivisao = b.nrodivisao AND c.nivelhierarquia = 3 AND c.statuscategor = 'A'
           inner join implantacao.map_famdivcateg d on d.seqfamilia = a.seqfamilia AND  d.seqcategoria = c.seqcategoria AND d.status = 'A') f 
on f.seqproduto = a.seqproduto 
order by a.seqproduto asc 



