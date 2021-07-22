create or replace NONEDITIONABLE PACKAGE utils_pkg
AS 

    TYPE materia_prima_rec_t IS RECORD (
        codigo              materia_prima.codigo%TYPE,
        quantidade          materia_prima.quantidade%TYPE,
        unid_medida_codigo  materia_prima.unid_medida_codigo%TYPE
    );

    TYPE materia_prima_t 
        IS TABLE OF materia_prima_rec_t 
        INDEX BY PLS_INTEGER;

    TYPE vendas_rec IS RECORD (
        nome          tipo_prod.nome%TYPE,
        quantidade    NUMBER
    );
    
    TYPE vendas_t 
        IS TABLE OF vendas_rec;

    TYPE precos_venda_rec IS RECORD (
        nome          tipo_prod.nome%TYPE,
        preco         produto_stock.preco%TYPE,
        preco_final   prod_vendido.preco_final%TYPE,
        ganho_perda   prod_vendido.preco_final%TYPE
    );
    
    TYPE precos_venda_t 
        IS TABLE OF precos_venda_rec;

    TYPE mp_mais_usadas_rec IS RECORD (
        nome          materia_prima.nome%TYPE,
        cor           materia_prima.cor%TYPE
    );
    
    TYPE mp_mais_usadas_t 
        IS TABLE OF mp_mais_usadas_rec;

    TYPE fornecimento_mp_rec IS RECORD (
        nome_mp          materia_prima.nome%TYPE,
        nome_fornecedor  fornecedor.nome%TYPE,
        nipc             fornecedor.nipc%TYPE
    );
    
    TYPE fornecimento_mp_t 
        IS TABLE OF fornecimento_mp_rec;

    FUNCTION  preco_ideal_fnc  (
        email_p                 IN  artesao.email%TYPE,
        producao_id             IN  producao.id%TYPE
    ) RETURN NUMBER;

    PROCEDURE  gera_alertas_prc  (
        email_p                 IN  artesao.email%TYPE,
        codigo_materia_prima_p   IN  materia_prima.codigo%TYPE
    );

    PROCEDURE  marcar_vistos_prc  (
        email_p  IN  artesao.email%TYPE
    );

    PROCEDURE  desmarca_alerta_prc  (
        email_p                 IN  artesao.email%TYPE,
        codigo_materia_prima_p   IN  materia_prima.codigo%TYPE
    );
    
    FUNCTION relatorio_vendas_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN vendas_t PIPELINED;
    
    FUNCTION relatorio_precos_venda_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN precos_venda_t PIPELINED;

    FUNCTION relatorio_mp_mais_usadas_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN mp_mais_usadas_t PIPELINED;

    FUNCTION lista_fornecimento_mp_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN fornecimento_mp_t PIPELINED;
    
END utils_pkg;
/

create or replace NONEDITIONABLE PACKAGE BODY utils_pkg
AS
    ----------------------------------------------------------------------------
    -- NOME: preco_ideal_fnc                                                  --
    -- DESCRIÇÃO: Função que calcula o preço ideal com base em indicadores    --
    ----------------------------------------------------------------------------
    FUNCTION preco_ideal_fnc (
        email_p                 IN  artesao.email%TYPE,
        producao_id             IN  producao.id%TYPE
        --
    ) RETURN NUMBER 
    IS
        custos_mao_obra_v       NUMBER := 0;
        custos_materia_prima_v  NUMBER := 0;
        gastos_v                NUMBER := 0;
        custo_producao_v        NUMBER := 0;
        preco_ideal_v           NUMBER := 0;
        tempo_producao_v        producao.tempo_producao%TYPE;
        custo_hora_producao_v   producao.custo_hora_producao%TYPE;
        lucro_v                 tipo_prod.lucro%TYPE;
--        --
        unid_medida_tabela_v    unid_medida.nome%TYPE;
        unid_medida_user_v      unid_medida.nome%TYPE;
        --
        CURSOR tabela_materia_prima_c IS 
            SELECT mp.codigo, mp.nome, mp.quantidade, mp.especificacoes, mp.preco, mp.cor, mp.unid_medida_codigo
            FROM materia_prima mp
            INNER JOIN artesao a
            ON a.codigo = mp.artesao_codigo
            WHERE a.email = email_p
            ;
        --
        CURSOR tabela_gastos_c IS 
            SELECT g.codigo, g.nome, g.valor
            FROM gastos g
            INNER JOIN artesao a ON a.codigo = g.artesao_codigo
            WHERE a.email = email_p
            ;
        --
        CURSOR producao_c IS 
            SELECT P.tempo_producao, P.custo_hora_producao, tp.lucro
            FROM producao P
            INNER JOIN tipo_prod tp   ON tp.codigo = P.tipo_prod_codigo_id
            WHERE p.id = producao_id
            ;
        --
        CURSOR materias_primas_producao_c IS 
            SELECT P.ID, P.tempo_producao, P.custo_hora_producao, tp.lucro, mp.materia_prima_codigo, mp.quantidade
            FROM producao P
            INNER JOIN tipo_prod tp   ON tp.codigo = P.tipo_prod_codigo_id
            INNER JOIN mp_prod mp     ON mp.ID = P.ID
            ;
        --
        CURSOR gastos_producao_c IS 
            SELECT P.ID, P.tempo_producao, P.custo_hora_producao, tp.lucro, gp.percentagem, gp.gastos_codigo_id
            FROM producao P
            INNER JOIN tipo_prod tp   ON tp.codigo = P.tipo_prod_codigo_id
            INNER JOIN gastos_prod gp ON gp.ID = P.ID
            ;        
        --
        
    BEGIN
        DBMS_OUTPUT.PUT_LINE('* INICIO FUNÇÃO *');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Cálculo do Custo de Mão de Obra
        DBMS_OUTPUT.PUT_LINE('- Cálculo do Custo de Mão de Obra ');
        OPEN producao_c;
        FETCH producao_c INTO tempo_producao_v, custo_hora_producao_v, lucro_v;
        CLOSE producao_c;  
        custos_mao_obra_v := tempo_producao_v * (custo_hora_producao_v / 60);
        DBMS_OUTPUT.PUT_LINE(' > Custo Mão de Obra = '||custos_mao_obra_v);
        DBMS_OUTPUT.PUT_LINE('');

        
        -- Cálculo do Custo da Matéria Prima
        DBMS_OUTPUT.PUT_LINE('- Cálculo do Custo da Matéria Prima');       
        FOR mp IN tabela_materia_prima_c LOOP
            DBMS_OUTPUT.PUT_LINE('   LOOP TABELA MATERIA PRIMA');
            FOR i IN materias_primas_producao_c LOOP
                IF i.materia_prima_codigo = mp.codigo THEN
                    DBMS_OUTPUT.PUT_LINE('   MATERIA PRIMA '||mp.codigo||' ('||mp.nome||' ' ||mp.cor||', '||mp.especificacoes||') ENCONTRADA');
                    
                    SELECT abreviatura INTO unid_medida_tabela_v FROM unid_medida WHERE codigo = mp.unid_medida_codigo;
                    SELECT abreviatura INTO unid_medida_user_v FROM unid_medida WHERE codigo = i.materia_prima_codigo;

                    -- custos_materia_prima_v + ( (mp.quantidade [convertida unid menor] * mp.preco) / i.quantidade [convertida unid menor] )
                    custos_materia_prima_v := 
                        custos_materia_prima_v 
                        + 
                        ( ( CASE 
                                WHEN unid_medida_user_v = 'kg'             THEN i.quantidade * 1000000
                                WHEN unid_medida_user_v IN ('m', 'g', 'l') THEN i.quantidade * 1000
                                WHEN unid_medida_user_v IN ('cm', 'cl')    THEN i.quantidade * 10
                                ELSE i.quantidade
                                END
                            * mp.preco
                          )
                          / 
                          CASE 
                              WHEN unid_medida_tabela_v = 'kg'             THEN mp.quantidade * 1000000
                              WHEN unid_medida_tabela_v IN ('m', 'g', 'l') THEN mp.quantidade * 1000
                              WHEN unid_medida_tabela_v IN ('cm', 'cl')    THEN mp.quantidade * 10
                              ELSE mp.quantidade
                              END
                        )
                    ;
                ELSE
                    DBMS_OUTPUT.PUT_LINE('   MATERIA PRIMA '||mp.codigo||' ('||mp.nome||' ' ||mp.cor||', '||mp.especificacoes||') NÃO ENCONTRADA');
                END IF;
                DBMS_OUTPUT.PUT_LINE('   > Custo acumulado = '||custos_materia_prima_v);
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');


        -- Cálculo dos Gastos
        DBMS_OUTPUT.PUT_LINE('- Cálculo dos Gastos');
        FOR g IN tabela_gastos_c LOOP
            DBMS_OUTPUT.PUT_LINE('   LOOP TABELA GASTOS');
            FOR gp IN gastos_producao_c LOOP
                IF gp.gastos_codigo_id = g.codigo THEN
                    DBMS_OUTPUT.PUT_LINE('   GASTO '''||g.nome||''' EXISTE NA TABELA GASTOS');
                    gastos_v := gastos_v + (g.valor * gp.percentagem/100);
                    
                    DBMS_OUTPUT.PUT_LINE('   > Tabela Gastos: '||g.nome||' = ' ||g.valor);
                    DBMS_OUTPUT.PUT_LINE('   > Percentagem Artesao = ' ||gp.percentagem);
                    DBMS_OUTPUT.PUT_LINE('   > Valor acumulado = '||gastos_v);
                    DBMS_OUTPUT.PUT_LINE('');
                END IF;
            END LOOP;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Custo Mão de Obra = '||custos_mao_obra_v||' | Custo Matéria Prima = '||custos_materia_prima_v||' | Gastos = '||gastos_v);
        
        -- Cálculo Intermédio do Custo de Produção
        custo_producao_v := custos_mao_obra_v + custos_materia_prima_v + gastos_v;
        DBMS_OUTPUT.PUT_LINE('Custo de Produção = '||custo_producao_v);
        
        -- Cálculo Final do Preço Ideal
        preco_ideal_v := custo_producao_v + ((lucro_v/100) * custo_producao_v);
        DBMS_OUTPUT.PUT_LINE('Preço Ideal = '||preco_ideal_v||' ( '||custo_producao_v||' + '||((lucro_v/100) * custo_producao_v)||' )');
    
        RETURN preco_ideal_v;
    END preco_ideal_fnc;


    ----------------------------------------------------------------------------
    -- NOME: GERA_ALERTAS_PRC                                                 --
    -- DESCRIÇÃO: Procedimento para gerar alertas na tabela de alertas        --
    ----------------------------------------------------------------------------
    PROCEDURE  gera_alertas_prc  (
        email_p                 IN  artesao.email%TYPE,
        codigo_materia_prima_p   IN  materia_prima.codigo%TYPE
     )
    IS
        CURSOR tabela_materia_prima_c IS 
            SELECT mp.codigo, mp.nome, mp.quantidade, mp.alerta_qt_minima
            FROM materia_prima mp
            INNER JOIN artesao a
            ON a.codigo = mp.artesao_codigo
            WHERE a.email = email_p AND mp.codigo = codigo_materia_prima_p
            ;
    BEGIN
        FOR mp IN tabela_materia_prima_c LOOP
            IF mp.alerta_qt_minima IS NOT NULL AND mp.quantidade <= mp.alerta_qt_minima THEN
                DBMS_OUTPUT.PUT_LINE('Matéria Prima '||mp.nome||' com pouco stock (Quantidade: '||mp.quantidade||' | Quantidade Mínima: '||mp.alerta_qt_minima||')');
                
                INSERT INTO alerta (
                    nome,
                    mensagem,
                    visto,
                    data_inicio,
                    data_fim,
                    materia_prima_codigo
                ) VALUES (
                    'quantidade_minima',
                    'Quantidade Mínima de Stock de '|| mp.nome|| ' atingida.',
                    'N',
                    sysdate,
                    TO_DATE('9999-12-31 23:59:00', 'YYYY-MM-DD HH24:MI:SS'),
                    mp.codigo
                );
                COMMIT;
                
                DBMS_OUTPUT.PUT_LINE('Alerta gerado');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Condição não verificada: '||chr(10)||' mp.alerta_qt_minima IS NOT NULL'||chr(10)||' AND mp.quantidade <= mp.alerta_qt_minima');
            END IF;
        END LOOP;

    END gera_alertas_prc;


    ----------------------------------------------------------------------------
    -- NOME: marcar_vistos_prc                                                --
    -- DESCRIÇÃO: Procedimento para marcar todos os alertas do utilizador     --
    --            como visualizados                                           --
    ----------------------------------------------------------------------------
    PROCEDURE  marcar_vistos_prc  (
        email_p  IN  artesao.email%TYPE
    )
    IS
    BEGIN

        UPDATE alerta tab
        SET tab.visto = 'S'
        WHERE EXISTS (SELECT 1 
                        FROM alerta a
                        INNER JOIN materia_prima mp
                        ON mp.codigo = a.materia_prima_codigo
                        INNER JOIN artesao a
                        ON a.codigo = mp.artesao_codigo
                        WHERE a.email = email_p
                        AND a.codigo = tab.codigo
        );
        
        COMMIT;                
        
        DBMS_OUTPUT.PUT_LINE('Alertas visualizados');

    END marcar_vistos_prc;


    ----------------------------------------------------------------------------
    -- NOME: desmarca_alerta_prc                                              --
    -- DESCRIÇÃO: Procedimento que desmarca um alerta se alerta foi tratado   --
    --            pelo utilizador                                             --
    ----------------------------------------------------------------------------
    PROCEDURE  desmarca_alerta_prc  (
        email_p                 IN  artesao.email%TYPE,
        codigo_materia_prima_p  IN  materia_prima.codigo%TYPE
    )
    IS
    BEGIN

        UPDATE alerta tab
        SET tab.data_fim = SYSDATE
        WHERE EXISTS (SELECT 1 
                        FROM alerta a
                        INNER JOIN materia_prima mp
                        ON mp.codigo = a.materia_prima_codigo
                        INNER JOIN artesao a
                        ON a.codigo = mp.artesao_codigo
                        WHERE a.email = email_p
                        AND a.codigo  = tab.codigo
                        AND mp.codigo = codigo_materia_prima_p
        );
        
        COMMIT;                
        
        DBMS_OUTPUT.PUT_LINE('Alertas limpo');

    END desmarca_alerta_prc;


    ----------------------------------------------------------------------------
    -- NOME: relatorio_vendas                                                 --
    -- DESCRIÇÃO: Função que devolve as quantidades vendidas nos últimos 30   --
    --            dias                                                        --
    ----------------------------------------------------------------------------
    FUNCTION relatorio_vendas_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN vendas_t PIPELINED
    IS
        CURSOR vendas_c IS
            SELECT t.nome, count(*) as quantidade
            FROM artesao a
            INNER JOIN producao p      ON p.artesao_codigo_id = a.codigo
            INNER JOIN tipo_prod t     ON t.codigo = p.tipo_prod_codigo_id
            INNER JOIN produto_stock s ON s.tipo_prod_codigo = t.codigo 
            INNER JOIN prod_vendido v  ON v.produto_stock_tipo_prod_codigo = s.tipo_prod_codigo
            WHERE a.email = email_p AND TRUNC(v.data) >= ADD_MONTHS(TRUNC(SYSDATE),-1)
            GROUP BY t.nome
            ;
    BEGIN
      FOR v IN vendas_c LOOP
        PIPE ROW(vendas_rec(v.nome, v.quantidade));
      END LOOP;
    
      RETURN;
    END relatorio_vendas_fnc;


    ----------------------------------------------------------------------------
    -- NOME: relatorio_precos_venda_fnc                                       --
    -- DESCRIÇÃO: Função que devolve as vendas dos últimos 30 dias            --
    ----------------------------------------------------------------------------
    FUNCTION relatorio_precos_venda_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN precos_venda_t PIPELINED
    IS
        CURSOR precos_venda_c IS
            SELECT t.nome, (s.preco/s.quantidade) as preco, v.preco_final, v.preco_final - (s.preco/s.quantidade) as ganho_perda
            FROM artesao a
            INNER JOIN producao p      ON p.artesao_codigo_id = a.codigo
            INNER JOIN tipo_prod t     ON t.codigo = p.tipo_prod_codigo_id
            INNER JOIN produto_stock s ON s.tipo_prod_codigo = t.codigo 
            INNER JOIN prod_vendido v  ON v.produto_stock_tipo_prod_codigo = s.tipo_prod_codigo
            WHERE a.email = email_p
            ;
    BEGIN
      FOR pv IN precos_venda_c LOOP
        PIPE ROW(precos_venda_rec(pv.nome, pv.preco, pv.preco_final, pv.ganho_perda));
      END LOOP;
    
      RETURN;
    END relatorio_precos_venda_fnc;


    ----------------------------------------------------------------------------
    -- NOME: relatorio_mp_mais_usadas_fnc                                    --
    -- DESCRIÇÃO: Função que devolve as matérias primas mais usadas          --
    ----------------------------------------------------------------------------
    FUNCTION relatorio_mp_mais_usadas_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN mp_mais_usadas_t PIPELINED
    IS
        CURSOR mp_mais_usadas_c IS
            SELECT nome, cor FROM (
                SELECT  mp_p.materia_prima_codigo, mp.nome, mp.cor,
                    row_number() OVER (ORDER BY COUNT(DISTINCT mp_p.materia_prima_codigo) DESC) AS row_
                FROM mp_prod mp_p
                INNER JOIN materia_prima mp
                ON mp.codigo = mp_p.materia_prima_codigo
                GROUP BY mp_p.materia_prima_codigo, mp.nome, mp.cor
            ) WHERE row_ <= 5;
            
    BEGIN
      FOR mp IN mp_mais_usadas_c LOOP
        PIPE ROW(mp_mais_usadas_rec(mp.nome, mp.cor));
      END LOOP;
    
      RETURN;
    END relatorio_mp_mais_usadas_fnc;
    
    
    ----------------------------------------------------------------------------
    -- NOME: lista_fornecimento_mp_fnc                                        --
    -- DESCRIÇÃO: Função que devolve lista de fornecedores das matérias       --
    --            primas existentes                                            --
    ----------------------------------------------------------------------------
    FUNCTION lista_fornecimento_mp_fnc (
        email_p    IN  artesao.email%TYPE
    ) RETURN fornecimento_mp_t PIPELINED
    IS
        CURSOR fornecimento_mp_c IS
            select mp.nome as nome_mp, f2.nome as nome_fornecedor, f2.nipc
            FROM artesao a
            INNER JOIN materia_prima mp ON mp.artesao_codigo = a.codigo
            INNER JOIN fornecimento  f  ON f.materia_prima_codigo = mp.codigo
            INNER JOIN fornecedor    f2 ON f2.nipc = f.fornecedor_nipc
            WHERE a.email = email_p;
            
    BEGIN
      FOR f IN fornecimento_mp_c LOOP
        PIPE ROW(fornecimento_mp_rec(f.nome_mp, f.nome_fornecedor, f.nipc));
      END LOOP;
    
      RETURN;
    END lista_fornecimento_mp_fnc;
    
END utils_pkg;
/