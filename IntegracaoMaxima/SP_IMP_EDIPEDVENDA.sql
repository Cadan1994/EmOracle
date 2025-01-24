begin
  -- Call the procedure
  implantacao.sp_imp_edipedvenda(pnseqedipedvenda => :pnseqedipedvenda,
                                 pnnrorepresentante => :pnnrorepresentante);
end;
