CREATE DATABASE PETSHOP;
USE PETSHOP;

-- Script de criação das tabelas
CREATE TABLE RACA (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    raca VARCHAR(200) NOT NULL,
    CONSTRAINT uk_raca_nome UNIQUE (raca)
);
 
CREATE TABLE PORTE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    porte VARCHAR(10) NOT NULL,
    percentual DECIMAL(3, 2) NOT NULL,
    CONSTRAINT uk_porte_nome UNIQUE (porte),
    CONSTRAINT valida_porte CHECK(porte IN ('pequeno','medio', 'grande'))
);

CREATE TABLE CLIENTE ( 
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    cpf CHAR(11) NOT NULL,
    email VARCHAR(200) NOT NULL,
    telefone VARCHAR(11) NOT NULL,
    rua VARCHAR(200) NOT NULL,
    numero INT NOT NULL,
    cep CHAR(8) NOT NULL,
    cidade VARCHAR(200) NOT NULL,
    estado CHAR(2) NOT NULL,
    ativo BOOL DEFAULT TRUE,
    CONSTRAINT uk_cliente_cpf UNIQUE (cpf)
);

CREATE TABLE PET (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    id_cliente INT NOT NULL,
    id_porte INT NOT NULL,
    id_raca INT NOT NULL,
    ativo BOOL DEFAULT TRUE,
    CONSTRAINT fk_pet_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id),
    CONSTRAINT fk_pet_porte FOREIGN KEY (id_porte) REFERENCES PORTE (id),
    CONSTRAINT fk_pet_raca FOREIGN KEY (id_raca) REFERENCES RACA (id)
);
 
CREATE TABLE SERVICO(
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico VARCHAR(100) NOT NULL,
    preco DECIMAL(5, 2) NOT NULL,
    duracao TIME NOT NULL,
    ativo BOOL DEFAULT TRUE,
    CONSTRAINT uk_servico_nome UNIQUE (servico)
);

CREATE TABLE STATUS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(20) NOT NULL DEFAULT 'Agendado',
    CONSTRAINT agend_check CHECK(status IN ('Agendado','Confirmado','Realizado','Cancelado'))
);
 
CREATE TABLE AGENDAMENTO (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_total DECIMAL(6, 2) NOT NULL DEFAULT 0.00,
    id_pet INT NOT NULL,
    data_agend DATE NOT NULL,
    hora_agend TIME NOT NULL,
	id_status INT NOT NULL,
    ativo BOOL DEFAULT TRUE,
    CONSTRAINT fk_agend_pet FOREIGN KEY (id_pet) REFERENCES PET (id),
    CONSTRAINT fk_agend_sta FOREIGN KEY (id_status) REFERENCES STATUS (id)
);

CREATE TABLE AGENDAMENTO_SERVICO (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_servico DECIMAL(5, 2) DEFAULT 0 NOT NULL,
    id_agendamento INT NOT NULL,
    id_servico INT NOT NULL,
    ativo BOOL DEFAULT TRUE,
    CONSTRAINT uq_agend_serv UNIQUE (id_agendamento, id_servico),
    CONSTRAINT fk_as_agendamento FOREIGN KEY (id_agendamento) REFERENCES AGENDAMENTO (id),
    CONSTRAINT fk_as_servico FOREIGN KEY (id_servico) REFERENCES SERVICO (id)
);

-- Script de povoamento
INSERT INTO RACA (raca) VALUES
    ('Labrador Retriever'),
    ('Poodle Toy'),
    ('Bulldog Francês'),
    ('Mastim Persa'),
    ('Golden Retriever');
 
INSERT INTO PORTE (porte, percentual) VALUES
    ('pequeno', 0.90),   -- 90% PB
    ('medio',   1.00),   -- 100% PB
    ('grande',  1.10);   -- 110% PB

INSERT INTO CLIENTE (nome, cpf, email, telefone, rua, numero, cep, cidade, estado) VALUES
    ('Bruno Hoogeboom', '12345678901', 'bruno@email.com', '11987654321', 'Rua das Orquídeas', '45',   '01310100', 'São Paulo', 'SP'),
    ('Eduarda Cristina', '23456789012', 'eduarda@email.com', '11976543210', 'Av. Atlântica', '820',  '22010000', 'Rio de Janeiro', 'RJ'),
    ('Anderson Rodrigues', '34567890123', 'anderson@email.com', '31965432109', 'Rua dos Goitacazes', '12', '30110010', 'Belo Horizonte', 'MG'),
    ('Ryan de Melo', '45678901234', 'ryan@email.com', '41954321098', 'Rua XV de Novembro', '300', '80020310', 'Curitiba', 'PR'),
    ('Rebeca de Souza', '56789012345', 'rebeca@email.com', '85943210987', 'Rua Padre Valdevino', '77', '60135170', 'Fortaleza', 'CE');

INSERT INTO SERVICO (servico, preco, duracao) VALUES
    ('Banho e secagem', 50.00, '00:45:00'),
    ('Escova', 40.00, '00:25:00'),
    ('Limpeza dos ouvidos', 30.00, '00:15:00'),
    ('Corte das unhas', 20.00, '00:25:00'),
    ('Higiene bucal', 15.00, '00:20:00');
    
INSERT INTO PET (nome, id_cliente, id_porte, id_raca) VALUES
    (
        'Thor',
        (SELECT id FROM CLIENTE WHERE cpf = '12345678901'),
        (SELECT id FROM PORTE WHERE porte = 'grande'),
        (SELECT id FROM RACA WHERE raca = 'Labrador Retriever')
    ),
    (
        'Luna',
        (SELECT id FROM CLIENTE WHERE cpf = '23456789012'),
        (SELECT id FROM PORTE WHERE porte = 'pequeno'),
        (SELECT id FROM RACA WHERE raca = 'Mastim Persa')
    ),
    (
        'Bolinha',
        (SELECT id FROM CLIENTE WHERE cpf = '34567890123'),
        (SELECT id FROM PORTE WHERE porte = 'pequeno'),
        (SELECT id FROM RACA WHERE raca  = 'Poodle Toy')
    ),
    (
        'Nina',
        (SELECT id FROM CLIENTE WHERE cpf = '45678901234'),
        (SELECT id FROM PORTE WHERE porte = 'medio'),
        (SELECT id FROM RACA WHERE raca  = 'Bulldog Francês')
    ),
    (
        'Max',
        (SELECT id FROM CLIENTE WHERE cpf = '56789012345'),
        (SELECT id FROM PORTE WHERE porte = 'grande'),
        (SELECT id FROM RACA WHERE raca  = 'Golden Retriever')
    );

INSERT INTO STATUS (status) VALUES ('Agendado'),('Confirmado'),('Realizado'),('Cancelado');

INSERT INTO AGENDAMENTO (valor_total, id_pet, data_agend, hora_agend, id_status) VALUES
    (
        0.00,
        (SELECT p.id FROM PET p JOIN CLIENTE c ON c.id = p.id_cliente
         WHERE c.cpf = '12345678901' AND p.nome = 'Thor'),
        '2025-06-02', '09:00:00', (select id from status where status = "Agendado")
    ),
    (
        0.00,
        (SELECT p.id FROM PET p JOIN CLIENTE c ON c.id = p.id_cliente
         WHERE c.cpf = '23456789012' AND p.nome = 'Luna'),
        '2025-06-02', '10:30:00', (select id from status where status = "Agendado")
    ),
    (
        0.00,
        (SELECT p.id FROM PET p JOIN CLIENTE c ON c.id = p.id_cliente
         WHERE c.cpf = '34567890123' AND p.nome = 'Bolinha'),
        '2025-06-03', '14:00:00', (select id from status where status = "Agendado")
    ),
    (
        0.00,
        (SELECT p.id FROM PET p JOIN CLIENTE c ON c.id = p.id_cliente
         WHERE c.cpf = '45678901234' AND p.nome = 'Nina'),
        '2025-06-04', '08:00:00', (select id from status where status = "Agendado")
    ),
    (
        0.00,
        (SELECT p.id FROM PET p JOIN CLIENTE c ON c.id = p.id_cliente
         WHERE c.cpf = '56789012345' AND p.nome = 'Max'),
        '2025-06-05', '11:00:00', (select id from status where status = "Agendado")
    );

-- Registro 1: Thor (grande × 1.10) + Banho e secagem (R$50,00) = R$55,00
INSERT INTO AGENDAMENTO_SERVICO (valor_servico, id_agendamento, id_servico)
SELECT
    ROUND((SELECT preco FROM SERVICO WHERE servico = 'Banho e secagem') * po.percentual, 2),
    ag.id,
    (SELECT id FROM SERVICO WHERE servico = 'Banho e secagem')
FROM AGENDAMENTO ag
JOIN PET     p  ON p.id  = ag.id_pet
JOIN PORTE   po ON po.id = p.id_porte
JOIN CLIENTE c  ON c.id  = p.id_cliente
WHERE c.cpf         = '12345678901'
  AND p.nome        = 'Thor'
  AND ag.data_agend = '2025-06-02'
  AND ag.hora_agend = '09:00:00';
 
-- Registro 2: Luna (pequeno × 0.90) + Escova (R$40,00) = R$36,00
INSERT INTO AGENDAMENTO_SERVICO (valor_servico, id_agendamento, id_servico)
SELECT
    ROUND((SELECT preco FROM SERVICO WHERE servico = 'Escova') * po.percentual, 2),
    ag.id,
    (SELECT id FROM SERVICO WHERE servico = 'Escova')
FROM AGENDAMENTO ag
JOIN PET     p  ON p.id  = ag.id_pet
JOIN PORTE   po ON po.id = p.id_porte
JOIN CLIENTE c  ON c.id  = p.id_cliente
WHERE c.cpf         = '23456789012'
  AND p.nome        = 'Luna'
  AND ag.data_agend = '2025-06-02'
  AND ag.hora_agend = '10:30:00';
 
-- Registro 3: Bolinha (pequeno × 0.90) + Limpeza dos ouvidos (R$30,00) = R$27,00
INSERT INTO AGENDAMENTO_SERVICO (valor_servico, id_agendamento, id_servico)
SELECT
    ROUND((SELECT preco FROM SERVICO WHERE servico = 'Limpeza dos ouvidos') * po.percentual, 2),
    ag.id,
    (SELECT id FROM SERVICO WHERE servico = 'Limpeza dos ouvidos')
FROM AGENDAMENTO ag
JOIN PET     p  ON p.id  = ag.id_pet
JOIN PORTE   po ON po.id = p.id_porte
JOIN CLIENTE c  ON c.id  = p.id_cliente
WHERE c.cpf         = '34567890123'
  AND p.nome        = 'Bolinha'
  AND ag.data_agend = '2025-06-03'
  AND ag.hora_agend = '14:00:00';
 
-- Registro 4: Nina (Médio × 1.00) + Corte das unhas (R$20,00) = R$20,00
INSERT INTO AGENDAMENTO_SERVICO (valor_servico, id_agendamento, id_servico)
SELECT
    ROUND((SELECT preco FROM SERVICO WHERE servico = 'Corte das unhas') * po.percentual, 2),
    ag.id,
    (SELECT id FROM SERVICO WHERE servico = 'Corte das unhas')
FROM AGENDAMENTO ag
JOIN PET     p  ON p.id  = ag.id_pet
JOIN PORTE   po ON po.id = p.id_porte
JOIN CLIENTE c  ON c.id  = p.id_cliente
WHERE c.cpf         = '45678901234'
  AND p.nome        = 'Nina'
  AND ag.data_agend = '2025-06-04'
  AND ag.hora_agend = '08:00:00';
 
-- Registro 5: Max (grande × 1.10) + Higiene bucal (R$15,00) = R$16,50
INSERT INTO AGENDAMENTO_SERVICO (valor_servico, id_agendamento, id_servico)
SELECT
    ROUND((SELECT preco FROM SERVICO WHERE servico = 'Higiene bucal') * po.percentual, 2),
    ag.id,
    (SELECT id FROM SERVICO WHERE servico = 'Higiene bucal')
FROM AGENDAMENTO ag
JOIN PET     p  ON p.id  = ag.id_pet
JOIN PORTE   po ON po.id = p.id_porte
JOIN CLIENTE c  ON c.id  = p.id_cliente
WHERE c.cpf         = '56789012345'
  AND p.nome        = 'Max'
  AND ag.data_agend = '2025-06-05'
  AND ag.hora_agend = '11:00:00';

-- Views

-- Agenda detalhada dos próximos atendimentos confirmados
CREATE VIEW agenda_detalhada AS
SELECT
    ag.data_agend AS data,
    ag.hora_agend AS hora,
    st.status AS status,
    c.nome AS cliente,
    c.telefone,
    p.nome AS pet,
    r.raca,
    po.porte,
    sv.servico
FROM AGENDAMENTO ag
JOIN STATUS st ON st.id = ag.id_status
JOIN PET p ON p.id = ag.id_pet
JOIN CLIENTE c ON c.id = p.id_cliente
JOIN RACA r ON r.id = p.id_raca
JOIN PORTE po ON po.id = p.id_porte
JOIN AGENDAMENTO_SERVICO asv ON asv.id_agendamento = ag.id
JOIN SERVICO sv ON sv.id = asv.id_servico
WHERE ag.data_agend >= CURDATE()
  AND st.status IN ('Agendado', 'Confirmado')
ORDER BY ag.data_agend, ag.hora_agend;

-- Exibe o faturamento total por mês dos agendamentos realizados para cada mês do ano vigente, até o mês atual.
create view faturamento_mensal as 
    SELECT MONTH(data_agend) AS 'Mês', SUM(valor_total) AS 'Faturamento'
    FROM agendamento
    WHERE YEAR(data_agend) = YEAR(NOW()) AND MONTH(data_agend) <= MONTH(NOW()) AND id_status = (select id from status where status = "Realizado") AND ativo = true
    GROUP BY MONTH(data_agend)
    ORDER BY MONTH(data_agend);

-- Faturamneto por serviço.
CREATE VIEW vw_faturamento_por_servico AS 
	SELECT s.servico,
       SUM(asv.valor_servico) AS faturamento
	FROM SERVICO s
	JOIN AGENDAMENTO_SERVICO asv ON asv.id_servico = s.id
	GROUP BY s.servico;
    
-- Clientes com mais de 1 pet cadastrado
CREATE VIEW vw_clientes_multiplos_pets AS
SELECT
    c.nome              AS cliente,
    c.telefone          AS telefone,
    COUNT(p.id)         AS total_pets
FROM CLIENTE c
JOIN PET p ON p.id_cliente = c.id
GROUP BY c.id, c.nome, c.telefone
HAVING COUNT(p.id) > 1
ORDER BY total_pets DESC;

-- Histórico de atendimento que permite consultar de forma simples todos os serviços realizados no petshop, reunindo dados de clientes, pets, serviços e valores.
CREATE VIEW historico_atendimento AS
SELECT
    ag.id AS id_agendamento,
    c.nome AS cliente,
    p.nome AS pet,
    r.raca,
    po.porte,
    ag.data_agend,
    ag.hora_agend,
    st.status,
    SUM(asv.valor_servico) AS total_pago
FROM AGENDAMENTO ag
JOIN STATUS st ON st.id = ag.id_status
JOIN PET p ON p.id = ag.id_pet
JOIN CLIENTE c ON c.id = p.id_cliente
JOIN RACA r ON r.id = p.id_raca
JOIN PORTE po ON po.id = p.id_porte
JOIN AGENDAMENTO_SERVICO asv ON asv.id_agendamento = ag.id
GROUP BY 
    ag.id,
    c.nome,
    p.nome,
    r.raca,
    po.porte,
    ag.data_agend,
    ag.hora_agend,
    st.status
ORDER BY ag.data_agend DESC, ag.hora_agend DESC;

-- Relatório do agendamentos do dia para confirmação.
CREATE VIEW confirmar_agendamentos AS
SELECT cliente.nome AS "Cliente", pet.nome AS "Pet", agendamento.hora_agend AS 'Hora', cliente.telefone AS 'Telefone', cliente.email AS 'E-mail', status.status AS "Status"
FROM agendamento
JOIN pet on pet.id = agendamento.id_pet
JOIN cliente on cliente.id = pet.id_cliente
JOIN status on agendamento.id_status = status.id
WHERE agendamento.data_agend = CURDATE() AND id_status = (SELECT id FROM STATUS WHERE STATUS = "Agendado") AND agendamento.ativo = true
ORDER BY agendamento.hora_agend;

-- Índices

CREATE INDEX idx_cliente_cpf ON CLIENTE (cpf);
CREATE INDEX idx_pet_nome ON PET (nome);
CREATE INDEX idx_agend_data_status ON AGENDAMENTO (data_agend, id_status);

-- Procedures

-- RACA
-- Procedure de inserção
DELIMITER //
CREATE PROCEDURE insere_raca (
    IN nome_raca VARCHAR(200)
)
BEGIN
    INSERT INTO RACA (raca)
    VALUES (nome_raca);
END //
DELIMITER ;

-- Procedure de atualização
DELIMITER //
CREATE PROCEDURE atualiza_raca (
    IN raca_id INT,
    IN novo_nome VARCHAR(200)
)
BEGIN
    UPDATE RACA
    SET raca = novo_nome
    WHERE id = raca_id;
END //
DELIMITER ;

-- CLIENTE
-- Procedure de inserção
DELIMITER //
CREATE PROCEDURE sp_inserir_cliente (
    IN p_nome VARCHAR(200),
    IN p_cpf CHAR(11),
    IN p_email VARCHAR(200),
    IN p_telefone VARCHAR(11),
    IN p_rua VARCHAR(200),
    IN p_numero INT,
    IN p_cep CHAR(8),
    IN p_cidade VARCHAR(200),
    IN p_estado CHAR(2)
)
BEGIN
    INSERT INTO CLIENTE (
        nome,
        cpf,
        email,
        telefone,
        rua,
        numero,
        cep,
        cidade,
        estado
    )
    VALUES (
        p_nome,
        p_cpf,
        p_email,
        p_telefone,
        p_rua,
        p_numero,
        p_cep,
        p_cidade,
        p_estado
    );
END //
DELIMITER ;

-- Procedure de atualização
DELIMITER //
CREATE PROCEDURE sp_atualizar_cliente (
    IN p_id INT,
    IN p_nome VARCHAR(200),
    IN p_cpf CHAR(11),
    IN p_email VARCHAR(200),
    IN p_telefone VARCHAR(11),
    IN p_rua VARCHAR(200),
    IN p_numero INT,
    IN p_cep CHAR(8),
    IN p_cidade VARCHAR(200),
    IN p_estado CHAR(2)
)
BEGIN
    UPDATE CLIENTE
    SET
        nome = p_nome,
        cpf = p_cpf,
        email = p_email,
        telefone = p_telefone,
        rua = p_rua,
        numero = p_numero,
        cep = p_cep,
        cidade = p_cidade,
        estado = p_estado
    WHERE id = p_id;
END //
DELIMITER ;

-- Procedure de exclusão lógica
DELIMITER //
CREATE PROCEDURE sp_exclusao_logica_cliente (
    IN p_id INT
)
BEGIN
    UPDATE CLIENTE
    SET ativo = FALSE
    WHERE id = p_id;
END //
DELIMITER ;

-- PET
-- Procedure de inserção
DELIMITER //
CREATE PROCEDURE insere_pet (in nome varchar(200),in id_cliente int,in nome_porte varchar(10),in id_raca int)
BEGIN
	INSERT INTO PET (nome,id_cliente,id_porte,id_raca) VALUES 
    (nome,id_cliente, (select id from porte where porte = nome_porte), id_raca);
END //
DELIMITER ;

-- Procedure de atualização: Altera o porte do pet
DELIMITER //
CREATE PROCEDURE atualiza_porte_pet (in pet_nome varchar(200), in cpf_tutor char(11), in porte_nome varchar(10))
BEGIN
	DECLARE porteId INT;
    DECLARE idTutor INT;
    DECLARE petId INT;
    
    SELECT id FROM porte WHERE porte = porte_nome INTO porteId;
    SELECT id FROM cliente WHERE cpf = cpf_tutor INTO idTutor;
    SELECT id FROM pet WHERE nome = pet_nome AND id_cliente = idTutor INTO petId;
    
	UPDATE PET SET id_porte = porteId WHERE id = petId;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE atualiza_porte_pet (in pet_nome varchar(200), in cpf_tutor char(11), in porte_nome varchar(10))
BEGIN
    UPDATE PET SET id_porte = (select id from porte where porte = porte_nome) 
    WHERE id = (select id from pet where nome = pet_nome and id_cliente = (select id from cliente where cpf = cpf_tutor));
END //
DELIMITER ; 

-- Procedure de exclusão lógica
DELIMITER //
CREATE PROCEDURE exclui_pet (in pet_id int, in status bool)
BEGIN
	IF status IN (0,1) THEN
		UPDATE PET SET ativo = status where id = pet_id; 
	ELSE
		SELECT 'Ativo aceita apenas 0 ou 1';
    END IF;
END //
DELIMITER ;

-- SERVICO
-- Procedure de inserção
DELIMITER //
CREATE PROCEDURE inserir_servico (
    IN p_servico VARCHAR(100),
    IN p_preco DECIMAL(5,2),
    IN p_duracao TIME
)
BEGIN

    INSERT INTO SERVICO (
        servico,
        preco,
        duracao
    )
    VALUES (
        p_servico,
        p_preco,
        p_duracao
    );

END //
DELIMITER ;

-- Procedure de atualização
DELIMITER //
CREATE PROCEDURE atualizar_servico (
    IN p_id INT,
    IN p_servico VARCHAR(100),
    IN p_preco DECIMAL(5,2),
    IN p_duracao TIME
)
BEGIN

    UPDATE SERVICO
    SET
        servico = p_servico,
        preco = p_preco,
        duracao = p_duracao
    WHERE id = p_id;
END //
DELIMITER ;

-- Procedure de exclusão lógica
DELIMITER //
CREATE PROCEDURE excluir_servico (
    IN p_id INT
)
BEGIN
    UPDATE SERVICO
    SET ativo = FALSE
    WHERE id = p_id;
END //
DELIMITER ;

-- AGENDAMENTO
-- Procedure de inserção
DELIMITER //
CREATE PROCEDURE inserir_agendamento (
    IN p_id_pet INT,
    IN p_data_agend DATE,
    IN p_hora_agend TIME,
    IN p_id_status INT
)
BEGIN
    INSERT INTO AGENDAMENTO (valor_total, id_pet, data_agend, hora_agend, id_status)
    VALUES (0.00, p_id_pet, p_data_agend, p_hora_agend, p_id_status);
END //
DELIMITER ;

-- Procedure de atualização
DELIMITER //
CREATE PROCEDURE atualizar_agendamento (
    IN p_id INT,
    IN p_data_agend DATE,
    IN p_hora_agend TIME,
    IN p_id_status INT
)
BEGIN
    UPDATE AGENDAMENTO
    SET
        data_agend = p_data_agend,
        hora_agend = p_hora_agend,
        id_status  = p_id_status
    WHERE id = p_id;
END //
DELIMITER ;

-- Procedure de exclusão lógica
DELIMITER //
CREATE PROCEDURE excluir_agendamento (
    IN p_id INT
)
BEGIN
    UPDATE AGENDAMENTO
    SET ativo = FALSE
    WHERE id = p_id;
END //
DELIMITER ;

-- AGENDAMENTO_SERVICO
-- Procedure de inserção
DELIMITER //
CREATE PROCEDURE p_inserir_agendamento(
    IN p_id_agendamento INT,
    IN p_id_servico INT
)
BEGIN
    INSERT INTO agendamento_servico (id_agendamento, id_servico)
    VALUES (p_id_agendamento, p_id_servico);
END //
DELIMITER ;

-- Procedure de atualização
DELIMITER //
CREATE PROCEDURE p_atualizar_agendamento(
	IN p_id_agendamento INT,
    IN p_servico_antigo VARCHAR(100), 
    IN p_servico_novo VARCHAR(100) 
)
BEGIN
     UPDATE agendamento_servico
     SET id_servico = (select id from servico where servico = p_servico_novo)
     WHERE id_agendamento = p_id_agendamento AND id_servico = (select id from servico where servico = p_servico_antigo);
END //
DELIMITER ;

-- Procedure de exclusão lógica
DELIMITER //
CREATE PROCEDURE p_excluir_agendamento(
    IN p_id_agendamento INT,
    IN p_servico VARCHAR(100)
)
BEGIN
	UPDATE agendamento_servico
    SET ativo = FALSE
    WHERE id_agendamento = p_id_agendamento AND id_servico = (select id from servico where servico = p_servico);
END //
DELIMITER ;

-- Trigger da regra de negocio
-- Atualizar valor_servico em AGENDAMENTO_SERVICO e valor_total em AGENDAMENTO quando:
	-- Inserir novo agendamento de servico [OK]
	-- Alterar servico agendado [ ]

-- Define valor_servico em AGENDAMENTO_SERVICO ao inserir novo registro e atualiza valor_total em AGENDAMENTO
DELIMITER //
CREATE TRIGGER atualizar_preco_insert
BEFORE INSERT 
ON AGENDAMENTO_SERVICO 
FOR EACH ROW
BEGIN
	DECLARE valor_preco_base DECIMAL(5, 2);
    DECLARE valor_percentual DECIMAL(4, 2);
    DECLARE valor_total_atual DECIMAL(6, 2);
    
    -- Busca preço base
	SELECT preco INTO valor_preco_base 
    FROM SERVICO 
    WHERE id = NEW.id_servico;
    
    -- Buscar fator porte
    SELECT PORTE.percentual INTO valor_percentual
    FROM AGENDAMENTO
    JOIN PET ON AGENDAMENTO.id_pet = PET.id
    JOIN PORTE ON PET.id_porte = PORTE.id
    WHERE AGENDAMENTO.id = NEW.id_agendamento;
    
    -- Define valor corrigido com base no porte
    SET NEW.valor_servico = valor_preco_base * valor_percentual;
    
    -- Atualiza valor_total em AGENDAMENTO
    -- Busca valor_total atual e armazena em variável
    SELECT valor_total INTO valor_total_atual
    FROM AGENDAMENTO
    WHERE id = NEW.id_agendamento;
    -- Soma o valor do serviço ao total
    UPDATE AGENDAMENTO 
    SET valor_total = valor_total_atual + NEW.valor_servico
    WHERE id = NEW.id_agendamento;
END //
DELIMITER ;

-- Define valor_servico em AGENDAMENTO_SERVICO ao atualizar serviço agedando e atualiza valor_total em AGENDAMENTO
