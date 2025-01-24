SELECT a.nroempresa,a.seqproduto,b.dtavalidade,b.qtdatual,a.statusendereco
FROM implantacao.mlo_endereco a
INNER JOIN implantacao.mlo_enderecoqtde b ON b.seqendereco = a.seqendereco
