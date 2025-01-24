CREATE OR REPLACE Package Body IMPLANTACAO.Pkg_Edi_Neogrid_edit2 Is
  /*
  LAYOUT NEOGRID
  */
  Procedure Sp_Gera_Edi_Neogrid_exe(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                                    Pddtainicial In Date,
                                    Pddtafinal   In Date,
                                    Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type) Is
    Vsdiretorioarquivo Mrl_Empsoftpdv.Diretexportarquivo%Type;
    Vsarquivoant       Varchar2(100);
    Vhwndfile          Sys.Utl_File.File_Type;
    Vstipoexportacao   Mrl_Empsoftpdv.Tipoexportacao%Type;
    --vsPD_VERSAOLAYOUTNEOGRID max_parametro.valor%type;
    Vsversaolayout         Max_Edi.Versao_Layout%Type;
    Vsnroindustria         Varchar2(3);
    Vsnomeprojeto          Varchar2(300);
    Vspdgeranfserieoe      Max_Parametro.Valor%Type := 'N';
    Vspdexpprodativovenda  Max_Parametro.Valor%Type := 'S';
    Vsdatahorageracao      Varchar2(14) := To_Char(Sysdate,
                                                   'YYYYMMDDHH24MISS');
    Vsconsideranotastransf Max_Parametro.Valor%Type := 'N';
    VspdAgrupEmpVirtBase   Max_Parametro.Valor%Type;
    VspdGeraVenCons        Max_Parametro.Valor%Type;
    -- vsTempos
    /*time_before BINARY_INTEGER;
    time_after BINARY_INTEGER;*/
  Begin
    execute immediate 'alter session set "_optim_peek_user_binds" = true';
    /*sp_checaparamdinamico( 'EXPORTACAO_NEOGRID', 0, 'VERSAO_LAYOUT_EDI_NEOGRID', 'S', '3',
                               'VERSÃO DO LAYOUT DO ARQUIVO DE EDI - NEOGRID
    LAYOUTS DISPONIVEIS: 3 E 4
    VALOR PADRÃO: 3');
        select fc5maxparametro('EXPORTACAO_NEOGRID', 0, 'VERSAO_LAYOUT_EDI_NEOGRID')
        into   vsPD_VERSAOLAYOUTNEOGRID
        from   dual;*/
    --Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    --Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                               0,
                               'EXP_PROD_ATIVO_VENDA'),
               'S')
      Into Vspdexpprodativovenda
      From Dual;
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          Pnnroempresa,
                          'CONSIDERA_NOTAS_TRANSFERENCIA',
                          'S',
                          'N',
                          'INFORMA SE NOTAS FISCAIS DE TRANSFERENCIA ENTRE FILIAIS SERÃO CONSIDERADAS
                          NA COMPOSIÇÃO DO REGISTRO. (S/N) DEFAULT: N.
                          OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE',
                          Vsconsideranotastransf);
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'AGRUP_EMP_VIRTUAL_BASE',
                          'S',
                          'N',
                          'INFORMA SE SERÁ AGRUPADO OS DADOS DA EMPRESA VIRTUAL COM A EMPRESA BASE,
                              NA COMPOSIÇÃO DO REGISTRO. (S/N) DEFAULT: N.
                              OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE',
                          VspdAgrupEmpVirtBase);
    SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                          0,
                          'GERA_VENDAS_CONSOLIDADAS',
                          'S',
                          'N',
                          'INFORMA SE SERA GERADO ARQUIVO DE VENDAS CONSOLIDADAS' ||
                          chr(13) || chr(10) || 'S-SIM' || chr(13) ||
                          chr(10) || 'N-NÃO(PADRÃO)',
                          VspdGeraVenCons);
    Select a.Versao_Layout
      Into Vsversaolayout
      From Max_Edi a
     Where a.Nomeedi = Pssoftpdv
       And a.Layout = 'NEOGRID'
       And a.Status = 'A';
    If Upper(Pssoftpdv) = 'UNILEVER' Then
      Vsnroindustria := '009';
    Elsif Upper(Pssoftpdv) = 'GOMES_COSTA' Then
      Vsnroindustria := '200';
    Elsif Upper(Pssoftpdv) = 'MEADJOHNSON' Or Upper(Pssoftpdv) = 'JOHNSON' Then
      Vsnroindustria := '510';
    Elsif Upper(Pssoftpdv) = 'MASTERFOOD' Or Upper(Pssoftpdv) = 'MARS' Then
      Vsnroindustria := '520';
    Elsif Upper(Pssoftpdv) = 'LOREAL' Then
      Vsnroindustria := '550';
    Elsif Upper(Pssoftpdv) In ('COLGATE', 'LINEA', 'HEINZ') Then
      Vsnroindustria := '670';
    End If;
    --------------------------
    Delete From Maxx_Selecrowid;
    -- buscar todas as empresas mesmo CNPJ -
    if VspdAgrupEmpVirtBase = 'S' then
      Insert Into Maxx_Selecrowid
        (Sequencia, Seqselecao) --SeqSelecao = 99 para Empresas
        SELECT a.nroempresa, 99
          From max_empresa a
         Where a.nrocgc || a.digcgc =
               (Select a.nrocgc || a.digcgc
                  From max_empresa a
                 Where a.nroempresa = Pnnroempresa);
    else
      Insert Into Maxx_Selecrowid
        (Sequencia, Seqselecao) --SeqSelecao = 99 para uma unica empresa
        SELECT Pnnroempresa, 99 From dual;
    end if;
    -- CALCULAR TEMPO DOS INSERTS NA TABELA TEMPORARIA --
    /*time_before := DBMS_UTILITY.GET_TIME; */
    --Busca os fornecedores
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 1 para fornecedor
      Select Distinct a.Seqfornecedor, 1
        From Maf_Fornecedi a
       Where a.Status = 'A'
         And a.Nomeedi = Pssoftpdv
         And a.Layout = 'NEOGRID'
            --         And a.Nroempresa = Pnnroempresa;
         And a.Nroempresa In (Select x.Sequencia
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 99);
    --Busca os produtos
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 2 para Produto
      Select Distinct a.Seqproduto, 2
        From Map_Produto      a,
             Map_Famfornec    b,
             Map_Famembalagem c,
             Map_Famdivcateg  d,
             Max_Empresa      e,
             Map_Categoria    f,
             Ge_Pessoa        g,
             Map_Familia      h,
             --  Mrl_Prodempseg   i,
             Map_Famdivisao j
       Where a.Seqfamilia = b.Seqfamilia
         And a.Seqfamilia = c.Seqfamilia
         And a.Seqfamilia = d.Seqfamilia
         And a.Seqfamilia = h.Seqfamilia
         And e.Nroempresa In (Select x.Sequencia
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 99)
         And e.Nrodivisao = d.Nrodivisao
         And d.Seqcategoria = f.Seqcategoria
         And e.Nrodivisao = f.Nrodivisao
         And b.Seqfornecedor = g.Seqpessoa
         And f.Actfamilia = 'S'
         And f.Tipcategoria = 'M'
         And f.Statuscategor = 'A'
         And d.Status = 'A'
         And b.Principal = 'S'
         And b.Seqfornecedor In
             (Select x.Sequencia
                From Maxx_Selecrowid x
               Where x.Seqselecao = 1)
         And c.Qtdembalagem =
             Fpadraoembvendaseg(a.Seqfamilia, e.nrosegmentoprinc)
            --  And a.Seqproduto   = i.Seqproduto
            --  And c.Qtdembalagem = i.Qtdembalagem
            --and   E.NROSEGMENTOPRINC = I.NROSEGMENTO
            --  And e.Nroempresa = i.Nroempresa
         And j.Seqfamilia = a.Seqfamilia
         And j.Nrodivisao = e.Nrodivisao
         And j.Finalidadefamilia != 'B'
         And ((Vspdexpprodativovenda = 'S' And
             fstatusvendaproduto(a.seqproduto,
                                   e.nroempresa,
                                   null /*e.nrosegmentoprinc*/) = 'A') Or
             Vspdexpprodativovenda = 'N');
    /*--Busca Vendedores  -- Subistiuido para melhor performace
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 3 para Vendedores
      Select Distinct a.Nrorepresentante, 3
        From Mflv_Basedfitem a, Max_Empserienf b, Mad_Representante c
       Where a.Nroempresa = b.Nroempresa(+)
         And a.Seriedf = b.Serienf(+)
         And a.Nrorepresentante = c.Nrorepresentante
         And a.Seqproduto In (Select x.Sequencia
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 2)
         And a.Nroempresa In (Select Column_Value From Table(Cast(C5_Complexin.C5intable(
                             FlistaNroEmpresas_670(Pnnroempresa, VspdAgrupEmpVirtBase)) As C5instrtable)))
         And a.Dtaentrada Between Pddtainicial And Pddtafinal
            \*and    ( (vsConsideraNotasTransf = 'S' and (A.TIPNOTAFISCAL || A.TIPDOCFISCAL in ('ED' , 'SC', 'ST'))) or
                               A.TIPNOTAFISCAL || A.TIPDOCFISCAL in ('ED' , 'SC')  )
                and    (a.acmcompravenda in ( 'S', 'I' ) or a.apporigem in (2,18))*\
         And a.Nrorepresentante > 0
         And c.Tiprepresentante != 'A'
         And ((Vspdgeranfserieoe = 'N' And Nvl(b.Tipodocto, 'x') != 'O') Or
             (Vspdgeranfserieoe = 'S'));*/
    ---############################ Representantes ############################################################---
    ---Busca os representantes
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 3 para representante
      SELECT DISTINCT a.Nrorepresentante, 3
        FROM mflv_basedfitem_EDI A,
             (Select x.Sequencia nroempresa
                From Maxx_Selecrowid x
               Where x.Seqselecao = 99) emp,
             Mad_Representante c
       Where a.Dtaentrada Between Pddtainicial And Pddtafinal
         And emp.nroempresa = a.nroempresa
         And a.Nrorepresentante = c.Nrorepresentante
         And a.Nrorepresentante > 0
         And c.Tiprepresentante != 'A'
         And exists (Select x.Sequencia
                From Maxx_Selecrowid x
               Where x.Seqselecao = 2
                 and x.sequencia = a.seqproduto)
      /*And ((Vspdgeranfserieoe = 'N' And Nvl(a.Tipodocto, 'x') != 'O') Or
      (Vspdgeranfserieoe = 'S'))*/
      ;
    ---############################ Representantes fim ############################################################---
    /*   --Busca Clientes  -- substituido para melhor performace ---
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 4 para Clientes
      Select Distinct a.Seqpessoa, 4
        From Mflv_Basedfitem a, Max_Empserienf b
       Where a.Nroempresa = b.Nroempresa(+)
         And a.Seriedf = b.Serienf(+)
         And a.Seqproduto In (Select x.Sequencia
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 2)
         And a.Nroempresa = Pnnroempresa
         And a.Dtaentrada Between Pddtainicial And Pddtafinal
            \*and    ( (vsConsideraNotasTransf = 'S' and (A.TIPNOTAFISCAL || A.TIPDOCFISCAL in ('ED' , 'SC', 'ST'))) or
                               A.TIPNOTAFISCAL || A.TIPDOCFISCAL in ('ED' , 'SC')  )*\
         And a.Seqpessoa > 0
         And ((Vspdgeranfserieoe = 'N' And Nvl(b.Tipodocto, 'x') != 'O') Or
             (Vspdgeranfserieoe = 'S'));*/
    ---############################ Clientes #######################################
    --Busca Clientes
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 4 para Clientes
      SELECT DISTINCT a.seqpessoa, 4
        FROM mflv_basedfitem_EDI A,
             (Select x.Sequencia nroempresa
                From Maxx_Selecrowid x
               Where x.Seqselecao = 99) emp,
             Mad_Representante c
       Where a.Dtaentrada Between Pddtainicial And Pddtafinal
         And emp.nroempresa = a.nroempresa
         And a.Nrorepresentante = c.Nrorepresentante
         And a.Seqpessoa > 0
         And exists (Select x.Sequencia
                From Maxx_Selecrowid x
               Where x.Seqselecao = 2
                 and x.sequencia = a.seqproduto)
      /*And ((Vspdgeranfserieoe = 'N' And Nvl(a.Tipodocto, 'x') != 'O') Or
      (Vspdgeranfserieoe = 'S'))*/
      ;
    ---############################ Clientes fim #######################################
    -- mostrar tempo
    /*  time_after := DBMS_UTILITY.GET_TIME;
    DBMS_OUTPUT.PUT_LINE ('Tempo insert na tabela temp...');
    DBMS_OUTPUT.PUT_LINE (time_after - time_before);
    DBMS_OUTPUT.PUT_LINE ('###################');*/
    /* -- Gera os Registros -- */
    If Vsnroindustria = '009' Then
      -- Gera cabeçalho do arquivo
      Sp_Gera_Cabecalho_009(Pnnroempresa,
                            Pssoftpdv,
                            Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Vendedor
      Sp_Gera_Vendedor_009(Pnnroempresa,
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Cliente
      Sp_Gera_Cliente_009(Pnnroempresa,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Vendas
      Sp_Gera_Vendas_009(Pnnroempresa,
                         Pddtainicial,
                         Pddtafinal,
                         Pssoftpdv,
                         Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Estoque
      Sp_Gera_Estoque_009(Pnnroempresa,
                          Pddtafinal,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Notas Fiscais
      Sp_Gera_Notasfiscais_009(Pnnroempresa,
                               Pddtainicial,
                               Pddtafinal,
                               Pssoftpdv,
                               Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Vendas Consolidadas
      If VspdGeraVenCons = 'S' Then
        Sp_Gera_Vendas_Cons_009(Pnnroempresa => Pnnroempresa,
                                Pddtainicial => Pddtainicial,
                                Pddtafinal   => Pddtafinal,
                                Pssoftpdv    => Pssoftpdv);
      End If;
    Elsif Vsnroindustria = '200' Then
      -- Gera cabeçalho do arquivo
      Sp_Gera_Cabecalho_200(Pnnroempresa,
                            Pssoftpdv,
                            Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Vendedor
      Sp_Gera_Vendedor_200(Pnnroempresa,
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Cliente
      Sp_Gera_Cliente_200(Pnnroempresa,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Vendas
      Sp_Gera_Vendas_200(Pnnroempresa,
                         Pddtainicial,
                         Pddtafinal,
                         Pssoftpdv,
                         Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Estoque
      Sp_Gera_Estoque_200(Pnnroempresa,
                          Pddtafinal,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Notas Fiscais
      Sp_Gera_Notasfiscais_200(Pnnroempresa,
                               Pddtainicial,
                               Pddtafinal,
                               Pssoftpdv,
                               Nvl(Vsversaolayout, '3'));
    Elsif Vsnroindustria = '510' Then
      -- Gera cabeçalho do arquivo
      Sp_Gera_Cabecalho_510(Pnnroempresa,
                            Pssoftpdv,
                            Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Vendedor
      Sp_Gera_Vendedor_510(Pnnroempresa,
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Cliente
      Sp_Gera_Cliente_510(Pnnroempresa,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Vendas
      Sp_Gera_Vendas_510(Pnnroempresa,
                         Pddtainicial,
                         Pddtafinal,
                         Pssoftpdv,
                         Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Estoque
      Sp_Gera_Estoque_510(Pnnroempresa,
                          Pddtafinal,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Notas Fiscais
      Sp_Gera_Notasfiscais_510(Pnnroempresa,
                               Pddtainicial,
                               Pddtafinal,
                               Pssoftpdv,
                               Nvl(Vsversaolayout, '3'));
    Elsif Vsnroindustria = '520' Then
      -- Gera cabeçalho do arquivo
      Sp_Gera_Cabecalho_520(Pnnroempresa,
                            Pssoftpdv,
                            Nvl(Vsversaolayout, '4'));
      --Gera Arquivo Vendedor
      Sp_Gera_Vendedor_520(Pnnroempresa,
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '4'));
      --Gera Arquivo Cliente
      Sp_Gera_Cliente_520(Pnnroempresa,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '4'));
      --Gera Arquivo de Vendas
      Sp_Gera_Vendas_520(Pnnroempresa,
                         Pddtainicial,
                         Pddtafinal,
                         Pssoftpdv,
                         Nvl(Vsversaolayout, '4'));
      --Gera Arquivo de Estoque
      Sp_Gera_Estoque_520(Pnnroempresa,
                          Pddtafinal,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '4'));
    Elsif Vsnroindustria = '550' Then
      -- Gera cabeçalho do arquivo
      Sp_Gera_Cabecalho_550(Pnnroempresa,
                            Pssoftpdv,
                            Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Vendedor
      Sp_Gera_Vendedor_550(Pnnroempresa,
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '3'));
      --Gera Arquivo Cliente
      Sp_Gera_Cliente_550(Pnnroempresa,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Vendas
      Sp_Gera_Vendas_550(Pnnroempresa,
                         Pddtainicial,
                         Pddtafinal,
                         Pssoftpdv,
                         Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Estoque
      Sp_Gera_Estoque_550(Pnnroempresa,
                          Pddtafinal,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '3'));
      --Gera Arquivo de Notas Fiscais
      Sp_Gera_Notasfiscais_550(Pnnroempresa,
                               Pddtainicial,
                               Pddtafinal,
                               Pssoftpdv,
                               Nvl(Vsversaolayout, '3'));
    Elsif Vsnroindustria = '670' Then
      -- Gera cabeçalho do arquivo
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME;*/
      Sp_Gera_Cabecalho_670(Pnnroempresa,
                            Pssoftpdv,
                            Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /*time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('tempo - Cabecaço ...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################');*/
      --Gera Arquivo Vendedor
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME;*/
      Sp_Gera_Vendedor_670(Pnnroempresa,
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /* time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('Tempo vendedor...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################');*/
      --Gera Arquivo Cliente
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME; */
      Sp_Gera_Cliente_670(Pnnroempresa,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /* time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('Tempo cliente...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################'); */
      --Gera Arquivo de Vendas
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME; */
      Sp_Gera_Vendas_670(Pnnroempresa,
                         Pddtainicial,
                         Pddtafinal,
                         Pssoftpdv,
                         Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /* time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('Tempo vendas...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################'); */
      --Gera Arquivo de Estoque
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME; */
      Sp_Gera_Estoque_670(Pnnroempresa,
                          Pddtainicial,
                          Pddtafinal,
                          Pssoftpdv,
                          Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /* time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('Tempo estoque...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################'); */
      --Gera Arquivo de Notas Fiscais
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME;*/
      Sp_Gera_Notasfiscais_670(Pnnroempresa,
                               Pddtainicial,
                               Pddtafinal,
                               Pssoftpdv,
                               Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /* time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('Tempo NFs ...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################'); */
      --Gera Arquivo de Produtos
      -- iniciar tempo para calcular performece --
      /*time_before := DBMS_UTILITY.GET_TIME; */
      Sp_Gera_Produtos_670(Pnnroempresa,
                           /*Pddtainicial,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Pddtafinal,*/
                           Pssoftpdv,
                           Nvl(Vsversaolayout, '4'));
      -- mostrar tempo
      /* time_after := DBMS_UTILITY.GET_TIME;
      DBMS_OUTPUT.PUT_LINE ('Tempo produtos...');
      DBMS_OUTPUT.PUT_LINE (time_after - time_before);
      DBMS_OUTPUT.PUT_LINE ('###################'); */
    Elsif Upper(Pssoftpdv) = 'MELITTA' Then
      -- Gera Arquivo de Vendedor
      Sp_Gera_Vendedor_Melitta(Pnnroempresa   => Pnnroempresa,
                               Pssoftpdv      => Pssoftpdv,
                               Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Cliente
      Sp_Gera_Cliente_Melitta(Pnnroempresa   => Pnnroempresa,
                              Pssoftpdv      => Pssoftpdv,
                              Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Venda
      Sp_Gera_Vendas_Melitta(Pnnroempresa   => Pnnroempresa,
                             Pddtainicial   => Pddtainicial,
                             Pddtafinal     => Pddtafinal,
                             Pssoftpdv      => Pssoftpdv,
                             Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Estoque
      Sp_Gera_Estoque_Melitta(Pnnroempresa   => Pnnroempresa,
                              Pddtainicial   => Pddtainicial,
                              Pddtafinal     => Pddtafinal,
                              Pssoftpdv      => Pssoftpdv,
                              Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Produtos
      Sp_Gera_Prod_Melitta(Pnnroempresa   => Pnnroempresa,
                           Pssoftpdv      => Pssoftpdv,
                           Psversaolayout => Nvl(Vsversaolayout, '5'));
    Elsif Upper(Pssoftpdv) = 'SANTA_HELENA' Then
      -- Gera Arquivo de Vendedor
      Sp_Gera_Vendedor_Santahelena(Pnnroempresa   => Pnnroempresa,
                                   Pssoftpdv      => Pssoftpdv,
                                   Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Cliente
      Sp_Gera_Cliente_Santahelena(Pnnroempresa   => Pnnroempresa,
                                  Pssoftpdv      => Pssoftpdv,
                                  Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Venda
      Sp_Gera_Vendas_Santahelena(Pnnroempresa   => Pnnroempresa,
                                 Pddtainicial   => Pddtainicial,
                                 Pddtafinal     => Pddtafinal,
                                 Pssoftpdv      => Pssoftpdv,
                                 Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Estoque
      Sp_Gera_Estoque_Santahelena(Pnnroempresa   => Pnnroempresa,
                                  Pddtainicial   => Pddtainicial,
                                  Pddtafinal     => Pddtafinal,
                                  Pssoftpdv      => Pssoftpdv,
                                  Psversaolayout => Nvl(Vsversaolayout, '5'));
      -- Gera Arquivo de Produtos
      Sp_Gera_Prod_Santahelena(Pnnroempresa   => Pnnroempresa,
                               Pssoftpdv      => Pssoftpdv,
                               Psversaolayout => Nvl(Vsversaolayout, '5'));
    Elsif Upper(Pssoftpdv) In ('NEOGRIDV5') Then
      -- Gera Arquivo de Vendedor
      Sp_Gera_Vendedor_V5(Pnnroempresa => Pnnroempresa,
                          Pssoftpdv    => Pssoftpdv /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          psVersaoLayout => nvl(vsVersaoLayout,'5')*/);
      -- Gera Arquivo de Cliente
      Sp_Gera_Cliente_V5(Pnnroempresa => Pnnroempresa,
                         Pssoftpdv    => Pssoftpdv /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  psVersaoLayout => nvl(vsVersaoLayout,'5')*/);
      -- Gera Arquivo de Venda
      Sp_Gera_Vendas_V5(Pnnroempresa => Pnnroempresa,
                        Pddtainicial => Pddtainicial,
                        Pddtafinal   => Pddtafinal,
                        Pssoftpdv    => Pssoftpdv /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          psVersaoLayout => nvl(vsVersaoLayout,'5')*/);
      -- Gera Arquivo de Estoque
      Sp_Gera_Estoque_V5(Pnnroempresa => Pnnroempresa,
                         Pddtainicial => Pddtainicial,
                         Pddtafinal   => Pddtafinal,
                         Pssoftpdv    => Pssoftpdv /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  psVersaoLayout => nvl(vsVersaoLayout,'5')*/);
      -- Gera Arquivo de Produtos
      Sp_Gera_Prod_V5(Pnnroempresa => Pnnroempresa,
                      Pssoftpdv    => Pssoftpdv /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          psVersaoLayout => nvl(vsVersaoLayout,'5')*/);
    End If;
    --Gera os Arquivos--
    --Busca Diretorio do Arquivo
    Begin
      Select a.Diretexportarquivo, Nvl(a.Tipoexportacao, 'S')
        Into Vsdiretorioarquivo, Vstipoexportacao
        From Mrl_Empsoftpdv a
       Where a.Nroempresa = Pnnroempresa
         And a.Softpdv = Pssoftpdv
         And a.Tiposoft = 'E'
         And a.Tipocarga = 'N'
         And a.Status = 'A';
    Exception
      When No_Data_Found Then
        Raise_Application_Error(-20200,
                                'SP_GERA_EDI_NEOGRID - NÃO FOI DEFINIDO SOFTWARE DE INTEGRACAO - ' ||
                                Sqlerrm);
    End;
    --Tipo Exportacao Servidor
    If Vstipoexportacao = 'S' Then
      Vsarquivoant := ' ';
      --Nome do Projeto
      If Pssoftpdv In ('MELITTA', 'SANTA_HELENA', 'NEOGRIDV5') Then
        Vsnomeprojeto := Null;
      Elsif Pssoftpdv = 'MASTERFOOD' Then
        Vsnomeprojeto := 'DIMARS_';
      Else
        Vsnomeprojeto := 'DI' || Pssoftpdv || '_';
      End If;
      For Vtfile In (Select Linha, Arquivo
                       From Mrlx_Pdvimportacao
                      Where Nroempresa = Pnnroempresa
                        And Softpdv = Pssoftpdv
                      Order By Arquivo,
                               Nvl(Seqnotafiscal, 0),
                               Ordem,
                               Seqlinha) Loop
        If Vsarquivoant != Vtfile.Arquivo Then
          If Vsarquivoant != ' ' Then
            Sys.Utl_File.Fclose(Vhwndfile);
          End If;
          If substr(Vtfile.Arquivo, 1, 9) = 'VALIDADOR' Then
            Vsnomeprojeto := Null;
          End If;
          Vhwndfile    := Sys.Utl_File.Fopen(Vsdiretorioarquivo,
                                             Vsnomeprojeto || Vtfile.Arquivo || '_' ||
                                             Vsdatahorageracao || '.txt',
                                             'w');
          Vsarquivoant := Vtfile.Arquivo;
        End If;
        Sys.Utl_File.Put(Vhwndfile, Vtfile.Linha || Chr(13) || Chr(10));
        -- salva linha no arquivo
        Utl_File.Fflush(Vhwndfile);
      End Loop;
      If Vsarquivoant != ' ' Then
        Sys.Utl_File.Fclose(Vhwndfile);
      End If;
    End If;
    --commit;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_EDI_NEOGRID - ' || Sqlerrm);
  End Sp_Gera_Edi_Neogrid_exe;
  /* Unilever - Início */
  Procedure Sp_Gera_Cabecalho_009(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                  Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                  Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Vslinha       := '';
      --Tipo de Registro
      Vslinha := Vslinha || '01';
      --CNPJ Distribuidor (Filial)
      Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
      --Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi');
      --Versão Layout
      Vslinha := Vslinha || '03';
      --Código Indústria
      Vslinha := Vslinha || '009';
      --Filler
      Vslinha := Vslinha || Rpad(' ', 267, ' ');
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vscpnjempresa,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_CABECALHO_009 - ' || Sqlerrm);
  End Sp_Gera_Cabecalho_009;
  Procedure Sp_Gera_Vendedor_009(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Vendedor
      For Vtvendedor In (Select b.Nomerazao As Nomerazaorepres,
                                --    a.Nrorepresentante As Nrorepresentante,
                                FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                       'UNILEVER',
                                                       'NEOGRID') as NroRepresentante,
                                d.Nomerazao As Nomerazaosup,
                                c.Seqpessoa As Seqpessoasup
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            And a.Nrorepresentante In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 3)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02';
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nrorepresentante, 11, ' ');
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Nome Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 115, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_009 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_009;
  Procedure Sp_Gera_Cliente_009(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha              Varchar2(300);
    Vscpnjempresa        Varchar2(14);
    Vncontador           Integer := 0;
    Vscodsegmentocli     Varchar2(3);
    Vscontato            Ge_Pessoa.Nomerazao%Type;
    Vsgeraatividadeporte Max_Parametro.Parametro%Type;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_ATIVIDADE_OU_PORTE'),
                 'A')
        Into Vsgeraatividadeporte
        From Dual;
      --Movimento de Vendas
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               /*DECODE(A.FISICAJURIDICA,'J',LPAD(A.NROCGCCPF || LPAD(A.DIGCGCCPF, 2, 0), 14, '0'),
                               LPAD(A.NROCGCCPF || LPAD(A.DIGCGCCPF, 2, 0), 11, '0')) as CpfCnpjCliente,*/
                               Case
                                 When a.Fisicajuridica = 'J' Then
                                  Lpad(a.Nrocgccpf || Lpad(a.Digcgccpf, 2, 0),
                                       14,
                                       '0')
                                 When Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0') = '11111111111' Then
                                  Vscpnjempresa
                                 When Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0') = '67067067088' Then
                                  Vscpnjempresa
                                 Else
                                  Lpad(a.Nrocgccpf || Lpad(a.Digcgccpf, 2, 0),
                                       11,
                                       '0')
                               End As Cpfcnpjcliente, -- (alterado para Cadan)
                               Nvl(Regexp_Replace(a.Cep, '[^0-9]'), 0) As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(Decode(Vsgeraatividadeporte,
                                            'P',
                                            a.Porte,
                                            a.Atividade)) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente,
                               Nvl(a.Foneddd1 || a.Fonenro1, 0) As Telefonecliente,
                               a.Fisicajuridica,
                               a.Bairro As Bairrocliente
                          From Ge_Pessoa a
                         Where a.Seqpessoa In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 4)) Loop
        Select Nvl(Substr(Max(a.Codatividadeedi), 1, 3), ' ') Codatividadeedi
          Into Vscodsegmentocli
          From Mad_Ediatividade a
         Where a.Nomeedi = Pssoftpdv
           And a.Layout = 'NEOGRID'
           And Upper(a.Codatividade) =
               Upper(Substr(Vtcliente.Atividadecliente, 1, 30));
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 14, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 8, '0');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 50, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Enderecocliente, 75, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 50, ' ');
        -- Código Segmento Cliente
        Vslinha := Vslinha || Rpad(Vscodsegmentocli, 3, ' ');
        -- Telefone
        Vslinha := Vslinha || Lpad(Vtcliente.Telefonecliente, 15, '0');
        -- Contato
        If Vtcliente.Fisicajuridica = 'J' Then
          Begin
            Select b.Nomerazao
              Into Vscontato
              From Ge_Pessoacontato a, Ge_Pessoa b
             Where a.Seqprincipal = Vtcliente.Seqpessoa
               And a.Tipcontato = 'COMPRADOR'
               And a.Seqpessoa = b.Seqpessoa;
          Exception
            When No_Data_Found Then
              Vscontato := ' ';
          End;
        Else
          Vscontato := ' ';
        End If;
        Vslinha := Vslinha || Rpad(Vscontato, 20, ' ');
        -- Bairro
        Vslinha := Vslinha || Rpad(Vtcliente.Bairrocliente, 20, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 41, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_009 - ' || Sqlerrm);
  End Sp_Gera_Cliente_009;
  Procedure Sp_Gera_Vendas_009(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                               Pddtainicial   In Date,
                               Pddtafinal     In Date,
                               Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                               Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                 Varchar2(300);
    Vscpnjempresa           Varchar2(14);
    Vncontador              Integer := 0;
    Vspdgeranfserieoe       Max_Parametro.Valor%Type := 'N';
    Vspdgerasinalnegdevcanc Max_Parametro.Valor%Type := 'N';
    Vscgobonifexp           Max_Parametro.Valor%Type := '0';
  Begin
    -- Parâmetro Dinâmico - CGOs consistidos como Bonificação na Geração do EDI
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIF_EXP',
                          'N',
                          '0',
                          'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                          Vscgobonifexp);
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N'),
             Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_SINAL_NEGATIVO_DEVOL_CANC'),
                 'N')
        Into Vspdgeranfserieoe, Vspdgerasinalnegdevcanc
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtnota In (Select a.Numerodf,
                            a.Seriedf,
                            --- enviará o código EAN
                            Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                Nvl(Fcodacessoprodedi(a.Seqproduto, 'D', 'N'),
                                    fCodAcessoProdEDIdepara(a.seqproduto,
                                                            Pssoftpdv,
                                                            'NEOGRID'))) As Codigoprod,
                            /* '01' as TipoCodigoProd,
                            'U'  as CodUnidMedida,*/
                            Case
                              When fCodAcessoProdEDIdepara(a.seqproduto,
                                                           Pssoftpdv,
                                                           'NEOGRID') !=
                                   a.seqproduto Then
                               'U'
                              When Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                             'D',
                                                             'N'),
                                           fCodAcessoProdEDIdepara(a.seqproduto,
                                                                   Pssoftpdv,
                                                                   'NEOGRID'))) =
                                   Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       a.Seqproduto) Then
                               'U'
                              Else
                               'C'
                            End As Codunidmedida,
                            Case
                              When fCodAcessoProdEDIdepara(a.seqproduto,
                                                           Pssoftpdv,
                                                           'NEOGRID') !=
                                   a.seqproduto Then
                               '01'
                              When Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                             'D',
                                                             'N'),
                                           fCodAcessoProdEDIdepara(a.seqproduto,
                                                                   Pssoftpdv,
                                                                   'NEOGRID'))) =
                                   Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       a.Seqproduto) Then
                               '01'
                              Else
                               '02'
                            End As Tipocodprod,
                            Round(Sum(a.Quantidade /
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Null,
                                             a.Qtdembalagem,
                                             1)),
                                  3) * 1000 As Quantidade,
                            Decode(a.Indtipodescbonif,
                                   'T',
                                   'S',
                                   fIndRegistroBonif670(a.Codgeraloper,
                                                        c.Cgonfbonificacao,
                                                        Vscgobonifexp)) As Bonificacao,
                            Round(Sum(a.Vlrcontabil /
                                      (a.Quantidade /
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                                'E',
                                                                'N'),
                                              Null,
                                              a.Qtdembalagem,
                                              1))),
                                  2) * 100 As Vlrunitario,
                            Round(Sum(a.Vlrcontabil), 2) * 100 As Vlrbruto,
                            (Case
                              When Nvl(a.Statusdf, 'V') = 'C' Or
                                   Nvl(a.Statusitem, 'V') = 'C' Then
                               '3'
                              Else
                               Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                      'ED',
                                      '2',
                                      '1')
                            End) As Tiponotafiscal,
                            a.Dtaentrada Dtaemissao,
                            b.Desccompleta,
                            max(g.Indecommerce) Indecommerce
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e,
                            Mad_Pedvenda     g
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        And a.Seqproduto In
                            (Select x.Sequencia
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.nropedidovenda = g.nropedvenda(+)
                        And a.nroempresa = g.nroempresa(+)
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        And a.Tipnotafiscal || a.Tipdocfiscal In
                            ('ED', 'SC')
                        And ((Vspdgeranfserieoe = 'N' And
                            Nvl(d.Tipodocto, 'x') != 'O') Or
                            (Vspdgeranfserieoe = 'S'))
                      Group By a.Numerodf,
                               a.Seriedf,
                               a.Seqproduto,
                               e.Embalagem,
                               a.Tipnotafiscal || a.Tipdocfiscal,
                               Decode(a.Indtipodescbonif,
                                      'T',
                                      'S',
                                      fIndRegistroBonif670(a.Codgeraloper,
                                                           c.Cgonfbonificacao,
                                                           Vscgobonifexp)),
                               (Case
                                 When Nvl(a.Statusdf, 'V') = 'C' Or
                                      Nvl(a.Statusitem, 'V') = 'C' Then
                                  '3'
                                 Else
                                  Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                         'ED',
                                         '2',
                                         '1')
                               End),
                               a.Dtaentrada,
                               b.Desccompleta
                      Order By a.Numerodf, a.Seriedf) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '04';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtnota.Codigoprod, 20, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtnota.Tipocodprod, 2, ' ');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtnota.Codunidmedida, 1, ' ');
        -- Quantidade vendida
        Vslinha := Vslinha || Lpad(Vtnota.Quantidade, 15, '0');
        -- Bonificação
        Vslinha := Vslinha || Rpad(Vtnota.Bonificacao, 1, ' ');
        -- Valor Unitário
        If Vspdgerasinalnegdevcanc = 'S' Then
          Vslinha := Vslinha || Case
                       When (Vtnota.Tiponotafiscal = '2' Or
                            Vtnota.Tiponotafiscal = '3') Then
                        '-' || Lpad(Vtnota.Vlrunitario, 14, '0')
                       Else
                        Lpad(Vtnota.Vlrunitario, 15, '0')
                     End;
        Else
          Vslinha := Vslinha || Lpad(Vtnota.Vlrunitario, 15, '0');
        End If;
        -- Valor total bruto
        Vslinha := Vslinha || Lpad(Vtnota.Vlrbruto, 15, '0');
        -- Canal de Venda
        If Vtnota.Indecommerce = 'S' Then
          Vslinha := Vslinha || Rpad('04', 2, '0');
        Else
          Vslinha := Vslinha || Rpad('01', 2, '0');
        End if;
        -- Filler
        Vslinha := Vslinha || Rpad(' ', 40, ' ');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Data de Emissão
        Vslinha := Vslinha || To_Char(Vtnota.Dtaemissao, 'YYYYMMDD');
        -- Descrição do Produto
        Vslinha := Vslinha || Rpad(Vtnota.Desccompleta, 50, ' '); --Verificar o tamanho
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 104, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           4,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_009 - ' || Sqlerrm);
  End Sp_Gera_Vendas_009;
  Procedure Sp_Gera_Estoque_009(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pddtabase      In Date,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(500);
    Vscpnjempresa Varchar2(25);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtestoque In (Select --- enviará o código EAN
                         Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                             Nvl(Fcodacessoprodedi(a.Seqproduto, 'D', 'N'),
                                 fCodAcessoProdEDIdepara(a.seqproduto,
                                                         Pssoftpdv,
                                                         'NEOGRID'))) As Codproduto,
                         To_Char(Pddtabase, 'yyyymmdd') As Dtaestoque,
                         sum(Round(Nvl(i.Qtdestqinicial, 0) +
                                   Nvl(i.Qtdentrada, 0) - Nvl(i.Qtdsaida, 0),
                                   3)) * 1000 As Qtdeestoque,
                         /*'U' as CodUnidMedida,
                         '01' as TipoCodProd*/
                         Case
                           When Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                    Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                          'D',
                                                          'N'),
                                        fCodAcessoProdEDIdepara(a.seqproduto,
                                                                Pssoftpdv,
                                                                'NEOGRID'))) !=
                                to_char(a.seqproduto)
                           /*Fcodacessoprodedi(a.Seqproduto, 'E', 'N')*/
                            Then
                            'U'
                           Else
                            'C'
                         End As Codunidmedida,
                         Case
                           When Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                    Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                          'D',
                                                          'N'),
                                        fCodAcessoProdEDIdepara(a.seqproduto,
                                                                Pssoftpdv,
                                                                'NEOGRID'))) !=
                                to_char(a.seqproduto)
                           /*Fcodacessoprodedi(a.Seqproduto, 'E', 'N')*/
                            Then
                            '01'
                           Else
                            '02'
                         End As Tipocodprod
                          From Map_Produto a, Max_Empresa b, Mrl_Custodia i
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And i.Dtaentradasaida =
                               (Select Max(x.Dtaentradasaida)
                                  From Mrl_Custodia x
                                 Where x.Seqproduto = i.Seqproduto
                                   And x.Nroempresa = i.Nroempresa
                                   And x.Dtaentradasaida <= Pddtabase)
                           And a.Seqproduto In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 2)
                         group by Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                        'E',
                                                        'N'),
                                      Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                            'D',
                                                            'N'),
                                          fCodAcessoProdEDIdepara(a.seqproduto,
                                                                  Pssoftpdv,
                                                                  'NEOGRID'))),
                                  To_Char(Pddtabase, 'yyyymmdd'),
                                  Case
                                    When Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                                   'D',
                                                                   'N'),
                                                 fCodAcessoProdEDIdepara(a.seqproduto,
                                                                         Pssoftpdv,
                                                                         'NEOGRID'))) !=
                                         to_char(a.seqproduto)
                                    /*Fcodacessoprodedi(a.Seqproduto, 'E', 'N')*/
                                     Then
                                     'U'
                                    Else
                                     'C'
                                  End,
                                  Case
                                    When Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                                   'D',
                                                                   'N'),
                                                 fCodAcessoProdEDIdepara(a.seqproduto,
                                                                         Pssoftpdv,
                                                                         'NEOGRID'))) !=
                                         to_char(a.seqproduto)
                                    /*Fcodacessoprodedi(a.Seqproduto, 'E', 'N')*/
                                     Then
                                     '01'
                                    Else
                                     '02'
                                  End) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '05';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 20, ' ');
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 8, '0');
        -- Quantidade de Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 15, '0');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtestoque.Codunidmedida, 1, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtestoque.Tipocodprod, 2, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 252, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           5,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_009 - ' || Sqlerrm);
  End Sp_Gera_Estoque_009;
  Procedure Sp_Gera_Notasfiscais_009(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pddtainicial   In Date,
                                     Pddtafinal     In Date,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha           Varchar2(300);
    Vscpnjempresa     Varchar2(14);
    Vncontador        Integer := 0;
    Vspdgeranfserieoe Max_Parametro.Valor%Type := 'N';
  Begin
    --Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtnota In (Select Distinct a.Numerodf,
                                     a.Seriedf,
                                     To_Char(a.Dtaentrada, 'yyyymmdd') As Dtaemissao,
                                     (Case
                                       When Nvl(a.Statusdf, 'V') = 'C' Or
                                            Nvl(a.Statusitem, 'V') = 'C' Then
                                        '3'
                                       Else
                                        Decode(a.Tipnotafiscal ||
                                               a.Tipdocfiscal,
                                               'ED',
                                               '2',
                                               '1')
                                     End) As Tiponotafiscal,
                                     --     a.Nrorepresentante As Codvendedor,
                                     FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                            'UNILEVER',
                                                            'NEOGRID') as Codvendedor,
                                     /*DECODE(F.FISICAJURIDICA,'J',LPAD(F.NROCGCCPF || LPAD(F.DIGCGCCPF, 2, 0), 14, '0'),
                                     LPAD(F.NROCGCCPF || LPAD(F.DIGCGCCPF, 2, 0), 11, '0')) as CodCliente*/
                                     case
                                       when F.Fisicajuridica = 'J' then
                                        LPAD(F.NROCGCCPF ||
                                             LPAD(F.DIGCGCCPF, 2, 0),
                                             14,
                                             '0')
                                       when LPAD(F.NROCGCCPF ||
                                                 LPAD(F.DIGCGCCPF, 2, 0),
                                                 11,
                                                 '0') = '11111111111' then
                                        vsCPNJEmpresa
                                       when LPAD(F.NROCGCCPF ||
                                                 LPAD(F.DIGCGCCPF, 2, 0),
                                                 11,
                                                 '0') = '67067067088' then
                                        vsCPNJEmpresa
                                       else
                                        LPAD(F.NROCGCCPF ||
                                             LPAD(F.DIGCGCCPF, 2, 0),
                                             11,
                                             '0')
                                     end as CodCliente -- (alterado para Cadan)
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e,
                            Ge_Pessoa        f,
                            Map_Famfornec    g
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        And a.Seqproduto In
                            (Select x.Sequencia
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Seqpessoa = f.Seqpessoa
                        And b.Seqfamilia = g.Seqfamilia
                        And g.Principal = 'S'
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (Vspdgeranfserieoe = 'S'))
                      order by A.NUMERODF, A.SERIEDF) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '06';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Data Emissão da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Dtaemissao, 8, '0');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Código do Vendedor
        Vslinha := Vslinha || Lpad(Vtnota.Codvendedor, 11, '0');
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtnota.Codcliente, 14, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 240, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           6,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_NOTASFISCAIS_009 - ' || sqlerrm);
  End Sp_Gera_Notasfiscais_009;
  Procedure Sp_Gera_Vendas_Cons_009(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                                    Pddtainicial In Date,
                                    Pddtafinal   In Date,
                                    Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type) Is
    Vslinha           Varchar2(300);
    Vscnpjempresa     Varchar2(14);
    Vscnpjfornec      Varchar2(14);
    Vsnomearquivo     Varchar2(40);
    Vncontador        Integer := 0;
    Vspdgeranfserieoe Max_Parametro.Valor%Type := 'N';
    Vscgobonifexp     Max_Parametro.Valor%Type := '0';
  Begin
    -- Parâmetro Dinâmico - CGOs consistidos como Bonificação na Geração do EDI
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIF_EXP',
                          'N',
                          '0',
                          'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                          Vscgobonifexp);
    --Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    -- Busca CNPJ da Empresa
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    -- Busca CNPJ da Industria/Fornecedor
    Select Max(b.Nrocgccpf || Lpad(b.Digcgccpf, 2, '0'))
      Into Vscnpjfornec
      From MAF_FORNECEDI A, GE_PESSOA B
     Where a.Nroempresa = Pnnroempresa
       And a.Nomeedi = Pssoftpdv
       And a.Layout = 'NEOGRID'
       And a.Status = 'A'
       And a.Seqfornecedor = b.Seqpessoa;
    --- Vendas Consolidadas
    For Vtnota In (Select Lpad(b.Nrocgc || Lpad(b.Digcgc, 2, 0), 14, 0) CNPJDistribuidor,
                          a.Dtaentrada Dtaemissao,
                          Round(Sum(Decode(Decode(a.Indtipodescbonif,
                                                  'T',
                                                  'S',
                                                  fIndRegistroBonif670(a.Codgeraloper,
                                                                       e.Cgonfbonificacao,
                                                                       Vscgobonifexp)),
                                           'S',
                                           0,
                                           Decode(a.Tipnotafiscal ||
                                                  a.Tipdocfiscal,
                                                  'ED',
                                                  (a.Vlrcontabil * -1),
                                                  a.Vlrcontabil))),
                                2) As Vlrbruto,
                          Round(Sum(Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                           'ED',
                                           (a.Quantidade * -1),
                                           a.Quantidade) /
                                    Decode(Fcodacessoprodedi(a.Seqproduto,
                                                             'E',
                                                             'N'),
                                           Null,
                                           a.Qtdembalagem,
                                           1)),
                                3) As Quantidade
                     From Mflv_Basedfitem a,
                          Max_Empresa     b,
                          Ge_Pessoa       c,
                          Max_Empserienf  d,
                          Mad_Parametro   e
                    Where a.nroempresa = b.nroempresa
                      And a.Seqproduto In
                          (Select x.Sequencia
                             From Maxx_Selecrowid x
                            Where x.Seqselecao = 2)
                      And a.Nroempresa = e.Nroempresa
                      and a.Nroempresa = d.Nroempresa(+)
                      And a.Seriedf = d.Serienf(+)
                      And a.seqpessoa = c.seqpessoa
                      And a.Nroempresa = Pnnroempresa
                      And a.Dtaentrada Between Pddtainicial And Pddtafinal
                      And a.Tipnotafiscal || a.Tipdocfiscal In ('ED', 'SC')
                      And ((Vspdgeranfserieoe = 'N' And
                          Nvl(d.Tipodocto, 'x') != 'O') Or
                          (Vspdgeranfserieoe = 'S'))
                      and nvl(a.Statusdf, 'V') = 'V'
                      and Nvl(a.Statusitem, 'V') = 'V'
                   /*and nvl(a.Indtipodescbonif, 'x') != 'T'
                   and fIndRegistroBonif670(a.Codgeraloper, e.Cgonfbonificacao, Vscgobonifexp) != 'S'*/
                    Group By Lpad(b.Nrocgc || Lpad(b.Digcgc, 2, 0), 14, 0),
                             a.Dtaentrada) Loop
      Vslinha := '';
      -- CNPJ do Local de Venda (Distribuidor)
      vslinha := Vslinha || Vtnota.CNPJDistribuidor || ';';
      -- CNPJ do Destinatário do Relatório (Indústria)
      vslinha := Vslinha || Vscnpjfornec || ';';
      -- Data de Emissão
      Vslinha := Vslinha || To_Char(Vtnota.Dtaemissao, 'YYYYMMDD') || ';';
      -- Valor total bruto
      Vslinha := Vslinha ||
                 replace(fc5ConverteNumberToChar(Vtnota.Vlrbruto), '.', ',') || ';';
      -- Quantidade vendida
      Vslinha := Vslinha || Vtnota.Quantidade;
      -- Nome do Arquivo
      Vsnomearquivo := 'VALIDADOR_' || Vscnpjempresa;
      Vncontador    := Vncontador + 1;
      --insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         7,
         Vncontador);
    End Loop;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'Sp_Gera_Vendas_Cons_009 - ' || Sqlerrm);
  End Sp_Gera_Vendas_Cons_009;
  /* Unilever - Fim */
  /************************************************************************************/
  /* Gomes da Costa - Início */
  Procedure Sp_Gera_Cabecalho_200(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                  Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                  Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Vslinha       := '';
      --Tipo de Registro
      Vslinha := Vslinha || '01';
      --CNPJ Distribuidor (Filial)
      Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
      --Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi');
      --Versão Layout
      Vslinha := Vslinha || '03';
      --Fornecedor(Código da Indústria)
      Vslinha := Vslinha || '200';
      --Filler
      Vslinha := Vslinha || Rpad(' ', 267, ' ');
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vscpnjempresa,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_CABECALHO_200 - ' || sqlerrm);
  End Sp_Gera_Cabecalho_200;
  Procedure Sp_Gera_Vendedor_200(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Vendedor
      For vtVendedor in (select B.NOMERAZAO        as NomeRazaoRepres,
                                a.Nrorepresentante As Nrorepresentante,
                                d.Nomerazao        As Nomerazaosup,
                                c.Seqpessoa        As Seqpessoasup
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            and A.NROREPRESENTANTE in
                                (select X.SEQUENCIA
                                   From Maxx_Selecrowid x
                                  where X.SEQSELECAO = 3)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02';
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nrorepresentante, 11, ' ');
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Nome Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 115, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_510 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_200;
  Procedure Sp_Gera_Cliente_200(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha          Varchar2(300);
    Vscpnjempresa    Varchar2(14);
    Vncontador       Integer := 0;
    Vscodsegmentocli Varchar2(3);
    /*Vscontato              Ge_Pessoa.Nomerazao%Type;*/
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca Paramentro Dinamico
      select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'TIPO_CODSEGMENTO_CLI'),
                 'A')
        Into Vspdtipocodsegmentocli
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Movimento de Vendas
      For vtCliente in (select A.SEQPESSOA as SeqPessoa,
                               DECODE(A.FISICAJURIDICA,
                                      'J',
                                      LPAD(A.NROCGCCPF ||
                                           LPAD(A.DIGCGCCPF, 2, 0),
                                           14,
                                           '0'),
                                      LPAD(A.NROCGCCPF ||
                                           LPAD(A.DIGCGCCPF, 2, 0),
                                           11,
                                           '0')) as CpfCnpjCliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               A.LOGRADOURO || ' ' || A.NROLOGRADOURO || ' ' ||
                               A.CMPLTOLOGRADOURO as EnderecoCliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente,
                               Nvl(a.Foneddd1 || a.Fonenro1, 0) As Telefonecliente,
                               a.Fisicajuridica,
                               a.Bairro As Bairrocliente
                          From Ge_Pessoa a
                         where A.SEQPESSOA in
                               (select X.SEQUENCIA
                                  From Maxx_Selecrowid x
                                 where X.SEQSELECAO = 4)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 14, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 8, '0');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 50, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(' ', 75, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 50, ' ');
        -- Código Segmento Cliente
        If Vspdtipocodsegmentocli = 'G' Then
          If Vtcliente.Grupocliente = 'SUPERM MAIS DE 9 CHECK-OUTS' Then
            Vscodsegmentocli := '001';
          Elsif Vtcliente.Grupocliente = 'SUPERM DE 5 A 9 CHECK-OUTS' Then
            Vscodsegmentocli := '002';
          Elsif Vtcliente.Grupocliente = 'SUPERM DE 1 A 4 CHECK-OUTS' Then
            Vscodsegmentocli := '003';
          Elsif Vtcliente.Grupocliente = 'ATACADO' Then
            Vscodsegmentocli := '004';
          Elsif Vtcliente.Grupocliente = 'MERCEARIA' Then
            Vscodsegmentocli := '005';
          Elsif Vtcliente.Grupocliente = 'LOJA DE CONVENIÊNCIA' Then
            Vscodsegmentocli := '006';
          Elsif Vtcliente.Grupocliente = 'PADARIA' Then
            Vscodsegmentocli := '007';
          Elsif Vtcliente.Grupocliente = 'RESTAURANTE/PIZZARIA' Then
            Vscodsegmentocli := '008';
          Elsif Vtcliente.Grupocliente = 'OUTROS' Then
            Vscodsegmentocli := '009';
          Else
            Vscodsegmentocli := '009';
          End If;
        Else
          If Vtcliente.Atividadecliente = 'SUPERM MAIS DE 9 CHECK-OUTS' Then
            Vscodsegmentocli := '001';
          Elsif Vtcliente.Atividadecliente = 'SUPERM DE 5 A 9 CHECK-OUTS' Then
            Vscodsegmentocli := '002';
          Elsif Vtcliente.Atividadecliente = 'SUPERM DE 1 A 4 CHECK-OUTS' Then
            Vscodsegmentocli := '003';
          Elsif Vtcliente.Atividadecliente = 'ATACADO' Then
            Vscodsegmentocli := '004';
          Elsif Vtcliente.Atividadecliente = 'MERCEARIA' Then
            Vscodsegmentocli := '005';
          Elsif Vtcliente.Atividadecliente = 'LOJA DE CONVENIÊNCIA' Then
            Vscodsegmentocli := '006';
          Elsif Vtcliente.Atividadecliente = 'PADARIA' Then
            Vscodsegmentocli := '007';
          Elsif Vtcliente.Atividadecliente = 'RESTAURANTE/PIZZARIA' Then
            Vscodsegmentocli := '008';
          Elsif Vtcliente.Atividadecliente = 'OUTROS' Then
            Vscodsegmentocli := '009';
          Else
            Vscodsegmentocli := '009';
          End If;
        End If;
        Vslinha := Vslinha || Lpad(Vscodsegmentocli, 3, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 96, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_200 - ' || Sqlerrm);
  End Sp_Gera_Cliente_200;
  Procedure Sp_Gera_Vendas_200(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                               Pddtainicial   In Date,
                               Pddtafinal     In Date,
                               Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                               Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                 Varchar2(300);
    Vscpnjempresa           Varchar2(14);
    Vncontador              Integer := 0;
    Vspdgeranfserieoe       Max_Parametro.Valor%Type := 'N';
    Vspdgerasinalnegdevcanc Max_Parametro.Valor%Type := 'N';
  Begin
    if psVersaoLayout = '3' or psVersaoLayout = '03' then
      --Busca Paramentro Dinamico
      select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N'),
             nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_SINAL_NEGATIVO_DEVOL_CANC'),
                 'N')
        into vsPDGeraNfSerieOe, vsPDGeraSinalNegDevCanc
        from DUAL;
      --Busca CNPJ da Empresa
      vsCPNJEmpresa := fBuscaCNPJEmpresa(pnNroEmpresa);
      For vtNota in (select A.NUMERODF,
                            A.SERIEDF,
                            B.DESCCOMPLETA,
                            --- enviará o código DUN
                            nvl(FCODACESSOPRODEDI(A.SEQPRODUTO, 'D', 'N'),
                                ' ') as CodigoProd,
                            '02' as TipoCodigoProd,
                            'U' as CodUnidMedida,
                            -- Como envia o DUN, divide pela qtde da embalagem
                            round(SUM(A.QUANTIDADE / A.QTDEMBALAGEM), 3) * 1000 as Quantidade,
                            DECODE(A.CODGERALOPER,
                                   C.CGONFBONIFICACAO,
                                   'S',
                                   'N') as Bonificacao,
                            round(SUM(A.VLRCONTABIL / A.QTDEMBALAGEM), 2) * 100 as VlrUnitario,
                            round(SUM(A.VLRCONTABIL), 2) * 100 as VlrBruto,
                            round(SUM(A.VLRCONTABIL -
                                      (A.VLRICMS + A.VLRPIS + A.VLRCOFINS)),
                                  2) * 100 as VlrLiquido,
                            round(decode(nvl(SUM((A.VLRPRODBRUTO +
                                                 A.VLRACRESCIMO)),
                                             0),
                                         0,
                                         0,
                                         SUM(A.VLRDESCONTO * 100 /
                                             ((A.VLRPRODBRUTO +
                                             A.VLRACRESCIMO)))),
                                  2) * 100 as PercDesconto,
                            round(decode(nvl(SUM(A.VLRCONTABIL), 0),
                                         0,
                                         0,
                                         SUM(A.VLRICMS * 100 / A.VLRCONTABIL)),
                                  2) * 100 as PercIcms,
                            round(decode(nvl(SUM(A.VLRCONTABIL), 0),
                                         0,
                                         0,
                                         SUM(A.VLRIPI * 100 / A.VLRCONTABIL)),
                                  2) * 100 as PercIpi,
                            round(decode(nvl(SUM(A.VLRCONTABIL), 0),
                                         0,
                                         0,
                                         SUM((A.VLRPIS + A.VLRCOFINS) * 100 /
                                             A.VLRCONTABIL)),
                                  2) * 100 as PercPisCofins,
                            (case
                              when nvl(A.STATUSDF, 'V') = 'C' or
                                   nvl(A.STATUSITEM, 'V') = 'C' then
                               '3'
                              else
                               decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                      'ED',
                                      '2',
                                      '1')
                            end) as TipoNotaFiscal
                       from MFLV_BASEDFITEM  A,
                            MAP_PRODUTO      B,
                            MAD_PARAMETRO    C,
                            MAX_EMPSERIENF   D,
                            MAP_FAMEMBALAGEM E
                      where A.NROEMPRESA = D.NROEMPRESA(+)
                        and A.SERIEDF = D.SERIENF(+)
                        and A.SEQPRODUTO in
                            (select X.SEQUENCIA
                               from MAXX_SELECROWID X
                              where X.SEQSELECAO = 2)
                        and A.NROEMPRESA = C.NROEMPRESA
                        and A.SEQPRODUTO = B.SEQPRODUTO
                        and A.QTDEMBALAGEM = E.QTDEMBALAGEM
                        and B.SEQFAMILIA = E.SEQFAMILIA
                        and A.NROEMPRESA = pnNroEmpresa
                        and A.DTAENTRADA between pdDtaInicial and pdDtaFinal
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (vsPDGeraNfSerieOe = 'S'))
                      group by A.NUMERODF,
                               A.SERIEDF,
                               A.SEQPRODUTO,
                               B.DESCCOMPLETA,
                               E.EMBALAGEM,
                               A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                               DECODE(A.CODGERALOPER,
                                      C.CGONFBONIFICACAO,
                                      'S',
                                      'N'),
                               (case
                                 when nvl(A.STATUSDF, 'V') = 'C' or
                                      nvl(A.STATUSITEM, 'V') = 'C' then
                                  '3'
                                 else
                                  decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                         'ED',
                                         '2',
                                         '1')
                               end)
                      order by A.NUMERODF, A.SERIEDF) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '04';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtnota.Codigoprod, 20, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtnota.Tipocodigoprod, 2, ' ');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtnota.Codunidmedida, 1, ' ');
        -- Quantidade vendida
        Vslinha := Vslinha || Lpad(Vtnota.Quantidade, 15, '0');
        -- Bonificação
        Vslinha := Vslinha || Rpad(Vtnota.Bonificacao, 1, ' ');
        -- Valor Unitário
        If Vspdgerasinalnegdevcanc = 'S' Then
          vsLinha := vsLinha || case
                       when (vtNota.tiponotafiscal = '2' or
                            vtNota.TipoNotaFiscal = '3') then
                        '-' || lpad(vtNota.VlrUnitario, 14, '0')
                       else
                        lpad(vtNota.VlrUnitario, 15, '0')
                     end;
        Else
          Vslinha := Vslinha || Lpad(Vtnota.Vlrunitario, 15, '0');
        End If;
        -- Valor total bruto
        Vslinha := Vslinha || Lpad(Vtnota.Vlrbruto, 15, '0');
        -- Filler 1
        Vslinha := Vslinha || Rpad(' ', 42, ' ');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Filler 2
        Vslinha := Vslinha || Rpad(' ', 8, ' ');
        -- Descrição Produto
        Vslinha := Vslinha || Rpad(Vtnota.Desccompleta, 50, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 104, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           4,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_510 - ' || Sqlerrm);
  End Sp_Gera_Vendas_200;
  Procedure Sp_Gera_Estoque_200(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pddtabase      In Date,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(500);
    Vscpnjempresa Varchar2(25);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtestoque In (select nvl(FCODACESSOPRODEDI(A.SEQPRODUTO, 'D', 'N'),
                                   ' ') as CodProduto,
                               a.Desccompleta,
                               To_Char(Pddtabase, 'yyyymmdd') As Dtaestoque,
                               round(nvl(I.QTDESTQINICIAL, 0) +
                                     nvl(I.QTDENTRADA, 0) -
                                     nvl(I.QTDSAIDA, 0),
                                     3) * 1000 as QtdeEstoque,
                               'U' As Codunidmedida,
                               '02' As Tipocodprod,
                               round(DECODE(pdDtaBase,
                                            trunc(sysdate),
                                            nvl(H.QTDPEDRECTRANSITO, 0),
                                            0),
                                     3) * 1000 as QtdeEstoqueTrans,
                               Round(h.Estqminimoloja, 3) * 1000 As Qtdeestoquemin,
                               Round(h.Estqmaximoloja, 3) * 1000 As Qtdeestoquemax
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Mrl_Custodia       i
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           and C.QTDEMBALAGEM =
                               fpadraoembvendaseg(A.SEQFAMILIA,
                                                  B.NROSEGMENTOPRINC)
                           and I.DTAENTRADASAIDA =
                               (select max(X.DTAENTRADASAIDA)
                                  From Mrl_Custodia x
                                 Where x.Seqproduto = i.Seqproduto
                                   And x.Nroempresa = i.Nroempresa
                                   And x.Dtaentradasaida <= Pddtabase)
                           and A.SEQPRODUTO IN
                               (select X.SEQUENCIA
                                  From Maxx_Selecrowid x
                                 where X.SEQSELECAO = 2)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '05';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 20, ' ');
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 8, '0');
        -- Quantidade de Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 15, '0');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtestoque.Codunidmedida, 1, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtestoque.Tipocodprod, 2, ' ');
        -- Filler 1
        Vslinha := Vslinha || Rpad(' ', 45, ' ');
        -- Descrição do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Desccompleta, 50, ' ');
        -- Filler 2
        Vslinha    := Vslinha || Rpad(' ', 157, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           5,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_200 - ' || Sqlerrm);
  End Sp_Gera_Estoque_200;
  Procedure Sp_Gera_Notasfiscais_200(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pddtainicial   In Date,
                                     Pddtafinal     In Date,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
    /*Vnprazopagamento  Number;*/
    Vspdgeranfserieoe Max_Parametro.Valor%Type := 'N';
  Begin
    --Busca Paramentro Dinamico
    select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For vtNota in (select distinct A.NUMERODF,
                                     a.Seriedf,
                                     To_Char(a.Dtaentrada, 'yyyymmdd') As Dtaemissao,
                                     (Case
                                       When Nvl(a.Statusdf, 'V') = 'C' Or
                                            Nvl(a.Statusitem, 'V') = 'C' Then
                                        '3'
                                       else
                                        decode(A.TIPNOTAFISCAL ||
                                               A.TIPDOCFISCAL,
                                               'ED',
                                               '2',
                                               '1')
                                     End) As Tiponotafiscal,
                                     a.Nrorepresentante As Codvendedor,
                                     DECODE(F.FISICAJURIDICA,
                                            'J',
                                            LPAD(F.NROCGCCPF ||
                                                 LPAD(F.DIGCGCCPF, 2, 0),
                                                 14,
                                                 '0'),
                                            LPAD(F.NROCGCCPF ||
                                                 LPAD(F.DIGCGCCPF, 2, 0),
                                                 11,
                                                 '0')) as CodCliente,
                                     DECODE(F.FISICAJURIDICA,
                                            'F',
                                            '01',
                                            '02') as TipoFaturamento,
                                     Decode(a.Tipofrete, 'F', 'FOB', 'CIF') As Tipofrete,
                                     a.Linkerp,
                                     h.Uf As Origemmercadoria,
                                     Regexp_Replace(h.Cep, '[^0-9]') As Ceporigem,
                                     f.Uf As Destinomerc,
                                     Regexp_Replace(f.Cep, '[^0-9]') As Cepdestino
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e,
                            Ge_Pessoa        f,
                            Map_Famfornec    g,
                            Ge_Pessoa        h
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        and A.SEQPRODUTO in
                            (select X.SEQUENCIA
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Seqpessoa = f.Seqpessoa
                        And b.Seqfamilia = g.Seqfamilia
                        And g.Principal = 'S'
                        And g.Seqfornecedor = h.Seqpessoa
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (Vspdgeranfserieoe = 'S'))
                      order by A.NUMERODF, A.SERIEDF) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '06';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Data Emissão da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Dtaemissao, 8, '0');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Código do Vendedor
        Vslinha := Vslinha || Lpad(Vtnota.Codvendedor, 11, '0');
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtnota.Codcliente, 14, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 240, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           6,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_NOTASFISCAIS_200 - ' || sqlerrm);
  End Sp_Gera_Notasfiscais_200;
  /* Gomes da Costa - Fim */
  /************************************************************************************/
  /* Mead Johnson - Início */
  Procedure Sp_Gera_Cabecalho_510(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                  Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                  Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Vslinha       := '';
      --Tipo de Registro
      Vslinha := Vslinha || '01';
      --CNPJ Distribuidor (Filial)
      Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
      --Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi');
      --Versão Layout
      Vslinha := Vslinha || '03';
      --Código Indústria
      Vslinha := Vslinha || '510';
      --Filler
      Vslinha := Vslinha || Rpad(' ', 267, ' ');
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vscpnjempresa,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_CABECALHO_510 - ' || sqlerrm);
  End Sp_Gera_Cabecalho_510;
  Procedure Sp_Gera_Vendedor_510(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Vendedor
      For vtVendedor in (select B.NOMERAZAO        as NomeRazaoRepres,
                                a.Nrorepresentante As Nrorepresentante,
                                d.Nomerazao        As Nomerazaosup,
                                c.Seqpessoa        As Seqpessoasup
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            and A.NROREPRESENTANTE in
                                (select X.SEQUENCIA
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 3)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02';
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nrorepresentante, 11, ' ');
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Nome Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 115, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_510 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_510;
  Procedure Sp_Gera_Cliente_510(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                Varchar2(300);
    Vscpnjempresa          Varchar2(14);
    Vncontador             Integer := 0;
    Vscodsegmentocli       Varchar2(3);
    Vscontato              Ge_Pessoa.Nomerazao%Type;
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca Paramentro Dinamico
      select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'TIPO_CODSEGMENTO_CLI'),
                 'A')
        Into Vspdtipocodsegmentocli
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Movimento de Vendas
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               Decode(a.Fisicajuridica,
                                      'J',
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0')) As Cpfcnpjcliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente,
                               Nvl(a.Foneddd1 || a.Fonenro1, 0) As Telefonecliente,
                               a.Fisicajuridica,
                               a.Bairro As Bairrocliente
                          From Ge_Pessoa a
                         Where a.Seqpessoa In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 4)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 14, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 8, '0');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 50, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Enderecocliente, 75, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 50, ' ');
        -- Código Segmento Cliente
        If Vspdtipocodsegmentocli = 'G' Then
          If Vtcliente.Grupocliente = 'TRADICIONAL' Then
            Vscodsegmentocli := '001';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 1 A 4 CHECKOUTS' Then
            Vscodsegmentocli := '002';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 5 A 9 CHECKOUTS' Then
            Vscodsegmentocli := '003';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 10 A 19 CHECKOUTS' Then
            Vscodsegmentocli := '004';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 20 A 49 CHECKOUTS' Then
            Vscodsegmentocli := '005';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 50+ CHECKOUTS' Then
            Vscodsegmentocli := '006';
          Else
            Vscodsegmentocli := '001';
          End If;
        Else
          If Vtcliente.Atividadecliente = 'TRADICIONAL' Then
            Vscodsegmentocli := '001';
          Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 1 A 4 CHECKOUTS' Then
            Vscodsegmentocli := '002';
          Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 5 A 9 CHECKOUTS' Then
            Vscodsegmentocli := '003';
          elsif vtCliente.AtividadeCliente =
                'AUTO SERVICO 10 A 19 CHECKOUTS' then
            Vscodsegmentocli := '004';
          elsif vtCliente.AtividadeCliente =
                'AUTO SERVICO 20 A 49 CHECKOUTS' then
            Vscodsegmentocli := '005';
          Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 50+ CHECKOUTS' Then
            Vscodsegmentocli := '006';
          Else
            Vscodsegmentocli := '001';
          End If;
        End If;
        Vslinha := Vslinha || Lpad(Vscodsegmentocli, 3, '0');
        -- Telefone
        Vslinha := Vslinha || Lpad(Vtcliente.Telefonecliente, 15, '0');
        -- Contato
        If Vtcliente.Fisicajuridica = 'J' Then
          Begin
            Select b.Nomerazao
              Into Vscontato
              From Ge_Pessoacontato a, Ge_Pessoa b
             Where a.Seqprincipal = Vtcliente.Seqpessoa
               And a.Tipcontato = 'COMPRADOR'
               And a.Seqpessoa = b.Seqpessoa;
          Exception
            When No_Data_Found Then
              Vscontato := ' ';
          End;
        Else
          Vscontato := ' ';
        End If;
        Vslinha := Vslinha || Rpad(Vscontato, 20, ' ');
        -- Bairro
        Vslinha := Vslinha || Rpad(Vtcliente.Bairrocliente, 20, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 41, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_510 - ' || Sqlerrm);
  End Sp_Gera_Cliente_510;
  Procedure Sp_Gera_Vendas_510(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                               Pddtainicial   In Date,
                               Pddtafinal     In Date,
                               Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                               Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                 Varchar2(300);
    Vscpnjempresa           Varchar2(14);
    Vncontador              Integer := 0;
    Vspdgeranfserieoe       Max_Parametro.Valor%Type := 'N';
    Vspdgerasinalnegdevcanc Max_Parametro.Valor%Type := 'N';
    Vscgobonifexp           Max_Parametro.Valor%Type := '0';
  Begin
    -- Parâmetro Dinâmico - CGOs consistidos como Bonificação na Geração do EDI
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIF_EXP',
                          'N',
                          '0',
                          'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                          Vscgobonifexp);
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N'),
             Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_SINAL_NEGATIVO_DEVOL_CANC'),
                 'N')
        Into Vspdgeranfserieoe, Vspdgerasinalnegdevcanc
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtnota In (Select a.Numerodf,
                            a.Seriedf,
                            --- enviará o código EAN, se não existir manda DUN
                            Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                    Fcodacessoprodedi(a.Seqproduto, 'D', 'N')),
                                ' ') As Codigoprod,
                            Decode(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                   Null,
                                   '02',
                                   '01') As Tipocodigoprod,
                            (Case
                              When e.Embalagem In ('UN', 'PC') Or
                                   Fcodacessoprodedi(a.Seqproduto, 'E', 'N') Is Not Null Then
                               'U'
                              When e.Embalagem = 'KG' Then
                               'K'
                              When e.Embalagem = 'CX' Then
                               'C'
                              When e.Embalagem In ('TN', 'TO') Then
                               'T'
                              Else
                               'U'
                            End) As Codunidmedida,
                            -- a quantidade e o valor unitário verificarão o código enviado
                            -- se for EAN não divide pela qtde da embalagem, se for DUN precisa dividir
                            Round(Sum(a.Quantidade /
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Null,
                                             a.Qtdembalagem,
                                             1)),
                                  3) * 1000 As Quantidade,
                            --DECODE(A.CODGERALOPER,C.CGONFBONIFICACAO,'S','N') as Bonificacao,
                            Decode(a.indtipodescbonif,
                                   'T',
                                   'S',
                                   fIndRegistroBonif(A.codgeraloper,
                                                     C.CGONFBONIFICACAO,
                                                     vsCGOBonifExp)) as Bonificacao,
                            round(SUM(A.VLRCONTABIL /
                                      (A.QUANTIDADE /
                                      DECODE(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                                'E',
                                                                'N'),
                                              null,
                                              A.QTDEMBALAGEM,
                                              1))),
                                  2) * 100 as VlrUnitario,
                            Round(Sum(a.Vlrcontabil), 2) * 100 As Vlrbruto,
                            round(SUM(A.VLRCONTABIL -
                                      (A.VLRICMS + A.VLRPIS + A.VLRCOFINS)),
                                  2) * 100 as VlrLiquido,
                            round(decode(nvl(SUM((A.VLRPRODBRUTO +
                                                 A.VLRACRESCIMO)),
                                             0),
                                         0,
                                         0,
                                         SUM(A.VLRDESCONTO * 100 /
                                             ((A.VLRPRODBRUTO +
                                             A.VLRACRESCIMO)))),
                                  2) * 100 as PercDesconto,
                            round(decode(nvl(SUM(A.VLRCONTABIL), 0),
                                         0,
                                         0,
                                         SUM(A.VLRICMS * 100 / A.VLRCONTABIL)),
                                  2) * 100 as PercIcms,
                            round(decode(nvl(SUM(A.VLRCONTABIL), 0),
                                         0,
                                         0,
                                         SUM(A.VLRIPI * 100 / A.VLRCONTABIL)),
                                  2) * 100 as PercIpi,
                            round(decode(nvl(SUM(A.VLRCONTABIL), 0),
                                         0,
                                         0,
                                         SUM((A.VLRPIS + A.VLRCOFINS) * 100 /
                                             A.VLRCONTABIL)),
                                  2) * 100 as PercPisCofins,
                            (Case
                              When Nvl(a.Statusdf, 'V') = 'C' Or
                                   Nvl(a.Statusitem, 'V') = 'C' Then
                               '3'
                              else
                               decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                      'ED',
                                      '2',
                                      '1')
                            End) As Tiponotafiscal
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        And a.Seqproduto In
                            (Select x.Sequencia
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (Vspdgeranfserieoe = 'S'))
                      Group By a.Numerodf,
                               a.Seriedf,
                               a.Seqproduto,
                               e.Embalagem,
                               a.Tipnotafiscal || a.Tipdocfiscal,
                               Decode(a.Indtipodescbonif,
                                      'T',
                                      'S',
                                      Findregistrobonif(a.Codgeraloper,
                                                        c.Cgonfbonificacao,
                                                        Vscgobonifexp)),
                               (Case
                                 When Nvl(a.Statusdf, 'V') = 'C' Or
                                      Nvl(a.Statusitem, 'V') = 'C' Then
                                  '3'
                                 Else
                                  Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                         'ED',
                                         '2',
                                         '1')
                               End)
                      order by A.NUMERODF, A.SERIEDF) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '04';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtnota.Codigoprod, 20, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtnota.Tipocodigoprod, 2, ' ');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtnota.Codunidmedida, 1, ' ');
        -- Quantidade vendida
        Vslinha := Vslinha || Lpad(Vtnota.Quantidade, 15, '0');
        -- Bonificação
        Vslinha := Vslinha || Rpad(Vtnota.Bonificacao, 1, ' ');
        -- Valor Unitário
        If Vspdgerasinalnegdevcanc = 'S' Then
          vsLinha := vsLinha || case
                       when (vtNota.tiponotafiscal = '2' or
                            vtNota.TipoNotaFiscal = '3') then
                        '-' || lpad(vtNota.VlrUnitario, 7, '0')
                       else
                        lpad(vtNota.VlrUnitario, 8, '0')
                     end;
        Else
          Vslinha := Vslinha || Lpad(Vtnota.Vlrunitario, 8, '0');
        End If;
        -- Valor total bruto
        Vslinha := Vslinha || Lpad(Vtnota.Vlrbruto, 15, '0');
        -- Valor total liquido
        Vslinha := Vslinha || Lpad(Vtnota.Vlrliquido, 15, '0');
        -- Percentual Desconto
        Vslinha := Vslinha || Lpad(Vtnota.Percdesconto, 6, '0');
        -- Percentual ICMS
        Vslinha := Vslinha || Lpad(Vtnota.Percicms, 6, '0');
        -- Percentual IPI
        Vslinha := Vslinha || Lpad(Vtnota.Percipi, 6, '0');
        -- Percentual Pis/Cofins
        Vslinha := Vslinha || Lpad(Vtnota.Percpiscofins, 6, '0');
        -- Categoria da Venda
        Vslinha := Vslinha || Rpad(' ', 3, ' ');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 162, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           4,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_510 - ' || Sqlerrm);
  End Sp_Gera_Vendas_510;
  Procedure Sp_Gera_Estoque_510(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pddtabase      In Date,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(500);
    Vscpnjempresa Varchar2(25);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtestoque In (Select Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Fcodacessoprodedi(a.Seqproduto,
                                                         'D',
                                                         'N')),
                                   ' ') As Codproduto,
                               To_Char(Pddtabase, 'yyyymmdd') As Dtaestoque,
                               Round(Nvl(i.Qtdestqinicial, 0) +
                                     Nvl(i.Qtdentrada, 0) -
                                     Nvl(i.Qtdsaida, 0),
                                     3) * 1000 As Qtdeestoque,
                               (Case
                                 When c.Embalagem In ('UN', 'PC') Then
                                  'U'
                                 When c.Embalagem = 'KG' Then
                                  'K'
                                 When c.Embalagem = 'CX' Then
                                  'C'
                                 When c.Embalagem In ('TN', 'TO') Then
                                  'T'
                                 Else
                                  'U'
                               End) As Codunidmedida,
                               Decode(Fcodacessoprodedi(a.Seqproduto,
                                                        'E',
                                                        'N'),
                                      Null,
                                      '02',
                                      '01') As Tipocodprod,
                               Round(Decode(Pddtabase,
                                            Trunc(Sysdate),
                                            Nvl(h.Qtdpedrectransito, 0),
                                            0),
                                     3) * 1000 As Qtdeestoquetrans,
                               Round(h.Estqminimoloja, 3) * 1000 As Qtdeestoquemin,
                               Round(h.Estqmaximoloja, 3) * 1000 As Qtdeestoquemax
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Mrl_Custodia       i
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           And c.Qtdembalagem =
                               Fpadraoembvendaseg(a.Seqfamilia,
                                                  b.Nrosegmentoprinc)
                           And i.Dtaentradasaida =
                               (Select Max(x.Dtaentradasaida)
                                  From Mrl_Custodia x
                                 Where x.Seqproduto = i.Seqproduto
                                   And x.Nroempresa = i.Nroempresa
                                   And x.Dtaentradasaida <= Pddtabase)
                           And a.Seqproduto In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 where X.SEQSELECAO = 2)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '05';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 20, ' ');
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 8, '0');
        -- Quantidade de Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 15, '0');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtestoque.Codunidmedida, 1, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtestoque.Tipocodprod, 2, ' ');
        -- Quantidade Estoque em Transito
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquetrans, 15, '0');
        -- Quantidade Estoque Minimo
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquemin, 15, '0');
        -- Quantidade Estoque Máximo
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquemax, 15, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 207, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           5,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_510 - ' || Sqlerrm);
  End Sp_Gera_Estoque_510;
  Procedure Sp_Gera_Notasfiscais_510(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pddtainicial   In Date,
                                     Pddtafinal     In Date,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha           Varchar2(300);
    Vscpnjempresa     Varchar2(14);
    Vncontador        Integer := 0;
    Vnprazopagamento  Number;
    Vspdgeranfserieoe Max_Parametro.Valor%Type := 'N';
  Begin
    --Busca Paramentro Dinamico
    select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtnota In (Select Distinct a.Numerodf,
                                     a.Seriedf,
                                     To_Char(a.Dtaentrada, 'yyyymmdd') As Dtaemissao,
                                     (Case
                                       When Nvl(a.Statusdf, 'V') = 'C' Or
                                            Nvl(a.Statusitem, 'V') = 'C' Then
                                        '3'
                                       Else
                                        Decode(a.Tipnotafiscal ||
                                               a.Tipdocfiscal,
                                               'ED',
                                               '2',
                                               '1')
                                     End) As Tiponotafiscal,
                                     a.Nrorepresentante As Codvendedor,
                                     Decode(f.Fisicajuridica,
                                            'J',
                                            Lpad(f.Nrocgccpf ||
                                                 Lpad(f.Digcgccpf, 2, 0),
                                                 14,
                                                 '0'),
                                            Lpad(f.Nrocgccpf ||
                                                 Lpad(f.Digcgccpf, 2, 0),
                                                 11,
                                                 '0')) As Codcliente,
                                     Decode(f.Fisicajuridica,
                                            'F',
                                            '01',
                                            '02') As Tipofaturamento,
                                     Decode(a.Tipofrete, 'F', 'FOB', 'CIF') As Tipofrete,
                                     a.Linkerp,
                                     h.Uf As Origemmercadoria,
                                     Regexp_Replace(h.Cep, '[^0-9]') As Ceporigem,
                                     f.Uf As Destinomerc,
                                     Regexp_Replace(f.Cep, '[^0-9]') As Cepdestino
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e,
                            Ge_Pessoa        f,
                            Map_Famfornec    g,
                            Ge_Pessoa        h
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        And a.Seqproduto In
                            (Select x.Sequencia
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Seqpessoa = f.Seqpessoa
                        And b.Seqfamilia = g.Seqfamilia
                        And g.Principal = 'S'
                        And g.Seqfornecedor = h.Seqpessoa
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        And a.Tipnotafiscal || a.Tipdocfiscal In
                            ('ED', 'SC')
                        And ((Vspdgeranfserieoe = 'N' And
                            Nvl(d.Tipodocto, 'x') != 'O') Or
                            (Vspdgeranfserieoe = 'S'))
                      Order By a.Numerodf, a.Seriedf) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '06';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Data Emissão da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Dtaemissao, 8, '0');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Código do Vendedor
        Vslinha := Vslinha || Lpad(Vtnota.Codvendedor, 11, '0');
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtnota.Codcliente, 14, ' ');
        -- Tipo de Faturamento
        Vslinha := Vslinha || Rpad(Vtnota.Tipofaturamento, 2, ' ');
        -- Tipo de Frete
        Vslinha := Vslinha || Rpad(Vtnota.Tipofrete, 3, ' ');
        -- Prazo de Pagamento
        Begin
          Select Nvl(Round(Avg(a.Dtavencimento - a.Dtaemissao), 0), 0)
            Into Vnprazopagamento
            From Mrl_Titulofin a
           Where a.Linkerp = Vtnota.Linkerp;
        Exception
          When No_Data_Found Then
            Vnprazopagamento := 0;
        End;
        Vslinha := Vslinha || Lpad(Vnprazopagamento, 3, '0');
        -- Origem Mercadoria
        Vslinha := Vslinha || Rpad(Vtnota.Origemmercadoria, 2, ' ');
        -- CEP Origem
        Vslinha := Vslinha || Lpad(Vtnota.Ceporigem, 8, '0');
        -- Destino Mercadoria
        Vslinha := Vslinha || Rpad(Vtnota.Destinomerc, 2, ' ');
        -- CEP Destino
        Vslinha := Vslinha || Lpad(Vtnota.Cepdestino, 8, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 212, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           6,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_NOTASFISCAIS_510 - ' || Sqlerrm);
  End Sp_Gera_Notasfiscais_510;
  /* Mead Johnson - Fim */
  /************************************************************************************/
  /* Masterfood / Mars - Início */
  Procedure Sp_Gera_Cabecalho_520(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                  Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                  Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
  Begin
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Or Psversaolayout = '4.6' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Vslinha       := '';
      --Tipo de Registro
      Vslinha := Vslinha || '1';
      --CNPJ Distribuidor (Filial)
      Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
      --Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi');
      --Versão Layout
      Vslinha := Vslinha || '04';
      --Código Indústria
      Vslinha := Vslinha || '520';
      --Filler
      Vslinha := Vslinha || Rpad(' ', 268, ' ');
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vscpnjempresa,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_CABECALHO_520 - ' || Sqlerrm);
  End Sp_Gera_Cabecalho_520;
  Procedure Sp_Gera_Vendedor_520(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Or Psversaolayout = '4.6' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Vendedor
      /*For Vtvendedor In (Select b.Nomerazao As Nomerazaorepres,
            a.Nrorepresentante As Nrorepresentante,
            Decode(b.Fisicajuridica,
                   'J',
                   Lpad(b.Nrocgccpf ||
                        Lpad(b.Digcgccpf, 2, 0),
                        14,
                        '0'),
                   Lpad(b.Nrocgccpf ||
                        Lpad(b.Digcgccpf, 2, 0),
                        11,
                        '0')) As Cpfcnpjrepres,
            d.Nomerazao As Nomerazaosup,
            c.Seqpessoa As Seqpessoasup,
            Decode(d.Fisicajuridica,
                   'J',
                   Lpad(d.Nrocgccpf ||
                        Lpad(d.Digcgccpf, 2, 0),
                        14,
                        '0'),
                   Lpad(d.Nrocgccpf ||
                        Lpad(d.Digcgccpf, 2, 0),
                        11,
                        '0')) As Cpfcnpjsuperv
       From Mad_Representante a,
            Ge_Pessoa         b,
            Mad_Equipe        c,
            Ge_Pessoa         d
      Where a.Seqpessoa = b.Seqpessoa
        And a.Nroequipe = c.Nroequipe
        And c.Seqpessoa = d.Seqpessoa
        And a.Nrorepresentante In
            (Select x.Sequencia
               From Maxx_Selecrowid x
              Where x.Seqselecao = 3)) Loop*/
      For Vtvendedor In (Select b.Nomerazao As Nomerazaorepres,
                                a.Nrorepresentante As Nrorepresentante,
                                Decode(b.Fisicajuridica,
                                       'J',
                                       Lpad(b.Nrocgccpf ||
                                            Lpad(b.Digcgccpf, 2, 0),
                                            14,
                                            '0'),
                                       Lpad(b.Nrocgccpf ||
                                            Lpad(b.Digcgccpf, 2, 0),
                                            11,
                                            '0')) As Cpfcnpjrepres,
                                d.Nomerazao As Nomerazaosup,
                                c.Seqpessoa As Seqpessoasup,
                                Decode(d.Fisicajuridica,
                                       'J',
                                       Lpad(d.Nrocgccpf ||
                                            Lpad(d.Digcgccpf, 2, 0),
                                            14,
                                            '0'),
                                       Lpad(d.Nrocgccpf ||
                                            Lpad(d.Digcgccpf, 2, 0),
                                            11,
                                            '0')) As Cpfcnpjsuperv,
                                f.Nomerazao As Nomerazaoger,
                                e.Seqpessoa As Seqpessoager,
                                Decode(f.Fisicajuridica,
                                       'J',
                                       Lpad(f.Nrocgccpf ||
                                            Lpad(f.Digcgccpf, 2, 0),
                                            14,
                                            '0'),
                                       Lpad(f.Nrocgccpf ||
                                            Lpad(f.Digcgccpf, 2, 0),
                                            11,
                                            '0')) As Cpfcnpjger
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d,
                                Mad_Representante e,
                                Ge_Pessoa         f
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            And a.Nrorepresentante In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 3)
                               --   and e.nroequipe(+)   = a.nroequipe
                            and e.nrosegmento(+) = a.nrosegmento
                            and e.nroempresa(+) = a.nroempresa
                            and e.tiprepresentante(+) = 'G'
                            and e.seqpessoa = f.seqpessoa(+)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '2';
        --CNPJ Distribuidor (Filial)
        Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
        -- Filler
        Vslinha := Vslinha || Rpad(' ', 18, ' ');
        -- Código Gerente
        Vslinha := Vslinha ||
                   Rpad(nvl(Vtvendedor.Cpfcnpjger, Vtvendedor.Cpfcnpjsuperv),
                        13,
                        ' ');
        -- Nome Gerente
        Vslinha := Vslinha || Rpad(nvl(Vtvendedor.Nomerazaoger,
                                       Vtvendedor.Nomerazaosup),
                                   50,
                                   ' ');
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Cpfcnpjsuperv, 13, ' ');
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Cpfcnpjrepres, 20, ' ');
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 71, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_520 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_520;
  Procedure Sp_Gera_Cliente_520(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                Varchar2(300);
    Vscpnjempresa          Varchar2(14);
    Vncontador             Integer := 0;
    Vscodsegmentocli       Varchar2(3);
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
  Begin
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Or Psversaolayout = '4.6' Then
      --Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'TIPO_CODSEGMENTO_CLI'),
                 'A')
        Into Vspdtipocodsegmentocli
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Movimento de Vendas
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               Decode(a.Fisicajuridica,
                                      'J',
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0')) As Cpfcnpjcliente,
                               /*regexp_replace(A.CEP, '[^0-9]') as CepCliente,*/
                               Substr(a.Cep, 1, 5) || '-' ||
                               Substr(a.Cep, 6, 3) As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente
                          From Ge_Pessoa a
                         Where a.Seqpessoa In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 4)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '3';
        --CNPJ Distribuidor (Filial)
        Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 18, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 40, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Enderecocliente, 70, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 9, '0');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 30, ' ');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Usuário Vendedor PDV
        Vslinha := Vslinha || Rpad(' ', 10, ' ');
        -- Código Segmento Cliente
        If Psversaolayout = '4' Or Psversaolayout = '04' Then
          If Vspdtipocodsegmentocli = 'G' Then
            If Vtcliente.Grupocliente = 'TRADICIONAL' Then
              Vscodsegmentocli := '001';
            Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 1 A 4 CHECKOUTS' Then
              Vscodsegmentocli := '002';
            Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 5 A 9 CHECKOUTS' Then
              Vscodsegmentocli := '003';
            Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 10 A 19 CHECKOUTS' Then
              Vscodsegmentocli := '004';
            Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 20 A 49 CHECKOUTS' Then
              Vscodsegmentocli := '005';
            Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 50+ CHECKOUTS' Then
              Vscodsegmentocli := '006';
            Else
              Vscodsegmentocli := '001';
            End If;
          Else
            If Vtcliente.Atividadecliente = 'TRADICIONAL' Then
              Vscodsegmentocli := '001';
            elsif vtCliente.AtividadeCliente =
                  'AUTO SERVICO 1 A 4 CHECKOUTS' then
              Vscodsegmentocli := '002';
            elsif vtCliente.AtividadeCliente =
                  'AUTO SERVICO 5 A 9 CHECKOUTS' then
              Vscodsegmentocli := '003';
            elsif vtCliente.AtividadeCliente =
                  'AUTO SERVICO 10 A 19 CHECKOUTS' then
              Vscodsegmentocli := '004';
            elsif vtCliente.AtividadeCliente =
                  'AUTO SERVICO 20 A 49 CHECKOUTS' then
              Vscodsegmentocli := '005';
            Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 50+ CHECKOUTS' Then
              Vscodsegmentocli := '006';
            Else
              Vscodsegmentocli := '001';
            End If;
          End If;
          -- Código Segmento cliente LAYOUT versão 4.5 MARS
        Elsif Psversaolayout = '4.5' Then
          If Vspdtipocodsegmentocli = 'G' Then
            If Vtcliente.Grupocliente = 'ARMAZÉM/MERCEARIA/EMPÓRIO/PADARIA' Then
              Vscodsegmentocli := '200';
            Elsif Vtcliente.Grupocliente = 'LOJAS DE CONVENIÊNCIA' Then
              Vscodsegmentocli := '201';
            Elsif Vtcliente.Grupocliente = 'MERCADOS ATÉ 4 CHECKOUTS' Then
              Vscodsegmentocli := '202';
            Elsif Vtcliente.Grupocliente = 'MERCADOS DE 5 A 9 CHECKOUTS' Then
              Vscodsegmentocli := '203';
            Elsif Vtcliente.Grupocliente = '10 A 19 CHECKOUTS' Then
              Vscodsegmentocli := '204';
            Elsif Vtcliente.Grupocliente = '20 + CHECKOUTS' Then
              Vscodsegmentocli := '205';
            Elsif Vtcliente.Grupocliente = 'PEQUENAS REDES' Then
              Vscodsegmentocli := '206';
            Elsif Vtcliente.Grupocliente = 'CLÍNICAS VETERINÁRIAS' Then
              Vscodsegmentocli := '207';
            Elsif Vtcliente.Grupocliente = 'PET SHOP COM GRANEL' Then
              Vscodsegmentocli := '208';
            Elsif Vtcliente.Grupocliente = 'PET SHOP SEM GRANEL' Then
              Vscodsegmentocli := '209';
            Elsif Vtcliente.Grupocliente = 'PET SHOP TOP' Then
              Vscodsegmentocli := '210';
            Elsif Vtcliente.Grupocliente = 'BAR/LANCHONETE' Then
              Vscodsegmentocli := '211';
            Elsif Vtcliente.Grupocliente = 'CANTINAS' Then
              Vscodsegmentocli := '212';
            Elsif Vtcliente.Grupocliente = 'BANCA DE JORNAL' Then
              Vscodsegmentocli := '213';
            Elsif Vtcliente.Grupocliente = 'FARMÁCIA/DROGARIA' Then
              Vscodsegmentocli := '214';
            Elsif Vtcliente.Grupocliente = 'BOMBONIERE' Then
              Vscodsegmentocli := '215';
            Elsif Vtcliente.Grupocliente = 'RESTAURANTE' Then
              Vscodsegmentocli := '216';
            Elsif Vtcliente.Grupocliente = 'HOTEIS E MOTEIS' Then
              Vscodsegmentocli := '217';
            Elsif Vtcliente.Grupocliente = 'CINEMA' Then
              Vscodsegmentocli := '218';
            Elsif Vtcliente.Grupocliente = 'AÇOUGUE' Then
              Vscodsegmentocli := '219';
            Elsif Vtcliente.Grupocliente = 'CASA NOTURNA' Then
              Vscodsegmentocli := '220';
            Elsif Vtcliente.Grupocliente = 'ATACADO GENERALISTA' Then
              Vscodsegmentocli := '221';
            Elsif Vtcliente.Grupocliente = 'ATACADO DOCEIRO' Then
              Vscodsegmentocli := '222';
            Elsif Vtcliente.Grupocliente = 'VIDEO LOCADORA' Then
              Vscodsegmentocli := '223';
            Elsif Vtcliente.Grupocliente = 'FUNCIONÁRIOS DISTRIBUIDOR' Then
              Vscodsegmentocli := '225';
            Elsif Vtcliente.Grupocliente = 'CASH & CARRY' Then
              Vscodsegmentocli := '226';
            Elsif Vtcliente.Grupocliente = 'OUTROS' Then
              Vscodsegmentocli := '224';
            Else
              Vscodsegmentocli := '224';
            End If;
          Else
            if vtCliente.AtividadeCliente =
               'ARMAZÉM/MERCEARIA/EMPÓRIO/PADARIA' then
              Vscodsegmentocli := '200';
            Elsif Vtcliente.Atividadecliente = 'LOJAS DE CONVENIÊNCIA' Then
              Vscodsegmentocli := '201';
            Elsif Vtcliente.Atividadecliente = 'MERCADOS ATÉ 4 CHECKOUTS' Then
              Vscodsegmentocli := '202';
            elsif vtCliente.AtividadeCliente =
                  'MERCADOS DE 5 A 9 CHECKOUTS' then
              Vscodsegmentocli := '203';
            Elsif Vtcliente.Atividadecliente = '10 A 19 CHECKOUTS' Then
              Vscodsegmentocli := '204';
            Elsif Vtcliente.Atividadecliente = '20 + CHECKOUTS' Then
              Vscodsegmentocli := '205';
            Elsif Vtcliente.Atividadecliente = 'PEQUENAS REDES' Then
              Vscodsegmentocli := '206';
            Elsif Vtcliente.Atividadecliente = 'CLÍNICAS VETERINÁRIAS' Then
              Vscodsegmentocli := '207';
            Elsif Vtcliente.Atividadecliente = 'PET SHOP COM GRANEL' Then
              Vscodsegmentocli := '208';
            Elsif Vtcliente.Atividadecliente = 'PET SHOP SEM GRANEL' Then
              Vscodsegmentocli := '209';
            Elsif Vtcliente.Atividadecliente = 'PET SHOP TOP' Then
              Vscodsegmentocli := '210';
            Elsif Vtcliente.Atividadecliente = 'BAR/LANCHONETE' Then
              Vscodsegmentocli := '211';
            Elsif Vtcliente.Atividadecliente = 'CANTINAS' Then
              Vscodsegmentocli := '212';
            Elsif Vtcliente.Atividadecliente = 'BANCA DE JORNAL' Then
              Vscodsegmentocli := '213';
            Elsif Vtcliente.Atividadecliente = 'FARMÁCIA/DROGARIA' Then
              Vscodsegmentocli := '214';
            Elsif Vtcliente.Atividadecliente = 'BOMBONIERE' Then
              Vscodsegmentocli := '215';
            Elsif Vtcliente.Atividadecliente = 'RESTAURANTE' Then
              Vscodsegmentocli := '216';
            Elsif Vtcliente.Atividadecliente = 'HOTEIS E MOTEIS' Then
              Vscodsegmentocli := '217';
            Elsif Vtcliente.Atividadecliente = 'CINEMA' Then
              Vscodsegmentocli := '218';
            Elsif Vtcliente.Atividadecliente = 'AÇOUGUE' Then
              Vscodsegmentocli := '219';
            Elsif Vtcliente.Atividadecliente = 'CASA NOTURNA' Then
              Vscodsegmentocli := '220';
            Elsif Vtcliente.Atividadecliente = 'ATACADO GENERALISTA' Then
              Vscodsegmentocli := '221';
            Elsif Vtcliente.Atividadecliente = 'ATACADO DOCEIRO' Then
              Vscodsegmentocli := '222';
            Elsif Vtcliente.Atividadecliente = 'VIDEO LOCADORA' Then
              Vscodsegmentocli := '223';
            Elsif Vtcliente.Grupocliente = 'FUNCIONÁRIOS DISTRIBUIDOR' Then
              Vscodsegmentocli := '225';
            Elsif Vtcliente.Grupocliente = 'CASH & CARRY' Then
              Vscodsegmentocli := '226';
            Elsif Vtcliente.Atividadecliente = 'OUTROS' Then
              Vscodsegmentocli := '224';
            Else
              Vscodsegmentocli := '224';
            End If;
          End If;
        Elsif Psversaolayout = '4.6' Then
          Vscodsegmentocli := Nvl(Fbuscacodativclitente670(Vtcliente.Atividadecliente,
                                                           Pssoftpdv),
                                  '224');
        End If;
        Vslinha := Vslinha || Rpad(Vscodsegmentocli, 10, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 96, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_520 - ' || Sqlerrm);
  End Sp_Gera_Cliente_520;
  Procedure Sp_Gera_Vendas_520(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                               Pddtainicial   In Date,
                               Pddtafinal     In Date,
                               Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                               Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                 Varchar2(300);
    Vscpnjempresa           Varchar2(14);
    Vncontador              Integer := 0;
    Vspdgeranfserieoe       Max_Parametro.Valor%Type := 'N';
    Vspdgerasinalnegdevcanc Max_Parametro.Valor%Type := 'N';
    Vscgobonifexp           Max_Parametro.Valor%Type := '0';
  Begin
    -- Parâmetro Dinâmico - CGOs consistidos como Bonificação na Geração do EDI
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIF_EXP',
                          'N',
                          '0',
                          'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                          Vscgobonifexp);
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Or Psversaolayout = '4.6' Then
      --Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N'),
             Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_SINAL_NEGATIVO_DEVOL_CANC'),
                 'N')
        Into Vspdgeranfserieoe, Vspdgerasinalnegdevcanc
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtnota In (Select a.Numerodf,
                            a.Seriedf,
                            --- enviará o código EAN, se não existir manda DUN
                            Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                    Fcodacessoprodedi(a.Seqproduto, 'D', 'N')),
                                ' ') As Codigoprod,
                            -- a quantidade e o valor unitário verificarão o código enviado
                            Round(Sum(a.Quantidade /
                                      fQtdeCodAcessoProdEDI(a.Seqproduto,
                                                            'E')),
                                  0) As Quantidade,
                            --DECODE(A.CODGERALOPER,C.CGONFBONIFICACAO,'S','N') as Bonificacao,
                            Decode(a.Indtipodescbonif,
                                   'T',
                                   'S',
                                   Findregistrobonif(a.Codgeraloper,
                                                     c.Cgonfbonificacao,
                                                     Vscgobonifexp)) As Bonificacao,
                            Replace(Round(Sum(a.Vlrcontabil /
                                              (a.Quantidade /
                                              fQtdeCodAcessoProdEDI(a.Seqproduto,
                                                                     'E'))),
                                          2),
                                    ',',
                                    '.') As Vlrunitario,
                            To_Char(a.Dtaemissao, 'yyyymmdd') As Dtaemissao,
                            Decode(h.Fisicajuridica,
                                   'J',
                                   Lpad(h.Nrocgccpf ||
                                        Lpad(h.Digcgccpf, 2, 0),
                                        14,
                                        '0'),
                                   Lpad(h.Nrocgccpf ||
                                        Lpad(h.Digcgccpf, 2, 0),
                                        11,
                                        '0')) As Nrorepresentante,
                            DECODE(F.FISICAJURIDICA,
                                   'J',
                                   LPAD(F.NROCGCCPF ||
                                        LPAD(F.DIGCGCCPF, 2, 0),
                                        14,
                                        '0'),
                                   LPAD(F.NROCGCCPF ||
                                        LPAD(F.DIGCGCCPF, 2, 0),
                                        11,
                                        '0')) as CpfCnpjCliente,
                            decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                   'ED',
                                   '2',
                                   '1') As Tiponotafiscal
                       From Mflv_Basedfitem   a,
                            Map_Produto       b,
                            Mad_Parametro     c,
                            Max_Empserienf    d,
                            Map_Famembalagem  e,
                            Ge_Pessoa         f,
                            Mad_Representante g,
                            Ge_Pessoa         h
                      Where a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        and a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        and A.SEQPRODUTO in
                            (select X.SEQUENCIA
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Seqpessoa = f.Seqpessoa
                        And a.Nrorepresentante = g.nrorepresentante
                        and g.seqpessoa = h.seqpessoa
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (Vspdgeranfserieoe = 'S'))
                     --   And a.Tipnotafiscal = 'S'
                      Group By a.Numerodf,
                               a.Seriedf,
                               --- enviará o código EAN, se não existir manda DUN
                               Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Fcodacessoprodedi(a.Seqproduto,
                                                         'D',
                                                         'N')),
                                   ' '),
                               Decode(a.Indtipodescbonif,
                                      'T',
                                      'S',
                                      Findregistrobonif(a.Codgeraloper,
                                                        c.Cgonfbonificacao,
                                                        Vscgobonifexp)),
                               To_Char(a.Dtaemissao, 'yyyymmdd'),
                               Decode(h.Fisicajuridica,
                                      'J',
                                      Lpad(h.Nrocgccpf ||
                                           Lpad(h.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(h.Nrocgccpf ||
                                           Lpad(h.Digcgccpf, 2, 0),
                                           11,
                                           '0')),
                               DECODE(F.FISICAJURIDICA,
                                      'J',
                                      LPAD(F.NROCGCCPF ||
                                           LPAD(F.DIGCGCCPF, 2, 0),
                                           14,
                                           '0'),
                                      LPAD(F.NROCGCCPF ||
                                           LPAD(F.DIGCGCCPF, 2, 0),
                                           11,
                                           '0')),
                               decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                      'ED',
                                      '2',
                                      '1')
                     -------------------------
                     union all
                     Select a.Numerodf,
                            a.Seriedf,
                            --- enviará o código EAN, se não existir manda DUN
                            Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                    Fcodacessoprodedi(a.Seqproduto, 'D', 'N')),
                                ' ') As Codigoprod,
                            -- a quantidade e o valor unitário verificarão o código enviado
                            Round(Sum(a.Quantidade /
                                      fQtdeCodAcessoProdEDI(a.Seqproduto,
                                                            'E')),
                                  0) As Quantidade,
                            --DECODE(A.CODGERALOPER,C.CGONFBONIFICACAO,'S','N') as Bonificacao,
                            Decode(a.Indtipodescbonif,
                                   'T',
                                   'S',
                                   Findregistrobonif(a.Codgeraloper,
                                                     c.Cgonfbonificacao,
                                                     Vscgobonifexp)) As Bonificacao,
                            Replace(Round(Sum(a.Vlrcontabil /
                                              (a.Quantidade /
                                              fQtdeCodAcessoProdEDI(a.Seqproduto,
                                                                     'E'))),
                                          2),
                                    ',',
                                    '.') As Vlrunitario,
                            To_Char(a.Dtaemissao, 'yyyymmdd') As Dtaemissao,
                            Decode(h.Fisicajuridica,
                                   'J',
                                   Lpad(h.Nrocgccpf ||
                                        Lpad(h.Digcgccpf, 2, 0),
                                        14,
                                        '0'),
                                   Lpad(h.Nrocgccpf ||
                                        Lpad(h.Digcgccpf, 2, 0),
                                        11,
                                        '0')) As Nrorepresentante,
                            DECODE(F.FISICAJURIDICA,
                                   'J',
                                   LPAD(F.NROCGCCPF ||
                                        LPAD(F.DIGCGCCPF, 2, 0),
                                        14,
                                        '0'),
                                   LPAD(F.NROCGCCPF ||
                                        LPAD(F.DIGCGCCPF, 2, 0),
                                        11,
                                        '0')) as CpfCnpjCliente,
                            '3' As Tiponotafiscal
                       From Mflv_Basedfitem   a,
                            Map_Produto       b,
                            Mad_Parametro     c,
                            Max_Empserienf    d,
                            Map_Famembalagem  e,
                            Ge_Pessoa         f,
                            Mad_Representante g,
                            Ge_Pessoa         h
                      Where a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        and a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        and A.SEQPRODUTO in
                            (select X.SEQUENCIA
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Seqpessoa = f.Seqpessoa
                        And a.Nrorepresentante = g.nrorepresentante
                        and g.seqpessoa = h.seqpessoa
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (Vspdgeranfserieoe = 'S'))
                        And a.Tipnotafiscal = 'S'
                        and (Nvl(a.Statusdf, 'V') = 'C' Or
                            Nvl(a.Statusitem, 'V') = 'C')
                      Group By a.Numerodf,
                               a.Seriedf,
                               --- enviará o código EAN, se não existir manda DUN
                               Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Fcodacessoprodedi(a.Seqproduto,
                                                         'D',
                                                         'N')),
                                   ' '),
                               Decode(a.Indtipodescbonif,
                                      'T',
                                      'S',
                                      Findregistrobonif(a.Codgeraloper,
                                                        c.Cgonfbonificacao,
                                                        Vscgobonifexp)),
                               To_Char(a.Dtaemissao, 'yyyymmdd'),
                               Decode(h.Fisicajuridica,
                                      'J',
                                      Lpad(h.Nrocgccpf ||
                                           Lpad(h.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(h.Nrocgccpf ||
                                           Lpad(h.Digcgccpf, 2, 0),
                                           11,
                                           '0')),
                               DECODE(F.FISICAJURIDICA,
                                      'J',
                                      LPAD(F.NROCGCCPF ||
                                           LPAD(F.DIGCGCCPF, 2, 0),
                                           14,
                                           '0'),
                                      LPAD(F.NROCGCCPF ||
                                           LPAD(F.DIGCGCCPF, 2, 0),
                                           11,
                                           '0'))
                      order by 1, 2, 3) --A.NUMERODF, A.SERIEDF)
       Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '4';
        --CNPJ Distribuidor (Filial)
        Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtnota.Cpfcnpjcliente, 18, ' ');
        --Data Hora Geração do Docto
        Vslinha := Vslinha || Lpad(Vtnota.Dtaemissao, 8, 0);
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtnota.Codigoprod, 14, ' ');
        -- Quantidade vendida
        If Vspdgerasinalnegdevcanc = 'S' Then
          Vslinha := Vslinha || Case
                       When (Vtnota.Tiponotafiscal = '2' Or
                            Vtnota.Tiponotafiscal = '3') Then
                        '-' || Lpad(Vtnota.Quantidade, 7, '0')
                       Else
                        Lpad(Vtnota.Quantidade, 8, '0')
                     End;
        Else
          Vslinha := Vslinha || Lpad(Vtnota.Quantidade, 8, '0');
        End If;
        -- Valor Unitário
        Vslinha := Vslinha ||
                   Lpad(To_Char(Vtnota.Vlrunitario, 'FM0000D00'), 8, '0');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtnota.Nrorepresentante, 20, ' ');
        -- Bonificação
        Vslinha := Vslinha || Rpad(Vtnota.Bonificacao, 10, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 179, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           4,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_520 - ' || Sqlerrm);
  End Sp_Gera_Vendas_520;
  Procedure Sp_Gera_Estoque_520(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pddtabase      In Date,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(500);
    Vscpnjempresa Varchar2(25);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Or Psversaolayout = '4.6' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtestoque In (Select Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Fcodacessoprodedi(a.Seqproduto,
                                                         'D',
                                                         'N')),
                                   ' ') As Codproduto,
                               To_Char(Pddtabase, 'yyyymmdd') As Dtaestoque,
                               Round(Nvl(i.Qtdestqinicial, 0) +
                                     Nvl(i.Qtdentrada, 0) -
                                     Nvl(i.Qtdsaida, 0),
                                     0) As Qtdeestoque
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Mrl_Custodia       i
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           And c.Qtdembalagem =
                               Fpadraoembvendaseg(a.Seqfamilia,
                                                  b.Nrosegmentoprinc)
                           And i.Dtaentradasaida =
                               (Select Max(x.Dtaentradasaida)
                                  From Mrl_Custodia x
                                 Where x.Seqproduto = i.Seqproduto
                                   And x.Nroempresa = i.Nroempresa
                                   And x.Dtaentradasaida <= Pddtabase)
                           And a.Seqproduto In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 2)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '5';
        --CNPJ Distribuidor (Filial)
        Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 14, ' ');
        -- Quantidade de Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 8, '0');
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 8, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 255, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           5,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_520 - ' || Sqlerrm);
  End Sp_Gera_Estoque_520;
  /* Masterfood / Mars - Fim */
  /************************************************************************************/
  /* L'oreal - Início */
  Procedure Sp_Gera_Cabecalho_550(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                  Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                  Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
  Begin
    If Psversaolayout = '3' Or Psversaolayout = '03' Or
       Psversaolayout = '3.1' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Vslinha       := '';
      --Tipo de Registro
      Vslinha := Vslinha || '01';
      --CNPJ Distribuidor (Filial)
      Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
      --Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi');
      --Versão Layout
      Vslinha := Vslinha || '03';
      --Código Indústria
      Vslinha := Vslinha || '550';
      --Filler
      Vslinha := Vslinha || Rpad(' ', 267, ' ');
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vscpnjempresa,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_CABECALHO_550 - ' || sqlerrm);
  End Sp_Gera_Cabecalho_550;
  Procedure Sp_Gera_Vendedor_550(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
  Begin
    if psVersaoLayout = '3' or psVersaoLayout = '03' or
       psVersaoLayout = '3.1' then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Vendedor
      For Vtvendedor In (Select b.Nomerazao        As Nomerazaorepres,
                                a.Nrorepresentante As Nrorepresentante,
                                d.Nomerazao        As Nomerazaosup,
                                c.Seqpessoa        As Seqpessoasup
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            And a.Nrorepresentante In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 3)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02';
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nrorepresentante, 11, ' ');
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Nome Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 115, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_550 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_550;
  Procedure Sp_Gera_Cliente_550(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                Varchar2(300);
    Vscpnjempresa          Varchar2(14);
    Vncontador             Integer := 0;
    Vscodsegmentocli       Varchar2(3);
    Vscodsegmentopadraocli Varchar2(3);
    Vscontato              Ge_Pessoa.Nomerazao%Type;
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
  Begin
    --Busca Paramentro Dinamico
    select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                               0,
                               'TIPO_CODSEGMENTO_CLI'),
               'A')
      Into Vspdtipocodsegmentocli
      From Dual;
    -- Parâmetro Dinâmico - Código padrão para Segmento do cliente
    SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                          0,
                          'COD_SEG_PADRAO_CLI',
                          'N',
                          NULL,
                          'INDICA O CODIGO DE SEGMENTO PADRAO PARA CLIENTES QUE NAO POSSUAM ATIVIDADES ASSOCIADAS. ' ||
                          'VALORES POSSIVEIS: QUALQUER VALOR, DESDE QUE CONSTE NO LAYOUT NEOGRID. ' ||
                          'VALOR PADRAO: NENHUM VALOR INFORMADO. ',
                          Vscodsegmentopadraocli);
    --Busca CNPJ da Empresa
    Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
    If Psversaolayout = '3' Or Psversaolayout = '03' Then
      --Movimento de Vendas
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               Decode(a.Fisicajuridica,
                                      'J',
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0')) As Cpfcnpjcliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente,
                               Nvl(a.Foneddd1 || a.Fonenro1, 0) As Telefonecliente,
                               a.Fisicajuridica,
                               a.Bairro As Bairrocliente
                          From Ge_Pessoa a
                         Where a.Seqpessoa In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 4)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 14, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 8, '0');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 50, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Enderecocliente, 75, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 50, ' ');
        -- Código Segmento Cliente
        If Vspdtipocodsegmentocli = 'G' Then
          If Vtcliente.Grupocliente = 'TRADICIONAL' Then
            Vscodsegmentocli := '001';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 1 A 4 CHECKOUTS' Then
            Vscodsegmentocli := '002';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 5 A 9 CHECKOUTS' Then
            Vscodsegmentocli := '003';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 10 A 19 CHECKOUTS' Then
            Vscodsegmentocli := '004';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 20 A 49 CHECKOUTS' Then
            Vscodsegmentocli := '005';
          Elsif Vtcliente.Grupocliente = 'AUTO SERVICO 50+ CHECKOUTS' Then
            Vscodsegmentocli := '006';
          Else
            Vscodsegmentocli := '001';
          End If;
        Else
          If Vtcliente.Atividadecliente = 'TRADICIONAL' Then
            Vscodsegmentocli := '001';
          Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 1 A 4 CHECKOUTS' Then
            Vscodsegmentocli := '002';
          Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 5 A 9 CHECKOUTS' Then
            Vscodsegmentocli := '003';
          Elsif Vtcliente.Atividadecliente =
                'AUTO SERVICO 10 A 19 CHECKOUTS' Then
            Vscodsegmentocli := '004';
          Elsif Vtcliente.Atividadecliente =
                'AUTO SERVICO 20 A 49 CHECKOUTS' Then
            Vscodsegmentocli := '005';
          Elsif Vtcliente.Atividadecliente = 'AUTO SERVICO 50+ CHECKOUTS' Then
            Vscodsegmentocli := '006';
          Else
            Vscodsegmentocli := '001';
          End If;
        End If;
        Vslinha := Vslinha || Lpad(Vscodsegmentocli, 3, '0');
        -- Telefone
        Vslinha := Vslinha || Lpad(Vtcliente.Telefonecliente, 15, '0');
        -- Contato
        If Vtcliente.Fisicajuridica = 'J' Then
          Begin
            Select b.Nomerazao
              Into Vscontato
              From Ge_Pessoacontato a, Ge_Pessoa b
             Where a.Seqprincipal = Vtcliente.Seqpessoa
               And a.Tipcontato = 'COMPRADOR'
               And a.Seqpessoa = b.Seqpessoa;
          Exception
            When No_Data_Found Then
              Vscontato := ' ';
          End;
        Else
          Vscontato := ' ';
        End If;
        Vslinha := Vslinha || Rpad(Vscontato, 20, ' ');
        -- Bairro
        Vslinha := Vslinha || Rpad(Vtcliente.Bairrocliente, 20, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 41, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    Else
      --Movimento de Vendas
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               Decode(a.Fisicajuridica,
                                      'J',
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0')) As Cpfcnpjcliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Nomerazao As Nomerazaocliente,
                               (Select To_Char(b.Codatividadeedi)
                                  From Max_Ediatividade b
                                 Where b.Seqediatividade = c.Seqediatividade
                                   And c.Seqediatividade Is Not Null
                                Union All
                                Select Vscodsegmentopadraocli
                                  From Dual
                                 Where c.Seqediatividade Is Null) Codsegmentocli,
                               Nvl(a.Foneddd1 || a.Fonenro1, 0) As Telefonecliente,
                               a.Fisicajuridica,
                               a.Bairro As Bairrocliente
                          From Ge_Pessoa             a,
                               Max_Ediatividadeassoc c,
                               Maxx_Selecrowid       x
                         Where c.Indgrupoatividade(+) =
                               Vspdtipocodsegmentocli
                           And c.Grupoatividade(+) =
                               Decode(Vspdtipocodsegmentocli,
                                      'A',
                                      a.Atividade,
                                      a.Grupo)
                           And a.Seqpessoa = x.Sequencia
                           And x.Seqselecao = 4) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 14, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 8, '0');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 50, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Enderecocliente, 75, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 50, ' ');
        -- Código Segmento Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Codsegmentocli, 3, '0');
        -- Telefone
        Vslinha := Vslinha || Lpad(Vtcliente.Telefonecliente, 15, '0');
        -- Contato
        If Vtcliente.Fisicajuridica = 'J' Then
          Begin
            Select b.Nomerazao
              Into Vscontato
              From Ge_Pessoacontato a, Ge_Pessoa b
             Where a.Seqprincipal = Vtcliente.Seqpessoa
               And a.Tipcontato = 'COMPRADOR'
               And a.Seqpessoa = b.Seqpessoa;
          Exception
            When No_Data_Found Then
              Vscontato := ' ';
          End;
        Else
          Vscontato := ' ';
        End If;
        Vslinha := Vslinha || Rpad(Vscontato, 20, ' ');
        -- Bairro
        Vslinha := Vslinha || Rpad(Vtcliente.Bairrocliente, 20, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 41, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_550 - ' || Sqlerrm);
  End Sp_Gera_Cliente_550;
  Procedure Sp_Gera_Vendas_550(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                               Pddtainicial   In Date,
                               Pddtafinal     In Date,
                               Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                               Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                 Varchar2(300);
    Vscpnjempresa           Varchar2(14);
    Vncontador              Integer := 0;
    Vspdgeranfserieoe       Max_Parametro.Valor%Type := 'N';
    Vspdgerasinalnegdevcanc Max_Parametro.Valor%Type := 'N';
    Vscgobonifexp           Max_Parametro.Valor%Type := '0';
  Begin
    -- Parâmetro Dinâmico - CGOs consistidos como Bonificação na Geração do EDI
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIF_EXP',
                          'N',
                          '0',
                          'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                          Vscgobonifexp);
    If Psversaolayout = '3' Or Psversaolayout = '03' Or
       Psversaolayout = '3.1' Then
      --Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N'),
             Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_SINAL_NEGATIVO_DEVOL_CANC'),
                 'N')
        Into Vspdgeranfserieoe, Vspdgerasinalnegdevcanc
        From Dual;
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtnota In (Select a.Numerodf,
                            a.Seriedf,
                            --- enviará o código EAN, se não existir manda DUN
                            Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                    Fcodacessoprodedi(a.Seqproduto, 'D', 'N')),
                                ' ') As Codigoprod,
                            Decode(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                   Null,
                                   '02',
                                   '01') As Tipocodigoprod,
                            (Case
                              When e.Embalagem In ('UN', 'PC') Or
                                   Fcodacessoprodedi(a.Seqproduto, 'E', 'N') Is Not Null Then
                               'U'
                              When e.Embalagem = 'KG' Then
                               'K'
                              When e.Embalagem = 'CX' Then
                               'C'
                              When e.Embalagem In ('TN', 'TO') Then
                               'T'
                              Else
                               'U'
                            End) As Codunidmedida,
                            -- a quantidade e o valor unitário verificarão o código enviado
                            -- se for EAN não divide pela qtde da embalagem, se for DUN precisa dividir
                            Round(Sum(a.Quantidade /
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Null,
                                             a.Qtdembalagem,
                                             1)),
                                  3) * 1000 As Quantidade,
                            --DECODE(A.CODGERALOPER,C.CGONFBONIFICACAO,'S','N') as Bonificacao,
                            Decode(a.Indtipodescbonif,
                                   'T',
                                   'S',
                                   Findregistrobonif(a.Codgeraloper,
                                                     c.Cgonfbonificacao,
                                                     Vscgobonifexp)) As Bonificacao,
                            Round(Sum(a.Vlrcontabil /
                                      (a.Quantidade /
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                                'E',
                                                                'N'),
                                              Null,
                                              a.Qtdembalagem,
                                              1))),
                                  2) * 100 As Vlrunitario,
                            Round(Sum(a.Vlrcontabil), 2) * 100 As Vlrbruto,
                            Round(Sum(a.Vlrcontabil -
                                      (a.Vlricms + a.Vlrpis + a.Vlrcofins)),
                                  2) * 100 As Vlrliquido,
                            Round(Decode(Nvl(Sum((a.Vlrprodbruto +
                                                 a.Vlracrescimo)),
                                             0),
                                         0,
                                         0,
                                         Sum(a.Vlrdesconto * 100 /
                                             ((a.Vlrprodbruto +
                                             a.Vlracrescimo)))),
                                  2) * 100 As Percdesconto,
                            Round(Decode(Nvl(Sum(a.Vlrcontabil), 0),
                                         0,
                                         0,
                                         Sum(a.Vlricms * 100 / a.Vlrcontabil)),
                                  2) * 100 As Percicms,
                            Round(Decode(Nvl(Sum(a.Vlrcontabil), 0),
                                         0,
                                         0,
                                         Sum(a.Vlripi * 100 / a.Vlrcontabil)),
                                  2) * 100 As Percipi,
                            Round(Decode(Nvl(Sum(a.Vlrcontabil), 0),
                                         0,
                                         0,
                                         Sum((a.Vlrpis + a.Vlrcofins) * 100 /
                                             a.Vlrcontabil)),
                                  2) * 100 As Percpiscofins,
                            (Case
                              When Nvl(a.Statusdf, 'V') = 'C' Or
                                   Nvl(a.Statusitem, 'V') = 'C' Then
                               '3'
                              Else
                               Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                      'ED',
                                      '2',
                                      '1')
                            End) As Tiponotafiscal
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        And a.Seqproduto In
                            (Select x.Sequencia
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        And a.Tipnotafiscal || a.Tipdocfiscal In
                            ('ED', 'SC')
                        And ((Vspdgeranfserieoe = 'N' And
                            Nvl(d.Tipodocto, 'x') != 'O') Or
                            (Vspdgeranfserieoe = 'S'))
                      Group By a.Numerodf,
                               a.Seriedf,
                               a.Seqproduto,
                               e.Embalagem,
                               a.Tipnotafiscal || a.Tipdocfiscal,
                               Decode(a.Indtipodescbonif,
                                      'T',
                                      'S',
                                      Findregistrobonif(a.Codgeraloper,
                                                        c.Cgonfbonificacao,
                                                        Vscgobonifexp)),
                               (Case
                                 When Nvl(a.Statusdf, 'V') = 'C' Or
                                      Nvl(a.Statusitem, 'V') = 'C' Then
                                  '3'
                                 Else
                                  Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                         'ED',
                                         '2',
                                         '1')
                               End)
                      Order By a.Numerodf, a.Seriedf) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '04';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtnota.Codigoprod, 20, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtnota.Tipocodigoprod, 2, ' ');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtnota.Codunidmedida, 1, ' ');
        -- Quantidade vendida
        Vslinha := Vslinha || Lpad(Vtnota.Quantidade, 15, '0');
        -- Bonificação
        Vslinha := Vslinha || Rpad(Vtnota.Bonificacao, 1, ' ');
        -- Valor Unitário
        If Vspdgerasinalnegdevcanc = 'S' Then
          vsLinha := vsLinha || case
                       when (vtNota.tiponotafiscal = '2' or
                            vtNota.TipoNotaFiscal = '3') then
                        '-' || lpad(vtNota.VlrUnitario, 14, '0')
                       else
                        lpad(vtNota.VlrUnitario, 15, '0')
                     end;
        Else
          Vslinha := Vslinha || Lpad(Vtnota.Vlrunitario, 15, '0');
        End If;
        -- Valor total bruto
        Vslinha := Vslinha || Lpad(Vtnota.Vlrbruto, 15, '0');
        -- Valor total liquido
        Vslinha := Vslinha || Lpad(Vtnota.Vlrliquido, 15, '0');
        -- Percentual Desconto
        Vslinha := Vslinha || Lpad(Vtnota.Percdesconto, 6, '0');
        -- Percentual ICMS
        Vslinha := Vslinha || Lpad(Vtnota.Percicms, 6, '0');
        -- Percentual IPI
        Vslinha := Vslinha || Lpad(Vtnota.Percipi, 6, '0');
        -- Percentual Pis/Cofins
        Vslinha := Vslinha || Lpad(Vtnota.Percpiscofins, 6, '0');
        -- Categoria da Venda
        Vslinha := Vslinha || Rpad(' ', 3, ' ');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Filler
        If Psversaolayout = '3.1' Then
          Vslinha := Vslinha || Rpad(' ', 162, ' ');
        Else
          Vslinha := Vslinha || Rpad(' ', 167, ' ');
        End If;
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           4,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_550 - ' || Sqlerrm);
  End Sp_Gera_Vendas_550;
  Procedure Sp_Gera_Estoque_550(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pddtabase      In Date,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(500);
    Vscpnjempresa Varchar2(25);
    Vncontador    Integer := 0;
    Vspdpadraoemb Max_Parametro.Valor%Type;
  Begin
    -- Padrão de embalagem
    Sp_Buscaparamdinamico('EDINEOGRIDUNILEVER',
                          0,
                          'PADRAOEMBALAGEM',
                          'S',
                          'M',
                          'EMBALAGEM PADRAO GERACAO VENDAS ("M" - MENOR EMB. FAM. / "S" - PADRAO VENDA SEGMENTO',
                          Vspdpadraoemb);
    If Psversaolayout = '3' Or Psversaolayout = '03' Or
       Psversaolayout = '3.1' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For Vtestoque In (Select Nvl(Nvl(Fcodacessoprodedi(a.Seqproduto,
                                                         'E',
                                                         'N'),
                                       Fcodacessoprodedi(a.Seqproduto,
                                                         'D',
                                                         'N')),
                                   ' ') As Codproduto,
                               To_Char(i.dtaentradasaida, 'yyyymmdd') As Dtaestoque,
                               Round(Nvl(i.Qtdestqinicial, 0) +
                                     Nvl(i.Qtdentrada, 0) -
                                     Nvl(i.Qtdsaida, 0),
                                     3) * 1000 As Qtdeestoque,
                               (Case
                                 When c.Embalagem In ('UN', 'PC') Then
                                  'U'
                                 When c.Embalagem = 'KG' Then
                                  'K'
                                 When c.Embalagem = 'CX' Then
                                  'C'
                                 When c.Embalagem In ('TN', 'TO') Then
                                  'T'
                                 Else
                                  'U'
                               End) As Codunidmedida,
                               Decode(Fcodacessoprodedi(a.Seqproduto,
                                                        'E',
                                                        'N'),
                                      Null,
                                      '02',
                                      '01') As Tipocodprod,
                               Round(Decode(i.dtaentradasaida,
                                            Trunc(Sysdate),
                                            Nvl(h.Qtdpedrectransito, 0),
                                            0),
                                     3) * 1000 As Qtdeestoquetrans,
                               Round(h.Estqminimoloja, 3) * 1000 As Qtdeestoquemin,
                               Round(h.Estqmaximoloja, 3) * 1000 As Qtdeestoquemax
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Mrl_Custodia       i
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           and C.QTDEMBALAGEM =
                               DECODE(vsPDPadraoEmb,
                                      'S',
                                      fpadraoembvendaseg(C.SEQFAMILIA,
                                                         B.NROSEGMENTOPRINC),
                                      (Select Min(x.Qtdembalagem)
                                         From Map_Famembalagem x
                                        WHERE X.SEQFAMILIA = C.SEQFAMILIA))
                           and I.DTAENTRADASAIDA =
                               (select max(X.DTAENTRADASAIDA)
                                  From Mrl_Custodia x
                                 Where x.Seqproduto = i.Seqproduto
                                   And x.Nroempresa = i.Nroempresa
                                   And x.Dtaentradasaida <= Pddtabase)
                           and A.SEQPRODUTO IN
                               (select X.SEQUENCIA
                                  From Maxx_Selecrowid x
                                 where X.SEQSELECAO = 2)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '05';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 20, ' ');
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 8, '0');
        -- Quantidade de Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 15, '0');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtestoque.Codunidmedida, 1, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtestoque.Tipocodprod, 2, ' ');
        -- Quantidade Estoque em Transito
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquetrans, 15, '0');
        -- Quantidade Estoque Minimo
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquemin, 15, '0');
        -- Quantidade Estoque Máximo
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquemax, 15, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 207, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           5,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_550 - ' || Sqlerrm);
  End Sp_Gera_Estoque_550;
  Procedure Sp_Gera_Notasfiscais_550(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pddtainicial   In Date,
                                     Pddtafinal     In Date,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha           Varchar2(300);
    Vscpnjempresa     Varchar2(14);
    Vncontador        Integer := 0;
    Vnprazopagamento  Number;
    Vspdgeranfserieoe Max_Parametro.Valor%Type := 'N';
  Begin
    --Busca Paramentro Dinamico
    select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    If Psversaolayout = '3' Or Psversaolayout = '03' Or
       Psversaolayout = '3.1' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      For vtNota in (select distinct A.NUMERODF,
                                     a.Seriedf,
                                     To_Char(a.Dtaentrada, 'yyyymmdd') As Dtaemissao,
                                     (Case
                                       When Nvl(a.Statusdf, 'V') = 'C' Or
                                            Nvl(a.Statusitem, 'V') = 'C' Then
                                        '3'
                                       else
                                        decode(A.TIPNOTAFISCAL ||
                                               A.TIPDOCFISCAL,
                                               'ED',
                                               '2',
                                               '1')
                                     End) As Tiponotafiscal,
                                     a.Nrorepresentante As Codvendedor,
                                     DECODE(F.FISICAJURIDICA,
                                            'J',
                                            LPAD(F.NROCGCCPF ||
                                                 LPAD(F.DIGCGCCPF, 2, 0),
                                                 14,
                                                 '0'),
                                            LPAD(F.NROCGCCPF ||
                                                 LPAD(F.DIGCGCCPF, 2, 0),
                                                 11,
                                                 '0')) as CodCliente,
                                     DECODE(F.FISICAJURIDICA,
                                            'F',
                                            '01',
                                            '02') as TipoFaturamento,
                                     Decode(a.Tipofrete, 'F', 'FOB', 'CIF') As Tipofrete,
                                     a.Linkerp,
                                     h.Uf As Origemmercadoria,
                                     Regexp_Replace(h.Cep, '[^0-9]') As Ceporigem,
                                     f.Uf As Destinomerc,
                                     Regexp_Replace(f.Cep, '[^0-9]') As Cepdestino
                       From Mflv_Basedfitem  a,
                            Map_Produto      b,
                            Mad_Parametro    c,
                            Max_Empserienf   d,
                            Map_Famembalagem e,
                            Ge_Pessoa        f,
                            Map_Famfornec    g,
                            Ge_Pessoa        h
                      Where a.Nroempresa = d.Nroempresa(+)
                        And a.Seriedf = d.Serienf(+)
                        and A.SEQPRODUTO in
                            (select X.SEQUENCIA
                               From Maxx_Selecrowid x
                              Where x.Seqselecao = 2)
                        And a.Nroempresa = c.Nroempresa
                        And a.Seqproduto = b.Seqproduto
                        And a.Qtdembalagem = e.Qtdembalagem
                        And b.Seqfamilia = e.Seqfamilia
                        And a.Seqpessoa = f.Seqpessoa
                        And b.Seqfamilia = g.Seqfamilia
                        And g.Principal = 'S'
                        And g.Seqfornecedor = h.Seqpessoa
                        And a.Nroempresa = Pnnroempresa
                        And a.Dtaentrada Between Pddtainicial And Pddtafinal
                        and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                            ('ED', 'SC')
                        and ((vsPDGeraNfSerieOe = 'N' and
                            NVL(D.TIPODOCTO, 'x') != 'O') or
                            (Vspdgeranfserieoe = 'S'))
                      order by A.NUMERODF, A.SERIEDF) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '06';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
        -- Data Emissão da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Dtaemissao, 8, '0');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
        -- Código do Vendedor
        If Psversaolayout = '3.1' Then
          Vslinha := Vslinha || Rpad(Vtnota.Codvendedor, 11, ' ');
        Else
          Vslinha := Vslinha || Lpad(Vtnota.Codvendedor, 11, '0');
        End If;
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtnota.Codcliente, 14, ' ');
        -- Tipo de Faturamento
        Vslinha := Vslinha || Rpad(Vtnota.Tipofaturamento, 2, ' ');
        -- Tipo de Frete
        Vslinha := Vslinha || Rpad(Vtnota.Tipofrete, 3, ' ');
        -- Prazo de Pagamento
        Begin
          Select Nvl(Round(Avg(a.Dtavencimento - a.Dtaemissao), 0), 0)
            Into Vnprazopagamento
            From Mrl_Titulofin a
           Where a.Linkerp = Vtnota.Linkerp;
        Exception
          When No_Data_Found Then
            Vnprazopagamento := 0;
        End;
        Vslinha := Vslinha || Lpad(Vnprazopagamento, 3, '0');
        -- Origem Mercadoria
        Vslinha := Vslinha || Rpad(Vtnota.Origemmercadoria, 2, ' ');
        -- CEP Origem
        Vslinha := Vslinha || Lpad(Vtnota.Ceporigem, 8, '0');
        -- Destino Mercadoria
        Vslinha := Vslinha || Rpad(Vtnota.Destinomerc, 2, ' ');
        -- CEP Destino
        Vslinha := Vslinha || Lpad(Vtnota.Cepdestino, 8, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 212, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           6,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_NOTASFISCAIS_550 - ' || sqlerrm);
  End Sp_Gera_Notasfiscais_550;
  /*  L'oreal  - Fim */
  /************************************************************************************/
  /* Colgate 670 - Início */
  Procedure Sp_Gera_Cabecalho_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                  Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                  Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
  Begin
    if psVersaoLayout = '4' or psVersaoLayout = '04' OR
       psVersaoLayout = '4.5' then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Vslinha       := '';
      --Tipo de Registro
      Vslinha := Vslinha || '01';
      --CNPJ Distribuidor (Filial)
      Vslinha := Vslinha || Lpad(Vscpnjempresa, 14, 0);
      --Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi');
      --Versão Layout
      Vslinha := Vslinha || '04';
      --Código Indústria
      Vslinha := Vslinha || '670';
      --Filler
      Vslinha := Vslinha || Rpad(' ', 267, ' ');
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vscpnjempresa,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_CABECALHO_670 - ' || sqlerrm);
  End Sp_Gera_Cabecalho_670;
  Procedure Sp_Gera_Vendedor_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
  Begin
    if psVersaoLayout = '4' or psVersaoLayout = '04' OR
       psVersaoLayout = '4.5' then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Vendedor
      For vtVendedor in (

                         select B.NOMERAZAO as NomeRazaoRepres,
                                 --LPAD(B.NROCGCCPF,9,0)||LPAD(B.DIGCGCCPF,2,0) as NroRepresentante,
                                 FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                        'COLGATE',
                                                        'NEOGRID') as NroRepresentante,
                                 d.Nomerazao As Nomerazaosup,
                                 LPAD(D.NROCGCCPF, 9, 0) ||
                                 LPAD(D.DIGCGCCPF, 2, 0) as SeqPessoaSup,
                                 Nvl(a.Indpartclubeitt, 'N') As Indpartclubeitt,
                                 CANDAN_PEGAGERENTE(C.SEQPESSOA) AS GERENTE,
                                 CADAN_PEGAGERENTECPF(C.SEQPESSOA) AS CODIGO,
                                 case
                                   when nvl(A.INDPARTCLUBEITT, 'N') = 'N' then
                                    '20501231'
                                   else
                                    nvl(to_char(A.DTAVIGENCIACLUBEITT,
                                                'yyyymmdd'),
                                        '20501231')
                                 End As Dtavegenciaclubeitt
                           From Mad_Representante a,
                                 Ge_Pessoa         b,
                                 Mad_Equipe        c,
                                 Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            and A.NROREPRESENTANTE = 777
                         UNION ALL

                         select B.NOMERAZAO as NomeRazaoRepres,
                                 --LPAD(B.NROCGCCPF,9,0)||LPAD(B.DIGCGCCPF,2,0) as NroRepresentante,
                                 FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                        'COLGATE',
                                                        'NEOGRID') as NroRepresentante,
                                 d.Nomerazao As Nomerazaosup,
                                 LPAD(D.NROCGCCPF, 9, 0) ||
                                 LPAD(D.DIGCGCCPF, 2, 0) as SeqPessoaSup,
                                 Nvl(a.Indpartclubeitt, 'N') As Indpartclubeitt,
                                 CANDAN_PEGAGERENTE(C.SEQPESSOA) AS GERENTE,
                                 CADAN_PEGAGERENTECPF(C.SEQPESSOA) AS CODIGO,
                                 case
                                   when nvl(A.INDPARTCLUBEITT, 'N') = 'N' then
                                    '20501231'
                                   else
                                    nvl(to_char(A.DTAVIGENCIACLUBEITT,
                                                'yyyymmdd'),
                                        '20501231')
                                 End As Dtavegenciaclubeitt
                           From Mad_Representante a,
                                 Ge_Pessoa         b,
                                 Mad_Equipe        c,
                                 Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            and A.NROREPRESENTANTE in
                                (select X.SEQUENCIA
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 3)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02';
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ');
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nrorepresentante, 11, ' ');
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ');
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Seqpessoasup, 11, ' ');
        -- Filler
        -- Vslinha := Vslinha || Rpad(' ', 61, ' '); -- ajusta aqui
        --GERENTE
        Vslinha := Vslinha || Rpad(nvl(Vtvendedor.GERENTE, 0), 50, ' ');
        --CODIGO
        Vslinha := Vslinha || Rpad(nvl(Vtvendedor.CODIGO, 0), 11, ' ');

        -- Clube ITT
        Vslinha := Vslinha || Rpad(Vtvendedor.Indpartclubeitt, 1, ' ');
        -- Vigencia
        Vslinha := Vslinha || Lpad(Vtvendedor.Dtavegenciaclubeitt, 8, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 106, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_670 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_670;
  Procedure Sp_Gera_Cliente_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                Varchar2(300);
    Vscpnjempresa          Varchar2(14);
    Vncontador             Integer := 0;
    Vscodsegmentocli       Varchar2(3);
    Vscodfreqvisita        Varchar2(2);
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
    /*Vnseqfornecedor        Maf_Fornecedor.Seqfornecedor%Type;*/
    Vsbuscacodativtabint Varchar2(1);
  Begin
    if psVersaoLayout = '4' or psVersaoLayout = '04' OR
       psVersaoLayout = '4.5' then
      --Busca Paramentro Dinamico
      select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'TIPO_CODSEGMENTO_CLI'),
                 'A')
        Into Vspdtipocodsegmentocli
        From Dual;
      SP_BuscaParamDinamico('EXPORTACAO_NEOGRID',
                            0,
                            'BUSCA_CODATIV_TAB_INT',
                            'S',
                            'N',
                            'BUSCAR CÓDIGO DE ATIVIDADE DA TABELA DE INTEGRAÇÃO ? (S/N)',
                            vsBuscaCodAtivTabInt);
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      --Clientes
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               Decode(a.Fisicajuridica,
                                      'J',
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0')) As Cpfcnpjcliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente
                          From Ge_Pessoa a
                         Where a.Seqpessoa In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 4)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cpfcnpjcliente, 14, ' ');
        -- CEP Cliente
        Vslinha := Vslinha || Lpad(Vtcliente.Cepcliente, 8, '0');
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ');
        -- Cidade Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Cidadecliente, 50, ' ');
        -- Endereço Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Enderecocliente, 75, ' ');
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 50, ' ');
        -- Código Segmento Cliente
        If Vspdtipocodsegmentocli = 'G' Then
          Vscodsegmentocli := Fbuscacodsegclitente670(Vtcliente.Grupocliente);
        Else
          If (Vsbuscacodativtabint = 'S') Then
            vsCodSegmentoCli := lpad(substr(nvl(FBuscaCodAtivClitente670(vtCliente.AtividadeCliente,
                                                                         psSoftPDV),
                                                ' '),
                                            1,
                                            2),
                                     2,
                                     ' ');
          Else
            Vscodsegmentocli := Fbuscacodsegclitente670(Vtcliente.Atividadecliente);
          End If;
        End If;
        Vslinha := Vslinha || Lpad(Vscodsegmentocli, 3, '0');
        -- Frequencia de Visita
        Begin
          select case
                   when A.PERIODVISITA = 'D' or A.PERIODVISITA = 'S' then
                    '04' --semanal
                   when A.PERIODVISITA = 'Q' then
                    '02' --quinzenal
                   when A.PERIODVISITA = 'M' then
                    '01' --Mensal
                   else
                    '01'
                 End
            Into Vscodfreqvisita
            From Mad_Clienterep a, Maxx_Selecrowid x
           Where x.Seqselecao = 3 --Registro 3: Mad_Representante
             And a.Nrorepresentante = x.Sequencia
             And a.Seqpessoa = Vtcliente.Seqpessoa;
        Exception
          when no_data_found then
            Vscodfreqvisita := '01';
          When Others Then
            Vscodfreqvisita := '01';
        End;
        Vslinha := Vslinha || Lpad(Vscodfreqvisita, 2, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 94, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           3,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_670 - ' || Sqlerrm);
  End Sp_Gera_Cliente_670;
  
  Procedure Sp_Gera_Vendas_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                               Pddtainicial   In Date,
                               Pddtafinal     In Date,
                               Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                               Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                    Varchar2(5000);
    Vscpnjempresa              Varchar2(14);
    Vncontador                 Integer := 0;
    Vspdgeranfserieoe          Max_Parametro.Valor%Type := 'N';
    Vspdgerasinalnegdevcanc    Max_Parametro.Valor%Type := 'N';
    Vspdutilcodacessoprodedi   Max_Parametro.Valor%Type;
    Vspdmultvlrunitmenorembseg Max_Parametro.Valor%Type := 'S';
    Vscgobonifexp              Max_Parametro.Valor%Type := '0';
    Vsconsideranotastransf     Max_Parametro.Valor%Type := 'N';
    Vsconsideraliqoubru        Max_Parametro.Valor%Type := 'L';
    Vspdcgosadesconsiderar     Max_Parametro.Valor%Type := '0';
  Begin
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Then
       Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
       Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'MULT_VLR_UNIT_MENOR_EMB_SEG',
                            'S',
                            'S',
                            'MULTIPLICA O VALOR UNITÁRIO DO PRODUTO PELA MENOR EMBALAGEM DO SEGMENTO? (S/N) DEFAULT: S.',
                            Vspdmultvlrunitmenorembseg);
       Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'CGO_BONIF_EXP',
                            'N',
                            '0',
                            'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
							 SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                             Vscgobonifexp);
       Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            Pnnroempresa,
                            'CONSIDERA_NOTAS_TRANSFERENCIA',
                            'S',
                            'N',
                            'INFORMA SE NOTAS FISCAIS DE TRANSFERENCIA ENTRE FILIAIS SERÃO CONSIDERADAS
                          NA COMPOSIÇÃO DO REGISTRO. (S/N) DEFAULT: N.
                          OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE',
                            Vsconsideranotastransf);
       Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'CONSIDERA_VALOR_LIQ_BRU',
                            'S',
                            'L',
                            'INFORMA SE CONSIDERA O VALOR BRUTO OU O VALOR LIQUIDO
                          NA COMPOSIÇÃO DO REGISTRO. (B/L) DEFAULT: L.
                          OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE',
                            Vsconsideraliqoubru);
       Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'CGO_A_DESCONSIDERAR',
                            'S',
                            '0',
                            'INFORMAR O CGO A SER DESCONSIDERADO NA EXPORTACAO DO EDI SEPARADOS POR VIRGULA.
                            Ex.: 100, 101,... - Default: 0 (nenhum)',
                            Vspdcgosadesconsiderar);
      --Busca Paramentro Dinamico
        Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',0,'GERA_NF_SERIE_OE'),'N'),
               Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',0,'GERA_SINAL_NEGATIVO_DEVOL_CANC'),'N')
        Into Vspdgeranfserieoe, Vspdgerasinalnegdevcanc
        From Dual;
      --Busca CNPJ da Empresa
        Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
        for vEmpresas in (Select x.Sequencia as CodEmpresa
                          From Maxx_Selecrowid x
                          Where x.Seqselecao = 99) loop
			For Vtvenda In (--NUMERODF, SERIEDF, CODIGOPROD, DESCPRODUTO, QUANTIDADE, BONIFICACAO, VLRUNITARIO, VLRBRUTO, VLRLIQUIDO, TIPONOTAFISCAL
				SELECT
				   V.NRODOCTO   AS NUMERODF,
				   V.SERIEDOCTO as SERIEDF,
				   V.seqproduto AS CODIGOPROD,
				   A.DESCCOMPLETA AS DESCPRODUTO,
				   round(sum(((V.QTDITEM - V.QTDDEVOLITEM)) * (nvl(a.propqtdprodutobase, 1))),3)* 1000
				   as QUANTIDADE,
				   CASE
				   WHEN v.codgeraloper in (205) then 'S'
				   else 'N'
				   END
				   AS BONIFICACAO,
				   ROUND(fC5_Divide(round(sum(V.VLRITEM),2),round(sum(round((V.QTDITEM - V.QTDDEVOLITEM) /K.QTDEMBALAGEM,6) * (nvl(a.propqtdprodutobase, 1))),2)) / K.QTDEMBALAGEM,2) * 100
				   as VLRUNITARIO,

				   /* Incluido por Hilson Santos em 21/03/2022*/
				   sum(round(V.VLRITEM,2)+round(V.VLRDESCONTO,2)+round(V.VLRICMSST,2)) * 100
				   as VLRBRUTO,

				   /* Incluido por Hilson Santos em 21/03/2022*/
				   sum(round(V.VLRITEM,2)+round(V.VLRICMSST,2)) * 100
				   as VLRLIQUIDO,

				   CASE
				   WHEN v.codgeraloper in (220, 201, 307, 314, 598, 205)
				   THEN '1'
				   WHEN v.codgeraloper in (102, 133, 173, 177, 188, 251, 401, 402, 567, 581, 708)
				   THEN '2'
				   ELSE '1'
				   END
				   AS TIPONOTAFISCAL,

				   /* Incluido por Hilson Santos em 21/03/2022*/
				   ROUND(sum(V.VLRDESCONTO),2)*100
				   AS VLRDESCONTO
				FROM HOS_NEOGRID_COLGATE V,
					 MRL_CUSTODIAFAM Y,
					 MAP_PRODUTO A,
					 MAP_PRODUTO PB,
					 MAP_FAMDIVISAO D,
					 MAP_FAMEMBALAGEM K,
					 MAX_EMPRESA E,
					 MAX_DIVISAO DV,
					 MAP_PRODACRESCCUSTORELAC PR,
					 MRLV_DESCONTOREGRA RE
				where D.SEQFAMILIA = A.SEQFAMILIA
				and D.NRODIVISAO = V.NRODIVISAO
				and V.SEQPRODUTO = A.SEQPRODUTO
				and V.SEQPRODUTOCUSTO = PB.SEQPRODUTO
				and V.NRODIVISAO = D.NRODIVISAO
				and E.NROEMPRESA = V.NROEMPRESA
				and E.NRODIVISAO = DV.NRODIVISAO
				AND V.SEQPRODUTO = PR.SEQPRODUTO(+)
				AND V.DTAVDA = PR.DTAMOVIMENTACAO(+)
				and Y.NROEMPRESA = nvl( E.NROEMPCUSTOABC, E.NROEMPRESA )
				and Y.DTAENTRADASAIDA = V.DTAVDA
				and K.SEQFAMILIA = A.SEQFAMILIA 
				AND V.SEQPRODUTO = RE.SEQPRODUTO (+)
				AND V.DTAVDA = RE.DATAFATURAMENTO (+)
				AND V.NRODOCTO = RE.NUMERODF (+)
				AND V.SERIEDOCTO = RE.SERIEDF (+)
				AND V.NROEMPRESA = RE.NROEMPRESA (+)
				and Y.SEQFAMILIA = PB.SEQFAMILIA
				AND V.seqproduto IN (SELECT DISTINCT  D.SEQPRODUTO
									 FROM MAF_FORNECEDI A
									 INNER JOIN GE_PESSOA B ON (A.SEQFORNECEDOR = B.SEQPESSOA)
									 INNER JOIN MAP_FAMFORNEC C ON (A.SEQFORNECEDOR = C.SEQFORNECEDOR AND C.SEQFORNECEDOR = B.SEQPESSOA AND C.PRINCIPAL = 'S')
									 INNER JOIN MAP_PRODUTO D ON (D.SEQFAMILIA = C.SEQFAMILIA) 
									 WHERE A.NOMEEDI = 'COLGATE'
									 AND A.LAYOUT = 'NEOGRID')
				and DECODE(V.TIPTABELA, 'S', V.CGOACMCOMPRAVENDA, V.ACMCOMPRAVENDA) in ( 'S', 'I' )
				and V.NROEMPRESA = vEmpresas.CodEmpresa
				and V.NROSEGMENTO in ( 1, 10, 4, 5, 6, 7, 8, 9, 3 )
				and V.DTAVDA Between Pddtainicial And Pddtafinal
				and K.QTDEMBALAGEM = 1 
				group by V.NRODOCTO, V.SERIEDOCTO, V.seqproduto, v.codgeraloper, A.DESCCOMPLETA,K.QTDEMBALAGEM
				) Loop
						  Vslinha := '';
						  -- Tipo de Registro
						  Vslinha := Vslinha || '04';
						 --  Vslinha := Vslinha || ';';
						  -- Numero Nota Fiscal
						  Vslinha := Vslinha || Rpad(Vtvenda.Numerodf, 20, ' ');
						--   Vslinha := Vslinha || ';';
						  -- Serie Nota Fiscal
						  Vslinha := Vslinha || Rpad(Vtvenda.Seriedf, 3, ' ');
						--   Vslinha := Vslinha || ';';
						  -- Código do Produto
						  Vslinha := Vslinha || Rpad(Vtvenda.Codigoprod, 20, ' ');
						 --  Vslinha := Vslinha || ';';
						  -- Tipo de código do produto
						  Vslinha := Vslinha || '04';
					   --    Vslinha := Vslinha || ';';
						  -- Código da Unidade de Medida
						  Vslinha := Vslinha || 'U';
					   --    Vslinha := Vslinha || ';';
						  -- Quantidade vendida
						  Vslinha := Vslinha || Lpad(Vtvenda.Quantidade, 15, '0');
						--   Vslinha := Vslinha || ';';
						  -- Bonificação
						  Vslinha := Vslinha || Rpad(Vtvenda.Bonificacao, 1, ' ');
						--   Vslinha := Vslinha || ';';
						  -- Valor Unitário

							Vslinha := Vslinha || Lpad(Vtvenda.Vlrunitario, 15, '0');

						 --  Vslinha := Vslinha || ';';
						  -- Valor total bruto
						  Vslinha := Vslinha || Lpad(Vtvenda.Vlrbruto, 15, '0');
						 --  Vslinha := Vslinha || ';';
						  -- Valor total liquido
						  Vslinha := Vslinha || Lpad(Vtvenda.Vlrliquido, 15, '0');
						 --  Vslinha := Vslinha || ';';
						  -- Filler
						  Vslinha := Vslinha || Rpad('01', 27, ' ');      /* Alterado por Hilson Santos em 15/03/2022 */
						 --  Vslinha := Vslinha || ';';
						  -- Tipo da Nota Fiscal
						  Vslinha := Vslinha || Lpad(Vtvenda.Tiponotafiscal, 2, '0');
						  -- Vslinha := Vslinha || ';';
						  -- Filler
						  Vslinha := Vslinha || Lpad(Vtvenda.Vlrdesconto, 8, '0');   /* Alterado por Hilson Santos em 02/03/2022 */
						  -- Vslinha := Vslinha || ';';
						  -- Descrição do Produto
						  Vslinha := Vslinha || Rpad(Vtvenda.Descproduto, 50, ' ');
						  --- Vslinha := Vslinha || ';';
						  -- Filler
						  Vslinha    := Vslinha || Rpad(' ', 104, ' ');
						 --  Vslinha := Vslinha || ';';
						  Vncontador := Vncontador + 1;
						  --insert
						  Insert Into Mrlx_Pdvimportacao
							(Nroempresa,
							 Softpdv,
							 Dtamovimento,
							 Dtahorlancamento,
							 Arquivo,
							 Linha,
							 Ordem,
							 Seqlinha)
						  Values
							(Pnnroempresa,
							 Pssoftpdv,
							 Sysdate,
							 Sysdate,
							 Vscpnjempresa,
							 Vslinha,
							 4,
							 Vncontador);
			End Loop;
		End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_670 - ' || Sqlerrm);
  End Sp_Gera_Vendas_670;
  
  Procedure Sp_Gera_Estoque_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                Pddtaini       In Date,
                                Pddtafim       In Date,
                                Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha Varchar2(500);
    --vsCPNJEmpresa           varchar2(25);
    Vscpnjempresa            Varchar2(14);
    Vncontador               Integer := 0;
    Vspdfinalidaderevenda    Max_Parametro.Valor%Type;
    Vspdutilcodacessoprodedi Max_Parametro.Valor%Type;
    --   VspdAgrupEmpVirtBase     Max_Parametro.Valor%Type;
  Begin
    if psVersaoLayout = '4' or psVersaoLayout = '04' OR
       psVersaoLayout = '4.5' then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Busca PD Finalidade Familia
      Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'PERM_EXP_ARQ_NEOGRID_REVENDA',
                            'S',
                            'N',
                            'PERMITE EXPORTAR NO ARQUIVO 05 e 07 - PRODUTOS DA EDI NEOGRID,' ||
                            Chr(13) || Chr(10) ||
                            'SOMENTE PRODUTOS EM QUE A FINALIDADE DA FAMÍLIA SEJA "REVENDA"?' ||
                            Chr(13) || Chr(10) || 'S-SIM' || Chr(13) ||
                            Chr(10) || 'N-NÃO(PADRÃO)',
                            Vspdfinalidaderevenda);
      Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      /*Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID', 0, 'AGRUP_EMP_VIRTUAL_BASE', 'S', 'N',
      'INFORMA SE SERÁ AGRUPADO OS DADOS DA EMPRESA VIRTUAL COM A EMPRESA BASE,
       NA COMPOSIÇÃO DO REGISTRO. (S/N) DEFAULT: N.
       OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE', VspdAgrupEmpVirtBase);*/
      For Vtestoque In (
select

 A.SEQPRODUTO as CODPRODUTO,

 A.DESCCOMPLETA as DESCPRODUTO,
 To_Char( /*Pddtabase*/ TO_DATE(Pddtafim), 'yyyymmdd') As Dtaestoque,

 round(sum(((ESTQSELECAO) - (C.QTDRESERVADAVDA + C.QTDRESERVADARECEB)) /
           K.QTDEMBALAGEM),
       3) * 1000 as QTDEESTOQUE,
 'U' AS CODUNIDMEDIDA,
 '04' AS TIPOCODPROD,
 0 AS QTDEESTOQUETRANS

  from MAP_PRODUTO A,
       MAP_FAMILIA B,
       (select Y.SEQPRODUTO,
               Y.NROEMPRESA,
               Y.SEQCLUSTER,
               decode((ESTQSELECAO), 0, null, Y.SEQPRODUTO) SEQPRODUTOCOMESTQ,
               Y.PRECO,
               Y.MENORPRECO,
               Y.MAIORPRECO,
               Y.NROGONDOLA,
               Y.ESTQSELECAO,
               Y.QTDPENDPEDCOMPRA,
               Y.QTDPENDPEDEXPED,
               Y.QTDRESERVADAVDA,
               Y.QTDRESERVADARECEB,
               Y.QTDRESERVADAFIXA,
               Y.MEDVDIAPROMOC,
               Y.MEDVDIAGERAL,
               Y.MEDVDIAFORAPROMOC,
               Y.CMULTVLRNF,
               Y.CMULTIPI,
               Y.CMULTCREDICMS,
               Y.CMULTICMSST,
               Y.CMULTDESPNF,
               Y.CMULTDESPFORANF,
               Y.CMULTDCTOFORANF,
               nvl(Y.CMULTIMPOSTOPRESUM, 0) CMULTIMPOSTOPRESUM,
               nvl(Y.CMULTCREDICMSPRESUM, 0) CMULTCREDICMSPRESUM,
               nvl(Y.CMULTCREDICMSANTECIP, 0) CMULTCREDICMSANTECIP,
               nvl(Y.CMULTCUSLIQUIDOEMP, 0) CMULTCUSLIQUIDOEMP,
               nvl(Y.CMULTCREDICMSEMP, 0) CMULTCREDICMSEMP,
               nvl(Y.CMULTCREDPISEMP, 0) CMULTCREDPISEMP,
               nvl(Y.CMULTCREDCOFINSEMP, 0) CMULTCREDCOFINSEMP,
               nvl(Y.CMULTCREDPIS, 0) CMULTCREDPIS,
               nvl(Y.CMULTCREDCOFINS, 0) CMULTCREDCOFINS,
               Y.STATUSCOMPRA,
               Y.STATUSVENDA,
               trunc(sysdate) - Y.DTAULTENTRADA DIASULTENTRADA,
               nvl(Y.NROSEGPRODUTO, E.NROSEGMENTOPRINC) NROSEGPRODUTO,
               Y.LOCENTRADA,
               Y.LOCSAIDA,
               nvl(Y.CLASSEABASTQTD, '**Sem Classificação**') CLASSEABASTQTD,
               nvl(Y.CLASSEABASTVLR, '**Sem Classificação**') CLASSEABASTVLR,
               nvl(Y.CMULTVLRCOMPROR, 0) CMULTVLRCOMPROR,
               nvl(Y.CMULTVLRDESCPISTRANSF, 0) CMULTVLRDESCPISTRANSF,
               nvl(Y.CMULTVLRDESCCOFINSTRANSF, 0) CMULTVLRDESCCOFINSTRANSF,
               nvl(Y.CMULTVLRDESCICMSTRANSF, 0) CMULTVLRDESCICMSTRANSF,
               nvl(Y.CMULTVLRDESCLUCROTRANSF, 0) CMULTVLRDESCLUCROTRANSF,
               nvl(Y.CMULTVLRDESCIPITRANSF, 0) CMULTVLRDESCIPITRANSF,
               nvl(Y.CMULTVLRDESCVERBATRANSF, 0) CMULTVLRDESCVERBATRANSF,
               nvl(Y.CMULTVLRDESCDIFERENCATRANSF, 0) CMULTVLRDESCDIFERENCATRANSF,
               nvl(Y.CMULTCREDIPI, 0) CMULTCREDIPI,
               trunc(sysdate) - Y.DTAULTENTRCUSTO DIASULTENTRCUSTO,
               (nvl(Y.CMULTVLRDESCPISTRANSF, 0) +
               nvl(Y.CMULTVLRDESCCOFINSTRANSF, 0) +
               nvl(Y.CMULTVLRDESCICMSTRANSF, 0) +
               nvl(Y.CMULTVLRDESCIPITRANSF, 0) +
               nvl(Y.CMULTVLRDESCLUCROTRANSF, 0) +
               nvl(Y.CMULTVLRDESCVERBATRANSF, 0) +
               nvl(Y.CMULTVLRDESCDIFERENCATRANSF, 0)) VLRDESCTRANSFCB,
               Y.SEQSENSIBILIDADE,
               Y.FORMAABASTECIMENTO,
               case
                 when nvl(Y.CMULTCUSLIQUIDOEMPMRL, 0) -
                      nvl(Y.CMULTDCTOFORANFEMPMRL, 0) < 0 then
                  0
                 else
                  nvl(Y.CMULTCUSLIQUIDOEMPMRL, 0) -
                  nvl(Y.CMULTDCTOFORANFEMPMRL, 0)
               end CUSTOFISCALUNIT,

               case
                 when nvl((nvl(Y.CMULTCUSLIQUIDOEMPMRL, 0) -
                          nvl(Y.CMULTDCTOFORANFEMPMRL, 0)) * Y.ESTQEMPRESA,
                          0) < 0 then
                  0
                 else
                  nvl((nvl(Y.CMULTCUSLIQUIDOEMPMRL, 0) -
                      nvl(Y.CMULTDCTOFORANFEMPMRL, 0)) * Y.ESTQEMPRESA,
                      0)
               end CUSTOFISCALTOTAL,

               coalesce(

                        (select (CUSTOA.CMDIACUSLIQUIDOEMP -
                                nvl(CUSTOA.CMDIADCTOFORANF, 0)) *
                                (CUSTOA.QTDESTQINICIALEMP +
                                CUSTOA.QTDENTRADAEMP - CUSTOA.QTDSAIDAEMP)
                           from MRL_CUSTODIAEMP CUSTOA
                          where CUSTOA.SEQPRODUTO = Y.SEQPRODUTO
                            and CUSTOA.NROEMPRESA = Y.NROEMPRESA
                            and CUSTOA.DTAENTRADASAIDA = Pddtafim),

                        (select (CUSTOA.CMDIACUSLIQUIDOEMP -
                                nvl(CUSTOA.CMDIADCTOFORANF, 0)) *
                                (CUSTOA.QTDESTQINICIALEMP +
                                CUSTOA.QTDENTRADAEMP - CUSTOA.QTDSAIDAEMP)
                           from MRL_CUSTODIAEMP CUSTOA
                          where CUSTOA.SEQPRODUTO = Y.SEQPRODUTO
                            and CUSTOA.NROEMPRESA = Y.NROEMPRESA
                            and CUSTOA.DTAENTRADASAIDA =
                                (select max(CUSTOB.DTAENTRADASAIDA)
                                   from MRL_CUSTODIAEMP CUSTOB
                                  where CUSTOB.SEQPRODUTO = CUSTOA.SEQPRODUTO
                                    and CUSTOB.NROEMPRESA = CUSTOA.NROEMPRESA
                                    and CUSTOB.DTAENTRADASAIDA <= Pddtafim))

                        ) CUSTOFISCALTOTALDIA,

               coalesce(

                        (select (CUSTOA.CMDIACUSLIQUIDOEMP -
                                nvl(CUSTOA.CMDIADCTOFORANF, 0))
                           from MRL_CUSTODIAEMP CUSTOA
                          where CUSTOA.SEQPRODUTO = Y.SEQPRODUTO
                            and CUSTOA.NROEMPRESA = Y.NROEMPRESA
                            and CUSTOA.DTAENTRADASAIDA = Pddtafim),

                        (select (CUSTOA.CMDIACUSLIQUIDOEMP -
                                nvl(CUSTOA.CMDIADCTOFORANF, 0))
                           from MRL_CUSTODIAEMP CUSTOA
                          where CUSTOA.SEQPRODUTO = Y.SEQPRODUTO
                            and CUSTOA.NROEMPRESA = Y.NROEMPRESA
                            and CUSTOA.DTAENTRADASAIDA =
                                (select max(CUSTOB.DTAENTRADASAIDA)
                                   from MRL_CUSTODIAEMP CUSTOB
                                  where CUSTOB.SEQPRODUTO = CUSTOA.SEQPRODUTO
                                    and CUSTOB.NROEMPRESA = CUSTOA.NROEMPRESA
                                    and CUSTOB.DTAENTRADASAIDA <= Pddtafim))

                        ) CUSTOFISCALUNITDIA,

               nvl(Y.ESTQEMPRESA, 0) ESTQEMPRESA,
               Y.DTAENTRADASAIDA,
               nvl(Y.CMULTVLRDESPFIXA, 0) CMULTVLRDESPFIXA,
               nvl(Y.CMULTVLRDESCFIXO, 0) CMULTVLRDESCFIXO,
               nvl(Y.CMULTVLRDESCRESTICMSTRANSF, 0) CMULTVLRDESCRESTICMSTRANSF,

               nvl(Y.CMULTVERBACOMPRA, 0) CMULTVERBACOMPRA,
               nvl(Y.CMULTVERBABONIFINCID, 0) CMULTVERBABONIFINCID,
               nvl(Y.CMULTVERBABONIFSEMINCID, 0) CMULTVERBABONIFSEMINCID,
               nvl(Y.CMULTVLRDESCVERBATRANSFSELLIN, 0) CMULTVLRDESCVERBATRANSFSELLIN,
               nvl(Y.CENTRULTVLRNF, 0) CENTRULTVLRNF,
               nvl(Y.CENTRULTIPI, 0) CENTRULTIPI,
               nvl(Y.CENTRULTICMSST, 0) CENTRULTICMSST,
               nvl(Y.CENTRULTDESPNF, 0) CENTRULTDESPNF,
               nvl(Y.CENTRULTDESPFORANF, 0) CENTRULTDESPFORANF,
               nvl(Y.CENTRULTDCTOFORANF, 0) CENTRULTDCTOFORANF,
               nvl(Y.CENTRULTCREDICMS, 0) CENTRULTCREDICMS,
               nvl(Y.CENTRULTCREDIPI, 0) CENTRULTCREDIPI,
               nvl(Y.CENTRULTCREDPIS, 0) CENTRULTCREDPIS,
               nvl(Y.CENTRULTCREDCOFINS, 0) CENTRULTCREDCOFINS,
               nvl(Y.QENTRULTCUSTO, 0) QENTRULTCUSTO,
               Y.INDPOSICAOCATEG,
               nvl(Y.CMULTDCTOFORANFEMP, 0) CMULTDCTOFORANFEMP,
               nvl(Y.ESTQMINIMOLOJA, 0) QTDESTOQUEMINIMO,
               nvl(Y.ESTQMAXIMOLOJA, 0) QTDESTOQUEMAXIMO,
               Y.DTAULTVENDA DTAULTVENDA,
               null CLNCUSTOM1,
               null CLNCUSTOM2,
               null CLNCUSTOM3,
               null CLNCUSTOM4,
               null CLNCUSTOM5,
               null CLNCUSTOM6,
               null CLNCUSTOM7,
               null CLNCUSTOM8,
               null CLSCUSTOM9,
               null CLSCUSTOM10,
               null CLSCUSTOM11,
               null CLSCUSTOM12

          from (select CST.SEQPRODUTO,
                       CST.DTAENTRADASAIDA,
                       CST.NROEMPRESA,
                       nvl((CST.QTDESTQINICIAL + CST.QTDENTRADA -
                           CST.QTDSAIDA),
                           0) ESTQSELECAO,
                       0 QTDPENDPEDCOMPRA,
                       0 QTDPENDPEDEXPED,
                       0 QTDRESERVADAVDA,
                       0 QTDRESERVADARECEB,
                       0 QTDRESERVADAFIXA,
                       W.MEDVDIAPROMOC,
                       W.MEDVDIAGERAL,
                       W.MEDVDIAFORAPROMOC,
                       nvl(CST.CMDIAVLRNF, 0) CMULTVLRNF,
                       nvl(CST.CMDIAIPI, 0) CMULTIPI,
                       nvl(CST.CMDIACREDICMS, 0) CMULTCREDICMS,
                       nvl(CST.CMDIAICMSST, 0) CMULTICMSST,
                       nvl(CST.CMDIADESPNF, 0) CMULTDESPNF,
                       nvl(CST.CMDIADESPFORANF, 0) CMULTDESPFORANF,
                       nvl(CST.CMDIADCTOFORANF, 0) CMULTDCTOFORANF,
                       nvl(CST.CMULTIMPOSTOPRESUM, 0) CMULTIMPOSTOPRESUM,
                       nvl(CST.CMDIACREDICMSPRESUM, 0) CMULTCREDICMSPRESUM,
                       nvl(CST.CMDIACREDICMSANTECIP, 0) CMULTCREDICMSANTECIP,
                       0 CMULTCREDICMSEMP,
                       0 CMULTCREDPISEMP,
                       0 CMULTCREDCOFINSEMP,
                       nvl(CST.CMDIACREDPIS, 0) CMULTCREDPIS,
                       nvl(CST.CMDIACREDCOFINS, 0) CMULTCREDCOFINS,
                       W.STATUSCOMPRA,
                       W.DTAULTENTRADA,
                       W.NROSEGPRODUTO,
                       W.NROGONDOLA,
                       W.LOCENTRADA,
                       W.LOCSAIDA,
                       nvl(decode(CST.QTDVDA,
                                  0,
                                  FProdSegPrecoData(CST.SEQPRODUTO,
                                                    null,
                                                    null,
                                                    CST.NROEMPRESA,
                                                    CST.DTAENTRADASAIDA),
                                  round(CST.VLRTOTALVDA / CST.QTDVDA, 2)),
                           0) PRECO,
                       nvl(decode(CST.QTDVDA,
                                  0,
                                  CST.VLRTOTALVDA,
                                  round(CST.VLRTOTALVDA / CST.QTDVDA, 2)),
                           0) MENORPRECO,
                       nvl(decode(CST.QTDVDA,
                                  0,
                                  CST.VLRTOTALVDA,
                                  round(CST.VLRTOTALVDA / CST.QTDVDA, 2)),
                           0) MAIORPRECO,
                       'A' STATUSVENDA,
                       W.CLASSEABASTQTD,
                       W.CLASSEABASTVLR,
                       W.CMULTVLRCOMPROR,
                       nvl(CST.CMDIAVLRDESCPISTRANSF, 0) CMULTVLRDESCPISTRANSF,
                       nvl(CST.CMDIAVLRDESCCOFINSTRANSF, 0) CMULTVLRDESCCOFINSTRANSF,
                       nvl(CST.CMDIAVLRDESCICMSTRANSF, 0) CMULTVLRDESCICMSTRANSF,
                       W.DTAULTENTRCUSTO,
                       W.INDAVALINCLUSAO,
                       nvl(CST.CMDIACREDIPI, 0) CMULTCREDIPI,
                       nvl(CST.CMDIAVLRDESCIPITRANSF, 0) CMULTVLRDESCIPITRANSF,
                       nvl(CST.CMDIAVLRDESCLUCROTRANSF, 0) CMULTVLRDESCLUCROTRANSF,
                       nvl(CST.CMDIAVLRDESCVERBATRANSF, 0) CMULTVLRDESCVERBATRANSF,
                       nvl(CST.CMDIAVLRDESCDIFERENCATRANSF, 0) CMULTVLRDESCDIFERENCATRANSF,
                       nvl(CST.CMDIAVLRDESCRESTICMSTRANSF, 0) CMULTVLRDESCRESTICMSTRANSF,
                       0 CMULTCREDIPIEMP,
                       nvl((CST.CMDIAVLRDESCPISTRANSF +
                           CST.CMDIAVLRDESCCOFINSTRANSF +
                           CST.CMDIAVLRDESCICMSTRANSF +
                           CST.CMDIAVLRDESCIPITRANSF +
                           CST.CMDIAVLRDESCLUCROTRANSF +
                           CST.CMDIAVLRDESCVERBATRANSF +
                           CST.CMDIAVLRDESCDIFERENCATRANSF),
                           0) VLRDESCTRANSFCB,
                       W.SEQSENSIBILIDADE,
                       W.FORMAABASTECIMENTO,
                       nvl(CST.CMDIACUSLIQUIDOEMP, 0) CMULTCUSLIQUIDOEMP,
                       nvl(CST.CMDIADCTOFORANFEMP, 0) CMULTDCTOFORANFEMP,
                       coalesce(

                                (select NVL((CUSTOA.QTDESTQINICIALEMP +
                                            CUSTOA.QTDENTRADAEMP -
                                            CUSTOA.QTDSAIDAEMP),
                                            0)
                                   from MRL_CUSTODIAEMP CUSTOA
                                  where CUSTOA.SEQPRODUTO = CST.SEQPRODUTO
                                    and CUSTOA.NROEMPRESA = CST.NROEMPRESA
                                    and CUSTOA.DTAENTRADASAIDA = Pddtafim),

                                (select NVL((CUSTOA.QTDESTQINICIALEMP +
                                            CUSTOA.QTDENTRADAEMP -
                                            CUSTOA.QTDSAIDAEMP),
                                            0)
                                   from MRL_CUSTODIAEMP CUSTOA
                                  where CUSTOA.SEQPRODUTO = CST.SEQPRODUTO
                                    and CUSTOA.NROEMPRESA = CST.NROEMPRESA
                                    and CUSTOA.DTAENTRADASAIDA =
                                        (select max(CUSTOB.DTAENTRADASAIDA)
                                           from MRL_CUSTODIAEMP CUSTOB
                                          where CUSTOB.SEQPRODUTO =
                                                CUSTOA.SEQPRODUTO
                                            and CUSTOB.NROEMPRESA =
                                                CUSTOA.NROEMPRESA
                                            and CUSTOB.DTAENTRADASAIDA <=
                                                Pddtafim))

                                ) AS ESTQEMPRESA,
                       nvl(CST.CMDIAVLRDESCFIXO, 0) CMULTVLRDESCFIXO,
                       nvl(CST.CMDIAVLRDESPFIXA, 0) CMULTVLRDESPFIXA,
                       W.SEQCLUSTER,
                       fPadraoEmbVenda2(CST.SEQFAMILIA, '1') QTDEMBALAGEMSEG,
                       W.ESTQLOJA,
                       W.ESTQDEPOSITO,
                       W.ESTQTROCA,
                       W.ESTQALMOXARIFADO,
                       W.ESTQOUTRO,
                       nvl(W.ESTQTERCEIRO, 0) ESTQTERCEIRO,
                       nvl(CST.CMDIAVERBACOMPRA, 0) CMULTVERBACOMPRA,
                       nvl(CST.CMDIAVERBABONIFINCID, 0) CMULTVERBABONIFINCID,
                       nvl(CST.CMDIAVERBABONIFSEMINCID, 0) CMULTVERBABONIFSEMINCID,
                       nvl(CST.CMDIAVLRDESCVERBATRANSFSELLIN, 0) CMULTVLRDESCVERBATRANSFSELLIN,
                       nvl(W.CENTRULTVLRNF, 0) CENTRULTVLRNF,
                       nvl(W.CENTRULTIPI, 0) CENTRULTIPI,
                       nvl(W.CENTRULTICMSST, 0) CENTRULTICMSST,
                       nvl(W.CENTRULTDESPNF, 0) CENTRULTDESPNF,
                       nvl(W.CENTRULTDESPFORANF, 0) CENTRULTDESPFORANF,
                       nvl(W.CENTRULTDCTOFORANF, 0) CENTRULTDCTOFORANF,
                       nvl(W.CENTRULTCREDICMS, 0) CENTRULTCREDICMS,
                       nvl(W.CENTRULTCREDIPI, 0) CENTRULTCREDIPI,
                       nvl(W.CENTRULTCREDPIS, 0) CENTRULTCREDPIS,
                       nvl(W.CENTRULTCREDCOFINS, 0) CENTRULTCREDCOFINS,
                       nvl(W.QENTRULTCUSTO, 0) QENTRULTCUSTO,
                       W.INDPOSICAOCATEG,
                       nvl(W.ESTQMINIMOLOJA, 0) ESTQMINIMOLOJA,
                       nvl(W.ESTQMAXIMOLOJA, 0) ESTQMAXIMOLOJA,
                       W.DTAULTVENDA DTAULTVENDA,
                       nvl(W.CMULTCUSLIQUIDOEMP, 0) CMULTCUSLIQUIDOEMPMRL,
                       nvl(W.CMULTDCTOFORANFEMP, 0) CMULTDCTOFORANFEMPMRL

                  from (select XX.S_RANK,
                               XX.SEQPRODUTO,
                               XX.DTAENTRADASAIDA,
                               XX.NROEMPRESA,
                               XX.QTDESTQINICIAL,
                               XX.QTDENTRADA,
                               XX.QTDSAIDA,
                               nvl(XX.QTDSAIDAMEDVENDA, 0) as QTDSAIDAMEDVENDA,
                               Z.QENTRCUSTO,
                               Z.CENTRVLRNF,
                               Z.CENTRIPI,
                               nvl(Z.CENTRCREDIPI, 0) as CENTRCREDIPI,
                               Z.CENTRCREDICMS,
                               Z.CENTRICMSST,
                               Z.CENTRDESPNF,
                               Z.CENTRDESPFORANF,
                               Z.CENTRDCTOFORANF,
                               nvl(Z.CENTRCREDICMSPRESUM, 0) as CENTRCREDICMSPRESUM,
                               nvl(Z.CENTRCREDICMSANTECIP, 0) as CENTRCREDICMSANTECIP,
                               nvl(Z.CENTRCREDPIS, 0) as CENTRCREDPIS,
                               nvl(Z.CENTRCREDCOFINS, 0) as CENTRCREDCOFINS,
                               Z.CMDIAVLRNF,
                               Z.CMDIAIPI,
                               Z.CMDIACREDICMS,
                               Z.CMDIAICMSST,
                               Z.CMDIADESPNF,
                               Z.CMDIADESPFORANF,
                               Z.CMDIADCTOFORANF,
                               nvl(Z.CMDIACREDICMSPRESUM, 0) as CMDIACREDICMSPRESUM,
                               nvl(Z.CMDIACREDICMSANTECIP, 0) as CMDIACREDICMSANTECIP,
                               nvl(Z.CMDIACREDPIS, 0) as CMDIACREDPIS,
                               nvl(Z.CMDIACREDCOFINS, 0) as CMDIACREDCOFINS,
                               Z.QTDCOMPRA,
                               Z.VLRTOTALCOMPRA,
                               Z.QTDVDA,
                               Z.VLRTOTALVDA,
                               Z.VLRCUSLIQUIDOVDA,
                               nvl(Z.VLRCUSBRUTOVDA, 0) as VLRCUSBRUTOVDA,
                               Z.VLRICMSVDA,
                               Z.VLRIMPOSTOVDA,
                               Z.VLRDESPESAVDA,
                               Z.VLRCOMISSAOVDA,
                               nvl(Z.VLRDESCFORANFVDA, 0) as VLRDESCFORANFVDA,
                               nvl(Z.VLRIPIVDA, 0) as VLRIPIVDA,
                               nvl(Z.VLRISSVDA, 0) as VLRISSVDA,
                               nvl(Z.VLRPISVDA, 0) as VLRPISVDA,
                               nvl(Z.VLRCOFINSVDA, 0) as VLRCOFINSVDA,
                               XX.NRONFCUPOMEMITIDO,
                               Z.QTDVERBAVDA,
                               Z.VLRVERBAVDA,
                               Z.QTDVERBAOUTSAI,
                               Z.VLRVERBAOUTSAI,
                               Z.SEQFAMILIA,
                               nvl(Z.CMDIACREDIPI, 0) as CMDIACREDIPI,
                               nvl(Z.CMDIAVLRDESPFIXA, 0) as CMDIAVLRDESPFIXA,
                               nvl(Z.CMDIAVLRDESCFIXO, 0) as CMDIAVLRDESCFIXO,
                               nvl(Z.CMDIACUSLIQUIDOEMP, 0) as CMDIACUSLIQUIDOEMP,
                               nvl(Z.CMDIADCTOFORANFEMP, 0) as CMDIADCTOFORANFEMP,
                               nvl(Z.CMDIAVLRDESCDIFERENCATRANSF, 0) as CMDIAVLRDESCDIFERENCATRANSF,
                               nvl(Z.CMDIAVLRDESCVERBATRANSF, 0) as CMDIAVLRDESCVERBATRANSF,
                               nvl(Z.CMDIAVLRDESCLUCROTRANSF, 0) as CMDIAVLRDESCLUCROTRANSF,
                               nvl(Z.CMDIAVLRDESCIPITRANSF, 0) as CMDIAVLRDESCIPITRANSF,
                               nvl(Z.CMDIAVLRDESCICMSTRANSF, 0) as CMDIAVLRDESCICMSTRANSF,
                               nvl(Z.CMDIAVLRDESCCOFINSTRANSF, 0) as CMDIAVLRDESCCOFINSTRANSF,
                               nvl(Z.CMDIAVLRDESCPISTRANSF, 0) as CMDIAVLRDESCPISTRANSF,
                               nvl(Z.CMDIAVLRDESCRESTICMSTRANSF, 0) as CMDIAVLRDESCRESTICMSTRANSF,
                               NVL(Z.CMDIAVERBACOMPRA, 0) as CMDIAVERBACOMPRA,
                               NVL(Z.CMDIAVERBABONIFINCID, 0) as CMDIAVERBABONIFINCID,
                               NVL(Z.CMDIAVERBABONIFSEMINCID, 0) as CMDIAVERBABONIFSEMINCID,
                               NVL(Z.CMDIAVLRDESCVERBATRANSFSELLIN, 0) as CMDIAVLRDESCVERBATRANSFSELLIN,
                               NVL(Z.CMULTIMPOSTOPRESUM, 0) as CMULTIMPOSTOPRESUM
                          from (select rank() over(partition by Y.NROEMPRESA, Y.SEQPRODUTO order by Y.NROEMPRESA, Y.SEQPRODUTO, Y.DTAENTRADASAIDA desc) as S_RANK,
                                       Y.SEQPRODUTO,
                                       max(Y.DTAENTRADASAIDA) over(partition by Y.NROEMPRESA, Y.SEQFAMILIA order by Y.NROEMPRESA, Y.SEQFAMILIA, Y.DTAENTRADASAIDA desc) as DTAENTRADASAIDA,
                                       Y.NROEMPRESA,
                                       Y.QTDESTQINICIAL,
                                       Y.QTDENTRADA,
                                       Y.QTDSAIDA,
                                       nvl(Y.QTDSAIDAMEDVENDA, 0) as QTDSAIDAMEDVENDA,
                                       Y.NRONFCUPOMEMITIDO,
                                       Y.QTDVERBAVDA,
                                       Y.VLRVERBAVDA,
                                       Y.QTDVERBAOUTSAI,
                                       Y.VLRVERBAOUTSAI,
                                       Y.SEQFAMILIA
                                  from MRL_CUSTODIA Y
                                 where Y.NROEMPRESA = Pnnroempresa
                                   and Y.DTAENTRADASAIDA <= Pddtafim

                                   and Y.SEQFAMILIA in
                                       (select SEQFAMILIA
                                          from MAP_FAMFORNEC
                                         where SEQFORNECEDOR in
                                               (7623, 7614, 37624, 20966, 7564)
                                           and PRINCIPAL = 'S')) XX,
                               MRL_CUSTODIAFAM Z
                         where Z.SEQFAMILIA = XX.SEQFAMILIA
                           and Z.NROEMPRESA = XX.NROEMPRESA
                           and Z.DTAENTRADASAIDA = XX.DTAENTRADASAIDA
                           and S_RANK = 1) CST,
                       MRL_PRODUTOEMPRESA W

                 where CST.S_RANK = 1
                   and CST.NROEMPRESA = Pnnroempresa
                   and CST.DTAENTRADASAIDA <= Pddtafim
                   and W.NROEMPRESA = CST.NROEMPRESA
                   and W.SEQPRODUTO = CST.SEQPRODUTO) Y,
               MAX_EMPRESA E
         where E.NROEMPRESA = Y.NROEMPRESA

           and Y.SEQPRODUTO in
               (select FF.SEQPRODUTO
                  from MAP_PRODUTO FF
                 where FF.SEQFAMILIA in
                       (select SEQFAMILIA
                          from MAP_FAMFORNEC
                         where SEQFORNECEDOR in
                               (7623, 7614, 37624, 20966, 7564)
                           and PRINCIPAL = 'S'))

        ) C,
       MAP_FAMDIVISAO D,
       MAP_FAMEMBALAGEM K,
       MAX_EMPRESA E,
       MAD_PARAMETRO J3,
       MAX_DIVISAO I2,
       MAP_CLASSIFABC Z2,
       MAD_FAMSEGMENTO H,
       MAP_TRIBUTACAOUF T3,
       MAPV_PISCOFINSTRIBUT SS,
       MAD_SEGMENTO SE,
       MAP_PRODACRESCCUSTORELAC PR,
       MAP_FAMDIVCATEG FDC,
       map_categoria cat
 where A.SEQPRODUTO = C.SEQPRODUTO
   and B.SEQFAMILIA = A.SEQFAMILIA
   and C.NROEMPRESA = Pnnroempresa
   and D.SEQFAMILIA = A.SEQFAMILIA
   and D.NRODIVISAO = E.NRODIVISAO
   and K.SEQFAMILIA = D.SEQFAMILIA
   and K.QTDEMBALAGEM = 1
   and E.NROEMPRESA = C.NROEMPRESA
   and J3.NROEMPRESA = E.NROEMPRESA
   and I2.NRODIVISAO = E.NRODIVISAO
   and I2.NRODIVISAO = D.NRODIVISAO
   and Z2.NROSEGMENTO = H.NROSEGMENTO
   and Z2.CLASSIFCOMERCABC = H.CLASSIFCOMERCABC
   and Z2.NROSEGMENTO = SE.NROSEGMENTO
   and T3.NROTRIBUTACAO = D.NROTRIBUTACAO
   and T3.UFEMPRESA = nvl(E.UFFORMACAOPRECO, E.UF)
   and T3.UFCLIENTEFORNEC = E.UF
   and T3.TIPTRIBUTACAO = decode(I2.TIPDIVISAO, 'V', 'SN', 'SC')
   and T3.NROREGTRIBUTACAO = nvl(E.NROREGTRIBUTACAO, 0)
   and a.seqfamilia = fdc.seqfamilia
   and fdc.nrodivisao = e.nrodivisao
   and fdc.seqcategoria = cat.seqcategoria
   and fdc.nrodivisao = cat.nrodivisao
   and b.seqfamilia = a.seqfamilia
   and b.seqfamilia = fdc.seqfamilia
   and cat.nivelhierarquia = 1
   and cat.statuscategor in ('A', 'F')
   and fdc.status = 'A'
   and cat.tipcategoria = 'M'
   and C.SEQPRODUTO = PR.SEQPRODUTO(+)
   and C.DTAENTRADASAIDA = PR.DTAMOVIMENTACAO(+)
   and SS.NROEMPRESA = E.NROEMPRESA
   and SS.NROTRIBUTACAO = T3.NROTRIBUTACAO
   and SS.UFEMPRESA = T3.UFEMPRESA
   and SS.UFCLIENTEFORNEC = T3.UFCLIENTEFORNEC
   and SS.TIPTRIBUTACAO = T3.TIPTRIBUTACAO
   and SS.NROREGTRIBUTACAO = T3.NROREGTRIBUTACAO
   and SS.SEQFAMILIA = B.SEQFAMILIA
   and H.SEQFAMILIA = A.SEQFAMILIA
   and H.NROSEGMENTO = E.NROSEGMENTOPRINC
   AND A.SEQFAMILIA IN (SELECT C.SEQFAMILIA
                             FROM MAF_FORNECEDI A
                            INNER JOIN GE_PESSOA B
                               ON (A.SEQFORNECEDOR = B.SEQPESSOA)
                            INNER JOIN MAP_FAMFORNEC C
                               ON (A.SEQFORNECEDOR = C.SEQFORNECEDOR AND
                                  C.SEQFORNECEDOR = B.SEQPESSOA AND
                                  C.PRINCIPAL = 'S')
                            INNER JOIN MAP_PRODUTO D
                               ON (D.SEQFAMILIA = C.SEQFAMILIA)
                            WHERE A.NOMEEDI = Pssoftpdv
                              AND A.LAYOUT = 'NEOGRID'
                              AND D.SEQPRODUTO = A.SEQPRODUTO)
 group by A.SEQPRODUTO,
          A.DESCCOMPLETA,
          K.QTDEMBALAGEM,
          K.EMBALAGEM || ' ' || K.QTDEMBALAGEM,
          K.LITROS


                         ) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '05';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 20, ' ');
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 8, '0');
        -- Quantidade de Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 15, '0');
        -- Código da Unidade de Medida
        Vslinha := Vslinha || Rpad(Vtestoque.Codunidmedida, 1, ' ');
        -- Tipo de código do produto
        Vslinha := Vslinha || Rpad(Vtestoque.Tipocodprod, 2, ' ');
        -- Filler
        Vslinha := Vslinha || Rpad(' ', 45, ' ');
        -- Descrição do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Descproduto, 50, ' ');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 157, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           5,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_670 - ' || Sqlerrm);
  End Sp_Gera_Estoque_670;

  Procedure Sp_Gera_Notasfiscais_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pddtainicial   In Date,
                                     Pddtafinal     In Date,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscpnjempresa Varchar2(14);
    Vncontador    Integer := 0;
    /*Vnprazopagamento       Number;*/
    Vspdgeranfserieoe      Max_Parametro.Valor%Type := 'N';
    Vsconsideranotastransf Max_Parametro.Valor%Type := 'N';
    vsCGOBonifExp          max_parametro.valor%type := '0';
    Vspdcgosadesconsiderar Max_Parametro.Valor%Type := '0';
    --   VspdAgrupEmpVirtBase   Max_Parametro.Valor%Type;
  Begin
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          Pnnroempresa,
                          'CONSIDERA_NOTAS_TRANSFERENCIA',
                          'S',
                          'N',
                          'INFORMA SE NOTAS FISCAIS DE TRANSFERENCIA ENTRE FILIAIS SERÃO CONSIDERADAS
                          NA COMPOSIÇÃO DO REGISTRO. (S/N) DEFAULT: N.
                          OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE',
                          Vsconsideranotastransf);
    SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIF_EXP',
                          'N',
                          '0',
                          'INFORMA QUAIS CGOS PODERÃO SER UTILIZADOS PARA CONSISTIR COMO BONIFICAÇÃO NO REGISTRO DO ARQUIVO GERADO. OS CGOS INFORMADOS
SERÃO CONSISTIDOS EM CONJUNTO COM O CGO INFORMADO NO PARÂMETRO DA EMPRESA. INFORMAR OS CGOS SEPARADOS POR VIRGULA. DEFAULT: 0',
                          vsCGOBonifExp);
    SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_A_DESCONSIDERAR',
                          'S',
                          '0',
                          'INFORMAR O CGO A SER DESCONSIDERADO NA EXPORTACAO DO EDI SEPARADOS POR VIRGULA.
Ex.: 100, 101,... - Default: 0 (nenhum)',
                          Vspdcgosadesconsiderar);
    /* Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID', 0, 'AGRUP_EMP_VIRTUAL_BASE', 'S', 'N',
    'INFORMA SE SERÁ AGRUPADO OS DADOS DA EMPRESA VIRTUAL COM A EMPRESA BASE,
     NA COMPOSIÇÃO DO REGISTRO. (S/N) DEFAULT: N.
     OPÇÃO DISPONÍVEL APENAS PARA O FORNECEDOR COLGATE', VspdAgrupEmpVirtBase);*/
    --Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Then
      --Busca CNPJ da Empresa
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      for vEmpresas in (Select x.Sequencia as CodEmpresa
                          From Maxx_Selecrowid x
                         Where x.Seqselecao = 99) Loop
        For Vtnota In (select DISTINCT V.NRODOCTO AS NRODF,
       V.NRODOCTO AS NUMERODF,
       V.SERIEDOCTO as SERIEDF,
       TO_CHAR(V.dtavda,'RRRRMMDD') AS DTAEMISSAO,
       CASE
         WHEN v.codgeraloper in (220, 201, 307, 314, 598, 205) then
          '1'
         else
          '1'
       END AS TIPONOTAFISCAL,
       Fbuscacpfrepresentante(V.Nrorepresentante, 'COLGATE', 'NEOGRID') As CODVENDEDOR,
       cadan_cpfcnpj(V.seqpessoa) AS CODCLIENTE

  from MAXV_ABCDISTRIBBASE      V,
       MRL_CUSTODIAFAM          Y,
       MAP_PRODUTO              A,
       MAP_PRODUTO              PB,
       MAP_FAMDIVISAO           D,
       MAP_FAMEMBALAGEM         K,
       MAX_EMPRESA              E,
       MAX_DIVISAO              DV,
       MAP_PRODACRESCCUSTORELAC PR,
       MRLV_DESCONTOREGRA       RE
 where D.SEQFAMILIA = A.SEQFAMILIA
   and D.NRODIVISAO = V.NRODIVISAO
   and V.SEQPRODUTO = A.SEQPRODUTO
   and V.SEQPRODUTOCUSTO = PB.SEQPRODUTO
   and V.NROEMPRESA = Pnnroempresa
   and V.NROSEGMENTO in (1, 10, 4, 5, 6, 7, 8, 9, 3)
   and V.NRODIVISAO = D.NRODIVISAO
   and E.NROEMPRESA = V.NROEMPRESA
   and E.NRODIVISAO = DV.NRODIVISAO
   AND V.SEQPRODUTO = PR.SEQPRODUTO(+)
   AND V.DTAVDA = PR.DTAMOVIMENTACAO(+)
   and V.DTAVDA Between Pddtainicial And Pddtafinal
   and Y.NROEMPRESA = nvl(E.NROEMPCUSTOABC, E.NROEMPRESA)
   and Y.DTAENTRADASAIDA = V.DTAVDA
   and K.SEQFAMILIA = A.SEQFAMILIA
   and K.QTDEMBALAGEM = fpadraoembvenda(a.seqfamilia, 1)
   AND V.SEQPRODUTO = RE.SEQPRODUTO(+)
   AND V.DTAVDA = RE.DATAFATURAMENTO(+)
   AND V.NRODOCTO = RE.NUMERODF(+)
   AND V.SERIEDOCTO = RE.SERIEDF(+)
   AND V.NROEMPRESA = RE.NROEMPRESA(+)
   AND v.codgeraloper in (220, 201, 307, 314, 598, 205)
   and Y.SEQFAMILIA = PB.SEQFAMILIA
 --  AND V.seqproduto IN (37474, 39484, 39415, 38929, 39)
   AND V.seqproduto IN
       (SELECT DISTINCT DD.SEQPRODUTO
          FROM MAF_FORNECEDI A
         INNER JOIN GE_PESSOA B
            ON (A.SEQFORNECEDOR = B.SEQPESSOA)
         INNER JOIN MAP_FAMFORNEC C
            ON (A.SEQFORNECEDOR = C.SEQFORNECEDOR AND
               C.SEQFORNECEDOR = B.SEQPESSOA AND C.PRINCIPAL = 'S')
         INNER JOIN MAP_PRODUTO DD
            ON (DD.SEQFAMILIA = C.SEQFAMILIA)
         WHERE A.NOMEEDI = 'COLGATE'
           AND A.LAYOUT = 'NEOGRID')
   and DECODE(V.TIPTABELA, 'S', V.CGOACMCOMPRAVENDA, V.ACMCOMPRAVENDA) in
       ('S', 'I')

/*   and exists
(select 1
         from MAP_FAMFORNEC
        where SEQFORNECEDOR in (7623, 7614, 37624, 20966, 7564)
          and PRINCIPAL = 'S'
          and MAP_FAMFORNEC.SEQFAMILIA = A.SEQFAMILIA)*/


---
UNION ALL

--NUMERODF, SERIEDF, CODIGOPROD, DESCPRODUTO, QUANTIDADE, BONIFICACAO, VLRUNITARIO, VLRBRUTO, VLRLIQUIDO, TIPONOTAFISCAL
select DISTINCT  V.NRODOCTO AS NRODF,
V.NRODOCTO AS NUMERODF,
       V.SERIEDOCTO as SERIEDF,
         TO_CHAR(V.dtavda,'RRRRMMDD') AS DTAEMISSAO,
       CASE
         WHEN v.codgeraloper in (220, 201, 307, 314, 598, 205) then
          '2'
         else
          '2'
       END AS TIPONOTAFISCAL,
       Fbuscacpfrepresentante(V.Nrorepresentante, 'COLGATE', 'NEOGRID') As CODVENDEDOR,
       cadan_cpfcnpj(V.seqpessoa) AS CODCLIENTE

  from MAXV_ABCDISTRIBBASE      V,
       MRL_CUSTODIAFAM          Y,
       MAP_PRODUTO              A,
       MAP_PRODUTO              PB,
       MAP_FAMDIVISAO           D,
       MAP_FAMEMBALAGEM         K,
       MAX_EMPRESA              E,
       MAX_DIVISAO              DV,
       MAP_PRODACRESCCUSTORELAC PR,
       MRLV_DESCONTOREGRA       RE
 where D.SEQFAMILIA = A.SEQFAMILIA
   and D.NRODIVISAO = V.NRODIVISAO
   and V.SEQPRODUTO = A.SEQPRODUTO
   and V.SEQPRODUTOCUSTO = PB.SEQPRODUTO
   and V.NROEMPRESA = Pnnroempresa
   and V.NROSEGMENTO in (1, 10, 4, 5, 6, 7, 8, 9, 3)
   and V.NRODIVISAO = D.NRODIVISAO
   and E.NROEMPRESA = V.NROEMPRESA
   and E.NRODIVISAO = DV.NRODIVISAO
   AND V.SEQPRODUTO = PR.SEQPRODUTO(+)
   AND V.DTAVDA = PR.DTAMOVIMENTACAO(+)
   and V.DTAVDA Between Pddtainicial And Pddtafinal
   and Y.NROEMPRESA = nvl(E.NROEMPCUSTOABC, E.NROEMPRESA)
   and Y.DTAENTRADASAIDA = V.DTAVDA
   and K.SEQFAMILIA = A.SEQFAMILIA
   and K.QTDEMBALAGEM = 1
   AND V.SEQPRODUTO = RE.SEQPRODUTO(+)
   AND V.DTAVDA = RE.DATAFATURAMENTO(+)
   AND V.NRODOCTO = RE.NUMERODF(+)
   AND V.SERIEDOCTO = RE.SERIEDF(+)
   AND V.NROEMPRESA = RE.NROEMPRESA(+)
   and Y.SEQFAMILIA = PB.SEQFAMILIA
   AND V.seqproduto IN
       (SELECT DISTINCT D.SEQPRODUTO
          FROM MAF_FORNECEDI A
         INNER JOIN GE_PESSOA B
            ON (A.SEQFORNECEDOR = B.SEQPESSOA)
         INNER JOIN MAP_FAMFORNEC C
            ON (A.SEQFORNECEDOR = C.SEQFORNECEDOR AND
               C.SEQFORNECEDOR = B.SEQPESSOA AND C.PRINCIPAL = 'S')
         INNER JOIN MAP_PRODUTO D
            ON (D.SEQFAMILIA = C.SEQFAMILIA)
         WHERE A.NOMEEDI = 'COLGATE'
           AND A.LAYOUT = 'NEOGRID')

   and V.QTDDEVOLITEM != 0
   and DECODE(V.TIPTABELA, 'S', V.CGOACMCOMPRAVENDA, V.ACMCOMPRAVENDA) in
       ('S', 'I')) Loop
          Vslinha := '';
          -- Tipo de Registro
          Vslinha := Vslinha || '06';
          -- Numero Nota Fiscal
          Vslinha := Vslinha || Rpad(Vtnota.Numerodf, 20, ' ');
          -- Serie Nota Fiscal
          Vslinha := Vslinha || Rpad(Vtnota.Seriedf, 3, ' ');
          -- Data Emissão da Nota Fiscal
          Vslinha := Vslinha || Lpad(Vtnota.Dtaemissao, 8, '0');
          -- Tipo da Nota Fiscal
          Vslinha := Vslinha || Lpad(Vtnota.Tiponotafiscal, 2, '0');
          -- Código do Vendedor
          Vslinha := Vslinha || Rpad(Vtnota.Codvendedor, 11, ' ');
          -- Código Cliente
          Vslinha := Vslinha || Rpad(Vtnota.Codcliente, 14, ' ');
          -- Filler
          Vslinha    := Vslinha || Rpad(' ', 240, ' ');
          Vncontador := Vncontador + 1;
          --insert
          Insert Into Mrlx_Pdvimportacao
            (Nroempresa,
             Softpdv,
             Dtamovimento,
             Dtahorlancamento,
             Arquivo,
             Linha,
             Ordem,
             Seqlinha)
          Values
            (Pnnroempresa,
             Pssoftpdv,
             Sysdate,
             Sysdate,
             Vscpnjempresa,
             Vslinha,
             6,
             Vncontador);
        End Loop;
      end Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_NOTASFISCAIS_670 - ' || sqlerrm);
  End Sp_Gera_Notasfiscais_670;

  Procedure Sp_Gera_Produtos_670(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                  Varchar2(300);
    Vscpnjempresa            Varchar2(14);
    Vncontador               Integer := 0;
    Vstipoitem               Varchar2(2);
    Vnvlrcustocompra         Number;
    Vnvlrcustovenda          Number;
    Vspdfinalidaderevenda    Max_Parametro.Valor%Type;
    Vspdutilcodacessoprodedi Max_Parametro.Valor%Type;
  Begin
    If Psversaolayout = '4' Or Psversaolayout = '04' Or
       Psversaolayout = '4.5' Then
      Vscpnjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Busca PD Finalidade Familia
      SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                            0,
                            'PERM_EXP_ARQ_NEOGRID_REVENDA',
                            'S',
                            'N',
                            'PERMITE EXPORTAR NO ARQUIVO 05 e 07 - PRODUTOS DA EDI NEOGRID,' ||
                            CHR(13) || CHR(10) ||
                            'SOMENTE PRODUTOS EM QUE A FINALIDADE DA FAMÍLIA SEJA "REVENDA"?' ||
                            CHR(13) || CHR(10) || 'S-SIM' || CHR(13) ||
                            CHR(10) || 'N-NÃO(PADRÃO)',
                            Vspdfinalidaderevenda);
      Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      For Vtproduto In (Select a.Seqproduto As Codinternoproduto,
                               Nvl(Fcodacessoprodedi(a.Seqproduto, 'E'),
                                   fCodAcessoProdEDIdepara(a.seqproduto,
                                                           Pssoftpdv,
                                                           'NEOGRID')) As Codproduto,
                               Round(c.Qtdembalagem, 0) As Qtdembalagem,
                               a.Desccompleta As Descproduto,
                               h.Nroempresa,
                               b.Nrodivisao,
                               b.Uf As Ufempresa,
                               b.Nrosegmentoprinc As Segmento,
                               a.Seqfamilia
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Map_Famdivisao     f
                         Where b.Nroempresa = pnNroEmpresa
                           And a.Seqproduto = h.Seqproduto
                           and h.statuscompra = 'A'
                           And a.Seqproduto not in
                               (35349,
                                36117,
                                36196,
                                38256,
                                38485,
                                23203,
                                22432,
                                39090,
                                39091,
                                39095,
                                38787)
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           And c.Qtdembalagem =
                               Decode(Vspdutilcodacessoprodedi,
                                      'S',
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Null,
                                             (Select Min(g.Qtdembalagem)
                                                From Map_Famembalagem g
                                               Where g.Seqfamilia =
                                                     a.Seqfamilia),
                                             1),
                                      Fpadraoembvendaseg(a.Seqfamilia,
                                                         b.Nrosegmentoprinc))
                           And f.Seqfamilia = a.Seqfamilia
                           And f.Nrodivisao = b.Nrodivisao
                           And f.Finalidadefamilia =
                               Decode(Vspdfinalidaderevenda,
                                      'S',
                                      'R',
                                      f.Finalidadefamilia)
                           AND EXISTS
                         (SELECT 1
                                  FROM MAF_FORNECEDI A
                                 INNER JOIN GE_PESSOA B
                                    ON (A.SEQFORNECEDOR = B.SEQPESSOA)
                                 INNER JOIN MAP_FAMFORNEC C
                                    ON (A.SEQFORNECEDOR = C.SEQFORNECEDOR AND
                                       C.SEQFORNECEDOR = B.SEQPESSOA AND
                                       C.PRINCIPAL = 'S')
                                 INNER JOIN MAP_PRODUTO D
                                    ON (D.SEQFAMILIA = C.SEQFAMILIA)
                                 WHERE A.NOMEEDI = Pssoftpdv
                                      --AND A.LAYOUT = Pssoftpdv
                                   AND D.SEQPRODUTO = A.SEQPRODUTO)) Loop

        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '07';
        -- Código Interno do Produto
        Vslinha := Vslinha || Rpad(Vtproduto.Codinternoproduto, 15, ' ');
        -- Código do Produto
        Vslinha := Vslinha || Lpad(Vtproduto.Codproduto, 13, '0');
        -- Quantidade de Produtos na Embalagem
        /*   Vslinha := Vslinha || Lpad(Vtproduto.Qtdembalagem, 10, '0');*/
        Vslinha := Vslinha || Lpad(1, 10, '0');
        -- Preço unitario cadastrado para venda

        --gustavo gomes 2020
        -----------------------------------------------------------

        Begin

          select Nvl(Max(Round(a.Precovalidnormal / a.Qtdembalagem, 2) * 100),
                     0) As Precovenda

            Into Vnvlrcustovenda
            From Mrl_Prodempseg a
           Where a.Seqproduto = Vtproduto.Codinternoproduto
             And a.Qtdembalagem =
                 Fpadraoembvendaseg(Vtproduto.Seqfamilia, a.Nrosegmento)
             and a.precobasenormal != 0
             and a.statusvenda = 'A'
             and a.seqproduto not in (39090, 39091, 39095, 38787)
             and a.PRECOBASENORMAL != 0
                /*Decode(Vspdutilcodacessoprodedi,
                'S',
                Fpadraoembvendaseg(Vtproduto.Seqfamilia,
                                   a.Nrosegmento),
                Vtproduto.Qtdembalagem)*/
             And a.Nroempresa = Vtproduto.Nroempresa
             And a.Seqproduto not in
                 (select a.seqproduto
                    from mrl_produtoempresa a
                   where a.nroempresa = Pnnroempresa
                     and a.statuscompra = 'I')
             And a.Nrosegmento = Vtproduto.Segmento;

        Exception
          When No_Data_Found Then
            Vnvlrcustovenda := 0;
        End;

        Vslinha := Vslinha || Lpad(Vnvlrcustovenda, 15, '0');
        Begin

          select Nvl(Max(Round(a.Precovalidnormal / a.Qtdembalagem, 2) * 100),
                     0) As Precovenda

            Into Vnvlrcustovenda
            From Mrl_Prodempseg a
           Where a.Seqproduto = Vtproduto.Codinternoproduto
             And a.Qtdembalagem =
                 Fpadraoembvendaseg(Vtproduto.Seqfamilia, a.Nrosegmento)
             and a.precobasenormal != 0
             and a.statusvenda = 'A'
             and a.seqproduto not in (39090, 39091, 39095, 38787)
             and a.PRECOBASENORMAL != 0

                /*Decode(Vspdutilcodacessoprodedi,
                'S',
                Fpadraoembvendaseg(Vtproduto.Seqfamilia,
                                   a.Nrosegmento),
                Vtproduto.Qtdembalagem)*/

             And a.Nroempresa = Vtproduto.Nroempresa
             And a.Seqproduto not in
                 (select a.seqproduto
                    from mrl_produtoempresa a
                   where a.nroempresa = Pnnroempresa
                     and a.statuscompra = 'I')
             And a.Nrosegmento = Vtproduto.Segmento;

        Exception
          When No_Data_Found Then
            Vnvlrcustovenda := 0;
        End;

        Vslinha := Vslinha || Lpad(Vnvlrcustovenda, 15, '0');
        /*Vnvlrcustocompra := 0;*/
        -- Preco unitario cadastrado para compra
        /*    Vnvlrcustocompra := Round(Fc_Cmdiacustobruto(Vtproduto.Codinternoproduto,
                                                     Vtproduto.Nroempresa),
                                  2) * 100;

        Vslinha := Vslinha || Lpad(Vnvlrcustocompra, 15, '0');*/

        -- Descrição interna produto
        Vslinha := Vslinha || Rpad(Vtproduto.Descproduto, 50, ' ');
        -- Tipo do Item (01-Regular, 02-Promocional)
        --   if fbuscaprecopromocao(vtProduto.CodInternoProduto,pnNroEmpresa) = 0 THEN
        Select Decode(Count(1), 0, '01', '02')
          Into Vstipoitem
          From Mrl_Prodempseg Empseg
         Where Empseg.Seqproduto = Vtproduto.Codinternoproduto
           And Empseg.Nroempresa = Vtproduto.Nroempresa
           and empseg.Seqproduto not in (35349,
                                         36117,
                                         36196,
                                         38256,
                                         38485,
                                         39090,
                                         39091,
                                         39095,
                                         38787)
              -- And Empseg.Precovalidpromoc > 0
           and Empseg.PRECOBASENORMAL != 0;

        Vslinha := Vslinha || Lpad(Vstipoitem, 2, '0');
        -- Filler
        Vslinha    := Vslinha || Rpad(' ', 178, ' ');
        Vncontador := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vscpnjempresa,
           Vslinha,
           7,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_PRODUTOS_670 - ' || Sqlerrm);
  End Sp_Gera_Produtos_670;
  Function Fbuscacodativclitente670(Psnomeatividade Varchar2,
                                    Pssoftpdv       In Mrl_Empsoftpdv.Softpdv%Type)
    Return Varchar2 Is
    Vscodativ Varchar2(10);
  Begin
    Select Max(Codatividadeedi)
      Into Vscodativ
      From Mad_Ediatividade a
     Where a.Codatividade = Psnomeatividade
       And a.Nomeedi = Pssoftpdv --'COLGATE'
       And a.Layout = 'NEOGRID';
    Return Vscodativ;
  End Fbuscacodativclitente670;
  Function Fbuscacodsegclitente670(Psnomesegmento Varchar2) Return Varchar2 Is
    Vscodseg Varchar2(10);
  Begin
    If Psnomesegmento = 'SUPM. DE 01 A 04 CHECK-OUTS' Then
      Vscodseg := '11';
    Elsif Psnomesegmento = 'SUPM. DE 05 A 09 CHECK-OUTS' Then
      Vscodseg := '12';
    Elsif Psnomesegmento = 'SUPM. DE 10 A 19 CHECK-OUTS' Then
      Vscodseg := '13';
    Elsif Psnomesegmento = 'SUPM. DE 20 A 49 CHECK-OUTS' Then
      Vscodseg := '14';
    Elsif Psnomesegmento = 'SUPM. DE 50 A + CHECK-OUTS' Then
      Vscodseg := '15';
    Elsif Psnomesegmento = 'PERFUMARIA' Then
      Vscodseg := '16';
    Elsif Psnomesegmento = 'LOJAS DE DEPARTAMENTO' Then
      Vscodseg := '17';
    Elsif Psnomesegmento = 'CLUBE COMPRA' Then
      Vscodseg := '18';
    Elsif Psnomesegmento = 'LOJAS DE DESCONTOS' Then
      Vscodseg := '19';
    Elsif Psnomesegmento = 'MASS MERCHANDISER' Then
      Vscodseg := '20';
    Elsif Psnomesegmento = 'FARMACIAS E DROGARIAS' Then
      Vscodseg := '25';
    Elsif Psnomesegmento = 'ATACADISTA TRADICIONAL' Then
      Vscodseg := '31';
    Elsif Psnomesegmento = 'ATAC DISTR DE FARMACIAS' Then
      Vscodseg := '32';
    Elsif Psnomesegmento = 'ATACADISTA DISTRIBUIDOR' Then
      Vscodseg := '33';
    Elsif Psnomesegmento = 'CASH ' || Chr(38) || ' CARRY' Then
      Vscodseg := '34';
    Elsif Psnomesegmento = 'DISTRIBUIDOR SEMI-EXCLUSIVO' Then
      Vscodseg := '35';
    Elsif Psnomesegmento = 'DISTRIBUIDOR EXCLUSIVO' Then
      Vscodseg := '36';
    Elsif Psnomesegmento = 'HOSPITAIS / CLÍNICAS / LABORATÓRIOS' Then
      Vscodseg := '40';
    Elsif Psnomesegmento = 'INFORMÁTICA / TECNOLOGIA' Then
      Vscodseg := '50';
    Elsif Psnomesegmento = 'USINAS / INDÚSTRIAS' Then
      Vscodseg := '51';
    Elsif Psnomesegmento = 'COOPERATIVAS' Then
      Vscodseg := '55';
    Elsif Psnomesegmento = 'SERVIÇO PÚBLICO' Then
      Vscodseg := '60';
    Elsif Psnomesegmento = 'ENTIDADE FILANTRÓPICA' Then
      Vscodseg := '70';
    Elsif Psnomesegmento = 'LOJA DE BEBÊ / INFANTIL' Then
      Vscodseg := '80';
    Elsif Psnomesegmento = 'LOJAS DE COVENIENCIAS' Then
      Vscodseg := '81';
    Elsif Psnomesegmento = 'ACADEMIAS E BICICLETARIAS' Then
      Vscodseg := '82';
    Elsif Psnomesegmento = 'MERCEARIA / EMPORIO' Then
      Vscodseg := '83';
    Elsif Psnomesegmento = 'BANCA DE JORNAIS' Then
      Vscodseg := '84';
    Elsif Psnomesegmento = 'BAR / RESTAURANTE / LANCHONETES' Then
      Vscodseg := '85';
    Elsif Psnomesegmento = 'PADARIA / DOCEIRA / BOMBONIERE' Then
      Vscodseg := '86';
    Elsif Psnomesegmento = 'LOJAS PET' Then
      Vscodseg := '87';
    Elsif Psnomesegmento = 'E-COMMERCE' Then
      Vscodseg := '88';
    Elsif Psnomesegmento = 'PESSOA FÍSICA' Then
      Vscodseg := '89';
    Elsif Psnomesegmento = 'OUTROS' Then
      Vscodseg := '90';
    Elsif Psnomesegmento = 'EXPORTAÇÃO' Then
      Vscodseg := '91';
    Else
      Vscodseg := '90'; --Outros
    End If;
    Return Vscodseg;
  End Fbuscacodsegclitente670;
  /* Colgate - Fim */
  /* Inicio Melitta */
  Procedure Sp_Gera_Cabecalho_Melitta(Pnnroempresa    In Max_Empresa.Nroempresa%Type,
                                      Pddtainicial    In Date,
                                      Pddtafinal      In Date,
                                      Pssoftpdv       In Mrl_Empsoftpdv.Softpdv%Type,
                                      Psversaolayout  In Max_Edi.Versao_Layout%Type,
                                      Psidentificacao In Varchar2) Is
    Vslinha           Varchar2(300);
    Vscodedirelatorio Varchar2(20);
    Vscnpjempresa     Varchar2(14);
    Vsnomearquivo     Varchar2(40);
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      Select Nvl(Max(a.Codedifornec), '0')
        Into Vscodedirelatorio
        From Maf_Fornecedi a
       Where a.Status = 'A'
         And a.Nomeedi = Pssoftpdv
         And a.Layout = 'NEOGRID'
         And a.Nroempresa = Pnnroempresa;
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '01' || '|';
      -- Identificação
      Vslinha := Vslinha || Psidentificacao || '|';
      -- Versao
      Vslinha := Vslinha || '050' || '|';
      -- Número do Relatório
      Vslinha := Vslinha || Rpad(Vscodedirelatorio, 20, ' ') || '|';
      -- Data Hora Geração do Docto
      Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi') || '|';
      -- Data Período
      If (Pddtainicial Is Not Null) And (Pddtafinal Is Not Null) Then
        Vslinha := Vslinha || To_Char(Pddtainicial, 'yyyymmdd') || '|';
        Vslinha := Vslinha || To_Char(Pddtafinal, 'yyyymmdd') || '|';
      End If;
      -- CNPJ Distribuidor
      Vslinha := Vslinha || Lpad(Vscnpjempresa, 14, 0) || '|';
      -- CNPJ Fornecedor
      Vslinha       := Vslinha || '03887830009046' || '|';
      Vsnomearquivo := Psidentificacao || '_' || Vscnpjempresa;
      -- Insere os dados do cabeçalho
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_CABECALHO_Melitta - ' || Sqlerrm);
  End Sp_Gera_Cabecalho_Melitta;
  Procedure Sp_Gera_Vendedor_Melitta(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha       Varchar2(300);
    Vscnpjempresa Varchar2(14);
    Vsnomearquivo Varchar2(40);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      --Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o cabeçalho do arquivo
      Sp_Gera_Cabecalho_Melitta(Pnnroempresa    => Pnnroempresa,
                                Pddtainicial    => Null,
                                Pddtafinal      => Null,
                                Pssoftpdv       => Pssoftpdv,
                                Psversaolayout  => Psversaolayout,
                                Psidentificacao => 'RELVEN');
      --
      --Vendedor
      For Vtvendedor In (Select b.Nomerazao As Nomerazaorepres,
                                Fbuscacpfrepresentante(a.Nrorepresentante,
                                                       'MELITTA',
                                                       'NEOGRID') As Nrorepresentante,
                                d.Nomerazao As Nomerazaosup,
                                Lpad(d.Nrocgccpf, 9, 0) ||
                                Lpad(d.Digcgccpf, 2, 0) As Cnpjsuper,
                                a.Status,
                                To_Char(Decode(Nvl(a.Status, 'A'),
                                               'I',
                                               a.Dtaafastamento,
                                               Trunc(Sysdate)),
                                        'yyyymmdd') Dtadesligamento
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And c.Seqpessoa = d.Seqpessoa
                            And a.Nrorepresentante In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 3)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Nome Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaorepres, 50, ' ') || '|';
        -- Código Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nrorepresentante, 20, ' ') || '|';
        -- Nome Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ') || '|';
        -- Código Supervisor
        Vslinha := Vslinha || Rpad(Vtvendedor.Cnpjsuper, 20, ' ') || '|';
        -- Nome Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Nomerazaosup, 50, ' ') || '|';
        -- Código Gerente
        Vslinha := Vslinha || Rpad(Vtvendedor.Cnpjsuper, 20, ' ') || '|';
        -- Status Vendedor
        Vslinha := Vslinha || Rpad(Vtvendedor.Status, 20, ' ') || '|';
        -- Data de Desligamento
        Vslinha       := Vslinha ||
                         Rpad(Vtvendedor.Dtadesligamento, 8, ' ') || '|';
        Vsnomearquivo := 'RELVEN' || '_' || Vscnpjempresa;
        Vncontador    := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_VENDEDOR_Melitta - ' || Sqlerrm);
  End Sp_Gera_Vendedor_Melitta;
  Procedure Sp_Gera_Cliente_Melitta(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                    Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                    Psversaolayout In Max_Edi.Versao_Layout%Type) Is
    Vslinha                Varchar2(3000);
    Vscnpjempresa          Varchar2(14);
    Vsnomearquivo          Varchar2(40);
    Vscodsegmentocli       Varchar2(3);
    Vscodfreqvisita        Varchar2(2);
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
    Vscontatocompra        Mrl_Cliente.Contatocomprador%Type;
    Vncontador             Integer := 0;
    /*Vnseqfornecedor Maf_Fornecedor.Seqfornecedor%Type;*/
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      -- Busca Paramentro Dinamico
      Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'TIPO_CODSEGMENTO_CLI'),
                 'A')
        Into Vspdtipocodsegmentocli
        From Dual;
      --Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o cabeçalho do arquivo
      Sp_Gera_Cabecalho_Melitta(Pnnroempresa    => Pnnroempresa,
                                Pddtainicial    => Null,
                                Pddtafinal      => Null,
                                Pssoftpdv       => Pssoftpdv,
                                Psversaolayout  => Psversaolayout,
                                Psidentificacao => 'RELCLI');
      --
      -- Clientes
      For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                               Decode(a.Fisicajuridica,
                                      'J',
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           14,
                                           '0'),
                                      Lpad(a.Nrocgccpf ||
                                           Lpad(a.Digcgccpf, 2, 0),
                                           11,
                                           '0')) As Cpfcnpjcliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                               a.Cmpltologradouro As Enderecocliente,
                               a.Bairro,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente,
                               Nvl((a.Foneddd1 || a.Fonenro1),
                                   (a.Foneddd2 || a.Fonenro2)) As Fone_Cliente
                          From Ge_Pessoa a
                         Where a.Seqpessoa In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 4)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Código Cliente
        vsLinha := vsLinha ||
                   rpad(substr(vtCliente.CpfCnpjCliente, 1, 20), 20, ' ') || '|';
        -- CEP Cliente
        vsLinha := vsLinha ||
                   lpad(substr(vtCliente.CepCliente, 1, 8), 8, '0') || '|';
        -- UF Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Ufcliente, 2, ' ') || '|';
        -- Cidade Cliente
        vsLinha := vsLinha ||
                   rpad(substr(vtCliente.CidadeCliente, 1, 100), 100, ' ') || '|';
        -- Endereço Cliente
        vsLinha := vsLinha ||
                   rpad(substr(vtCliente.EnderecoCliente, 1, 100), 100, ' ') || '|';
        -- Bairro Cliente
        vsLinha := vsLinha ||
                   rpad(substr(vtCliente.Bairro, 1, 50), 50, ' ') || '|';
        -- Cliente
        Vslinha := Vslinha || Rpad(Vtcliente.Nomerazaocliente, 100, ' ') || '|';
        -- Código Segmento Cliente
        If (Vspdtipocodsegmentocli = 'G') Then
          Vscodsegmentocli := Fbuscacodsegcli_Melitta(Vtcliente.Grupocliente);
        Else
          Vscodsegmentocli := Fbuscacodsegcli_Melitta(Vtcliente.Atividadecliente);
        End If;
        Vslinha := Vslinha || Lpad(Vscodsegmentocli, 3, '0') || '|';
        -- Frequencia de Visita
        Begin
          Select Case
                   When (a.Periodvisita = 'D' Or a.Periodvisita = 'S') Then
                    '03' --semanal
                   When a.Periodvisita = 'Q' Then
                    '02' --quinzenal
                   When a.Periodvisita = 'M' Then
                    '01' --Mensal
                   Else
                    '04'
                 End
            Into Vscodfreqvisita
            From Mad_Clienterep a, Maxx_Selecrowid x
           Where x.Seqselecao = 3
             And a.Nrorepresentante = x.Sequencia
             And a.Seqpessoa = Vtcliente.Seqpessoa;
        Exception
          When No_Data_Found Then
            Vscodfreqvisita := '01';
          When Others Then
            Vscodfreqvisita := '01';
        End;
        Vslinha := Vslinha || Lpad(Vscodfreqvisita, 2, '0') || '|';
        -- Final frequencia
        -- Telefone Cliente
        vsLinha := vsLinha ||
                   rpad(substr(vtCliente.Fone_Cliente, 1, 20), 20, ' ') || '|';
        -- Contato Cliente
        Begin
          Select Nvl(a.Contatocomprador, ' ')
            Into Vscontatocompra
            From Mrl_Cliente a
           Where a.Seqpessoa = Vtcliente.Seqpessoa;
        Exception
          When No_Data_Found Then
            Vscontatocompra := ' ';
          When Others Then
            Vscontatocompra := ' ';
        End;
        Vslinha := Vslinha || Rpad(Vscontatocompra, 50, ' ') || '|';
        -- Final Contato Cliente
        Vsnomearquivo := 'RELCLI' || '_' || Vscnpjempresa;
        Vncontador    := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_CLIENTE_Melitta - ' || Sqlerrm);
  End Sp_Gera_Cliente_Melitta;
  Function Fbuscacodsegcli_Melitta(Psnomesegmento Varchar2) Return Varchar2 Is
    Vscodseg Varchar2(3);
  Begin
    If Psnomesegmento = 'ACADEMIAS' Then
      Vscodseg := '100';
    Elsif Psnomesegmento = 'ACESSORIOS DE MODA' Then
      Vscodseg := '102';
    Elsif Psnomesegmento = 'ACOUGUE' Then
      Vscodseg := '103';
    Elsif Psnomesegmento = 'ADEGA/DIST. DE BEBIDAS' Then
      Vscodseg := '104';
    Elsif Psnomesegmento = 'AEROPORTO' Then
      Vscodseg := '105';
    Elsif Psnomesegmento = 'AGROPECUARIA' Then
      Vscodseg := '106';
    Elsif Psnomesegmento = 'AMBULANTE' Then
      Vscodseg := '107';
    Elsif Psnomesegmento = 'ARMAZEM' Then
      Vscodseg := '109';
    Elsif Psnomesegmento = 'ARTESANATOS' Then
      Vscodseg := '110';
    elsif psNomeSegmento = 'AS ¿ 1 a 5 Check Outs' then
      Vscodseg := '178';
    elsif psNomeSegmento = 'AS ¿ 11 a 15 Check Outs' then
      Vscodseg := '180';
    elsif psNomeSegmento = 'AS ¿ 15 A 20 Check Outs' then
      Vscodseg := '181';
    elsif psNomeSegmento = 'AS ¿ 6 a 10 Check Outs' then
      Vscodseg := '179';
    elsif psNomeSegmento = 'AS ¿ Mais de 20 Check Outs' then
      Vscodseg := '182';
    elsif psNomeSegmento = 'AS ¿ Sem quantidade de Check Outs' then
      Vscodseg := '183';
    Elsif Psnomesegmento = 'ASSOCIACOES E COLONIAS' Then
      Vscodseg := '111';
    Elsif Psnomesegmento = 'ATACAREJO' Then
      Vscodseg := '116';
    Elsif Psnomesegmento = 'ATC GRANDE PORTE' Then
      Vscodseg := '115';
    Elsif Psnomesegmento = 'ATC MEDIO PORTE' Then
      Vscodseg := '113';
    Elsif Psnomesegmento = 'ATC PEQUENO PORTE' Then
      Vscodseg := '114';
    Elsif Psnomesegmento = 'AUTO PECAS/VEICULOS' Then
      Vscodseg := '118';
    Elsif Psnomesegmento = 'BANCAS / QUIOSQUES' Then
      Vscodseg := '119';
    Elsif Psnomesegmento = 'BAR' Then
      Vscodseg := '120';
    Elsif Psnomesegmento = 'BAZAR' Then
      Vscodseg := '108';
    Elsif Psnomesegmento = 'BICICLETARIAS' Then
      Vscodseg := '101';
    Elsif Psnomesegmento = 'BOMBONIERE / DOCERIAS' Then
      Vscodseg := '126';
    Elsif Psnomesegmento = 'BORDADEIRA' Then
      Vscodseg := '127';
    Elsif Psnomesegmento = 'BOUTIQUE' Then
      Vscodseg := '128';
    Elsif Psnomesegmento = 'CAFETERIA' Then
      Vscodseg := '131';
    Elsif Psnomesegmento = 'CALCADOS' Then
      Vscodseg := '132';
    Elsif Psnomesegmento = 'CANTINAS' Then
      Vscodseg := '133';
    Elsif Psnomesegmento = 'CASH ' || Chr(38) || ' CARRY' Then
      Vscodseg := '134';
    Elsif Psnomesegmento = 'CHURRASCARIA' Then
      Vscodseg := '135';
    Elsif Psnomesegmento = 'CINEMAS' Then
      Vscodseg := '136';
    Elsif Psnomesegmento = 'CLINICAS' Then
      Vscodseg := '137';
    Elsif Psnomesegmento = 'CLUBES' Then
      Vscodseg := '138';
    Elsif Psnomesegmento = 'CONFECCOES' Then
      Vscodseg := '140';
    Elsif Psnomesegmento = 'CONSUMIDOR FINAL' Then
      Vscodseg := '141';
    Elsif Psnomesegmento = 'COOPERATIVA' Then
      Vscodseg := '117';
    Elsif Psnomesegmento = 'COPISTA' Then
      Vscodseg := '143';
    Elsif Psnomesegmento = 'CORPORATIVO' Then
      Vscodseg := '150';
    Elsif Psnomesegmento = 'COZINHA INDUSTRIAL' Then
      Vscodseg := '144';
    Elsif Psnomesegmento = 'DISTRIBUIDOR' Then
      Vscodseg := '145';
    Elsif Psnomesegmento = 'E-COMMERCE' Then
      Vscodseg := '146';
    Elsif Psnomesegmento = 'ENTIDADE FILANTROPICA' Then
      Vscodseg := '147';
    Elsif Psnomesegmento = 'ESTUDIO FOTOGRAFICO' Then
      Vscodseg := '125';
    Elsif Psnomesegmento = 'EVENTOS/FESTAS' Then
      Vscodseg := '148';
    Elsif Psnomesegmento = 'EXPORTACAO' Then
      Vscodseg := '149';
    Elsif Psnomesegmento = 'FARMACIAS E DROGARIAS' Then
      Vscodseg := '151';
    Elsif Psnomesegmento = 'FERRAGENS/MAT DE CONSTRUÇÃO' Then
      Vscodseg := '152';
    Elsif Psnomesegmento = 'FLORICULTURA' Then
      Vscodseg := '153';
    Elsif Psnomesegmento = 'FRUTEIRA' Then
      Vscodseg := '154';
    elsif psNomeSegmento = 'GOVERNO ¿ Licitação' then
      Vscodseg := '155';
    Elsif Psnomesegmento = 'GRAFICAS' Then
      Vscodseg := '156';
    Elsif Psnomesegmento = 'HOSPITAIS' Then
      Vscodseg := '157';
    Elsif Psnomesegmento = 'HOTEIS/MOTEIS' Then
      Vscodseg := '158';
    Elsif Psnomesegmento = 'IGREJAS/FUNERARIAS' Then
      Vscodseg := '159';
    Elsif Psnomesegmento = 'INDUSTRIA' Then
      Vscodseg := '160';
    Elsif Psnomesegmento = 'INFORMATICA / TECNOLOGIA' Then
      Vscodseg := '161';
    Elsif Psnomesegmento = 'INSTITUICAO DE ENSINO' Then
      Vscodseg := '139';
    Elsif Psnomesegmento = 'INSTITUIÇÕES FINANCEIRAS' Then
      Vscodseg := '184';
    Elsif Psnomesegmento = 'LANCHONETES' Then
      Vscodseg := '121';
    Elsif Psnomesegmento = 'LOCADORAS' Then
      Vscodseg := '162';
    Elsif Psnomesegmento = 'LOJA DE ARTIGOS ESPORTIVOS' Then
      Vscodseg := '167';
    Elsif Psnomesegmento = 'LOJA DE BRINQUEDOS' Then
      Vscodseg := '129';
    Elsif Psnomesegmento = 'LOJA DE CONVENIENCIA' Then
      Vscodseg := '164';
    Elsif Psnomesegmento = 'LOJA DE DEPARTAMENTO' Then
      Vscodseg := '165';
    Elsif Psnomesegmento = 'LOJA DE MOVEIS' Then
      Vscodseg := '166';
    Elsif Psnomesegmento = 'LOJA INFANTIL' Then
      Vscodseg := '163';
    Elsif Psnomesegmento = 'MERCADO E MINI MERCADO' Then
      Vscodseg := '168';
    Elsif Psnomesegmento = 'OTICA' Then
      Vscodseg := '124';
    Elsif Psnomesegmento = 'OUTROS' Then
      Vscodseg := '169';
    Elsif Psnomesegmento = 'PADARIA' Then
      Vscodseg := '170';
    Elsif Psnomesegmento = 'PADARIA E CONFEITARIA' Then
      Vscodseg := '171';
    Elsif Psnomesegmento = 'PAPELARIA' Then
      Vscodseg := '123';
    Elsif Psnomesegmento = 'PASTELARIA' Then
      Vscodseg := '172';
    Elsif Psnomesegmento = 'PEQUENOS ATCS E DISTS' Then
      Vscodseg := '173';
    Elsif Psnomesegmento = 'PIZZARIA' Then
      Vscodseg := '174';
    Elsif Psnomesegmento = 'RESTAURANTE' Then
      Vscodseg := '122';
    Elsif Psnomesegmento = 'RODOVIARIA' Then
      Vscodseg := '176';
    Elsif Psnomesegmento = 'SALAO DE BELEZA' Then
      Vscodseg := '130';
    Elsif Psnomesegmento = 'SERVICOS' Then
      Vscodseg := '142';
    Elsif Psnomesegmento = 'SORVETERIA' Then
      Vscodseg := '177';
    Elsif Psnomesegmento = 'TABACARIA' Then
      Vscodseg := '175';
    Elsif Psnomesegmento = 'VAREJO' Then
      Vscodseg := '112';
    Else
      Vscodseg := '169'; --Outros
    End If;
    Return Vscodseg;
  End Fbuscacodsegcli_Melitta;
  Procedure Sp_Gera_Vendas_Melitta(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                   Pddtainicial   In Date,
                                   Pddtafinal     In Date,
                                   Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                   psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) is
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vspdgeranfserieoe        Max_Parametro.Parametro%Type := 'N';
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type := 'N';
    Vncontador               Integer := 0;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      -- Busca Paramentro Dinamico
      select nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N')
        Into Vspdgeranfserieoe
        From Dual;
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o cabeçalho do arquivo
      Sp_Gera_Cabecalho_Melitta(Pnnroempresa    => Pnnroempresa,
                                Pddtainicial    => Pddtainicial,
                                Pddtafinal      => Pddtafinal,
                                Pssoftpdv       => Pssoftpdv,
                                Psversaolayout  => Psversaolayout,
                                Psidentificacao => 'VENDAS');
      --
      -- Gera o Registro 02 - Notas Fiscais
      For vtVenda in (select A.NUMERODF,
                             a.Seriedf,
                             (Case
                               When Nvl(a.Statusdf, 'V') = 'C' Or
                                    Nvl(a.Statusitem, 'V') = 'C' Then
                                '03'
                               Else
                                Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                       'ED',
                                       '02',
                                       '01')
                             End) As Tiponotafiscal,
                             To_Char(a.Dtahoremissao, 'yyyymmddhh24mi') Dtahoremissao,
                             FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                    'MELITTA',
                                                    'NEOGRID') as CpfCnpjRep,
                             DECODE(C.FISICAJURIDICA,
                                    'J',
                                    LPAD(C.NROCGCCPF ||
                                         LPAD(C.DIGCGCCPF, 2, 0),
                                         14,
                                         '0'),
                                    LPAD(C.NROCGCCPF ||
                                         LPAD(C.DIGCGCCPF, 2, 0),
                                         11,
                                         '0')) as CpfCnpjCliente,
                             e.Uf Ufemissor,
                             Regexp_Replace(Substr(e.Cep, 1, 8), '[^0-9]') Cepemissor,
                             c.Uf Ufdestinatario,
                             Regexp_Replace(Substr(c.Cep, 1, 8), '[^0-9]') Cepdestinatario
                        From Mflv_Basedfitem a,
                             Ge_Pessoa       c,
                             Max_Empserienf  d,
                             Max_Empresa     e
                       where A.SEQPRODUTO in
                             (select X.SEQUENCIA
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 2)
                         And a.Seqpessoa = c.Seqpessoa
                         And a.Nroempresa = d.Nroempresa(+)
                         And a.Seriedf = d.Serienf(+)
                         And a.Nroempresa = e.Nroempresa
                         And a.Nroempresa = Pnnroempresa
                         and A.DTAENTRADA between pdDtaInicial and
                             pdDtaFinal
                         and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                             ('ED', 'SC')
                         and ((vsPDGeraNfSerieOe = 'N' And
                             NVL(D.TIPODOCTO, 'x') != 'O') or
                             (Vspdgeranfserieoe = 'S'))
                         And Nvl(a.Statusnfe, 0) != 6
                       Group By a.Numerodf,
                                a.Seriedf,
                                (Case
                                  When Nvl(a.Statusdf, 'V') = 'C' Or
                                       Nvl(a.Statusitem, 'V') = 'C' Then
                                   '03'
                                  else
                                   decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                          'ED',
                                          '02',
                                          '01')
                                End),
                                a.Dtahoremissao,
                                a.Nrorepresentante,
                                c.Fisicajuridica,
                                c.Nrocgccpf,
                                c.Digcgccpf,
                                e.Uf,
                                e.Cep,
                                c.Uf,
                                c.Cep
                       order by A.NUMERODF, A.SERIEDF) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02';
        -- Tipo de Faturamento
        Vslinha := Vslinha || '01';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtvenda.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtvenda.Seriedf, 3, ' ');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtvenda.Tiponotafiscal, 2, '0');
        -- Data Emissão NF
        Vslinha := Vslinha || Rpad(Vtvenda.Dtahoremissao, 12, ' ');
        -- Código Representante
        Vslinha := Vslinha || Rpad(Vtvenda.Cpfcnpjrep, 20, ' ');
        -- Código Cliente
        Vslinha := Vslinha || Rpad(Vtvenda.Cpfcnpjcliente, 20, ' ');
        -- UF Emissor Mercadoria
        Vslinha := Vslinha || Rpad(Vtvenda.Ufemissor, 2, ' ');
        -- CEP Emissor
        Vslinha := Vslinha || Lpad(Vtvenda.Cepemissor, 8, '0');
        -- UF Destinatario Mercadoria
        Vslinha := Vslinha || Rpad(Vtvenda.Ufdestinatario, 2, ' ');
        -- CEP Destinatario
        Vslinha       := Vslinha || Lpad(Vtvenda.Cepdestinatario, 8, '0');
        Vsnomearquivo := 'VENDAS' || '_' || Vscnpjempresa;
        Vncontador    := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vncontador);
        --
      End Loop;
      --
      -- Gera o Registro 03 - ITENS
      For vtVendaItens in (select A.NUMERODF,
                                  a.Seriedf,
                                  a.Seqproduto As Codigoprod,
                                  decode(vsPDUtilCodAcessoProdEdi,
                                         'S',
                                         round(SUM(A.QUANTIDADE /
                                                   DECODE(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                                            'E',
                                                                            'N'),
                                                          null,
                                                          A.QTDEMBALAGEM,
                                                          1)),
                                               5),
                                         round(SUM(A.QUANTIDADE /
                                                   fpadraoembvendaseg(A.SEQFAMILIA,
                                                                      A.nrosegmento)),
                                               5)) as Quantidade,
                                  DECODE(A.CODGERALOPER,
                                         C.CGONFBONIFICACAO,
                                         'S',
                                         'N') as Bonificacao,
                                  Round(Sum(a.Vlrcontabil / a.Quantidade), 2) As Vlrunitario,
                                  Round(Sum(a.Vlrcontabil), 2) As Vlrbruto,
                                  round(SUM(A.VLRCONTABIL -
                                            (A.VLRICMS + A.VLRPIS +
                                            A.VLRCOFINS)),
                                        2) as VlrLiquido,
                                  Round(Sum(a.Vlripi), 2) As Vlripi,
                                  Round(Sum(a.Vlrpis + a.Vlrcofins), 2) As Vlrpiscofins,
                                  Round(Sum(a.Vlricmsst), 2) As Vlricmsst,
                                  Round(Sum(a.Vlricms), 2) As Vlricms,
                                  Round(Sum(a.Vlrdesconto), 2) As Vlrdesconto,
                                  (Case
                                    When Nvl(a.Statusdf, 'V') = 'C' Or
                                         Nvl(a.Statusitem, 'V') = 'C' Then
                                     '03'
                                    else
                                     decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                            'ED',
                                            '02',
                                            '01')
                                  End) As Tiponotafiscal
                             From Mflv_Basedfitem  a,
                                  Map_Produto      b,
                                  Mad_Parametro    c,
                                  Max_Empserienf   d,
                                  Map_Famembalagem e
                            Where a.Nroempresa = d.Nroempresa(+)
                              And a.Seriedf = d.Serienf(+)
                              and A.SEQPRODUTO in
                                  (select X.SEQUENCIA
                                     From Maxx_Selecrowid x
                                    Where x.Seqselecao = 2)
                              And a.Nroempresa = c.Nroempresa
                              And a.Seqproduto = b.Seqproduto
                              And a.Qtdembalagem = e.Qtdembalagem
                              And b.Seqfamilia = e.Seqfamilia
                              And a.Nroempresa = Pnnroempresa
                              and A.DTAENTRADA between pdDtaInicial and
                                  pdDtaFinal
                              and A.TIPNOTAFISCAL || A.TIPDOCFISCAL in
                                  ('ED', 'SC')
                              and ((vsPDGeraNfSerieOe = 'N' and
                                  NVL(D.TIPODOCTO, 'x') != 'O') or
                                  (Vspdgeranfserieoe = 'S'))
                              And Nvl(a.Statusnfe, 0) != 6
                            Group By a.Numerodf,
                                     a.Seriedf,
                                     a.Seqproduto,
                                     b.Desccompleta,
                                     Decode(a.Codgeraloper,
                                            c.Cgonfbonificacao,
                                            'S',
                                            'N'),
                                     (Case
                                       When Nvl(a.Statusdf, 'V') = 'C' Or
                                            Nvl(a.Statusitem, 'V') = 'C' Then
                                        '03'
                                       Else
                                        Decode(a.Tipnotafiscal ||
                                               a.Tipdocfiscal,
                                               'ED',
                                               '02',
                                               '01')
                                     End)
                            Order By a.Numerodf, a.Seriedf) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03';
        -- Numero Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtvendaitens.Numerodf, 20, ' ');
        -- Serie Nota Fiscal
        Vslinha := Vslinha || Rpad(Vtvendaitens.Seriedf, 3, ' ');
        -- Tipo da Nota Fiscal
        Vslinha := Vslinha || Lpad(Vtvendaitens.Tiponotafiscal, 2, '0');
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtvendaitens.Codigoprod, 30, ' ');
        -- Quantidade vendida
        Vslinha := Vslinha || Lpad(Vtvendaitens.Quantidade, 10, '0');
        -- Valor Unitário
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlrunitario, 10, '0');
        -- Bonificação
        Vslinha := Vslinha || Rpad(Vtvendaitens.Bonificacao, 1, ' ');
        -- Valor total bruto
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlrbruto, 10, '0');
        -- Valor total liquido
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlrliquido, 10, '0');
        -- Valor total IPI
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlripi, 10, '0');
        -- Valor total PIS / COFINS
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlrpiscofins, 10, '0');
        -- Valor total ST
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlricmsst, 10, '0');
        -- Valor total ICMS
        Vslinha := Vslinha || Lpad(Vtvendaitens.Vlricms, 10, '0');
        -- Valor total Descontos
        Vslinha       := Vslinha || Lpad(Vtvendaitens.Vlrdesconto, 10, '0');
        Vsnomearquivo := 'VENDAS' || '_' || Vscnpjempresa;
        Vncontador    := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           3,
           Vncontador);
      End Loop;
      --
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_VENDAS_Melitta - ' || sqlerrm);
  End Sp_Gera_Vendas_Melitta;
  Procedure Sp_Gera_Estoque_Melitta(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                    Pddtainicial   In Date,
                                    Pddtafinal     In Date,
                                    Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                    psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) is
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type := 'N';
    Vncontador               Integer := 0;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o cabeçalho do arquivo
      Sp_Gera_Cabecalho_Melitta(Pnnroempresa    => Pnnroempresa,
                                Pddtainicial    => Pddtainicial,
                                Pddtafinal      => Pddtafinal,
                                Pssoftpdv       => Pssoftpdv,
                                Psversaolayout  => Psversaolayout,
                                Psidentificacao => 'RELEST');
      --
      -- Gera Registro 02 - Estoque
      For Vtestoque In (Select a.Seqproduto As Codproduto,
                               To_Char(i.Dtaentradasaida, 'yyyymmddhh24mi') As Dtaestoque,
                               Round(Sum((Nvl(i.Qtdestqinicial, 0) +
                                         Nvl(i.Qtdentrada, 0) -
                                         Nvl(i.Qtdsaida, 0)) /
                                         c.Qtdembalagem),
                                     3) As Qtdeestoque,
                               round(DECODE(I.DTAENTRADASAIDA,
                                            trunc(sysdate),
                                            nvl(SUM(H.QTDPEDRECTRANSITO), 0),
                                            0),
                                     3) as QtdeEstoqueTrans
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Mrl_Prodestoquedia i,
                               Map_Famdivisao     f,
                               Mrl_Local          j
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And i.Nroempresa = j.Nroempresa
                           And i.Seqlocal = j.Seqlocal
                           And j.Tiplocal In ('D', 'L')
                           And a.Seqfamilia = c.Seqfamilia
                           And c.Qtdembalagem =
                               Decode(Vspdutilcodacessoprodedi,
                                      'S',
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Null,
                                             (Select Min(g.Qtdembalagem)
                                                From Map_Famembalagem g
                                               Where g.Seqfamilia =
                                                     a.Seqfamilia),
                                             1),
                                      Fpadraoembvendaseg(a.Seqfamilia,
                                                         b.Nrosegmentoprinc))
                           And f.Seqfamilia = a.Seqfamilia
                           And f.Nrodivisao = b.Nrodivisao
                           And f.Finalidadefamilia != 'B'
                           And i.Dtaentradasaida Between Pddtainicial And
                               Pddtafinal
                           And a.Seqproduto In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 2)
                         Group By a.Seqproduto, i.Dtaentradasaida) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Data do Estoque
        Vslinha := Vslinha || Lpad(Vtestoque.Dtaestoque, 12, '0') || '|';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtestoque.Codproduto, 20, ' ') || '|';
        -- Quantidade de Estoque
        If (Vtestoque.Qtdeestoque >= 0) Then
          Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoque, 10, '0') || '|';
        Else
          Vslinha := Vslinha || Lpad(0, 10, '0') || '|';
        End If;
        -- Estoque em Transito
        If (Vtestoque.Qtdeestoquetrans >= 0) Then
          Vslinha := Vslinha || Lpad(Vtestoque.Qtdeestoquetrans, 10, '0') || '|';
        Else
          Vslinha := Vslinha || Lpad(0, 10, '0') || '|';
        End If;
        Vsnomearquivo := 'RELEST' || '_' || Vscnpjempresa;
        Vncontador    := Vncontador + 1;
        --insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200,
                              'SP_GERA_ESTOQUE_Melitta - ' || Sqlerrm);
  End Sp_Gera_Estoque_Melitta;
  Procedure Sp_Gera_Prod_Melitta(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                 Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                 psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) is
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vscnpjfornec             Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vstipoitem               Varchar2(50);
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type;
    Vncontador               Integer := 0;
    Vnvlrprecovenda          Mrl_Prodempseg.Precobasenormal%Type;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      --Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o cabeçalho do arquivo
      Sp_Gera_Cabecalho_Melitta(Pnnroempresa    => Pnnroempresa,
                                Pddtainicial    => Null,
                                Pddtafinal      => Null,
                                Pssoftpdv       => Pssoftpdv,
                                Psversaolayout  => Psversaolayout,
                                Psidentificacao => 'RELPRO');
      --
      -- Produto
      For Vtproduto In (Select a.Seqproduto As Codinternoproduto,
                               a.Desccompleta As Descricaoprod,
                               Nvl(Fcodacessoprodedi(a.Seqproduto, 'E', 'N'),
                                   '0') As Codproduto,
                               Round(c.Qtdembalagem, 0) As Qtdembalagem,
                               h.Nroempresa,
                               b.Nrodivisao,
                               b.Uf As Ufempresa,
                               b.Nrosegmentoprinc As Segmento,
                               a.Seqfamilia
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Map_Famdivisao     f
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           And c.Qtdembalagem =
                               Decode(Vspdutilcodacessoprodedi,
                                      'S',
                                      Decode(Fcodacessoprodedi(a.Seqproduto,
                                                               'E',
                                                               'N'),
                                             Null,
                                             (Select Min(g.Qtdembalagem)
                                                From Map_Famembalagem g
                                               Where g.Seqfamilia =
                                                     a.Seqfamilia),
                                             1),
                                      Fpadraoembvendaseg(a.Seqfamilia,
                                                         b.Nrosegmentoprinc))
                           And f.Seqfamilia = a.Seqfamilia
                           And f.Nrodivisao = b.Nrodivisao
                           And f.Finalidadefamilia != 'B'
                           And a.Seqproduto In
                               (Select x.Sequencia
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 2)) Loop
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- CNPJ do Fornecedor
        Select Nvl(Max(Substr(b.Nrocgccpf || b.Digcgccpf, 1, 14)), 0)
          Into Vscnpjfornec
          From Maf_Fornecedi a, Ge_Pessoa b
         Where a.Nroempresa = Vtproduto.Nroempresa
           And a.Nomeedi = Pssoftpdv
           And a.Layout = 'NEOGRID'
           And a.Status = 'A'
           And a.Seqfornecedor = b.Seqpessoa;
        Vslinha := Vslinha || Rpad(Vscnpjfornec, 14, ' ') || '|';
        -- Código do Item
        Vslinha := Vslinha || Rpad(Vtproduto.Codinternoproduto, 20, ' ') || '|';
        -- Código do Produto
        Vslinha := Vslinha || Rpad(Vtproduto.Codproduto, 14, ' ') || '|';
        -- Tipo Item
        Select Decode(Count(1), 0, '01', '02')
          Into Vstipoitem
          From Mrl_Prodempseg Empseg
         Where Empseg.Seqproduto = Vtproduto.Codinternoproduto
           And Empseg.Nroempresa = Vtproduto.Nroempresa
           And Empseg.Precovalidpromoc > 0;
        Vslinha := Vslinha || Vstipoitem || '|';
        -- Final Tipo Item
        -- Quantidade de Produtos na Embalagem
        Vslinha := Vslinha || Lpad(Vtproduto.Qtdembalagem, 10, '0') || '|';
        -- Preço unitario cadastrado para venda
        Begin
          Select Round(Decode(a.Precovalidpromoc,
                              0,
                              a.Precovalidnormal,
                              a.Precovalidpromoc) / a.Qtdembalagem,
                       2)
            Into Vnvlrprecovenda
            From Mrl_Prodempseg a
           Where a.Seqproduto = Vtproduto.Codinternoproduto
             And a.Qtdembalagem =
                 Decode(Vspdutilcodacessoprodedi,
                        'S',
                        Fpadraoembvendaseg(Vtproduto.Seqfamilia,
                                           a.Nrosegmento),
                        Vtproduto.Qtdembalagem)
             And a.Nroempresa = Vtproduto.Nroempresa
             And a.Nrosegmento = Vtproduto.Segmento;
        Exception
          When No_Data_Found Then
            Vnvlrprecovenda := 0;
        End;
        Vslinha := Vslinha || Lpad(Vnvlrprecovenda, 10, '0') || '|';
        -- Final Preço de Venda
        -- Descrição interna do item
        Vslinha       := Vslinha || Rpad(Vtproduto.Descricaoprod, 100, ' ') || '|';
        Vsnomearquivo := 'RELPRO' || '_' || Vscnpjempresa;
        Vncontador    := Vncontador + 1;
        -- insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_PROD_Melitta - ' || Sqlerrm);
  End Sp_Gera_Prod_Melitta;
  /* Fim Melitta */
  /************************************************************************************/
  /* Inicio Versão 5.0 NEO */
  Procedure Sp_Gera_Cabecalho_V5(Pnnroempresa     In Max_Empresa.Nroempresa%Type,
                                 Pddtainicial     In Date,
                                 Pddtafinal       In Date,
                                 Pssoftpdv        In Mrl_Empsoftpdv.Softpdv%Type,
                                 Psversaolayout   In Max_Edi.Versao_Layout%Type,
                                 Psidentificacao  In Varchar2,
                                 Pscnpjfornecedor In Varchar2) Is
    Vslinha           Varchar2(300);
    Vscodedirelatorio Varchar2(20);
    Vscnpjempresa     Varchar2(14);
    Vsnomearquivo     Varchar2(40);
    Vscnpjfornec      Varchar2(14);
  Begin
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    Select Nvl(Max(a.Codedifornec), '0')
      Into Vscodedirelatorio
      From Maf_Fornecedi a
     Where a.Status = 'A'
       And a.Nomeedi = Pssoftpdv
       And a.Layout = 'NEOGRID'
       And a.Nroempresa = Pnnroempresa;
    Vslinha := '';
    -- Tipo de Registro
    Vslinha := Vslinha || '01' || '|';
    -- Identificação
    Vslinha := Vslinha || Psidentificacao || '|';
    -- Versao
    Vslinha := Vslinha || Psversaolayout || '|';
    -- Número do Relatório
    Vslinha := Vslinha || Vscodedirelatorio || '|';
    -- Data Hora Geração do Docto
    Vslinha := Vslinha || To_Char(Sysdate, 'yyyymmddhh24mi') || '|';
    -- Data Período
    If (Pddtainicial Is Not Null) And (Pddtafinal Is Not Null) Then
      Vslinha := Vslinha || To_Char(Pddtainicial, 'yyyymmdd') || '|';
      Vslinha := Vslinha || To_Char(Pddtafinal, 'yyyymmdd') || '|';
    End If;
    -- CNPJ Distribuidor
    Vslinha := Vslinha || Lpad(Vscnpjempresa, 14, 0) || '|';
    if Psidentificacao = 'RELPRO' then
      Vscnpjfornec := '03887830009046';
    else
      Vscnpjfornec := Lpad(Pscnpjfornecedor, 14, 0);
    end if;
    -- CNPJ Fornecedor e nome do arquivo
    If Pscnpjfornecedor Is Not Null Then
      Vslinha       := Vslinha || Vscnpjfornec || '|';
      Vsnomearquivo := Psidentificacao || '_' ||
                       Lpad(Pscnpjfornecedor, 14, 0) || '_' ||
                       Vscnpjempresa;
    Else
      Vslinha       := Vslinha || '03887830009046' || '|';
      Vsnomearquivo := Psidentificacao || '_' || Vscnpjempresa;
    End If;
    -- Insere os dados do cabeçalho
    Insert Into Mrlx_Pdvimportacao
      (Nroempresa,
       Softpdv,
       Dtamovimento,
       Dtahorlancamento,
       Arquivo,
       Linha,
       Ordem,
       Seqlinha)
    Values
      (Pnnroempresa,
       Pssoftpdv,
       Sysdate,
       Sysdate,
       Vsnomearquivo,
       Vslinha,
       1,
       1);
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CABECALHO_v5 - ' || Sqlerrm);
  End Sp_Gera_Cabecalho_V5;
  Procedure Sp_Gera_Vendedor_V5(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                                Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type)
  --psVersaoLayout   IN MAX_EDI.VERSAO_LAYOUT%TYPE,
    --psCNPJFornecedor IN varchar2)
   Is
    Vslinha       Varchar2(300);
    Vscnpjempresa Varchar2(14);
    Vsnomearquivo Varchar2(40);
    Vncontador    Integer := 0;
  Begin
    --Busca CNPJ da Empresa
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    -- Gera o cabeçalho do arquivo
    Sp_Gera_Cabecalho_V5(Pnnroempresa     => Pnnroempresa,
                         Pddtainicial     => Null,
                         Pddtafinal       => Null,
                         Pssoftpdv        => Pssoftpdv,
                         Psversaolayout   => '050',
                         Psidentificacao  => 'RELVEN',
                         Pscnpjfornecedor => Null);
    --Vendedor
    For Vtvendedor In (Select b.Nomerazao As Nomerazaorepres,
                              Fbuscacpfrepresentante(a.Nrorepresentante,
                                                     'NEOGRIDV5',
                                                     'NEOGRID') As Nrorepresentante,
                              d.Nomerazao As Nomerazaosup,
                              Lpad(d.Nrocgccpf, 9, 0) ||
                              Lpad(d.Digcgccpf, 2, 0) As Cnpjsuper,
                              a.Status,
                              To_Char(Decode(Nvl(a.Status, 'A'),
                                             'I',
                                             a.Dtaafastamento,
                                             Trunc(Sysdate)),
                                      'yyyymmdd') Dtadesligamento
                         From Mad_Representante a,
                              Ge_Pessoa         b,
                              Mad_Equipe        c,
                              Ge_Pessoa         d
                        Where a.Seqpessoa = b.Seqpessoa
                          And a.Nroequipe = c.Nroequipe
                          And c.Seqpessoa = d.Seqpessoa
                          And a.Nrorepresentante In
                              (Select x.Sequencia
                                 From Maxx_Selecrowid x
                                Where x.Seqselecao = 3)) Loop
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '02' || '|';
      -- Nome Vendedor
      Vslinha := Vslinha || Vtvendedor.Nomerazaorepres || '|';
      -- Código Vendedor
      Vslinha := Vslinha || Vtvendedor.Nrorepresentante || '|';
      -- Nome Supervisor
      Vslinha := Vslinha || Vtvendedor.Nomerazaosup || '|';
      -- Código Supervisor
      Vslinha := Vslinha || Nvl(Vtvendedor.Cnpjsuper, 'NAO INFORMADO') || '|';
      -- Nome Gerente
      Vslinha := Vslinha || Vtvendedor.Nomerazaosup || '|';
      -- Código Gerente
      Vslinha := Vslinha || Vtvendedor.Cnpjsuper || '|';
      -- Status Vendedor
      Vslinha := Vslinha || Vtvendedor.Status || '|';
      -- Data de Desligamento
      Vslinha       := Vslinha || Vtvendedor.Dtadesligamento || '|';
      Vsnomearquivo := 'RELVEN' || '_' || Vscnpjempresa;
      Vncontador    := Vncontador + 1;
      --insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         2,
         Vtvendedor.Nrorepresentante);
    End Loop;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDEDOR_v5 - ' || Sqlerrm);
  End Sp_Gera_Vendedor_V5;
  Procedure Sp_Gera_Cliente_V5(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                               Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               psVersaoLayout   IN MAX_EDI.VERSAO_LAYOUT%TYPE,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               psCNPJFornecedor IN varchar2*/) Is
    Vslinha                Varchar2(3000);
    Vscnpjempresa          Varchar2(14);
    Vsnomearquivo          Varchar2(40);
    Vscodsegmentocli       Varchar2(3);
    Vscodfreqvisita        Varchar2(2);
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
    Vscontatocompra        Mrl_Cliente.Contatocomprador%Type;
    Vncontador             Integer := 0;
    /*Vnseqfornecedor        Maf_Fornecedor.Seqfornecedor%Type;*/
    Vsbuscacodativtabint Varchar2(1);
  Begin
    -- Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID',
                               0,
                               'TIPO_CODSEGMENTO_CLI'),
               'A')
      Into Vspdtipocodsegmentocli
      From Dual;
    SP_BuscaParamDinamico('EXPORTACAO_NEOGRID',
                          0,
                          'BUSCA_CODATIV_TAB_INT',
                          'S',
                          'N',
                          'BUSCAR CÓDIGO DE ATIVIDADE DA TABELA DE INTEGRAÇÃO ? (S/N)',
                          vsBuscaCodAtivTabInt);
    --Busca CNPJ da Empresa
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    -- Gera o cabeçalho do arquivo
    Sp_Gera_Cabecalho_V5(Pnnroempresa     => Pnnroempresa,
                         Pddtainicial     => Null,
                         Pddtafinal       => Null,
                         Pssoftpdv        => Pssoftpdv,
                         Psversaolayout   => '050',
                         Psidentificacao  => 'RELCLI',
                         Pscnpjfornecedor => Null);
    --
    -- Clientes
    For Vtcliente In (Select a.Seqpessoa As Seqpessoa,
                             Decode(a.Fisicajuridica,
                                    'J',
                                    Lpad(a.Nrocgccpf ||
                                         Lpad(a.Digcgccpf, 2, 0),
                                         14,
                                         '0'),
                                    Lpad(a.Nrocgccpf ||
                                         Lpad(a.Digcgccpf, 2, 0),
                                         11,
                                         '0')) As Cpfcnpjcliente,
                             Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                             a.Uf As Ufcliente,
                             a.Cidade As Cidadecliente,
                             a.Logradouro || ' ' || a.Nrologradouro || ' ' ||
                             a.Cmpltologradouro As Enderecocliente,
                             a.Bairro,
                             a.Nomerazao As Nomerazaocliente,
                             Upper(a.Atividade) As Atividadecliente,
                             Upper(a.Grupo) As Grupocliente,
                             Nvl((a.Foneddd1 || a.Fonenro1),
                                 (a.Foneddd2 || a.Fonenro2)) As Fone_Cliente
                        From Ge_Pessoa a
                       Where a.Seqpessoa In
                             (Select x.Sequencia
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 4)) Loop
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '02' || '|';
      -- Código Cliente
      Vslinha := Vslinha || Substr(Vtcliente.Cpfcnpjcliente, 1, 20) || '|';
      -- CEP Cliente
      Vslinha := Vslinha ||
                 Lpad(Substr(Vtcliente.Cepcliente, 1, 8), 8, '0') || '|';
      -- UF Cliente
      Vslinha := Vslinha || Vtcliente.Ufcliente || '|';
      -- Cidade Cliente
      Vslinha := Vslinha || Substr(Vtcliente.Cidadecliente, 1, 100) || '|';
      -- Endereço Cliente
      Vslinha := Vslinha || Substr(Vtcliente.Enderecocliente, 1, 100) || '|';
      -- Bairro Cliente
      Vslinha := Vslinha || Substr(Vtcliente.Bairro, 1, 50) || '|';
      -- Cliente
      Vslinha := Vslinha || Vtcliente.Nomerazaocliente || '|';
      -- Código Segmento Cliente
      If Vspdtipocodsegmentocli = 'G' Then
        Vscodsegmentocli := Fbuscacodsegcli_V5(Vtcliente.Grupocliente);
      Else
        If (Vsbuscacodativtabint = 'S') Then
          VsCodSegmentoCli := FBuscaCodAtivCli_V5(VtCliente.AtividadeCliente,
                                                  psSoftPDV);
        Else
          Vscodsegmentocli := Fbuscacodsegcli_V5(Vtcliente.Atividadecliente);
        End If;
      End If;
      Vslinha := Vslinha || Vscodsegmentocli || '|';
      -- Frequencia de Visita
      Begin
        Select Case
                 When (a.Periodvisita = 'D' Or a.Periodvisita = 'S') Then
                  '03' --semanal
                 When a.Periodvisita = 'Q' Then
                  '02' --quinzenal
                 When a.Periodvisita = 'M' Then
                  '01' --Mensal
                 Else
                  '04'
               End
          Into Vscodfreqvisita
          From Mad_Clienterep a, Maxx_Selecrowid x
         Where x.Seqselecao = 3
           And a.Nrorepresentante = x.Sequencia
           And a.Seqpessoa = Vtcliente.Seqpessoa;
      Exception
        When No_Data_Found Then
          Vscodfreqvisita := '01';
        When Others Then
          Vscodfreqvisita := '01';
      End;
      Vslinha := Vslinha || Vscodfreqvisita || '|';
      -- Final frequencia
      -- Telefone Cliente
      Vslinha := Vslinha || Substr(Vtcliente.Fone_Cliente, 1, 20) || '|';
      -- Contato Cliente
      Begin
        Select Nvl(a.Contatocomprador, ' ')
          Into Vscontatocompra
          From Mrl_Cliente a
         Where a.Seqpessoa = Vtcliente.Seqpessoa;
      Exception
        When No_Data_Found Then
          Vscontatocompra := ' ';
        When Others Then
          Vscontatocompra := ' ';
      End;
      Vslinha := Vslinha || Vscontatocompra || '|';
      -- Final Contato Cliente
      Vsnomearquivo := 'RELCLI' || '_' || Vscnpjempresa;
      Vncontador    := Vncontador + 1;
      --insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         2,
         Vtcliente.Seqpessoa);
    End Loop;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_CLIENTE_v5 - ' || Sqlerrm);
  End Sp_Gera_Cliente_V5;
  Function Fbuscacodativcli_V5(Psnomeatividade Varchar2,
                               Pssoftpdv       In Mrl_Empsoftpdv.Softpdv%Type)
    Return Varchar2 Is
    Vscodativ Varchar2(10);
  Begin
    Select Max(Codatividadeedi)
      Into Vscodativ
      From Mad_Ediatividade a
     Where a.Codatividade = Psnomeatividade
       And a.Nomeedi = Pssoftpdv --'NEOGRIDV5'
       And a.Layout = 'NEOGRID';
    Return Vscodativ;
  End Fbuscacodativcli_V5;
  Function Fbuscacodsegcli_V5(Psnomesegmento Varchar2) Return Varchar2 Is
    Vscodseg Varchar2(3);
  Begin
    If Psnomesegmento = 'ACADEMIAS' Then
      Vscodseg := '100';
    Elsif Psnomesegmento = 'ACESSORIOS DE MODA' Then
      Vscodseg := '102';
    Elsif Psnomesegmento = 'ACOUGUE' Then
      Vscodseg := '103';
    Elsif Psnomesegmento = 'ADEGA/DIST. DE BEBIDAS' Then
      Vscodseg := '104';
    Elsif Psnomesegmento = 'AEROPORTO' Then
      Vscodseg := '105';
    Elsif Psnomesegmento = 'AGROPECUARIA' Then
      Vscodseg := '106';
    Elsif Psnomesegmento = 'AMBULANTE' Then
      Vscodseg := '107';
    Elsif Psnomesegmento = 'ARMAZEM' Then
      Vscodseg := '109';
    Elsif Psnomesegmento = 'ARTESANATOS' Then
      Vscodseg := '110';
    elsif psNomeSegmento = 'AS ¿ 1 a 5 Check Outs' then
      Vscodseg := '178';
    elsif psNomeSegmento = 'AS ¿ 11 a 15 Check Outs' then
      Vscodseg := '180';
    elsif psNomeSegmento = 'AS ¿ 15 A 20 Check Outs' then
      Vscodseg := '181';
    elsif psNomeSegmento = 'AS ¿ 6 a 10 Check Outs' then
      Vscodseg := '179';
    elsif psNomeSegmento = 'AS ¿ Mais de 20 Check Outs' then
      Vscodseg := '182';
    elsif psNomeSegmento = 'AS ¿ Sem quantidade de Check Outs' then
      Vscodseg := '183';
    Elsif Psnomesegmento = 'ASSOCIACOES E COLONIAS' Then
      Vscodseg := '111';
    Elsif Psnomesegmento = 'ATACAREJO' Then
      Vscodseg := '116';
    Elsif Psnomesegmento = 'ATC GRANDE PORTE' Then
      Vscodseg := '115';
    Elsif Psnomesegmento = 'ATC MEDIO PORTE' Then
      Vscodseg := '113';
    Elsif Psnomesegmento = 'ATC PEQUENO PORTE' Then
      Vscodseg := '114';
    Elsif Psnomesegmento = 'AUTO PECAS/VEICULOS' Then
      Vscodseg := '118';
    Elsif Psnomesegmento = 'BANCAS / QUIOSQUES' Then
      Vscodseg := '119';
    Elsif Psnomesegmento = 'BAR' Then
      Vscodseg := '120';
    Elsif Psnomesegmento = 'BAZAR' Then
      Vscodseg := '108';
    Elsif Psnomesegmento = 'BICICLETARIAS' Then
      Vscodseg := '101';
    Elsif Psnomesegmento = 'BOMBONIERE / DOCERIAS' Then
      Vscodseg := '126';
    Elsif Psnomesegmento = 'BORDADEIRA' Then
      Vscodseg := '127';
    Elsif Psnomesegmento = 'BOUTIQUE' Then
      Vscodseg := '128';
    Elsif Psnomesegmento = 'CAFETERIA' Then
      Vscodseg := '131';
    Elsif Psnomesegmento = 'CALCADOS' Then
      Vscodseg := '132';
    Elsif Psnomesegmento = 'CANTINAS' Then
      Vscodseg := '133';
    Elsif Psnomesegmento = 'CASH ' || Chr(38) || ' CARRY' Then
      Vscodseg := '134';
    Elsif Psnomesegmento = 'CHURRASCARIA' Then
      Vscodseg := '135';
    Elsif Psnomesegmento = 'CINEMAS' Then
      Vscodseg := '136';
    Elsif Psnomesegmento = 'CLINICAS' Then
      Vscodseg := '137';
    Elsif Psnomesegmento = 'CLUBES' Then
      Vscodseg := '138';
    Elsif Psnomesegmento = 'CONFECCOES' Then
      Vscodseg := '140';
    Elsif Psnomesegmento = 'CONSUMIDOR FINAL' Then
      Vscodseg := '141';
    Elsif Psnomesegmento = 'COOPERATIVA' Then
      Vscodseg := '117';
    Elsif Psnomesegmento = 'COPISTA' Then
      Vscodseg := '143';
    Elsif Psnomesegmento = 'CORPORATIVO' Then
      Vscodseg := '150';
    Elsif Psnomesegmento = 'COZINHA INDUSTRIAL' Then
      Vscodseg := '144';
    Elsif Psnomesegmento = 'DISTRIBUIDOR' Then
      Vscodseg := '145';
    Elsif Psnomesegmento = 'E-COMMERCE' Then
      Vscodseg := '146';
    Elsif Psnomesegmento = 'ENTIDADE FILANTROPICA' Then
      Vscodseg := '147';
    Elsif Psnomesegmento = 'ESTUDIO FOTOGRAFICO' Then
      Vscodseg := '125';
    Elsif Psnomesegmento = 'EVENTOS/FESTAS' Then
      Vscodseg := '148';
    Elsif Psnomesegmento = 'EXPORTACAO' Then
      Vscodseg := '149';
    Elsif Psnomesegmento = 'FARMACIAS E DROGARIAS' Then
      Vscodseg := '151';
    Elsif Psnomesegmento = 'FERRAGENS/MAT DE CONSTRUÇÃO' Then
      Vscodseg := '152';
    Elsif Psnomesegmento = 'FLORICULTURA' Then
      Vscodseg := '153';
    Elsif Psnomesegmento = 'FRUTEIRA' Then
      Vscodseg := '154';
    elsif psNomeSegmento = 'GOVERNO ¿ Licitação' then
      Vscodseg := '155';
    Elsif Psnomesegmento = 'GRAFICAS' Then
      Vscodseg := '156';
    Elsif Psnomesegmento = 'HOSPITAIS' Then
      Vscodseg := '157';
    Elsif Psnomesegmento = 'HOTEIS/MOTEIS' Then
      Vscodseg := '158';
    Elsif Psnomesegmento = 'IGREJAS/FUNERARIAS' Then
      Vscodseg := '159';
    Elsif Psnomesegmento = 'INDUSTRIA' Then
      Vscodseg := '160';
    Elsif Psnomesegmento = 'INFORMATICA / TECNOLOGIA' Then
      Vscodseg := '161';
    Elsif Psnomesegmento = 'INSTITUICAO DE ENSINO' Then
      Vscodseg := '139';
    Elsif Psnomesegmento = 'INSTITUIÇÕES FINANCEIRAS' Then
      Vscodseg := '184';
    Elsif Psnomesegmento = 'LANCHONETES' Then
      Vscodseg := '121';
    Elsif Psnomesegmento = 'LOCADORAS' Then
      Vscodseg := '162';
    Elsif Psnomesegmento = 'LOJA DE ARTIGOS ESPORTIVOS' Then
      Vscodseg := '167';
    Elsif Psnomesegmento = 'LOJA DE BRINQUEDOS' Then
      Vscodseg := '129';
    Elsif Psnomesegmento = 'LOJA DE CONVENIENCIA' Then
      Vscodseg := '164';
    Elsif Psnomesegmento = 'LOJA DE DEPARTAMENTO' Then
      Vscodseg := '165';
    Elsif Psnomesegmento = 'LOJA DE MOVEIS' Then
      Vscodseg := '166';
    Elsif Psnomesegmento = 'LOJA INFANTIL' Then
      Vscodseg := '163';
    Elsif Psnomesegmento = 'MERCADO E MINI MERCADO' Then
      Vscodseg := '168';
    Elsif Psnomesegmento = 'OTICA' Then
      Vscodseg := '124';
    Elsif Psnomesegmento = 'OUTROS' Then
      Vscodseg := '169';
    Elsif Psnomesegmento = 'PADARIA' Then
      Vscodseg := '170';
    Elsif Psnomesegmento = 'PADARIA E CONFEITARIA' Then
      Vscodseg := '171';
    Elsif Psnomesegmento = 'PAPELARIA' Then
      Vscodseg := '123';
    Elsif Psnomesegmento = 'PASTELARIA' Then
      Vscodseg := '172';
    Elsif Psnomesegmento = 'PEQUENOS ATCS E DISTS' Then
      Vscodseg := '173';
    Elsif Psnomesegmento = 'PIZZARIA' Then
      Vscodseg := '174';
    Elsif Psnomesegmento = 'RESTAURANTE' Then
      Vscodseg := '122';
    Elsif Psnomesegmento = 'RODOVIARIA' Then
      Vscodseg := '176';
    Elsif Psnomesegmento = 'SALAO DE BELEZA' Then
      Vscodseg := '130';
    Elsif Psnomesegmento = 'SERVICOS' Then
      Vscodseg := '142';
    Elsif Psnomesegmento = 'SORVETERIA' Then
      Vscodseg := '177';
    Elsif Psnomesegmento = 'TABACARIA' Then
      Vscodseg := '175';
    Elsif Psnomesegmento = 'VAREJO' Then
      Vscodseg := '112';
    Else
      Vscodseg := '169'; --Outros
    End If;
    Return Vscodseg;
  End Fbuscacodsegcli_V5;
  Procedure Sp_Gera_Vendas_V5(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                              Pddtainicial In Date,
                              Pddtafinal   In Date,
                              Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE*/) Is
    Vslinha           Varchar2(3000);
    Vscnpjempresa     Varchar2(14);
    Vsnomearquivo     Varchar2(40);
    Vspdgeranfserieoe Max_Parametro.Parametro%Type := 'N';
    /*vsPDUtilCodAcessoProdEdi         max_parametro.parametro%type := 'N';*/
    Vspdcgosbonificacao      Max_Parametro.Parametro%Type;
    Vncontador               Integer := 0;
    Vscnpjfornecedoranterior Varchar2(14) := 'x';
  Begin
    /*SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',0,'UTIL_CODACESSOPRODEDI','S','N',
    'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
    vsPDUtilCodAcessoProdEdi);*/
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'CGO_BONIFIC',
                          'S',
                          Null,
                          'INFORMAR O CGO DE BONIFICAÇÃO PARA EXPORTACAO SEPARADOS POR VIRGULA.
Ex.: 100, 101',
                          Vspdcgosbonificacao);
    -- Busca Paramentro Dinamico
    Select Nvl(Fc5maxparametro('EXPORTACAO_NEOGRID', 0, 'GERA_NF_SERIE_OE'),
               'N')
      Into Vspdgeranfserieoe
      From Dual;
    --Busca os CGOs BONIFICAÇÃO do parâmetro 'CGO_BONIFIC'
    Insert Into Maxx_Selecrowid
      (Sequencia, Seqselecao) --SeqSelecao = 5 para CGO_BONIFIC parâmetro
      Select To_Number(Column_Value) Codcgoparam, 5
        From Table(Cast(C5_Complexin.C5intable(Vspdcgosbonificacao) As
                        C5instrtable));
    -- Busca CNPJ da Empresa
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    -- Gera o Registro 02 - Notas Fiscais
    For Vtvenda In (Select a.Numerodf Numerodf,
                           a.Seriedf Seriedf,
                           (Case
                             When Nvl(a.Statusdf, 'V') = 'C' Or
                                  Nvl(a.Statusitem, 'V') = 'C' Then
                              '03'
                             Else
                              Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                     'ED',
                                     '02',
                                     '01')
                           End) As Tiponotafiscal,
                           To_Char(a.Dtaentrada, 'yyyymmddhh24mi') Dtahoremissao,
                           FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                  'BIS_COMPANY',
                                                  'NEOGRID') as CpfCnpjRep,
                           DECODE(C.FISICAJURIDICA,
                                  'J',
                                  LPAD(C.NROCGCCPF || LPAD(C.DIGCGCCPF, 2, 0),
                                       14,
                                       '0'),
                                  LPAD(C.NROCGCCPF || LPAD(C.DIGCGCCPF, 2, 0),
                                       11,
                                       '0')) as CpfCnpjCliente,
                           e.Uf Ufemissor,
                           Regexp_Replace(Substr(e.Cep, 1, 8), '[^0-9]') Cepemissor,
                           c.Uf Ufdestinatario,
                           Regexp_Replace(Substr(c.Cep, 1, 8), '[^0-9]') Cepdestinatario,
                           Decode(a.Tipofrete, 'C', 'CIF', 'F', 'FOB') As Tipofrete,
                           Nvl(f.Nrodiavencto, 0) As Diaspagto,
                           Lpad(g.Nrocgccpf || Lpad(g.Digcgccpf, 2, '0'),
                                14,
                                '0') Cnpjfornecedor
                      From Mflv_Basedfitem   a,
                           Map_Famfornec     b,
                           Ge_Pessoa         c,
                           Max_Empserienf    d,
                           Max_Empresa       e,
                           Mad_Condicaopagto f,
                           Ge_Pessoa         g,
                           Max_Codgeraloper  h
                     where A.SEQPRODUTO in
                           (select X.SEQUENCIA
                              From Maxx_Selecrowid x
                             Where x.Seqselecao = 2)
                       And a.Seqpessoa = c.Seqpessoa
                       And a.Nroempresa = d.Nroempresa(+)
                       And a.Seriedf = d.Serienf(+)
                       And a.Nroempresa = e.Nroempresa
                       And a.Nroempresa = Pnnroempresa
                       And a.Dtaentrada Between Pddtainicial And Pddtafinal
                       And a.Tipnotafiscal || a.Tipdocfiscal In ('ED', 'SC')
                       and (a.acmcompravenda in ('S', 'I') or
                           a.apporigem in (2, 3, 18))
                       and ((vsPDGeraNfSerieOe = 'N' And
                           NVL(D.TIPODOCTO, 'x') != 'O') or
                           (Vspdgeranfserieoe = 'S'))
                       And Nvl(a.Statusnfe, 0) != 6
                       And a.Statusdf != 'C'
                       And a.Statusitem != 'C'
                       And a.Nrocondicaopagto = f.Nrocondicaopagto(+)
                       And a.Seqfamilia = b.Seqfamilia
                       And b.Seqfornecedor = g.Seqpessoa
                       And b.Principal = 'S'
                       And a.Codgeraloper = h.Codgeraloper
                       and A.CODGERALOPER not in
                           (select X.SEQUENCIA
                              From Maxx_Selecrowid x
                             Where x.Seqselecao = 5)
                    --     and    decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', H.EXGREFDEVOLUCAO, 'S' ) != decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', 'N', 'N' )
                     Group By a.Numerodf,
                              a.Seriedf,
                              (Case
                                When Nvl(a.Statusdf, 'V') = 'C' Or
                                     Nvl(a.Statusitem, 'V') = 'C' Then
                                 '03'
                                else
                                 decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                        'ED',
                                        '02',
                                        '01')
                              End),
                              a.Dtaentrada,
                              a.Nrorepresentante,
                              c.Fisicajuridica,
                              c.Nrocgccpf,
                              c.Digcgccpf,
                              e.Uf,
                              e.Cep,
                              c.Uf,
                              c.Cep,
                              a.Tipofrete,
                              f.Nrodiavencto,
                              LPAD(G.NROCGCCPF || LPAD(G.DIGCGCCPF, 2, '0'),
                                   14,
                                   '0')
                    Union All
                    select A.NUMERODF NUMERODF,
                           a.Seriedf Seriedf,
                           (Case
                             When Nvl(a.Statusdf, 'V') = 'C' Or
                                  Nvl(a.Statusitem, 'V') = 'C' Then
                              '03'
                             Else
                              Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                     'ED',
                                     '02',
                                     '01')
                           End) As Tiponotafiscal,
                           To_Char(a.Dtaentrada, 'yyyymmddhh24mi') Dtahoremissao,
                           Fbuscacpfrepresentante(a.Nrorepresentante,
                                                  'BIS_COMPANY',
                                                  'NEOGRID') As Cpfcnpjrep,
                           Decode(c.Fisicajuridica,
                                  'J',
                                  Lpad(c.Nrocgccpf || Lpad(c.Digcgccpf, 2, 0),
                                       14,
                                       '0'),
                                  Lpad(c.Nrocgccpf || Lpad(c.Digcgccpf, 2, 0),
                                       11,
                                       '0')) As Cpfcnpjcliente,
                           e.Uf Ufemissor,
                           Regexp_Replace(Substr(e.Cep, 1, 8), '[^0-9]') Cepemissor,
                           c.Uf Ufdestinatario,
                           Regexp_Replace(Substr(c.Cep, 1, 8), '[^0-9]') Cepdestinatario,
                           Decode(a.Tipofrete, 'C', 'CIF', 'F', 'FOB') As Tipofrete,
                           Nvl(f.Nrodiavencto, 0) As Diaspagto,
                           Lpad(g.Nrocgccpf || Lpad(g.Digcgccpf, 2, '0'),
                                14,
                                '0') Cnpjfornecedor
                      From Mflv_Basedfitem   a,
                           Map_Famfornec     b,
                           Ge_Pessoa         c,
                           Max_Empserienf    d,
                           Max_Empresa       e,
                           Mad_Condicaopagto f,
                           Ge_Pessoa         g,
                           Max_Codgeraloper  h
                     Where a.Seqproduto In
                           (Select x.Sequencia
                              From Maxx_Selecrowid x
                             Where x.Seqselecao = 2)
                       And a.Seqpessoa = c.Seqpessoa
                       And a.Nroempresa = d.Nroempresa(+)
                       And a.Seriedf = d.Serienf(+)
                       And a.Nroempresa = e.Nroempresa
                       And a.Nroempresa = Pnnroempresa
                       And a.Dtaentrada Between Pddtainicial And Pddtafinal
                       and ((vsPDGeraNfSerieOe = 'N' And
                           NVL(D.TIPODOCTO, 'x') != 'O') or
                           (Vspdgeranfserieoe = 'S'))
                       And Nvl(a.Statusnfe, 0) != 6
                       And a.Statusdf != 'C'
                       And a.Statusitem != 'C'
                       And a.Nrocondicaopagto = f.Nrocondicaopagto(+)
                       And a.Seqfamilia = b.Seqfamilia
                       And b.Seqfornecedor = g.Seqpessoa
                       And b.Principal = 'S'
                       And a.Codgeraloper = h.Codgeraloper
                          --     and    decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', H.EXGREFDEVOLUCAO, 'S' ) != decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', 'N', 'N' )
                       and A.CODGERALOPER in
                           (select X.SEQUENCIA
                              From Maxx_Selecrowid x
                             Where x.Seqselecao = 5)
                    /*IN (SELECT COLUMN_VALUE
                    FROM TABLE(cast(c5_ComplexIn.c5InTable(vsPDCGOsBonificacao) as c5InStrTable)))*/
                     Group By a.Numerodf,
                              a.Seriedf,
                              (Case
                                When Nvl(a.Statusdf, 'V') = 'C' Or
                                     Nvl(a.Statusitem, 'V') = 'C' Then
                                 '03'
                                Else
                                 Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                        'ED',
                                        '02',
                                        '01')
                              End),
                              a.Dtaentrada,
                              a.Nrorepresentante,
                              c.Fisicajuridica,
                              c.Nrocgccpf,
                              c.Digcgccpf,
                              e.Uf,
                              e.Cep,
                              c.Uf,
                              c.Cep,
                              a.Tipofrete,
                              f.Nrodiavencto,
                              Lpad(g.Nrocgccpf || Lpad(g.Digcgccpf, 2, '0'),
                                   14,
                                   '0')
                     Order By Cnpjfornecedor, Numerodf, Seriedf) Loop
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '02' || '|';
      -- Tipo de Faturamento
      Vslinha := Vslinha || '01' || '|';
      -- Numero Nota Fiscal
      Vslinha := Vslinha || Vtvenda.Numerodf || '|';
      -- Serie Nota Fiscal
      Vslinha := Vslinha || Vtvenda.Seriedf || '|';
      -- Tipo da Nota Fiscal
      Vslinha := Vslinha || Vtvenda.Tiponotafiscal || '|';
      -- Data Emissão NF
      Vslinha := Vslinha || Vtvenda.Dtahoremissao || '|';
      -- Código Representante
      Vslinha := Vslinha || Vtvenda.Cpfcnpjrep || '|';
      -- Código Cliente
      Vslinha := Vslinha || Vtvenda.Cpfcnpjcliente || '|';
      -- UF Emissor Mercadoria
      Vslinha := Vslinha || Vtvenda.Ufemissor || '|';
      -- CEP Emissor
      Vslinha := Vslinha || Vtvenda.Cepemissor || '|';
      -- UF Destinatario Mercadoria
      Vslinha := Vslinha || Vtvenda.Ufdestinatario || '|';
      -- CEP Destinatario
      Vslinha := Vslinha || Vtvenda.Cepdestinatario || '|';
      -- Tipo de Frete
      Vslinha := Vslinha || Vtvenda.Tipofrete || '|';
      -- Dias de Pagamento
      Vslinha       := Vslinha || Vtvenda.Diaspagto || '|';
      vsNomeArquivo := 'VENDAS' || '_' || vtVenda.CNPJFornecedor || '_' ||
                       vsCNPJEmpresa;
      Vncontador    := Vncontador + 1;
      -- Insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha,
         Auxiliar1,
         Seqnotafiscal)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         2,
         Vncontador,
         Vtvenda.Seriedf,
         Vtvenda.Numerodf);
      --
    End Loop;
    --
    -- Gera o Registro 03 - ITENS
    For Vtvendaitens In (Select a.Numerodf   Numerodf,
                                a.Seriedf    Seriedf,
                                a.Seqproduto As Codigoprod,
                                /*decode(vsPDUtilCodAcessoProdEdi, 'S',
                                round(SUM(A.QUANTIDADE / DECODE(FCODACESSOPRODEDI(A.SEQPRODUTO, 'E', 'N'), null, A.QTDEMBALAGEM, 1)),5),
                                round(SUM(A.QUANTIDADE / fpadraoembvendaseg(A.SEQFAMILIA, A.nrosegmento) ),5) ) as Quantidade,*/
                                Round(Sum(a.Quantidade), 5) As Quantidade,
                                Decode(a.Codgeraloper,
                                       c.Cgonfbonificacao,
                                       'S',
                                       'N') As Bonificacao,
                                Round((Sum(a.Vlrcontabil) /
                                      Sum(a.Quantidade)),
                                      2) As Vlrunitario,
                                Round(Sum(a.Vlrcontabil), 2) As Vlrbruto,
                                (Case
                                  When Sum(a.Vlrcontabil -
                                           (a.Vlricms + a.Vlrpis +
                                           a.Vlrcofins)) < 0 Then
                                   0
                                  Else
                                   Round(Sum(a.Vlrcontabil -
                                             (a.Vlricms + a.Vlrpis +
                                             a.Vlrcofins)),
                                         2)
                                End) As Vlrliquido,
                                Round(Sum(a.Vlripi), 2) As Vlripi,
                                Round(Sum(a.Vlrpis + a.Vlrcofins), 2) As Vlrpiscofins,
                                Round(Sum(a.Vlricmsst), 2) As Vlricmsst,
                                Round(Sum(a.Vlricms), 2) As Vlricms,
                                Round(Sum(a.Vlrdesconto), 2) As Vlrdesconto,
                                (Case
                                  When Nvl(a.Statusdf, 'V') = 'C' Or
                                       Nvl(a.Statusitem, 'V') = 'C' Then
                                   '03'
                                  Else
                                   Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                          'ED',
                                          '02',
                                          '01')
                                End) As Tiponotafiscal,
                                Lpad(g.Nrocgccpf ||
                                     Lpad(g.Digcgccpf, 2, '0'),
                                     14,
                                     '0') Cnpjfornecedor
                           From Mflv_Basedfitem  a,
                                Map_Produto      b,
                                Mad_Parametro    c,
                                Max_Empserienf   d,
                                Map_Famembalagem e,
                                Map_Famfornec    f,
                                Ge_Pessoa        g,
                                Max_Codgeraloper h
                          Where a.Nroempresa = d.Nroempresa(+)
                            And a.Seriedf = d.Serienf(+)
                            And a.Seqproduto In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 2)
                            And a.Nroempresa = c.Nroempresa
                            And a.Seqproduto = b.Seqproduto
                            And a.Qtdembalagem = e.Qtdembalagem
                            And b.Seqfamilia = e.Seqfamilia
                            And a.Nroempresa = Pnnroempresa
                            And a.Dtaentrada Between Pddtainicial And
                                Pddtafinal
                            And a.Tipnotafiscal || a.Tipdocfiscal In
                                ('ED', 'SC')
                            And (a.Acmcompravenda In ('S', 'I') Or
                                a.Apporigem In (2, 3, 18))
                            And ((Vspdgeranfserieoe = 'N' And
                                Nvl(d.Tipodocto, 'x') != 'O') Or
                                (Vspdgeranfserieoe = 'S'))
                            And Nvl(a.Statusnfe, 0) != 6
                            And a.Statusdf != 'C'
                            And a.Statusitem != 'C'
                            And a.Seqfamilia = f.Seqfamilia
                            And f.Seqfornecedor = g.Seqpessoa
                            And f.Principal = 'S'
                            And a.Codgeraloper = h.Codgeraloper
                            And a.Codgeraloper Not In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 5)
                         --       and    decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', H.EXGREFDEVOLUCAO, 'S' ) != decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', 'N', 'N' )
                          Group By a.Numerodf,
                                   a.Seriedf,
                                   a.Seqproduto,
                                   b.Desccompleta,
                                   Decode(a.Codgeraloper,
                                          c.Cgonfbonificacao,
                                          'S',
                                          'N'),
                                   (Case
                                     When Nvl(a.Statusdf, 'V') = 'C' Or
                                          Nvl(a.Statusitem, 'V') = 'C' Then
                                      '03'
                                     Else
                                      Decode(a.Tipnotafiscal ||
                                             a.Tipdocfiscal,
                                             'ED',
                                             '02',
                                             '01')
                                   End),
                                   Lpad(g.Nrocgccpf ||
                                        Lpad(g.Digcgccpf, 2, '0'),
                                        14,
                                        '0')
                         Union All
                         Select a.Numerodf   Numerodf,
                                a.Seriedf    Seriedf,
                                a.Seqproduto As Codigoprod,
                                /*decode(vsPDUtilCodAcessoProdEdi, 'S',
                                round(SUM(A.QUANTIDADE / DECODE(FCODACESSOPRODEDI(A.SEQPRODUTO, 'E', 'N'), null, A.QTDEMBALAGEM, 1)),5),
                                round(SUM(A.QUANTIDADE / fpadraoembvendaseg(A.SEQFAMILIA, A.nrosegmento) ),5) ) as Quantidade,*/
                                Round(Sum(a.Quantidade), 5) As Quantidade,
                                /*DECODE(A.CODGERALOPER,C.CGONFBONIFICACAO,'S','N') as Bonificacao,*/
                                'S' As Bonificacao,
                                Round((Sum(a.Vlrcontabil) /
                                      Sum(a.Quantidade)),
                                      2) As Vlrunitario,
                                Round(Sum(a.Vlrcontabil), 2) As Vlrbruto,
                                (Case
                                  When Sum(a.Vlrcontabil -
                                           (a.Vlricms + a.Vlrpis +
                                           a.Vlrcofins)) < 0 Then
                                   0
                                  Else
                                   Round(Sum(a.Vlrcontabil -
                                             (a.Vlricms + a.Vlrpis +
                                             a.Vlrcofins)),
                                         2)
                                End) As Vlrliquido,
                                Round(Sum(a.Vlripi), 2) As Vlripi,
                                Round(Sum(a.Vlrpis + a.Vlrcofins), 2) As Vlrpiscofins,
                                Round(Sum(a.Vlricmsst), 2) As Vlricmsst,
                                Round(Sum(a.Vlricms), 2) As Vlricms,
                                Round(Sum(a.Vlrdesconto), 2) As Vlrdesconto,
                                (Case
                                  When Nvl(a.Statusdf, 'V') = 'C' Or
                                       Nvl(a.Statusitem, 'V') = 'C' Then
                                   '03'
                                  Else
                                   Decode(a.Tipnotafiscal || a.Tipdocfiscal,
                                          'ED',
                                          '02',
                                          '01')
                                End) As Tiponotafiscal,
                                Lpad(g.Nrocgccpf ||
                                     Lpad(g.Digcgccpf, 2, '0'),
                                     14,
                                     '0') Cnpjfornecedor
                           From Mflv_Basedfitem  a,
                                Map_Produto      b,
                                Mad_Parametro    c,
                                Max_Empserienf   d,
                                Map_Famembalagem e,
                                Map_Famfornec    f,
                                Ge_Pessoa        g,
                                Max_Codgeraloper h
                          Where a.Nroempresa = d.Nroempresa(+)
                            And a.Seriedf = d.Serienf(+)
                            And a.Seqproduto In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 2)
                            And a.Nroempresa = c.Nroempresa
                            And a.Seqproduto = b.Seqproduto
                            And a.Qtdembalagem = e.Qtdembalagem
                            And b.Seqfamilia = e.Seqfamilia
                            And a.Nroempresa = Pnnroempresa
                            And a.Dtaentrada Between Pddtainicial And
                                Pddtafinal
                            And ((Vspdgeranfserieoe = 'N' And
                                Nvl(d.Tipodocto, 'x') != 'O') Or
                                (Vspdgeranfserieoe = 'S'))
                            And Nvl(a.Statusnfe, 0) != 6
                            And a.Statusdf != 'C'
                            And a.Statusitem != 'C'
                            And a.Seqfamilia = f.Seqfamilia
                            And f.Seqfornecedor = g.Seqpessoa
                            And f.Principal = 'S'
                            And a.Codgeraloper = h.Codgeraloper
                               --       and    decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', H.EXGREFDEVOLUCAO, 'S' ) != decode( A.TIPNOTAFISCAL || A.TIPDOCFISCAL, 'ED', 'N', 'N' )
                            And a.Codgeraloper In
                                (Select x.Sequencia
                                   From Maxx_Selecrowid x
                                  Where x.Seqselecao = 5)
                         /*IN (SELECT COLUMN_VALUE
                         FROM TABLE(cast(c5_ComplexIn.c5InTable(vsPDCGOsBonificacao) as c5InStrTable)))*/
                          Group By a.Numerodf,
                                   a.Seriedf,
                                   a.Seqproduto,
                                   b.Desccompleta,
                                   Decode(a.Codgeraloper,
                                          c.Cgonfbonificacao,
                                          'S',
                                          'N'),
                                   (Case
                                     When Nvl(a.Statusdf, 'V') = 'C' Or
                                          Nvl(a.Statusitem, 'V') = 'C' Then
                                      '03'
                                     Else
                                      Decode(a.Tipnotafiscal ||
                                             a.Tipdocfiscal,
                                             'ED',
                                             '02',
                                             '01')
                                   End),
                                   Lpad(g.Nrocgccpf ||
                                        Lpad(g.Digcgccpf, 2, '0'),
                                        14,
                                        '0')
                          Order By Cnpjfornecedor, Numerodf, Seriedf) Loop
      If Nvl(Vscnpjfornecedoranterior, 'x') != Vtvendaitens.Cnpjfornecedor Then
        -- Gera o cabeçalho do arquivo
        Sp_Gera_Cabecalho_V5(Pnnroempresa     => Pnnroempresa,
                             Pddtainicial     => Pddtainicial,
                             Pddtafinal       => Pddtafinal,
                             Pssoftpdv        => Pssoftpdv,
                             Psversaolayout   => '051',
                             Psidentificacao  => 'VENDAS',
                             Pscnpjfornecedor => Vtvendaitens.Cnpjfornecedor);
        Vscnpjfornecedoranterior := Vtvendaitens.Cnpjfornecedor;
        Vncontador               := 0;
      End If;
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '03' || '|';
      -- Numero Nota Fiscal
      Vslinha := Vslinha || Vtvendaitens.Numerodf || '|';
      -- Serie Nota Fiscal
      Vslinha := Vslinha || Vtvendaitens.Seriedf || '|';
      -- Tipo da Nota Fiscal
      Vslinha := Vslinha || Vtvendaitens.Tiponotafiscal || '|';
      -- Código do Produto
      Vslinha := Vslinha || Vtvendaitens.Codigoprod || '|';
      -- Quantidade vendida
      vsLinha := vsLinha ||
                 to_char(vtVendaItens.Quantidade, 'fm999990.00000') || '|';
      -- Valor Unitário
      vsLinha := vsLinha ||
                 to_char(vtVendaItens.VlrUnitario, 'fm9999990.00') || '|';
      -- Bonificação
      Vslinha := Vslinha || Vtvendaitens.Bonificacao || '|';
      -- Valor total bruto
      Vslinha := Vslinha || To_Char(Vtvendaitens.Vlrbruto, 'fm9999990.00') || '|';
      -- Valor total liquido
      vsLinha := vsLinha ||
                 to_char(vtVendaItens.VlrLiquido, 'fm9999990.00') || '|';
      -- Valor total IPI
      Vslinha := Vslinha || To_Char(Vtvendaitens.Vlripi, 'fm9999990.00') || '|';
      -- Valor total PIS / COFINS
      vsLinha := vsLinha ||
                 to_char(vtVendaItens.Vlrpiscofins, 'fm9999990.00') || '|';
      -- Valor total ST
      Vslinha := Vslinha || To_Char(Vtvendaitens.Vlricmsst, 'fm9999990.00') || '|';
      -- Valor total ICMS
      Vslinha := Vslinha || To_Char(Vtvendaitens.Vlricms, 'fm9999990.00') || '|';
      -- Valor total Descontos
      vsLinha       := vsLinha ||
                       to_char(vtVendaItens.Vlrdesconto, 'fm9999990.00') || '|';
      vsNomeArquivo := 'VENDAS' || '_' || vtVendaItens.CNPJFornecedor || '_' ||
                       vsCNPJEmpresa;
      Vncontador    := Vncontador + 1;
      --insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha,
         Auxiliar1,
         Seqnotafiscal)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         3,
         Vncontador,
         Vtvendaitens.Seriedf,
         Vtvendaitens.Numerodf);
    End Loop;
    --
    /* update MRLX_PDVIMPORTACAO a
          set ARQUIVO = ( select max(ARQUIVO) from MRLX_PDVIMPORTACAO b
                              where a.auxiliar1     = b.auxiliar1
                              and   a.seqnotafiscal = b.seqnotafiscal
                              and   b.arquivo like 'VENDAS_%'
                              and   b.ordem         = 3 )
    where a.ordem      = 2
    and   a.softpdv    = psSoftPDV
    and   a.nroempresa = pnNroEmpresa
    and   a.arquivo like 'VENDAS_%'
    and   exists ( select max(ARQUIVO) from MRLX_PDVIMPORTACAO b
                              where a.auxiliar1     = b.auxiliar1
                              and   a.seqnotafiscal = b.seqnotafiscal
                              and   b.arquivo like 'VENDAS_%'
                              and   b.ordem         = 3 );*/
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_VENDAS_v5 - ' || Sqlerrm);
  End Sp_Gera_Vendas_V5;
  Procedure Sp_Gera_Estoque_V5(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                               Pddtainicial In Date,
                               Pddtafinal   In Date,
                               Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE*/) is
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type := 'N';
    Vncontador               Integer := 0;
    Vscnpjfornecedoranterior Varchar2(14) := 'x';
  Begin
    Sp_Buscaparamdinamico('EXPORTACAO_NEOGRID',
                          0,
                          'UTIL_CODACESSOPRODEDI',
                          'S',
                          'N',
                          'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                          Vspdutilcodacessoprodedi);
    -- Busca CNPJ da Empresa
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    -- Gera Registro 02 - Estoque
    For Vtestoque In (Select a.Seqproduto As Codproduto,
                             --  To_Char(i.Dtaentradasaida, 'yyyymmddhh24mi') As Dtaestoque,
                             To_Char(Pddtafinal, 'yyyymmddhh24mi') As Dtaestoque,
                             Round(Sum((Nvl(i.Qtdestqinicial, 0) +
                                       Nvl(i.Qtdentrada, 0) -
                                       Nvl(i.Qtdsaida, 0)) / c.Qtdembalagem),
                                   3) As Qtdeestoque,
                             Round(Decode(Pddtafinal,
                                          Trunc(Sysdate),
                                          Nvl(Sum(h.Qtdpedrectransito), 0),
                                          0),
                                   3) As Qtdeestoquetrans,
                             Lpad(m.Nrocgccpf || Lpad(m.Digcgccpf, 2, 0),
                                  14,
                                  '0') As Cnpjfornecedor
                        From Map_Produto        a,
                             Max_Empresa        b,
                             Map_Famembalagem   c,
                             Mrl_Produtoempresa h,
                             /*Mrl_Prodestoquedia i,*/
                             mrl_custodia   i,
                             Map_Famdivisao f,
                             /*Mrl_Local          j,*/
                             Map_Famfornec l,
                             Ge_Pessoa     m
                       Where b.Nroempresa = Pnnroempresa
                         And a.Seqproduto = h.Seqproduto
                         And b.Nroempresa = h.Nroempresa
                         And a.Seqproduto = i.Seqproduto
                         And b.Nroempresa = i.Nroempresa
                            /*And i.Nroempresa = j.Nroempresa(+)
                            And i.Seqlocal   = j.Seqlocal(+)
                            And j.Tiplocal(+) In ('D', 'L')*/
                         And a.Seqfamilia = c.Seqfamilia
                         and C.QTDEMBALAGEM =
                             Decode(vsPDUtilCodAcessoProdEdi,
                                    'S',
                                    DECODE(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                             'E',
                                                             'N'),
                                           null,
                                           (select min(g.qtdembalagem)
                                              From Map_Famembalagem g
                                             where g.seqfamilia = a.seqfamilia),
                                           1),
                                    fpadraoembvendaseg(A.SEQFAMILIA,
                                                       B.NROSEGMENTOPRINC))
                         And f.Seqfamilia = a.Seqfamilia
                         And f.Nrodivisao = b.Nrodivisao
                         And f.Finalidadefamilia != 'B'
                         and I.DTAENTRADASAIDA =
                             (select max(X.DTAENTRADASAIDA)
                                From mrl_custodia x
                               Where x.Seqproduto = i.Seqproduto
                                 And x.Nroempresa = i.Nroempresa
                                 And x.Dtaentradasaida between
                                     pdDtaInicial - 31 and pdDtaFinal)
                         and A.SEQPRODUTO IN
                             (select X.SEQUENCIA
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 2)
                         And a.Seqfamilia = l.Seqfamilia
                         And l.Seqfornecedor = m.Seqpessoa
                         And l.Principal = 'S'
                         and L.SEQFORNECEDOR IN
                             (select X.SEQUENCIA
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 1)
                       group by A.SEQPRODUTO,
                                Pddtafinal,
                                LPAD(M.NROCGCCPF || LPAD(M.DIGCGCCPF, 2, 0),
                                     14,
                                     '0')
                       order by LPAD(M.NROCGCCPF || LPAD(M.DIGCGCCPF, 2, 0),
                                     14,
                                     '0'),
                                A.SEQPRODUTO) Loop
      If Nvl(Vscnpjfornecedoranterior, 'x') != Vtestoque.Cnpjfornecedor Then
        -- Gera o cabeçalho do arquivo
        Sp_Gera_Cabecalho_V5(Pnnroempresa     => Pnnroempresa,
                             Pddtainicial     => Pddtainicial,
                             Pddtafinal       => Pddtafinal,
                             Pssoftpdv        => Pssoftpdv,
                             Psversaolayout   => '050',
                             Psidentificacao  => 'RELEST',
                             Pscnpjfornecedor => Vtestoque.Cnpjfornecedor);
        Vscnpjfornecedoranterior := Vtestoque.Cnpjfornecedor;
        Vncontador               := 0;
      End If;
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '02' || '|';
      -- Data do Estoque
      Vslinha := Vslinha || Vtestoque.Dtaestoque || '|';
      -- Código do Produto
      Vslinha := Vslinha || Vtestoque.Codproduto || '|';
      -- Quantidade de Estoque
      If (Vtestoque.Qtdeestoque >= 0) Then
        vsLinha := vsLinha ||
                   to_char(vtEstoque.QtdeEstoque, 'fm9999990.00') || '|';
      Else
        Vslinha := Vslinha || To_Char(0, 'fm9999990.00') || '|';
      End If;
      -- Estoque em Transito
      If (Vtestoque.Qtdeestoquetrans >= 0) Then
        vsLinha := vsLinha ||
                   to_char(vtEstoque.QtdeEstoqueTrans, 'fm9999990.00') || '|';
      Else
        Vslinha := Vslinha || To_Char(0, 'fm9999990.00') || '|';
      End If;
      vsNomeArquivo := 'RELEST' || '_' || vtEstoque.CNPJFornecedor || '_' ||
                       vsCNPJEmpresa;
      Vncontador    := Vncontador + 1;
      --insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         2,
         Vncontador);
    End Loop;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_ESTOQUE_v5 - ' || Sqlerrm);
  End Sp_Gera_Estoque_V5;
  Procedure Sp_Gera_Prod_V5(Pnnroempresa In Max_Empresa.Nroempresa%Type,
                            Pssoftpdv    In Mrl_Empsoftpdv.Softpdv%Type /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   psCNPJFornecedor IN varchar2*/) is
    Vslinha       Varchar2(3000);
    Vscnpjempresa Varchar2(14);
    --  vsCNPJFornec                  varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vstipoitem               Varchar2(50);
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type;
    Vsconsideraembcodacesso  Max_Parametro.Parametro%Type;
    Vncontador               Integer := 0;
    Vnvlrprecovenda          Mrl_Prodempseg.Precobasenormal%Type;
    Vscnpjfornecedoranterior Varchar2(14) := 'x';
  Begin
    SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                          0,
                          'UTIL_CODACESSOPRODEDI',
                          'S',
                          'N',
                          'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                          Vspdutilcodacessoprodedi);
    SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                          0,
                          'CONSIDERA_EMB_CODACESSO',
                          'S',
                          'N',
                          'INFORMA SE CONSIDERA A QUANTIDADE DA EMBALAGEM DE VENDA PARA PEGAR O CODIGO DE ACESSO
                          (S/N) DEFAULT: N.',
                          Vsconsideraembcodacesso);
    --Busca CNPJ da Empresa
    Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
    /*  -- Gera o cabeçalho do arquivo
    Sp_Gera_Cabecalho_V5(Pnnroempresa     => Pnnroempresa,
                         Pddtainicial     => Null,
                         Pddtafinal       => Null,
                         Pssoftpdv        => Pssoftpdv,
                         Psversaolayout   => '051',
                         Psidentificacao  => 'RELPRO',
                         Pscnpjfornecedor => Null);*/
    -- Produto
    For Vtproduto In (Select a.Seqproduto   As Codinternoproduto,
                             a.Desccompleta As Descricaoprod,
                             --   nvl(FCODACESSOPRODEDI(A.SEQPRODUTO, 'E', 'N', decode(vsConsideraEmbCodAcesso, 'N', null, round(C.QTDEMBALAGEM,0))),A.SEQPRODUTO) as CodProduto,
                             nvl(nvl(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                       'E',
                                                       'N',
                                                       decode(vsConsideraEmbCodAcesso,
                                                              'N',
                                                              null,
                                                              round(C.QTDEMBALAGEM,
                                                                    0))),
                                     FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                       'D',
                                                       'N',
                                                       decode(vsConsideraEmbCodAcesso,
                                                              'N',
                                                              null,
                                                              round(C.QTDEMBALAGEM,
                                                                    0)))),
                                 A.SEQPRODUTO) as CodProduto,
                             decode(vsConsideraEmbCodAcesso,
                                    'N',
                                    1,
                                    round(C.QTDEMBALAGEM, 0)) as QtdEmbalagem,
                             h.Nroempresa,
                             b.Nrodivisao,
                             b.Uf As Ufempresa,
                             b.Nrosegmentoprinc As Segmento,
                             a.Seqfamilia,
                             Decode(l.Statusvenda, 'A', '01', 'I', '02') As Status,
                             LPAD(G.NROCGCCPF || LPAD(G.DIGCGCCPF, 2, '0'),
                                  14,
                                  '0') CNPJFornecedor
                        From Map_Produto        a,
                             Max_Empresa        b,
                             Map_Famembalagem   c,
                             Map_Famfornec      d,
                             Mrl_Produtoempresa h,
                             Map_Famdivisao     f,
                             Ge_Pessoa          g,
                             Mrl_Prodempseg     l
                       Where b.Nroempresa = Pnnroempresa
                         And a.Seqproduto = h.Seqproduto
                         And b.Nroempresa = h.Nroempresa
                         And a.Seqfamilia = c.Seqfamilia
                         and C.QTDEMBALAGEM =
                             Decode(vsPDUtilCodAcessoProdEdi,
                                    'S',
                                    DECODE(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                             'E',
                                                             'N'),
                                           null,
                                           (select min(g.qtdembalagem)
                                              From Map_Famembalagem g
                                             where g.seqfamilia = a.seqfamilia),
                                           1),
                                    fpadraoembvendaseg(A.SEQFAMILIA,
                                                       B.NROSEGMENTOPRINC))
                         And f.Seqfamilia = a.Seqfamilia
                         And f.Nrodivisao = b.Nrodivisao
                         And f.Finalidadefamilia != 'B'
                         and A.SEQPRODUTO IN
                             (select X.SEQUENCIA
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 2)
                         And a.Seqfamilia = d.Seqfamilia
                         And d.Seqfornecedor = g.Seqpessoa
                         And d.Principal = 'S'
                         And a.Seqproduto = l.Seqproduto
                         And l.Nrosegmento = b.Nrosegmentoprinc
                         And l.Nroempresa = b.Nroempresa
                         And l.Qtdembalagem = c.Qtdembalagem
                       Order By Cnpjfornecedor, Codinternoproduto) Loop
      If Nvl(Vscnpjfornecedoranterior, 'x') != Vtproduto.Cnpjfornecedor Then
        -- Gera o cabeçalho do arquivo
        Sp_Gera_Cabecalho_V5(Pnnroempresa     => Pnnroempresa,
                             Pddtainicial     => Null,
                             Pddtafinal       => Null,
                             Pssoftpdv        => Pssoftpdv,
                             Psversaolayout   => '051',
                             Psidentificacao  => 'RELPRO',
                             Pscnpjfornecedor => Vtproduto.Cnpjfornecedor);
        Vscnpjfornecedoranterior := Vtproduto.Cnpjfornecedor;
        Vncontador               := 0;
      End If;
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '02' || '|';
      /* -- CNPJ do Fornecedor Lpad(B.DIGCGCCPF, 2, '0')
      select  nvl(max(substr(b.nrocgccpf || lpad(b.digcgccpf, 2, 0),1,14)),0)
      into    vsCNPJFornec
      from    maf_fornecedi a, ge_pessoa b
      where   a.nroempresa  = vtProduto.Nroempresa
      and     a.nomeedi     = psSoftPDV
      and     a.layout      = 'NEOGRID'
      and     a.status      = 'A'
      and     a.seqfornecedor  = b.seqpessoa;*/
      Vslinha := Vslinha || Vtproduto.Cnpjfornecedor || '|';
      -- Código do Item
      Vslinha := Vslinha || Vtproduto.Codinternoproduto || '|';
      -- Código do Produto
      Vslinha := Vslinha || Vtproduto.Codproduto || '|';
      -- Tipo Item
      Select Decode(Count(1), 0, '01', '02')
        Into Vstipoitem
        From Mrl_Prodempseg Empseg
       Where Empseg.Seqproduto = Vtproduto.Codinternoproduto
         And Empseg.Nroempresa = Vtproduto.Nroempresa
         And Empseg.Precovalidpromoc > 0;
      Vslinha := Vslinha || Vstipoitem || '|';
      -- Final Tipo Item
      -- Quantidade de Produtos na Embalagem
      Vslinha := Vslinha || To_Char(Vtproduto.Qtdembalagem, 'fm9990.00000') || '|';
      -- Preço unitario cadastrado para venda
      Begin
        Select Nvl(Max(To_Char(Decode(a.Precovalidpromoc,
                                      0,
                                      a.Precovalidnormal,
                                      a.Precovalidpromoc) / a.Qtdembalagem,
                               'fm9999999.90')),
                   0)
          Into Vnvlrprecovenda
          From Mrl_Prodempseg a
         Where a.Seqproduto = Vtproduto.Codinternoproduto
           and a.qtdembalagem =
               DECODE(vsPDUtilCodAcessoProdEdi,
                      'S',
                      fpadraoembvendaseg(vtProduto.SEQFAMILIA, A.nrosegmento),
                      vtProduto.QtdEmbalagem)
           And a.Nroempresa = Vtproduto.Nroempresa
           And a.Nrosegmento = Vtproduto.Segmento;
        -- RC 155738
        If Vnvlrprecovenda = 0 Then
          Select Nvl(Max(To_Char(Decode(a.Precovalidpromoc,
                                        0,
                                        a.Precovalidnormal,
                                        a.precovalidpromoc) /
                                 a.QtdEmbalagem,
                                 'fm9999999.90')),
                     0) as PrecoVenda
            Into Vnvlrprecovenda
            From Mrl_Prodempseg a
           Where a.Seqproduto = Vtproduto.Codinternoproduto
             and a.qtdembalagem =
                 DECODE(vsPDUtilCodAcessoProdEdi,
                        'S',
                        fpadraoembvendaseg(vtProduto.SEQFAMILIA,
                                           A.nrosegmento),
                        vtProduto.QtdEmbalagem)
             and a.nroempresa = vtProduto.Nroempresa having
           max(round(decode(a.precovalidpromoc,
                                  0,
                                  a.Precovalidnormal,
                                  a.Precovalidpromoc) / a.Qtdembalagem,
                           2)) > 0;
        End If;
      Exception
        when no_data_found then
          Vnvlrprecovenda := 0;
      End;
      --    vsLinha := vsLinha || vnVlrPrecoVenda || '|';
      Vslinha := Vslinha || Trim(To_Char(Vnvlrprecovenda, '9999990D99')) || '|';
      -- Final Preço de Venda
      -- Descrição interna do item
      Vslinha := Vslinha || Vtproduto.Descricaoprod || '|';
      -- Status do Item
      Vslinha := Vslinha || Vtproduto.Status || '|';
      --   Vsnomearquivo := 'RELPRO' || '_' || Vscnpjempresa;
      vsNomeArquivo := 'RELPRO' || '_' || Vtproduto.CNPJFornecedor || '_' ||
                       vsCNPJEmpresa;
      Vncontador    := Vncontador + 1;
      -- insert
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         2,
         Vncontador);
    End Loop;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'SP_GERA_PROD_v5 - ' || Sqlerrm);
  End Sp_Gera_Prod_V5;
  /* Final Versão 5.0 NEO */
  /* Santa Helena - Início */
  Procedure Sp_Gera_Cabecalho_Santahelena(Pnnroempresa    In Max_Empresa.Nroempresa%Type,
                                          Pddtainicial    In Date,
                                          Pddtafinal      In Date,
                                          Pssoftpdv       In Mrl_Empsoftpdv.Softpdv%Type,
                                          Psversaolayout  In Max_Edi.Versao_Layout%Type,
                                          Psidentificacao In Varchar2,
                                          psCNPJDest      IN VARCHAR2) IS
    Vslinha           Varchar2(300);
    Vscodedirelatorio Varchar2(20);
    Vscnpjempresa     Varchar2(14);
    Vsnomearquivo     Varchar2(40);
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Busca Numero do Relatorio
      Select Nvl(Max(a.Codedifornec), '0')
        Into Vscodedirelatorio
        From Maf_Fornecedi a
       Where a.Status = 'A'
         And a.Nomeedi = Pssoftpdv
         And a.Layout = 'NEOGRID'
         And a.Nroempresa = Pnnroempresa;
      -- Inicia Linha
      Vslinha := '';
      -- Tipo de Registro
      Vslinha := Vslinha || '01' || '|';
      -- Identificacao
      Vslinha := Vslinha || Psidentificacao || '|';
      -- Versao
      Vslinha := Vslinha || '050' || '|';
      -- Numero do Relatorio
      Vslinha := Vslinha || Vscodedirelatorio || '|';
      -- Data - Hora de Emissao do Documento
      Vslinha := Vslinha || To_Char(Sysdate, 'YYYYMMDDHH24MI') || '|';
      -- Data Inicial do Periodo
      If Pddtainicial Is Not Null Then
        Vslinha := Vslinha || To_Char(Pddtainicial, 'YYYYMMDD') || '|';
      End If;
      -- Data Final do Periodo
      If Pddtafinal Is Not Null Then
        Vslinha := Vslinha || To_Char(Pddtafinal, 'YYYYMMDD') || '|';
      End If;
      -- CNPJ do Emissor do Relatorio (Distribuidor)
      Vslinha := Vslinha || Vscnpjempresa || '|';
      -- CNPJ do Destinatario do Relatorio (Fornecedor)
      Vslinha := Vslinha || Pscnpjdest;
      -- Nome do Arquivo
      Vsnomearquivo := Psidentificacao || '_' || Vscnpjempresa;
      -- Insere os Dados do Cabecalho
      Insert Into Mrlx_Pdvimportacao
        (Nroempresa,
         Softpdv,
         Dtamovimento,
         Dtahorlancamento,
         Arquivo,
         Linha,
         Ordem,
         Seqlinha)
      Values
        (Pnnroempresa,
         Pssoftpdv,
         Sysdate,
         Sysdate,
         Vsnomearquivo,
         Vslinha,
         1,
         1);
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_CABECALHO_SantaHelena - ' || Sqlerrm);
  End Sp_Gera_Cabecalho_Santahelena;
  Procedure Sp_Gera_Vendedor_Santahelena(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                         Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                         psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) IS
    Vslinha       Varchar2(300);
    Vscnpjempresa Varchar2(14);
    Vsnomearquivo Varchar2(40);
    Vncontador    Integer := 0;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      --Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o Cabeçalho do Arquivo
      Sp_Gera_Cabecalho_Santahelena(Pnnroempresa    => Pnnroempresa,
                                    Pddtainicial    => Null,
                                    Pddtafinal      => Null,
                                    Pssoftpdv       => Pssoftpdv,
                                    Psversaolayout  => Psversaolayout,
                                    Psidentificacao => 'RELVEN',
                                    Pscnpjdest      => '03887830009046');
      -- Vendedor
      For vtVendedor In (Select B.NOMERAZAO As NomeRazaoRepres,
                                FBUSCACPFREPRESENTANTE(A.NROREPRESENTANTE,
                                                       'SANTA_HELENA',
                                                       'NEOGRID') As NroRepresentante,
                                d.Nomerazao As Nomerazaosup,
                                Lpad(D.NROCGCCPF, 9, '0') ||
                                Lpad(D.DIGCGCCPF, 2, '0') As CNPJSuper,
                                a.Status As Status,
                                To_Char(Decode(Nvl(A.STATUS, 'A'),
                                               'I',
                                               A.DTAAFASTAMENTO,
                                               Trunc(Sysdate)),
                                        'YYYYMMDD') As DtaDesligamento
                           From Mad_Representante a,
                                Ge_Pessoa         b,
                                Mad_Equipe        c,
                                Ge_Pessoa         d
                          Where a.Seqpessoa = b.Seqpessoa
                            And a.Nroequipe = c.Nroequipe
                            And a.Status = 'A'
                            And c.Seqpessoa = d.Seqpessoa
                            And A.NROREPRESENTANTE In
                                (Select X.SEQUENCIA
                                   From Maxx_Selecrowid x
                                  Where X.SEQSELECAO = 3)) Loop
        -- Inicia Linha
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Nome Vendedor
        Vslinha := Vslinha || Substr(Vtvendedor.Nomerazaorepres, 0, 50) || '|';
        -- Codigo Vendedor
        Vslinha := Vslinha || Vtvendedor.Nrorepresentante || '|';
        -- Nome Supervisor
        Vslinha := Vslinha || Substr(Vtvendedor.Nomerazaosup, 0, 50) || '|';
        -- Codigo Supervisor
        Vslinha := Vslinha || Nvl(Vtvendedor.Cnpjsuper, 'NAO INFORMADO') || '|';
        -- Nome Gerente
        Vslinha := Vslinha || Substr(Vtvendedor.Nomerazaosup, 0, 50) || '|';
        -- Codigo Gerente
        Vslinha := Vslinha || Vtvendedor.Cnpjsuper || '|';
        -- Status Vendedor
        Vslinha := Vslinha || Vtvendedor.Status || '|';
        -- Data de Desligamento Vendedor
        Vslinha := Vslinha || Vtvendedor.Dtadesligamento;
        -- Nome do Arquivo
        Vsnomearquivo := 'RELVEN' || '_' || Vscnpjempresa;
        -- Contador
        Vncontador := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vtvendedor.Nrorepresentante);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_VENDEDOR_SantaHelena - ' || Sqlerrm);
  End Sp_Gera_Vendedor_Santahelena;
  Procedure Sp_Gera_Cliente_Santahelena(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                        Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                        psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) IS
    Vslinha                Varchar2(3000);
    Vscnpjempresa          Varchar2(14);
    Vsnomearquivo          Varchar2(40);
    Vscodsegmentocli       Varchar2(3);
    Vscodfreqvisita        Varchar2(2);
    Vspdtipocodsegmentocli Max_Parametro.Valor%Type;
    Vscontatocompra        Mrl_Cliente.Contatocomprador%Type;
    Vncontador             Integer := 0;
    /*Vnseqfornecedor        Maf_Fornecedor.Seqfornecedor%Type;*/
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      -- Busca Paramentro Dinamico
      Select Nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'TIPO_CODSEGMENTO_CLI'),
                 'A')
        Into Vspdtipocodsegmentocli
        From Dual;
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o Cabecalho do Arquivo
      Sp_Gera_Cabecalho_Santahelena(Pnnroempresa    => Pnnroempresa,
                                    Pddtainicial    => Null,
                                    Pddtafinal      => Null,
                                    Pssoftpdv       => Pssoftpdv,
                                    Psversaolayout  => Psversaolayout,
                                    Psidentificacao => 'RELCLI',
                                    Pscnpjdest      => '03887830009046');
      -- Clientes
      For vtCliente In (Select A.SEQPESSOA As SeqPessoa,
                               Decode(A.FISICAJURIDICA,
                                      'J',
                                      LPAD(A.NROCGCCPF ||
                                           LPAD(A.DIGCGCCPF, 2, '0'),
                                           14,
                                           '0'),
                                      LPAD(A.NROCGCCPF ||
                                           LPAD(A.DIGCGCCPF, 2, '0'),
                                           11,
                                           '0')) As CpfCnpjCliente,
                               Regexp_Replace(a.Cep, '[^0-9]') As Cepcliente,
                               a.Uf As Ufcliente,
                               a.Cidade As Cidadecliente,
                               A.LOGRADOURO || ' ' || A.NROLOGRADOURO || ' ' ||
                               A.CMPLTOLOGRADOURO As EnderecoCliente,
                               a.Bairro As Bairrocliente,
                               a.Nomerazao As Nomerazaocliente,
                               Upper(a.Atividade) As Atividadecliente,
                               Upper(a.Grupo) As Grupocliente,
                               Nvl((A.FONEDDD1 || A.FONENRO1),
                                   (A.FONEDDD2 || A.FONENRO2)) As FoneCliente
                          From Ge_Pessoa a
                         Where A.SEQPESSOA In
                               (Select X.SEQUENCIA
                                  From Maxx_Selecrowid x
                                 Where X.SEQSELECAO = 4)) Loop
        -- Inicia Linha
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Codigo Cliente
        Vslinha := Vslinha || Vtcliente.Cpfcnpjcliente || '|';
        -- CEP Cliente
        Vslinha := Vslinha || Vtcliente.Cepcliente || '|';
        -- UF Cliente
        Vslinha := Vslinha || Vtcliente.Ufcliente || '|';
        -- Cidade Cliente
        Vslinha := Vslinha || Substr(Vtcliente.Cidadecliente, 0, 100) || '|';
        -- Endereco Cliente
        Vslinha := Vslinha || Substr(Vtcliente.Enderecocliente, 0, 100) || '|';
        -- Bairro Cliente
        Vslinha := Vslinha || Substr(Vtcliente.Bairrocliente, 0, 50) || '|';
        -- Nome Cliente
        Vslinha := Vslinha || Substr(Vtcliente.Nomerazaocliente, 0, 100) || '|';
        -- Codigo Segmento Cliente
        If (Vspdtipocodsegmentocli = 'G') Then
          Vscodsegmentocli := Fbuscacodsegcli_Santahelena(Vtcliente.Grupocliente);
        Else
          Vscodsegmentocli := Fbuscacodsegcli_Santahelena(Vtcliente.Atividadecliente);
        End If;
        Vslinha := Vslinha || Vscodsegmentocli || '|';
        -- Frequencia Visita
        Begin
          Select Case
                   When (A.PERIODVISITA = 'D' Or A.PERIODVISITA = 'S') Then
                    '03' -- Semanal
                   When A.PERIODVISITA = 'Q' Then
                    '02' -- Quinzenal
                   When A.PERIODVISITA = 'M' Then
                    '01' -- Mensal
                   Else
                    '04'
                 End
            Into Vscodfreqvisita
            From Mad_Clienterep a, Maxx_Selecrowid x
           Where x.Seqselecao = 3
             And a.Nrorepresentante = x.Sequencia
             And a.Seqpessoa = Vtcliente.Seqpessoa;
        Exception
          When No_Data_Found Then
            Vscodfreqvisita := '01';
          When Others Then
            Vscodfreqvisita := '01';
        End;
        Vslinha := Vslinha || Vscodfreqvisita || '|';
        -- Telefone Cliente
        Vslinha := Vslinha || Vtcliente.Fonecliente || '|';
        -- Contato Cliente
        Begin
          Select a.Contatocomprador
            Into Vscontatocompra
            From Mrl_Cliente a
           Where a.Seqpessoa = Vtcliente.Seqpessoa;
        Exception
          When No_Data_Found Then
            Vscontatocompra := '';
          When Others Then
            Vscontatocompra := '';
        End;
        Vslinha := Vslinha || Substr(Vscontatocompra, 0, 50);
        -- Nome do Arquivo
        Vsnomearquivo := 'RELCLI' || '_' || Vscnpjempresa;
        -- Contador
        Vncontador := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vtcliente.Seqpessoa);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_CLIENTE_SantaHelena - ' || Sqlerrm);
  End Sp_Gera_Cliente_Santahelena;
  Procedure Sp_Gera_Vendas_Santahelena(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                       Pddtainicial   In Date,
                                       Pddtafinal     In Date,
                                       Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                       psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) IS
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vscnpjfornec             Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vspdgeranfserieoe        Max_Parametro.Parametro%Type := 'N';
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type := 'N';
    Vncontador               Integer := 0;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      -- Busca Parametro Dinamico
      SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      -- Busca Paramentro Dinamico
      Select Nvl(fc5MaxParametro('EXPORTACAO_NEOGRID',
                                 0,
                                 'GERA_NF_SERIE_OE'),
                 'N')
        Into Vspdgeranfserieoe
        From Dual;
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Busca CNPJ da Industria/Fornecedor
      Select Max(b.Nrocgccpf || Lpad(b.Digcgccpf, 2, '0'))
        Into Vscnpjfornec
        From Maf_Fornecedi a, Ge_Pessoa b
       Where a.Nroempresa = Pnnroempresa
         And a.Nomeedi = Pssoftpdv
         And a.Layout = 'NEOGRID'
         And a.Status = 'A'
         And a.Seqfornecedor = b.Seqpessoa;
      -- Gera o Cabecalho do Arquivo
      Sp_Gera_Cabecalho_Santahelena(Pnnroempresa    => Pnnroempresa,
                                    Pddtainicial    => Pddtainicial,
                                    Pddtafinal      => Pddtafinal,
                                    Pssoftpdv       => Pssoftpdv,
                                    Psversaolayout  => Psversaolayout,
                                    Psidentificacao => 'VENDAS',
                                    Pscnpjdest      => Vscnpjfornec);
      -- Notas Fiscais
      For Vtvenda In (Select a.Seqnf As Seqnf,
                             a.Numerodf As Numerodf,
                             a.Seriedf As Seriedf,
                             (Case
                               When Nvl(A.STATUSDF, 'V') = 'C' Or
                                    Nvl(A.STATUSITEM, 'V') = 'C' Then
                                '03'
                               Else
                                Decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                       'ED',
                                       '02',
                                       '01')
                             End) As Tiponotafiscal,
                             --       To_Char(A.DTAHOREMISSAO, 'YYYYMMDDHH24MI') As DtaHorEmissao,
                             To_Char(a.Dtaentrada, 'YYYYMMDDHH24MI') As Dtahoremissao,
                             FBUSCACPFREPRESENTANTE(Max(A.NROREPRESENTANTE),
                                                    'SANTA_HELENA',
                                                    'NEOGRID') As CpfCnpjRep,
                             Decode(C.FISICAJURIDICA,
                                    'J',
                                    Lpad(C.NROCGCCPF ||
                                         Lpad(C.DIGCGCCPF, 2, 0),
                                         14,
                                         '0'),
                                    Lpad(C.NROCGCCPF ||
                                         Lpad(C.DIGCGCCPF, 2, 0),
                                         11,
                                         '0')) As CpfCnpjCliente,
                             e.Uf As Ufemissor,
                             Regexp_Replace(Substr(e.Cep, 1, 8), '[^0-9]') As Cepemissor,
                             c.Uf As Ufdestinatario,
                             Regexp_Replace(Substr(c.Cep, 1, 8), '[^0-9]') As Cepdestinatario,
                             Decode(a.Tipofrete, 'F', 'FOB', 'CIF') As Tipofrete,
                             Nvl(a.Prazomediovencto, 0) As Diaspagamento
                        From Mflv_Basedfitem a,
                             Ge_Pessoa       c,
                             Max_Empserienf  d,
                             Max_Empresa     e
                       Where A.SEQPRODUTO In
                             (Select X.SEQUENCIA
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 2)
                         And a.Seqpessoa = c.Seqpessoa
                         And a.Nroempresa = d.Nroempresa(+)
                         And a.Seriedf = d.Serienf(+)
                         And a.Nroempresa = e.Nroempresa
                         And a.Nroempresa = Pnnroempresa
                         And A.DTAENTRADA Between pdDtaInicial And
                             pdDtaFinal
                         And A.TIPNOTAFISCAL || A.TIPDOCFISCAL In
                             ('ED', 'SC')
                         And a.Acmcompravenda In ('S', 'I')
                         And ((vsPDGeraNfSerieOe = 'N' And
                             Nvl(D.TIPODOCTO, 'x') != 'O') Or
                             (Vspdgeranfserieoe = 'S'))
                         And Nvl(a.Statusnfe, 0) != 6
                         And A.NROREPRESENTANTE In
                             (Select X.SEQUENCIA
                                From Maxx_Selecrowid x
                               Where x.Seqselecao = 3) --RC142297
                       Group By a.Seqnf,
                                a.Numerodf,
                                a.Seriedf,
                                (Case
                                  When Nvl(A.STATUSDF, 'V') = 'C' Or
                                       Nvl(A.STATUSITEM, 'V') = 'C' Then
                                   '03'
                                  Else
                                   Decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                          'ED',
                                          '02',
                                          '01')
                                End),
                                a.Dtaentrada,
                                c.Fisicajuridica,
                                c.Nrocgccpf,
                                c.Digcgccpf,
                                e.Uf,
                                e.Cep,
                                c.Uf,
                                c.Cep,
                                a.Tipofrete,
                                a.Prazomediovencto
                       Order By A.NUMERODF, A.SERIEDF) Loop
        -- Inicia Linha
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Tipo de Faturamento
        Vslinha := Vslinha || '01' || '|';
        -- Numero NF
        Vslinha := Vslinha || Vtvenda.Numerodf || '|';
        -- Serie NF
        Vslinha := Vslinha || Vtvenda.Seriedf || '|';
        -- Tipo NF
        Vslinha := Vslinha || Vtvenda.Tiponotafiscal || '|';
        -- Data Emissao NF
        Vslinha := Vslinha || Vtvenda.Dtahoremissao || '|';
        -- Codigo do Vendedor (Representante)
        Vslinha := Vslinha || Vtvenda.Cpfcnpjrep || '|';
        -- Codigo Cliente
        Vslinha := Vslinha || Vtvenda.Cpfcnpjcliente || '|';
        -- UF Emissor Mercadoria
        Vslinha := Vslinha || Vtvenda.Ufemissor || '|';
        -- CEP Emissor Mercadoria
        Vslinha := Vslinha || Vtvenda.Cepemissor || '|';
        -- UF Destinatario Mercadoria
        Vslinha := Vslinha || Vtvenda.Ufdestinatario || '|';
        -- CEP Destinatario Mercadoria
        Vslinha := Vslinha || Vtvenda.Cepdestinatario || '|';
        -- Condicao de Entrega (tipo de frete)
        Vslinha := Vslinha || Vtvenda.Tipofrete || '|';
        -- Dias de Pagamento
        Vslinha := Vslinha || Vtvenda.Diaspagamento;
        -- Nome do Arquivo
        Vsnomearquivo := 'VENDAS' || '_' || Vscnpjempresa;
        -- Contador
        Vncontador := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha,
           Seqnotafiscal)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vncontador,
           Vtvenda.Seqnf);
      End Loop;
      -- Itens
      For vtVendaItens In (Select A.SEQNF As SeqNF,
                                  a.Numerodf As Numerodf,
                                  a.Seriedf As Seriedf,
                                  a.Seqproduto As Codigoprod,
                                  Decode(vsPDUtilCodAcessoProdEdi,
                                         'S',
                                         Sum(A.QUANTIDADE /
                                             Decode(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                                      'E',
                                                                      'N'),
                                                    Null,
                                                    A.QTDEMBALAGEM,
                                                    1)),
                                         Sum(A.QUANTIDADE /
                                             fpadraoembvendaseg(A.SEQFAMILIA,
                                                                A.NROSEGMENTO))) As Quantidade,
                                  Decode(A.CODGERALOPER,
                                         C.CGONFBONIFICACAO,
                                         'S',
                                         'N') As Bonificacao,
                                  Sum(a.Vlrcontabil / a.Quantidade) As Vlrunitario,
                                  Sum(a.Vlrcontabil) As Vlrbruto,
                                  (case
                                    when SUM(A.VLRCONTABIL -
                                             (A.VLRICMS + A.VLRPIS +
                                             A.VLRCOFINS)) < 0 then
                                     0
                                    else
                                     round(SUM(A.VLRCONTABIL -
                                               (A.VLRICMS + A.VLRPIS +
                                               A.VLRCOFINS)),
                                           2)
                                  End) As Vlrliquido,
                                  Sum(a.Vlripi) As Vlripi,
                                  Sum(a.Vlrpis + a.Vlrcofins) As Vlrpiscofins,
                                  Sum(a.Vlricmsst) As Vlricmsst,
                                  Sum(a.Vlricms) As Vlricms,
                                  Sum(a.Vlrdesconto) As Vlrdesconto,
                                  (Case
                                    When Nvl(A.STATUSDF, 'V') = 'C' Or
                                         Nvl(A.STATUSITEM, 'V') = 'C' Then
                                     '03'
                                    Else
                                     Decode(A.TIPNOTAFISCAL || A.TIPDOCFISCAL,
                                            'ED',
                                            '02',
                                            '01')
                                  End) As Tiponotafiscal
                             From Mflv_Basedfitem  a,
                                  Map_Produto      b,
                                  Mad_Parametro    c,
                                  Max_Empserienf   d,
                                  Map_Famembalagem e
                            Where a.Nroempresa = d.Nroempresa(+)
                              And a.Seriedf = d.Serienf(+)
                              And A.SEQPRODUTO In
                                  (Select X.SEQUENCIA
                                     From Maxx_Selecrowid x
                                    Where x.Seqselecao = 2)
                              And a.Nroempresa = c.Nroempresa
                              And a.Seqproduto = b.Seqproduto
                              And a.Qtdembalagem = e.Qtdembalagem
                              And b.Seqfamilia = e.Seqfamilia
                              And a.Nroempresa = Pnnroempresa
                              And A.DTAENTRADA Between pdDtaInicial And
                                  pdDtaFinal
                              And A.TIPNOTAFISCAL || A.TIPDOCFISCAL In
                                  ('ED', 'SC')
                              And a.Acmcompravenda In ('S', 'I')
                              And ((vsPDGeraNfSerieOe = 'N' And
                                  Nvl(D.TIPODOCTO, 'x') != 'O') Or
                                  (Vspdgeranfserieoe = 'S'))
                              And Nvl(a.Statusnfe, 0) != 6
                              And A.NROREPRESENTANTE In
                                  (Select X.SEQUENCIA
                                     From Maxx_Selecrowid x
                                    Where x.Seqselecao = 3)
                            Group By a.Seqnf,
                                     a.Numerodf,
                                     a.Seriedf,
                                     a.Seqproduto,
                                     b.Desccompleta,
                                     Decode(A.CODGERALOPER,
                                            C.CGONFBONIFICACAO,
                                            'S',
                                            'N'),
                                     (Case
                                       When Nvl(A.STATUSDF, 'V') = 'C' Or
                                            Nvl(A.STATUSITEM, 'V') = 'C' Then
                                        '03'
                                       Else
                                        Decode(A.TIPNOTAFISCAL ||
                                               A.TIPDOCFISCAL,
                                               'ED',
                                               '02',
                                               '01')
                                     End)
                            Order By A.NUMERODF, A.SERIEDF) Loop
        -- Inicia Linha
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '03' || '|';
        -- Numero NF
        Vslinha := Vslinha || Vtvendaitens.Numerodf || '|';
        -- Serie NF
        Vslinha := Vslinha || Vtvendaitens.Seriedf || '|';
        -- Tipo NF
        Vslinha := Vslinha || Vtvendaitens.Tiponotafiscal || '|';
        -- Codigo do Item
        Vslinha := Vslinha || Vtvendaitens.Codigoprod || '|';
        -- Quantidade Vendida
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.Quantidade, '99990D99999')) || '|';
        -- Preco Unitario Bruto Praticado
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrUnitario, '9999990D99')) || '|';
        -- Bonificacao
        Vslinha := Vslinha || Vtvendaitens.Bonificacao || '|';
        -- Valor Total Bruto
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrBruto, '9999990D99')) || '|';
        -- Valor Total Liquido
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrLiquido, '9999990D99')) || '|';
        -- Valor IPI
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrIPI, '9999990D99')) || '|';
        -- Valor PIS \ CONFINS
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrPISCOFINS, '9999990D99')) || '|';
        -- Valor Substituicao Tributaria
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrICMSST, '9999990D99')) || '|';
        -- Valor ICMS
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrICMS, '9999990D99')) || '|';
        -- Valor Descontos
        vsLinha := vsLinha ||
                   Trim(To_Char(vtVendaItens.VlrDesconto, '9999990D99'));
        -- Nome do Arquivo
        Vsnomearquivo := 'VENDAS' || '_' || Vscnpjempresa;
        -- Contador
        Vncontador := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha,
           Seqnotafiscal)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           3,
           Vncontador,
           Vtvendaitens.Seqnf);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_VENDAS_SantaHelena - ' || Sqlerrm);
  End Sp_Gera_Vendas_Santahelena;
  Procedure Sp_Gera_Estoque_Santahelena(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                        Pddtainicial   In Date,
                                        Pddtafinal     In Date,
                                        Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                        psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) IS
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vscnpjfornec             Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type := 'N';
    Vncontador               Integer := 0;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      -- Busca Parametro Dinamico
      SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Busca CNPJ da Industria/Fornecedor
      Select Max(b.Nrocgccpf || Lpad(b.Digcgccpf, 2, '0'))
        Into Vscnpjfornec
        From MAF_FORNECEDI A, GE_PESSOA B
       Where a.Nroempresa = Pnnroempresa
         And a.Nomeedi = Pssoftpdv
         And a.Layout = 'NEOGRID'
         And a.Status = 'A'
         And a.Seqfornecedor = b.Seqpessoa;
      -- Gera o Cabecalho do Arquivo
      Sp_Gera_Cabecalho_Santahelena(Pnnroempresa    => Pnnroempresa,
                                    Pddtainicial    => Pddtainicial,
                                    Pddtafinal      => Pddtafinal,
                                    Pssoftpdv       => Pssoftpdv,
                                    Psversaolayout  => Psversaolayout,
                                    Psidentificacao => 'RELEST',
                                    Pscnpjdest      => Vscnpjfornec);
      -- Gera Registro 02 - Estoque
      For vtEstoque In (Select A.SEQPRODUTO As CodProduto,
                               To_Char(i.Dtaentradasaida, 'YYYYMMDDHH24MI') As Dtaestoque,
                               Sum((Nvl(I.QTDESTQINICIAL, 0) +
                                   Nvl(I.QTDENTRADA, 0) -
                                   Nvl(I.QTDSAIDA, 0)) / C.QTDEMBALAGEM) As QtdeEstoque,
                               Decode(I.DTAENTRADASAIDA,
                                      Trunc(Sysdate),
                                      Nvl(Sum(H.QTDPEDRECTRANSITO), 0),
                                      0) As QtdeEstoqueTrans
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Mrl_Prodestoquedia i,
                               Map_Famdivisao     f,
                               Mrl_Local          j
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqproduto = i.Seqproduto
                           And b.Nroempresa = i.Nroempresa
                           And i.Nroempresa = j.Nroempresa
                           And i.Seqlocal = j.Seqlocal
                           And j.Tiplocal In ('D', 'L')
                           And a.Seqfamilia = c.Seqfamilia
                           And C.QTDEMBALAGEM =
                               Decode(vsPDUtilCodAcessoProdEdi,
                                      'S',
                                      Decode(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                               'E',
                                                               'N'),
                                             Null,
                                             (Select Min(G.QTDEMBALAGEM)
                                                From Map_Famembalagem g
                                               Where G.SEQFAMILIA =
                                                     A.SEQFAMILIA),
                                             1),
                                      fpadraoembvendaseg(A.SEQFAMILIA,
                                                         B.NROSEGMENTOPRINC))
                           And f.Seqfamilia = a.Seqfamilia
                           And f.Nrodivisao = b.Nrodivisao
                           And f.Finalidadefamilia != 'B'
                           And I.DTAENTRADASAIDA Between pdDtaInicial And
                               pdDtaFinal
                           And A.SEQPRODUTO In
                               (Select X.SEQUENCIA
                                  From Maxx_Selecrowid x
                                 Where x.Seqselecao = 2)
                         Group By A.SEQPRODUTO, I.DTAENTRADASAIDA) Loop
        -- Inicia Linha
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- Data - Hora do Estoque
        Vslinha := Vslinha || Vtestoque.Dtaestoque || '|';
        -- Codigo Item
        Vslinha := Vslinha || Vtestoque.Codproduto || '|';
        -- Quantidade de Estoque
        If (Vtestoque.Qtdeestoque >= 0) Then
          vsLinha := vsLinha ||
                     Trim(To_Char(vtEstoque.QtdeEstoque, '9999990D99')) || '|';
        Else
          Vslinha := Vslinha || To_Char(0, '9999990D99') || '|';
        End If;
        -- Estoque em Transito
        If (Vtestoque.Qtdeestoquetrans >= 0) Then
          vsLinha := vsLinha ||
                     Trim(To_Char(vtEstoque.QtdeEstoqueTrans, '9999990D99'));
        Else
          Vslinha := Vslinha || To_Char(0, '9999990D99') || '|';
        End If;
        -- Nome do Arquivo
        Vsnomearquivo := 'RELEST' || '_' || Vscnpjempresa;
        -- Contador
        Vncontador := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_ESTOQUE_SantaHelena - ' || Sqlerrm);
  End Sp_Gera_Estoque_Santahelena;
  Procedure Sp_Gera_Prod_Santahelena(Pnnroempresa   In Max_Empresa.Nroempresa%Type,
                                     Pssoftpdv      In Mrl_Empsoftpdv.Softpdv%Type,
                                     psVersaoLayout IN MAX_EDI.VERSAO_LAYOUT%TYPE) IS
    Vslinha                  Varchar2(3000);
    Vscnpjempresa            Varchar2(14);
    Vscnpjfornec             Varchar2(14);
    Vsnomearquivo            Varchar2(40);
    Vstipoitem               Varchar2(50);
    Vspdutilcodacessoprodedi Max_Parametro.Parametro%Type;
    Vncontador               Integer := 0;
    Vnvlrprecovenda          Mrl_Prodempseg.Precobasenormal%Type;
  Begin
    If Psversaolayout In ('5', '05', '50', '5.0', '050') Then
      -- Busca Parametro Dinamico
      SP_BUSCAPARAMDINAMICO('EXPORTACAO_NEOGRID',
                            0,
                            'UTIL_CODACESSOPRODEDI',
                            'S',
                            'N',
                            'UTILIZA CODIGO DE ACESSO PREFERENCIAL DO EDI S-SIM  N-NÃO(PADRÃO)',
                            Vspdutilcodacessoprodedi);
      -- Busca CNPJ da Empresa
      Vscnpjempresa := Fbuscacnpjempresa(Pnnroempresa);
      -- Gera o Cabecalho do Arquivo
      Sp_Gera_Cabecalho_Santahelena(Pnnroempresa    => Pnnroempresa,
                                    Pddtainicial    => Null,
                                    Pddtafinal      => Null,
                                    Pssoftpdv       => Pssoftpdv,
                                    Psversaolayout  => Psversaolayout,
                                    Psidentificacao => 'RELPRO',
                                    Pscnpjdest      => '03887830009046');
      -- Produto
      For vtProduto In (Select A.SEQPRODUTO As CodInternoProduto,
                               a.Desccompleta As Descricaoprod,
                               Nvl(FCODACESSOPRODEDI(A.SEQPRODUTO, 'E', 'N'),
                                   nvl(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                         'D',
                                                         'N'),
                                       A.SEQPRODUTO)) As CodProduto,
                               c.Qtdembalagem As Qtdembalagem,
                               h.Nroempresa As Nroempresa,
                               b.Nrodivisao As Nrodivisao,
                               b.Uf As Ufempresa,
                               b.Nrosegmentoprinc As Segmento,
                               a.Seqfamilia As Seqfamilia,
                               Decode(h.Statuscompra, 'I', '02', '01') As Status
                          From Map_Produto        a,
                               Max_Empresa        b,
                               Map_Famembalagem   c,
                               Mrl_Produtoempresa h,
                               Map_Famdivisao     f
                         Where b.Nroempresa = Pnnroempresa
                           And a.Seqproduto = h.Seqproduto
                           And b.Nroempresa = h.Nroempresa
                           And a.Seqfamilia = c.Seqfamilia
                           And C.QTDEMBALAGEM =
                               Decode(vsPDUtilCodAcessoProdEdi,
                                      'S',
                                      Decode(FCODACESSOPRODEDI(A.SEQPRODUTO,
                                                               'E',
                                                               'N'),
                                             Null,
                                             (Select Min(G.QTDEMBALAGEM)
                                                From Map_Famembalagem g
                                               Where G.SEQFAMILIA =
                                                     A.SEQFAMILIA),
                                             1),
                                      fpadraoembvendaseg(A.SEQFAMILIA,
                                                         B.NROSEGMENTOPRINC))
                           And f.Seqfamilia = a.Seqfamilia
                           And f.Nrodivisao = b.Nrodivisao
                           And f.Finalidadefamilia != 'B'
                           And A.SEQPRODUTO In
                               (Select X.SEQUENCIA
                                  From Maxx_Selecrowid x
                                 Where X.SEQSELECAO = 2)) Loop
        -- Inicia Linha
        Vslinha := '';
        -- Tipo de Registro
        Vslinha := Vslinha || '02' || '|';
        -- CNPJ da Industria/Fornecedor
        Select Max(b.Nrocgccpf || Lpad(b.Digcgccpf, 2, '0'))
          Into Vscnpjfornec
          From MAF_FORNECEDI A, GE_PESSOA B
         Where a.Nroempresa = Vtproduto.Nroempresa
           And a.Nomeedi = Pssoftpdv
           And a.Layout = 'NEOGRID'
           And a.Status = 'A'
           And a.Seqfornecedor = b.Seqpessoa;
        Vslinha := Vslinha || Vscnpjfornec || '|';
        -- Codigo Item
        Vslinha := Vslinha || Substr(Vtproduto.Codinternoproduto, 0, 20) || '|';
        -- Codigo Produto
        Vslinha := Vslinha || Substr(Vtproduto.Codproduto, 0, 14) || '|';
        -- Tipo Item
        Select Decode(Count(1), 0, '01', '02')
          Into Vstipoitem
          From Mrl_Prodempseg Empseg
         Where Empseg.Seqproduto = Vtproduto.Codinternoproduto
           And Empseg.Nroempresa = Vtproduto.Nroempresa
           And Empseg.Precovalidpromoc > 0;
        Vslinha := Vslinha || Vstipoitem || '|';
        -- Quantidade Produto Embalagem
        vsLinha := vsLinha ||
                   Trim(To_Char(vtProduto.QtdEmbalagem, '9990D99999')) || '|';
        -- Preco Tabela Unidade
        Begin
          Select Decode(a.Precovalidpromoc,
                        0,
                        A.PRECOVALIDNORMAL,
                        a.Precovalidpromoc) / a.Qtdembalagem
            Into Vnvlrprecovenda
            From Mrl_Prodempseg a
           Where a.Seqproduto = Vtproduto.Codinternoproduto
             And A.QTDEMBALAGEM =
                 Decode(vsPDUtilCodAcessoProdEdi,
                        'S',
                        fpadraoembvendaseg(vtProduto.SeqFamilia,
                                           A.NROSEGMENTO),
                        Vtproduto.Qtdembalagem)
             And a.Nroempresa = Vtproduto.Nroempresa
             And a.Nrosegmento = Vtproduto.Segmento;
        Exception
          When No_Data_Found Then
            Vnvlrprecovenda := 0;
        End;
        Vslinha := Vslinha || Trim(To_Char(Vnvlrprecovenda, '9999990D99')) || '|';
        -- Descricao Interna do Item
        Vslinha := Vslinha || Substr(Vtproduto.Descricaoprod, 0, 100) || '|';
        -- Status Produto
        Vslinha := Vslinha || Vtproduto.Status;
        -- Nome do Arquivo
        Vsnomearquivo := 'RELPRO' || '_' || Vscnpjempresa;
        -- Contador
        Vncontador := Vncontador + 1;
        -- Insert
        Insert Into Mrlx_Pdvimportacao
          (Nroempresa,
           Softpdv,
           Dtamovimento,
           Dtahorlancamento,
           Arquivo,
           Linha,
           Ordem,
           Seqlinha)
        Values
          (Pnnroempresa,
           Pssoftpdv,
           Sysdate,
           Sysdate,
           Vsnomearquivo,
           Vslinha,
           2,
           Vncontador);
      End Loop;
    End If;
  Exception
    When Others Then
      raise_application_error(-20200,
                              'SP_GERA_PROD_SantaHelena - ' || Sqlerrm);
  End Sp_Gera_Prod_Santahelena;
  Function Fbuscacodsegcli_Santahelena(Psnomesegmento Varchar2)
    RETURN VARCHAR2 IS
    Vscodseg Varchar2(3);
  Begin
    If Psnomesegmento = 'ACADEMIAS' Then
      Vscodseg := '100';
    Elsif Psnomesegmento = 'ACESSORIOS DE MODA' Then
      Vscodseg := '102';
    Elsif Psnomesegmento = 'ACOUGUE' Then
      Vscodseg := '103';
    Elsif Psnomesegmento = 'ADEGA/DIST. DE BEBIDAS' Then
      Vscodseg := '104';
    Elsif Psnomesegmento = 'AEROPORTO' Then
      Vscodseg := '105';
    Elsif Psnomesegmento = 'AGROPECUARIA' Then
      Vscodseg := '106';
    Elsif Psnomesegmento = 'AMBULANTE' Then
      Vscodseg := '107';
    Elsif Psnomesegmento = 'ARMAZEM' Then
      Vscodseg := '109';
    Elsif Psnomesegmento = 'ARTESANATOS' Then
      Vscodseg := '110';
    elsif psNomeSegmento = 'AS ¿ 1 a 5 Check Outs' then
      Vscodseg := '178';
    elsif psNomeSegmento = 'AS ¿ 11 a 15 Check Outs' then
      Vscodseg := '180';
    elsif psNomeSegmento = 'AS ¿ 15 A 20 Check Outs' then
      Vscodseg := '181';
    elsif psNomeSegmento = 'AS ¿ 6 a 10 Check Outs' then
      Vscodseg := '179';
    elsif psNomeSegmento = 'AS ¿ Mais de 20 Check Outs' then
      Vscodseg := '182';
    elsif psNomeSegmento = 'AS ¿ Sem quantidade de Check Outs' then
      Vscodseg := '183';
    Elsif Psnomesegmento = 'ASSOCIACOES E COLONIAS' Then
      Vscodseg := '111';
    Elsif Psnomesegmento = 'ATACAREJO' Then
      Vscodseg := '116';
    Elsif Psnomesegmento = 'ATC GRANDE PORTE' Then
      Vscodseg := '115';
    Elsif Psnomesegmento = 'ATC MEDIO PORTE' Then
      Vscodseg := '113';
    Elsif Psnomesegmento = 'ATC PEQUENO PORTE' Then
      Vscodseg := '114';
    Elsif Psnomesegmento = 'AUTO PECAS/VEICULOS' Then
      Vscodseg := '118';
    Elsif Psnomesegmento = 'BANCAS / QUIOSQUES' Then
      Vscodseg := '119';
    Elsif Psnomesegmento = 'BAR' Then
      Vscodseg := '120';
    Elsif Psnomesegmento = 'BAZAR' Then
      Vscodseg := '108';
    Elsif Psnomesegmento = 'BICICLETARIAS' Then
      Vscodseg := '101';
    Elsif Psnomesegmento = 'BOMBONIERE / DOCERIAS' Then
      Vscodseg := '126';
    Elsif Psnomesegmento = 'BORDADEIRA' Then
      Vscodseg := '127';
    Elsif Psnomesegmento = 'BOUTIQUE' Then
      Vscodseg := '128';
    Elsif Psnomesegmento = 'CAFETERIA' Then
      Vscodseg := '131';
    Elsif Psnomesegmento = 'CALCADOS' Then
      Vscodseg := '132';
    Elsif Psnomesegmento = 'CANTINAS' Then
      Vscodseg := '133';
    Elsif Psnomesegmento = 'CASH ' || Chr(38) || ' CARRY' Then
      Vscodseg := '134';
    Elsif Psnomesegmento = 'CHURRASCARIA' Then
      Vscodseg := '135';
    Elsif Psnomesegmento = 'CINEMAS' Then
      Vscodseg := '136';
    Elsif Psnomesegmento = 'CLINICAS' Then
      Vscodseg := '137';
    Elsif Psnomesegmento = 'CLUBES' Then
      Vscodseg := '138';
    Elsif Psnomesegmento = 'CONFECCOES' Then
      Vscodseg := '140';
    Elsif Psnomesegmento = 'CONSUMIDOR FINAL' Then
      Vscodseg := '141';
    Elsif Psnomesegmento = 'COOPERATIVA' Then
      Vscodseg := '117';
    Elsif Psnomesegmento = 'COPISTA' Then
      Vscodseg := '143';
    Elsif Psnomesegmento = 'CORPORATIVO' Then
      Vscodseg := '150';
    Elsif Psnomesegmento = 'COZINHA INDUSTRIAL' Then
      Vscodseg := '144';
    Elsif Psnomesegmento = 'DISTRIBUIDOR' Then
      Vscodseg := '145';
    Elsif Psnomesegmento = 'E-COMMERCE' Then
      Vscodseg := '146';
    Elsif Psnomesegmento = 'ENTIDADE FILANTROPICA' Then
      Vscodseg := '147';
    Elsif Psnomesegmento = 'ESTUDIO FOTOGRAFICO' Then
      Vscodseg := '125';
    Elsif Psnomesegmento = 'EVENTOS/FESTAS' Then
      Vscodseg := '148';
    Elsif Psnomesegmento = 'EXPORTACAO' Then
      Vscodseg := '149';
    Elsif Psnomesegmento = 'FARMACIAS E DROGARIAS' Then
      Vscodseg := '151';
    Elsif Psnomesegmento = 'FERRAGENS/MAT DE CONSTRUÇÃO' Then
      Vscodseg := '152';
    Elsif Psnomesegmento = 'FLORICULTURA' Then
      Vscodseg := '153';
    Elsif Psnomesegmento = 'FRUTEIRA' Then
      Vscodseg := '154';
    elsif psNomeSegmento = 'GOVERNO ¿ Licitação' then
      Vscodseg := '155';
    Elsif Psnomesegmento = 'GRAFICAS' Then
      Vscodseg := '156';
    Elsif Psnomesegmento = 'HOSPITAIS' Then
      Vscodseg := '157';
    Elsif Psnomesegmento = 'HOTEIS/MOTEIS' Then
      Vscodseg := '158';
    Elsif Psnomesegmento = 'IGREJAS/FUNERARIAS' Then
      Vscodseg := '159';
    Elsif Psnomesegmento = 'INDUSTRIA' Then
      Vscodseg := '160';
    Elsif Psnomesegmento = 'INFORMATICA / TECNOLOGIA' Then
      Vscodseg := '161';
    Elsif Psnomesegmento = 'INSTITUICAO DE ENSINO' Then
      Vscodseg := '139';
    Elsif Psnomesegmento = 'INSTITUIÇÕES FINANCEIRAS' Then
      Vscodseg := '184';
    Elsif Psnomesegmento = 'LANCHONETES' Then
      Vscodseg := '121';
    Elsif Psnomesegmento = 'LOCADORAS' Then
      Vscodseg := '162';
    Elsif Psnomesegmento = 'LOJA DE ARTIGOS ESPORTIVOS' Then
      Vscodseg := '167';
    Elsif Psnomesegmento = 'LOJA DE BRINQUEDOS' Then
      Vscodseg := '129';
    Elsif Psnomesegmento = 'LOJA DE CONVENIENCIA' Then
      Vscodseg := '164';
    Elsif Psnomesegmento = 'LOJA DE DEPARTAMENTO' Then
      Vscodseg := '165';
    Elsif Psnomesegmento = 'LOJA DE MOVEIS' Then
      Vscodseg := '166';
    Elsif Psnomesegmento = 'LOJA INFANTIL' Then
      Vscodseg := '163';
    Elsif Psnomesegmento = 'MERCADO E MINI MERCADO' Then
      Vscodseg := '168';
    Elsif Psnomesegmento = 'OTICA' Then
      Vscodseg := '124';
    Elsif Psnomesegmento = 'OUTROS' Then
      Vscodseg := '169';
    Elsif Psnomesegmento = 'PADARIA' Then
      Vscodseg := '170';
    Elsif Psnomesegmento = 'PADARIA E CONFEITARIA' Then
      Vscodseg := '171';
    Elsif Psnomesegmento = 'PAPELARIA' Then
      Vscodseg := '123';
    Elsif Psnomesegmento = 'PASTELARIA' Then
      Vscodseg := '172';
    Elsif Psnomesegmento = 'PEQUENOS ATCS E DISTS' Then
      Vscodseg := '173';
    Elsif Psnomesegmento = 'PIZZARIA' Then
      Vscodseg := '174';
    Elsif Psnomesegmento = 'RESTAURANTE' Then
      Vscodseg := '122';
    Elsif Psnomesegmento = 'RODOVIARIA' Then
      Vscodseg := '176';
    Elsif Psnomesegmento = 'SALAO DE BELEZA' Then
      Vscodseg := '130';
    Elsif Psnomesegmento = 'SERVICOS' Then
      Vscodseg := '142';
    Elsif Psnomesegmento = 'SORVETERIA' Then
      Vscodseg := '177';
    Elsif Psnomesegmento = 'TABACARIA' Then
      Vscodseg := '175';
    Elsif Psnomesegmento = 'VAREJO' Then
      Vscodseg := '112';
    Else
      Vscodseg := '169'; -- Outros
    End If;
    Return Vscodseg;
  End Fbuscacodsegcli_Santahelena;
  /* Santa Helena - Fim */
  /************************************************************************************/
  Function Fbuscaprecopromocao(Pnseqproduto In Map_Produto.Seqproduto%Type,
                               Pnnroempresa In Ge_Empresa.Nroempresa%Type)
    Return Number Is
    Vnvalorpromocional Number(15, 2);
  Begin
    Select (b.Precopromocional / b.Qtdembalagem) Precopromocional
      Into Vnvalorpromocional
      FROM MRL_PROMOCAO A, MRL_PROMOCAOITEM B, MAX_EMPRESA C
     Where b.Seqpromocao = a.Seqpromocao
       And b.Nroempresa = a.Nroempresa
       And b.Centralloja = a.Centralloja
       And b.Nrosegmento = a.Nrosegmento
       And c.Nroempresa = a.Nroempresa
       And a.Dtafim >= Trunc(Sysdate)
       AND (A.SEQPROMOCAO, A.NROEMPRESA, A.CENTRALLOJA, A.NROSEGMENTO,
            B.QTDEMBALAGEM) IN
           (SELECT MAX(X.SEQPROMOCAO),
                   X.NROEMPRESA,
                   X.CENTRALLOJA,
                   X.NROSEGMENTO,
                   MIN(Y.QTDEMBALAGEM)
              From Mrl_Promocao x, Mrl_Promocaoitem y, Max_Empresa w
             Where y.Seqpromocao = x.Seqpromocao
               And y.Nroempresa = x.Nroempresa
               And y.Centralloja = x.Centralloja
               And y.Nrosegmento = x.Nrosegmento
               And w.Nroempresa = x.Nroempresa
               And Trunc(Sysdate) Between x.Dtainicio And x.Dtafim
               And (y.Precopromocional / y.Qtdembalagem) =
                   Fprecoembpromoc(y.Seqproduto,
                                   1,
                                   w.Nrosegmentoprinc,
                                   x.Nroempresa)
             Group By x.Nroempresa, x.Centralloja, x.Nrosegmento)
       And a.Nroempresa = Pnnroempresa
       And b.Seqproduto = Pnseqproduto;
  Exception
    When No_Data_Found Then
      Vnvalorpromocional := 0;
      Return Vnvalorpromocional;
      Return Vnvalorpromocional;
  End Fbuscaprecopromocao;
  Function Fbuscacnpjempresa(Pnnroempresa In Max_Empresa.Nroempresa%Type)
    Return Varchar2 Is
    Vscpnjempresa Varchar2(14);
  Begin
    --Busca CNPJ da Empresa
    Select Lpad(Nrocgc || Lpad(Digcgc, 2, 0), 14, 0)
      Into Vscpnjempresa
      From Max_Empresa a
     Where a.Nroempresa = Pnnroempresa;
    Return Vscpnjempresa;
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'FBUSCACNPJEMPRESA - ' || Sqlerrm);
  End Fbuscacnpjempresa;
  Function Findregistrobonif(Pncgonota  In Max_Codgeraloper.Codgeraloper%Type,
                             Pncgoemp   In Max_Codgeraloper.Codgeraloper%Type,
                             Pscgoparam In Varchar2) Return Varchar2 Is
  Begin
    If Pncgonota = Pncgoemp Then
      return 'B';
    Else
      For t In (Select Column_Value As Cgoparametro
                  FROM TABLE(cast(c5_ComplexIn.c5InTable(psCgoParam) as
                                  c5InStrTable))) loop
        If Pncgonota = t.Cgoparametro Then
          return 'B';
        End If;
      End Loop;
    End If;
    Return 'N';
  Exception
    When Others Then
      Raise_Application_Error(-20200, 'fIndRegistroBonif - ' || Sqlerrm);
  End Findregistrobonif;
  function fIndRegistroBonif670(pnCgoNota  IN MAX_CODGERALOPER.CODGERALOPER%TYPE,
                                pnCgoEmp   IN MAX_CODGERALOPER.CODGERALOPER%TYPE,
                                psCgoParam IN VARCHAR2) return varchar2 is
  begin
    if pnCgoNota = pnCgoEmp then
      return 'S';
    else
      for t in (SELECT COLUMN_VALUE as CgoParametro
                  FROM TABLE(cast(c5_ComplexIn.c5InTable(psCgoParam) as
                                  c5InStrTable))) loop
        if pnCgoNota = t.cgoparametro then
          return 'S';
        end if;
      end loop;
    end if;
    return 'N';
  exception
    when others then
      raise_application_error(-20200, 'fIndRegistroBonif670 - ' || sqlerrm);
  end fIndRegistroBonif670;
End Pkg_Edi_Neogrid_edit2;
