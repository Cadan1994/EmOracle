-- 1� PASSO -- ALTER TABLE implantacao.mad_pedvendaitem ADD (vlrembtabpreco_1 NUMBER(13,6));
-- 2� PASSO -- UPDATE implantacao.mad_pedvendaitem SET vlrembtabpreco_1 = vlrembtabpreco;
-- 3� PASSO -- UPDATE implantacao.mad_pedvendaitem SET vlrembtabpreco = 0;
-- 4� PASSO -- ALTER TABLE implantacao.mad_pedvendaitem MODIFY(vlrembtabpreco NUMBER(13,4));
-- 5� PASSO -- UPDATE implantacao.mad_pedvendaitem SET vlrembtabpreco = vlrembtabpreco_1;
-- 6� PASSO -- ALTER TABLE implantacao.mad_pedvendaitem DROP COLUMN vlrembtabpreco_1;