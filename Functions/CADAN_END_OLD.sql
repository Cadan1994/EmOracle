create or replace FUNCTION          cadan_end(codpedi polibras_observacao.codigo_pedido%TYPE)

 return NUMBER is
  vsCodAcesso IMPLANTACAO.MAD_CLIENTEEND.SEQPESSOAEND%TYPE;

begin

  SELECT max(C.SEQPESSOAEND)
    INTO vsCodAcesso
    FROM POLIBRAS_PEDCAB2 A
  
   INNER JOIN POLIBRAS_OBSERVACAO B
      ON (A.CODIGO_PEDIDO = B.CODIGO_PEDIDO AND b.indice = 7)
  
   INNER JOIN IMPLANTACAO.MAD_CLIENTEEND C
      ON (A.CODIGO_CLIENTE = C.SEQPESSOA AND
         decode(e_numero(to_char(LPAD(b.VALOR, 1))),
                 0,
                 0,
                 TO_NUMBER(LPAD(B.VALOR, 1))) = C.SEQPESSOAEND)
   WHERE A.CODIGO_PEDIDO = codpedi;

  return vsCodAcesso;

end cadan_end;
