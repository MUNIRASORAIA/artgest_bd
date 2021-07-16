-- DROP TRIGGERS

DROP TRIGGER artesao_trg;
DROP TRIGGER categoria_trg;
DROP TRIGGER gastos_trg;
DROP TRIGGER gastos_prod_trg;
DROP TRIGGER instrucoes_trg;
DROP TRIGGER materia_prima_trg;
DROP TRIGGER mp_prod_trg;
DROP TRIGGER unid_medida_trg;
DROP TRIGGER prod_vendido_trg;
DROP TRIGGER tipo_prod_trg;
DROP TRIGGER alerta_trg;




-- DROP SEQUENCE

DROP SEQUENCE artesao_cod_seq;
DROP SEQUENCE categoria_cod_seq;
DROP SEQUENCE gastos_cod_seq;
DROP SEQUENCE gastos_prod_cod_seq;
DROP SEQUENCE instrucoes_cod_seq;
DROP SEQUENCE materia_prima_cod_seq;
DROP SEQUENCE mp_prod_cod_seq;
DROP SEQUENCE unid_medida_cod_seq;
DROP SEQUENCE prod_vendido_cod_seq;
DROP SEQUENCE tipo_prod_cod_seq;
DROP SEQUENCE alerta_cod_seq;



-- DROP TABLE

DROP TABLE unid_medida CASCADE CONSTRAINTS;
DROP TABLE tipo_prod CASCADE CONSTRAINTS;
DROP TABLE produto_stock CASCADE CONSTRAINTS;
DROP TABLE producao CASCADE CONSTRAINTS;
DROP TABLE prod_vendido CASCADE CONSTRAINTS;
DROP TABLE mp_prod CASCADE CONSTRAINTS;
DROP TABLE materia_prima CASCADE CONSTRAINTS;
DROP TABLE instrucoes CASCADE CONSTRAINTS;
DROP TABLE inst_prod CASCADE CONSTRAINTS;
DROP TABLE gastos_prod CASCADE CONSTRAINTS;
DROP TABLE gastos CASCADE CONSTRAINTS;
DROP TABLE fornecimento CASCADE CONSTRAINTS;
DROP TABLE fornecedor CASCADE CONSTRAINTS;
DROP TABLE categoria CASCADE CONSTRAINTS;
DROP TABLE artesao CASCADE CONSTRAINTS;
DROP TABLE alerta CASCADE CONSTRAINTS;


-- CREATE SEQUENCE 

CREATE SEQUENCE artesao_cod_seq
START WITH 10000000000
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE categoria_cod_seq
START WITH 100
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE gastos_cod_seq
START WITH 100
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE gastos_prod_cod_seq
START WITH 100
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE instrucoes_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE materia_prima_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE mp_prod_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE unid_medida_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;


CREATE SEQUENCE prod_vendido_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE tipo_prod_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;

CREATE SEQUENCE alerta_cod_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
;






-- TRIGGER

CREATE OR REPLACE TRIGGER artesao_trg
BEFORE
    INSERT ON artesao
    FOR EACH ROW
BEGIN
    :new.codigo := artesao_cod_seq.nextval;
END;
/


CREATE OR REPLACE TRIGGER categoria_trg
BEFORE
    INSERT ON categoria
    FOR EACH ROW
BEGIN
    :new.codigo := categoria_cod_seq.nextval;
END
;
/

CREATE OR REPLACE TRIGGER gastos_trg
BEFORE
    INSERT ON gastos
    FOR EACH ROW
BEGIN
    :new.codigo := gastos_cod_seq.nextval;
END
;
/

CREATE OR REPLACE TRIGGER gastos_prod_trg
BEFORE
    INSERT ON gastos_prod
    FOR EACH ROW
BEGIN
    :new.codigo := gastos_prod_cod_seq.nextval;
END
;
/

CREATE OR REPLACE TRIGGER instrucoes_trg
BEFORE
    INSERT ON instrucoes
    FOR EACH ROW
BEGIN
    :new.codigo := instrucoes_cod_seq.nextval;
END
;
/

CREATE OR REPLACE TRIGGER materia_prima_trg
BEFORE
    INSERT ON materia_prima
    FOR EACH ROW
BEGIN
    IF :new.codigo is null OR :new.codigo = 0
    THEN       
        :new.codigo := materia_prima_cod_seq.nextval;
    END IF; 
END
;
/

CREATE OR REPLACE TRIGGER mp_prod_trg
BEFORE
    INSERT ON mp_prod
    FOR EACH ROW
BEGIN
    :new.codigo := mp_prod_cod_seq.nextval;
END
;
/

CREATE OR REPLACE TRIGGER unid_medida_trg
BEFORE
    INSERT ON unid_medida
    FOR EACH ROW
BEGIN
    :new.codigo := unid_medida_cod_seq.nextval;
END
;
/


CREATE OR REPLACE TRIGGER prod_vendido_trg
BEFORE
    INSERT ON prod_vendido
    FOR EACH ROW
BEGIN
    :new.codigo_venda := prod_vendido_cod_seq.nextval;
END
;
/

CREATE OR REPLACE TRIGGER tipo_prod_trg
BEFORE
    INSERT ON tipo_prod
    FOR EACH ROW
BEGIN
    IF :new.codigo is null OR :new.codigo = 0
    THEN       
        :new.codigo := tipo_prod_cod_seq.nextval;
    END IF; 
END
;
/

CREATE OR REPLACE TRIGGER alerta_trg
BEFORE
    INSERT ON alerta
    FOR EACH ROW
BEGIN
    :new.codigo := alerta_cod_seq.nextval;
END
;
/



-- CREATE TABLE

CREATE TABLE alerta (
    codigo                NUMBER(4) NOT NULL,
    nome                  VARCHAR2(30) NOT NULL,
    mensagem              VARCHAR2(200) NOT NULL,
    visto                 CHAR(1) NOT NULL,
    data_inicio           DATE NOT NULL,
    data_fim              DATE NOT NULL,
    materia_prima_codigo  NUMBER(4) NOT NULL
);

ALTER TABLE alerta ADD CONSTRAINT alerta_pk PRIMARY KEY ( codigo );

CREATE TABLE artesao (
    codigo    NUMBER(11) NOT NULL,
    first_name VARCHAR2(150) NOT NULL,
    last_name VARCHAR2(150) NOT NULL,
    username VARCHAR2(150) NOT NULL,
    email     VARCHAR2(254) NOT NULL,
    password  VARCHAR2(128) NOT NULL,
    last_login TIMESTAMP(6),
    is_superuser NUMBER(1),
    is_staff NUMBER(1),
    is_active NUMBER(1) DEFAULT 1,
    date_joined TIMESTAMP(6)
    
);

ALTER TABLE artesao ADD CONSTRAINT artesao_pk PRIMARY KEY ( codigo );

ALTER TABLE artesao ADD CONSTRAINT artesao_uk UNIQUE ( email,
                                                       username );
CREATE TABLE categoria (
    codigo  NUMBER(3) NOT NULL,
    nome    VARCHAR2(20) NOT NULL
);

ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY ( codigo );

CREATE TABLE fornecedor (
    nipc        VARCHAR2(10) NOT NULL,
    nome        VARCHAR2(50) NOT NULL,
    email       VARCHAR2(50) NOT NULL,
    morada      VARCHAR2(150) NOT NULL,
    n_porta     VARCHAR2(10) NOT NULL,
    cod_postal  VARCHAR2(8) NOT NULL,
    localidade  VARCHAR2(20) NOT NULL,
    concelho    VARCHAR2(20) NOT NULL,
    telefone    NUMBER(14) NOT NULL
);

ALTER TABLE fornecedor ADD CONSTRAINT fornecedor_pk PRIMARY KEY ( nipc );

CREATE TABLE fornecimento (
    fornecedor_nipc       VARCHAR2(10) NOT NULL,
    materia_prima_codigo  NUMBER(4) NOT NULL
);

ALTER TABLE fornecimento ADD CONSTRAINT fornecimento_pk PRIMARY KEY ( materia_prima_codigo,
                                                                      fornecedor_nipc );

CREATE TABLE gastos (
    codigo          NUMBER(3) NOT NULL,
    nome            VARCHAR2(20) NOT NULL,
    valor           NUMBER(6, 2) NOT NULL,
    artesao_codigo  NUMBER(11) NOT NULL
);

ALTER TABLE gastos ADD CHECK ( valor > 0 );

ALTER TABLE gastos ADD CONSTRAINT outros_gastos_pk PRIMARY KEY ( codigo );

ALTER TABLE gastos ADD CONSTRAINT gastos_uk UNIQUE ( nome,
                                                     artesao_codigo );

CREATE TABLE gastos_prod (
    codigo         NUMBER(3) NOT NULL,
    gastos_codigo  NUMBER(3) NOT NULL,
    percentagem    FLOAT NOT NULL,
    producao_artesao_codigo    NUMBER(11) NOT NULL,
    producao_tipo_prod_codigo  NUMBER(4) NOT NULL                                                                                        
);

ALTER TABLE gastos_prod ADD CONSTRAINT gastos_prod_pk PRIMARY KEY ( codigo );

CREATE TABLE inst_prod (
    tipo_prod_codigo   NUMBER(4) NOT NULL,
    instrucoes_codigo  NUMBER(4) NOT NULL
);

ALTER TABLE inst_prod ADD CONSTRAINT inst_prod_pk PRIMARY KEY ( tipo_prod_codigo,
                                                                instrucoes_codigo );

CREATE TABLE instrucoes (
    codigo     NUMBER(4) NOT NULL,
    nome       VARCHAR2(20),                            
    instrucao  VARCHAR2(4000),
    imagem     VARCHAR2(4000)
);

ALTER TABLE instrucoes ADD CONSTRAINT instrucoes_pk PRIMARY KEY ( codigo );

ALTER TABLE instrucoes ADD CONSTRAINT instrucoes__un UNIQUE ( nome );                                                                    
CREATE TABLE materia_prima (
    codigo              NUMBER(4) NOT NULL,
    nome                VARCHAR2(20) NOT NULL,
    quantidade          FLOAT NOT NULL,
    especificacoes      VARCHAR2(100),
    preco               NUMBER(6, 2) NOT NULL,
    cor                 VARCHAR2(20) NOT NULL,
    alerta_qt_minima    FLOAT(4),                                
    unid_medida_codigo  NUMBER(4) NOT NULL,
    artesao_codigo      NUMBER(11) NOT NULL
    
);

ALTER TABLE materia_prima ADD CHECK ( preco > 0 );

ALTER TABLE materia_prima ADD CONSTRAINT materia_prima_pk PRIMARY KEY ( codigo );

ALTER TABLE materia_prima ADD CONSTRAINT materia_prima_uk UNIQUE ( nome,
                                                                   artesao_codigo );


CREATE TABLE mp_prod (
    codigo                NUMBER(4) NOT NULL,
    quantidade            FLOAT NOT NULL,
    materia_prima_codigo       NUMBER(4) NOT NULL,                                                
    unid_medida_codigo         NUMBER(4) NOT NULL,
    producao_artesao_codigo    NUMBER(11) NOT NULL,
    producao_tipo_prod_codigo  NUMBER(4) NOT NULL                                                
);

ALTER TABLE mp_prod ADD CONSTRAINT mp_prod_pk PRIMARY KEY ( codigo );

CREATE TABLE prod_vendido (
    codigo_venda                    NUMBER(4) NOT NULL,
    data                            DATE NOT NULL,
    local                           VARCHAR2(10) NOT NULL,
    preco_final                     NUMBER(6, 2) NOT NULL,
    produto_stock_tipo_prod_codigo  NUMBER(4) NOT NULL
);

ALTER TABLE prod_vendido ADD CHECK ( preco_final > 0 );

ALTER TABLE prod_vendido ADD CONSTRAINT prod_vendido_pk PRIMARY KEY ( codigo_venda );

CREATE TABLE producao (
    artesao_codigo       NUMBER(11) NOT NULL,
    tipo_prod_codigo     NUMBER(4) NOT NULL,
    tempo_producao       NUMBER(8) NOT NULL,
    custo_hora_producao  NUMBER(6, 2) NOT NULL
);

ALTER TABLE producao ADD CHECK ( custo_hora_producao > 0 );


ALTER TABLE producao ADD CONSTRAINT producao_pk PRIMARY KEY ( artesao_codigo,
                                                              tipo_prod_codigo );



CREATE TABLE produto_stock (
    tipo_prod_codigo  NUMBER(4) NOT NULL,
    quantidade        NUMBER(5) NOT NULL,
    preco             NUMBER(6, 2) NOT NULL
);

ALTER TABLE produto_stock ADD CHECK ( preco > 0 );

ALTER TABLE produto_stock ADD CONSTRAINT produto_stock_pk PRIMARY KEY ( tipo_prod_codigo );

CREATE TABLE tipo_prod (
    codigo            NUMBER(4) NOT NULL,
    nome              VARCHAR2(50) NOT NULL,
    imagem            VARCHAR2(4000),
    custo_producao    NUMBER(6, 2) NOT NULL DEFAULT 0,
    lucro             FLOAT NOT NULL,
    preco             NUMBER(6, 2) DEFAULT 0,
    categoria_codigo  NUMBER(3) NOT NULL
);

ALTER TABLE tipo_prod ADD CONSTRAINT tipo_prod_pk PRIMARY KEY ( codigo );

ALTER TABLE tipo_prod ADD CONSTRAINT tipo_prod__un UNIQUE ( nome );

CREATE TABLE unid_medida (
    codigo       NUMBER(4) NOT NULL,
    nome         VARCHAR2(20),
    abreviatura  VARCHAR2(4)
);

ALTER TABLE unid_medida ADD CONSTRAINT unidade_medida_pk PRIMARY KEY ( codigo );

ALTER TABLE alerta
    ADD CONSTRAINT alerta_materia_prima_fk FOREIGN KEY ( materia_prima_codigo )
        REFERENCES materia_prima ( codigo );

ALTER TABLE fornecimento
    ADD CONSTRAINT fornecimento_fornecedor_fk FOREIGN KEY ( fornecedor_nipc )
        REFERENCES fornecedor ( nipc );

ALTER TABLE fornecimento
    ADD CONSTRAINT fornecimento_materia_prima_fk FOREIGN KEY ( materia_prima_codigo )
        REFERENCES materia_prima ( codigo );

ALTER TABLE gastos
    ADD CONSTRAINT gastos_artesao_fk FOREIGN KEY ( artesao_codigo )
        REFERENCES artesao ( codigo );

ALTER TABLE gastos_prod
    ADD CONSTRAINT gastos_prod_gastos_fk FOREIGN KEY ( gastos_codigo )
        REFERENCES gastos ( codigo );

ALTER TABLE gastos_prod
    ADD CONSTRAINT gastos_prod_producao_fk FOREIGN KEY ( producao_artesao_codigo,
                                                         producao_tipo_prod_codigo )
        REFERENCES producao ( artesao_codigo,
                              tipo_prod_codigo );                      
ALTER TABLE inst_prod
    ADD CONSTRAINT inst_prod_instrucoes_fk FOREIGN KEY ( instrucoes_codigo )
        REFERENCES instrucoes ( codigo );

ALTER TABLE inst_prod
    ADD CONSTRAINT inst_prod_tipo_prod_fk FOREIGN KEY ( tipo_prod_codigo )
        REFERENCES tipo_prod ( codigo );

ALTER TABLE materia_prima
    ADD CONSTRAINT materia_prima_artesao_fk FOREIGN KEY ( artesao_codigo )
        REFERENCES artesao ( codigo );

ALTER TABLE materia_prima
    ADD CONSTRAINT materia_prima_unid_medida_fk FOREIGN KEY ( unid_medida_codigo )
        REFERENCES unid_medida ( codigo );

ALTER TABLE mp_prod
    ADD CONSTRAINT mp_prod_materia_prima_fk FOREIGN KEY ( materia_prima_codigo )
        REFERENCES materia_prima ( codigo );

ALTER TABLE mp_prod
    ADD CONSTRAINT mp_prod_producao_fk FOREIGN KEY ( producao_artesao_codigo,
                                                     producao_tipo_prod_codigo )
        REFERENCES producao ( artesao_codigo,
                              tipo_prod_codigo );

ALTER TABLE mp_prod
    ADD CONSTRAINT mp_prod_unid_medida_fk FOREIGN KEY ( unid_medida_codigo )
        REFERENCES unid_medida ( codigo );                 
ALTER TABLE prod_vendido
    ADD CONSTRAINT prod_vendido_produto_stock_fk FOREIGN KEY ( produto_stock_tipo_prod_codigo )
        REFERENCES produto_stock ( tipo_prod_codigo );

ALTER TABLE producao
    ADD CONSTRAINT producao_artesao_fk FOREIGN KEY ( artesao_codigo )
        REFERENCES artesao ( codigo );

ALTER TABLE producao
    ADD CONSTRAINT producao_tipo_prod_fk FOREIGN KEY ( tipo_prod_codigo )
        REFERENCES tipo_prod ( codigo );

ALTER TABLE produto_stock
    ADD CONSTRAINT produto_stock_tipo_prod_fk FOREIGN KEY ( tipo_prod_codigo )
        REFERENCES tipo_prod ( codigo );

ALTER TABLE tipo_prod
    ADD CONSTRAINT tipo_prod_categoria_fk FOREIGN KEY ( categoria_codigo )
        REFERENCES categoria ( codigo );




-- PACKAGE AND FUNCTIONS 

create or replace NONEDITIONABLE PACKAGE utils_pkg
AS 

    TYPE gastos_t
        IS TABLE OF gastos.valor%TYPE 
        INDEX BY gastos.nome%TYPE;

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
        tempo_producao_p        IN  producao.tempo_producao%TYPE,
        custo_hora_producao_p   IN  producao.custo_hora_producao%TYPE,
        gastos_p                IN  gastos_t,
        materia_prima_p         IN  materia_prima_t,
        lucro_p                 IN  NUMBER
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
        tempo_producao_p        IN  producao.tempo_producao%TYPE,
        custo_hora_producao_p   IN  producao.custo_hora_producao%TYPE,
        gastos_p                IN  gastos_t,
        materia_prima_p         IN  materia_prima_t,
        lucro_p                 IN  NUMBER
        --
    ) RETURN NUMBER 
    IS
        custos_mao_obra_v       NUMBER := 0;
        custos_materia_prima_v  NUMBER := 0;
        gastos_v                NUMBER := 0;
        custo_producao_v        NUMBER := 0;
        preco_ideal_v           NUMBER := 0;
        --
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
            SELECT g.nome, g.valor 
            FROM gastos g
            INNER JOIN artesao a ON a.codigo = g.artesao_codigo
            WHERE a.email = email_p
            ;
        --
        
    BEGIN
        DBMS_OUTPUT.PUT_LINE('* INICIO FUNÇÃO *');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Cálculo do Custo de Mão de Obra
        DBMS_OUTPUT.PUT_LINE('- Cálculo do Custo de Mão de Obra ');
        custos_mao_obra_v := tempo_producao_p * (custo_hora_producao_p / 60);
        DBMS_OUTPUT.PUT_LINE(' > Custo Mão de Obra = '||custos_mao_obra_v);
        DBMS_OUTPUT.PUT_LINE('');

        
        -- Cálculo do Custo da Matéria Prima
        DBMS_OUTPUT.PUT_LINE('- Cálculo do Custo da Matéria Prima');       
        FOR mp IN tabela_materia_prima_c LOOP
            DBMS_OUTPUT.PUT_LINE('   LOOP TABELA MATERIA PRIMA');
            FOR i IN materia_prima_p.FIRST .. materia_prima_p.LAST LOOP
               
                IF materia_prima_p(i).codigo = mp.codigo THEN
                    DBMS_OUTPUT.PUT_LINE('   MATERIA PRIMA '||mp.codigo||' ('||mp.nome||' ' ||mp.cor||', '||mp.especificacoes||') ENCONTRADA');
                    
                    SELECT abreviatura INTO unid_medida_tabela_v FROM unid_medida WHERE codigo = mp.unid_medida_codigo;
                    SELECT abreviatura INTO unid_medida_user_v FROM unid_medida WHERE codigo = materia_prima_p(i).codigo;

                    -- custos_materia_prima_v + ( (mp.quantidade [convertida unid menor] * mp.preco) / materia_prima_p(i).quantidade [convertida unid menor] )
                    custos_materia_prima_v := 
                        custos_materia_prima_v 
                        + 
                        ( ( CASE 
                                WHEN unid_medida_user_v = 'kg'             THEN materia_prima_p(i).quantidade * 1000000
                                WHEN unid_medida_user_v IN ('m', 'g', 'l') THEN materia_prima_p(i).quantidade * 1000
                                WHEN unid_medida_user_v IN ('cm', 'cl')    THEN materia_prima_p(i).quantidade * 10
                                ELSE materia_prima_p(i).quantidade
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
            IF gastos_p.EXISTS(g.nome) THEN
                DBMS_OUTPUT.PUT_LINE('   GASTO '''||g.nome||''' EXISTE NA TABELA GASTOS');
                gastos_v := gastos_v + (g.valor * gastos_p(g.nome));
                
                DBMS_OUTPUT.PUT_LINE('   > Tabela Gastos: '||g.nome||' = ' ||g.valor);
                DBMS_OUTPUT.PUT_LINE('   > Percentagem Artesao = ' ||gastos_p(g.nome));
                DBMS_OUTPUT.PUT_LINE('   > Valor acumulado = '||gastos_v);
                DBMS_OUTPUT.PUT_LINE('');
            END IF;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Custo Mão de Obra = '||custos_mao_obra_v||' | Custo Matéria Prima = '||custos_materia_prima_v||' | Gastos = '||gastos_v);
        
        -- Cálculo Intermédio do Custo de Produção
        custo_producao_v := custos_mao_obra_v + custos_materia_prima_v + gastos_v;
        DBMS_OUTPUT.PUT_LINE('Custo de Produção = '||custo_producao_v);
        
        -- Cálculo Final do Preço Ideal
        preco_ideal_v := custo_producao_v + (lucro_p * custo_producao_v);
        DBMS_OUTPUT.PUT_LINE('Preço Ideal = '||preco_ideal_v||' ( '||custo_producao_v||' + '||(lucro_p * custo_producao_v)||' )');
    
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
            INNER JOIN producao p      ON p.artesao_codigo = a.codigo
            INNER JOIN tipo_prod t     ON t.codigo = p.tipo_prod_codigo
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
            INNER JOIN producao p      ON p.artesao_codigo = a.codigo
            INNER JOIN tipo_prod t     ON t.codigo = p.tipo_prod_codigo
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