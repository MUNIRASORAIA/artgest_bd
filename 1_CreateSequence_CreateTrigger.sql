


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

CREATE SEQUENCE producao_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
;



-- CREATE TRIGGER

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


CREATE OR REPLACE TRIGGER producao_trg
BEFORE
    INSERT ON producao
    FOR EACH ROW
BEGIN
    :new.id := producao_id_seq.nextval;
END
;
/
